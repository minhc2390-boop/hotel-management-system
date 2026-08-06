package com.hotel.controller;

import com.hotel.dao.BillDAO;
import com.hotel.dao.BillDetailDAO;
import com.hotel.dao.RoomDAO;
import com.hotel.dao.ServiceDAO;
import com.hotel.model.*;
import com.hotel.util.ParamUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet(name = "BillServlet", urlPatterns = {"/bills"})
public class BillServlet extends HttpServlet {
    private final BillDAO billDAO = new BillDAO();
    private final BillDetailDAO billDetailDAO = new BillDetailDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        switch (action) {
            case "list":
                // Admin/Receptionist sees all bills
                if (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }
                List<Bill> allBills = billDAO.getAllBills();
                request.setAttribute("bills", allBills);
                request.getRequestDispatcher("/admin/bills.jsp").forward(request, response);
                break;

            case "mybills":
                // Customers see only their bills
                List<Bill> myBills = billDAO.getBillsByUserId(currentUser.getId(), currentUser.getEmail());
                request.setAttribute("bills", myBills);
                request.getRequestDispatcher("/my-bills.jsp").forward(request, response);
                break;

            case "detail":
                int billId = Integer.parseInt(request.getParameter("id"));
                Bill bill = billDAO.getBillById(billId);
                
                // Security check: Customer can only see their own bills (either matching user id or customer email)
                boolean isOwnBill = (bill.getUserId() == currentUser.getId()) || 
                                    (bill.getCustomer() != null && currentUser.getEmail() != null && currentUser.getEmail().equalsIgnoreCase(bill.getCustomer().getCustomerEmail()));
                if ("Customer".equals(currentUser.getRole()) && !isOwnBill) {
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }
                
                List<BillDetail> details = billDetailDAO.getBillDetailsByBillId(billId);
                List<Service> services = serviceDAO.getAllServices();
                
                request.setAttribute("bill", bill);
                request.setAttribute("details", details);
                request.setAttribute("services", services);
                request.getRequestDispatcher("/bill-details.jsp").forward(request, response);
                break;

            case "pay":
                int payBillId = ParamUtil.getInt(request, "id", 0);
                response.sendRedirect(request.getContextPath()
                        + "/bills?action=detail&id=" + payBillId + "&error=paymentMethodRequired");
                break;

            case "cancel":
                int cancelBillId = Integer.parseInt(request.getParameter("id"));
                Bill cancelBill = billDAO.getBillById(cancelBillId);
                
                // Customer can only cancel their own unpaid bill
                if ("Customer".equals(currentUser.getRole()) && cancelBill.getUserId() != currentUser.getId()) {
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }
                
                billDAO.updateBillStatus(cancelBillId, "Cancelled");
                
                // Free up the room
                List<BillDetail> cancelDetails = billDetailDAO.getBillDetailsByBillId(cancelBillId);
                for (BillDetail bd : cancelDetails) {
                    if (bd.getRoomId() != null) {
                        roomDAO.updateRoomStatus(bd.getRoomId(), "Available");
                    }
                }
                
                if ("Customer".equals(currentUser.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/bills?action=mybills");
                } else {
                    response.sendRedirect(request.getContextPath() + "/bills?action=list");
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/home");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if ("pay".equals(action)) {
            if (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }

            int billId = ParamUtil.getInt(request, "billId", 0);
            String paymentMethod = ParamUtil.getString(request, "paymentMethod", "");
            if (!"Cash".equals(paymentMethod)
                    && !"BankTransfer".equals(paymentMethod)
                    && !"Card".equals(paymentMethod)) {
                response.sendRedirect(request.getContextPath()
                        + "/bills?action=detail&id=" + billId + "&error=paymentMethodRequired");
                return;
            }

            boolean paid = billDAO.markBillPaid(billId, paymentMethod);
            if (paid) {
                List<BillDetail> payDetails = billDetailDAO.getBillDetailsByBillId(billId);
                for (BillDetail detail : payDetails) {
                    if (detail.getRoomId() != null) {
                        roomDAO.updateRoomStatus(detail.getRoomId(), "Available");
                    }
                }
            }
            response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + billId
                    + (paid ? "&paid=1" : "&error=paymentFailed"));

        } else if ("createBooking".equals(action)) {
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            String checkInStr = request.getParameter("checkInDate");
            String checkOutStr = request.getParameter("checkOutDate");
            
            SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
            try {
                Date checkIn = df.parse(checkInStr);
                Date checkOut = df.parse(checkOutStr);
                
                // Calculate stay days
                long diffMs = checkOut.getTime() - checkIn.getTime();
                long days = diffMs / (1000 * 60 * 60 * 24);
                if (days <= 0) days = 1; // Minimum 1 day

                Room room = roomDAO.getRoomById(roomId);
                double roomPrice = room.getRoomType().getPricePerDay();
                double totalRoomCharge = days * roomPrice;

                // 1. Create and Insert Bill
                Bill bill = new Bill();
                bill.setUserId(currentUser.getId());
                bill.setCheckInDate(new Timestamp(checkIn.getTime()));
                bill.setCheckOutDate(new Timestamp(checkOut.getTime()));
                bill.setTotalAmount(totalRoomCharge);
                bill.setStatus("Unpaid");
                
                int billId = billDAO.insertBill(bill);
                
                if (billId > 0) {
                    // 2. Create and Insert BillDetail for room charge
                    BillDetail roomChargeDetail = new BillDetail();
                    roomChargeDetail.setBillId(billId);
                    roomChargeDetail.setRoomId(roomId);
                    roomChargeDetail.setQuantity((int) days);
                    roomChargeDetail.setPrice(roomPrice);
                    billDetailDAO.insertBillDetail(roomChargeDetail);

                    // 3. Mark room as Booked
                    roomDAO.updateRoomStatus(roomId, "Booked");
                    
                    response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + billId);
                } else {
                    request.setAttribute("error", "Cannot process booking, please try again.");
                    request.getRequestDispatcher("/rooms?action=bookForm&roomId=" + roomId).forward(request, response);
                }

            } catch (ParseException e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/home");
            }

        } else if ("addService".equals(action)) {
            int billId = Integer.parseInt(request.getParameter("billId"));
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            Service service = serviceDAO.getServiceById(serviceId);
            if (service != null) {
                // 1. Insert service into BillDetails
                BillDetail serviceDetail = new BillDetail();
                serviceDetail.setBillId(billId);
                serviceDetail.setServiceId(serviceId);
                serviceDetail.setQuantity(quantity);
                serviceDetail.setPrice(service.getPrice());
                billDetailDAO.insertBillDetail(serviceDetail);

                // 2. Update Bill Total Amount
                Bill bill = billDAO.getBillById(billId);
                double newTotal = bill.getTotalAmount() + (service.getPrice() * quantity);
                billDAO.updateBillTotal(billId, newTotal);
            }

            response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + billId);
        }
    }
}
