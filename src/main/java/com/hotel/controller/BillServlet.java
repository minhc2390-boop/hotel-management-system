package com.hotel.controller;

import com.hotel.dao.BillDAO;
import com.hotel.dao.BillDetailDAO;
import com.hotel.dao.BookingDAO;
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
    private final BookingDAO bookingDAO = new BookingDAO();
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
                // Chỉ Admin mới được xem toàn bộ danh sách hóa đơn
                if (!"Admin".equalsIgnoreCase(currentUser.getRole())) {
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
                
                // Security check: Customer can only see their own bills (matching user id, linked customer user, or customer email)
                boolean isOwnBill = (bill.getUserId() == currentUser.getId()) || 
                                    (bill.getCustomer() != null && bill.getCustomer().getUser() != null && bill.getCustomer().getUser().getId() == currentUser.getId()) ||
                                    (bill.getCustomer() != null && currentUser.getEmail() != null && currentUser.getEmail().equalsIgnoreCase(bill.getCustomer().getCustomerEmail()));
                if ("Customer".equals(currentUser.getRole()) && !isOwnBill) {
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }
                
                List<BillDetail> details = billDetailDAO.getBillDetailsByBillId(billId);
                List<Service> services = serviceDAO.getAllServices();
                
                // 1. Fetch VietQR bank info from SystemSettingDAO
                com.hotel.dao.SystemSettingDAO systemSettingDAO = new com.hotel.dao.SystemSettingDAO();
                String bankId = systemSettingDAO.getBankId();
                String bankAccount = systemSettingDAO.getBankAccount();
                String bankName = systemSettingDAO.getBankName();

                // 2. Fetch Laundry list and calculate formula:
                // Tổng tiền = (Đơn giá phòng × Số đêm) + Tiền dịch vụ đi kèm + Tiền dịch vụ giặt ủi
                String roomNumber = "";
                double roomTotal = 0.0;
                double serviceTotal = 0.0;

                if (details != null) {
                    for (BillDetail bd : details) {
                        double itemTotal = bd.getPrice() * bd.getQuantity();
                        if (bd.getRoomId() != null || bd.getRoom() != null) {
                            roomTotal += itemTotal;
                            if (roomNumber.isEmpty()) {
                                roomNumber = bd.getRoom() != null ? bd.getRoom().getRoomNumber() : String.valueOf(bd.getRoomId());
                            }
                        } else {
                            serviceTotal += itemTotal;
                        }
                    }
                }

                com.hotel.dao.LaundryDAO laundryDAO = new com.hotel.dao.LaundryDAO();
                List<Laundry> laundryList = laundryDAO.getLaundriesByRoomNumber(roomNumber);
                double laundryTotal = 0.0;
                if (laundryList != null) {
                    for (Laundry l : laundryList) {
                        laundryTotal += l.getTotalPrice();
                    }
                }

                // 3. Kiểm tra xem đơn đặt phòng tương ứng có thanh toán cọc 20% trước đó không
                double depositPaid = 0.0;
                if (details != null) {
                    for (BillDetail bd : details) {
                        if (bd.getRoomId() != null || bd.getRoom() != null) {
                            int rId = bd.getRoom() != null ? bd.getRoom().getId() : bd.getRoomId();
                            List<Booking> roomBookings = bookingDAO.getBookingsByRoomId(rId);
                            if (roomBookings != null) {
                                for (Booking b : roomBookings) {
                                    if (b.getNote() != null && (b.getNote().contains("Đã cọc 20%") || b.getNote().contains("cọc 20%"))) {
                                        int stayDays = bd.getQuantity() > 0 ? bd.getQuantity() : 1;
                                        double lineRoomTotal = stayDays * bd.getPrice();
                                        depositPaid += lineRoomTotal * 0.20;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }

                double subTotal = roomTotal + serviceTotal + laundryTotal;
                double taxRate = 0.08; // Thuế VAT 8%
                double taxAmount = subTotal * taxRate;
                double grossTotal = subTotal + taxAmount;
                double depositDeduction = depositPaid * 1.08; // Tiền cọc đã gồm 8% thuế
                double finalPayable = Math.max(0.0, grossTotal - depositDeduction);

                if (finalPayable > 0 && Math.abs(finalPayable - bill.getTotalAmount()) > 0.01) {
                    bill.setTotalAmount(finalPayable);
                    billDAO.updateBillTotal(billId, finalPayable);
                }

                request.setAttribute("bankId", bankId);
                request.setAttribute("bankAccount", bankAccount);
                request.setAttribute("bankName", bankName);
                request.setAttribute("bill", bill);
                request.setAttribute("details", details);
                request.setAttribute("services", services);
                request.setAttribute("laundryList", laundryList);
                request.setAttribute("laundryTotal", laundryTotal);
                request.setAttribute("roomTotal", roomTotal);
                request.setAttribute("serviceTotal", serviceTotal);
                request.setAttribute("subTotal", subTotal);
                request.setAttribute("taxRate", taxRate);
                request.setAttribute("taxAmount", taxAmount);
                request.setAttribute("grossTotal", grossTotal);
                request.setAttribute("depositDeduction", depositDeduction);
                request.setAttribute("finalPayable", finalPayable);
                request.getRequestDispatcher("/bill-details.jsp").forward(request, response);
                break;

            case "pay":
                int payBillId = ParamUtil.getInt(request, "id", 0);
                if (payBillId == 0) {
                    payBillId = ParamUtil.getInt(request, "billId", 0);
                }
                String getRawMethod = ParamUtil.getString(request, "paymentMethod", "Cash");
                String getPayMethod = "Cash";
                if ("transfer".equalsIgnoreCase(getRawMethod) || "BankTransfer".equalsIgnoreCase(getRawMethod) || "qr".equalsIgnoreCase(getRawMethod)) {
                    getPayMethod = "BankTransfer";
                } else if ("card".equalsIgnoreCase(getRawMethod)) {
                    getPayMethod = "Card";
                }

                Bill getPayBill = billDAO.getBillById(payBillId);
                if (getPayBill != null) {
                    boolean canPay = "Admin".equalsIgnoreCase(currentUser.getRole()) 
                                  || "Receptionist".equalsIgnoreCase(currentUser.getRole())
                                  || (getPayBill.getUserId() == currentUser.getId())
                                  || (getPayBill.getCustomer() != null && getPayBill.getCustomer().getUser() != null && getPayBill.getCustomer().getUser().getId() == currentUser.getId())
                                  || (getPayBill.getCustomer() != null && currentUser.getEmail() != null && currentUser.getEmail().equalsIgnoreCase(getPayBill.getCustomer().getCustomerEmail()));
                    if (!canPay) {
                        response.sendRedirect(request.getContextPath() + "/home");
                        return;
                    }

                    if ("Paid".equalsIgnoreCase(getPayBill.getStatus())) {
                        response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + payBillId + "&paid=1");
                        return;
                    }

                    if ("Cancelled".equalsIgnoreCase(getPayBill.getStatus())) {
                        response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + payBillId + "&error=billCancelled");
                        return;
                    }

                    boolean paid = billDAO.markBillPaid(payBillId, getPayMethod);
                    if (paid) {
                        List<BillDetail> payDetails = billDetailDAO.getBillDetailsByBillId(payBillId);
                        if (payDetails != null) {
                            for (BillDetail detail : payDetails) {
                                if (detail.getRoomId() != null) {
                                    roomDAO.updateRoomStatus(detail.getRoomId(), "Available");
                                } else if (detail.getRoom() != null) {
                                    roomDAO.updateRoomStatus(detail.getRoom().getId(), "Available");
                                }
                            }
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + payBillId + (paid ? "&paid=1" : "&error=paymentFailed"));
                    return;
                }
                response.sendRedirect(request.getContextPath() + "/bills?action=list");
                break;

            case "cancel":
                int cancelBillId = ParamUtil.getInt(request, "id", 0);
                if (cancelBillId <= 0) {
                    response.sendRedirect(request.getContextPath() + "/bills?action=list");
                    return;
                }
                Bill cancelBill = billDAO.getBillById(cancelBillId);
                if (cancelBill == null) {
                    response.sendRedirect(request.getContextPath() + "/bills?action=list");
                    return;
                }
                
                String cancelReturnAction = "Customer".equals(currentUser.getRole()) ? "mybills" : "list";

                // Customer can only cancel their own unpaid bill
                boolean isManager = "Admin".equalsIgnoreCase(currentUser.getRole()) || "Receptionist".equalsIgnoreCase(currentUser.getRole());
                boolean isOwner = (cancelBill.getUserId() == currentUser.getId())
                               || (cancelBill.getCustomer() != null && cancelBill.getCustomer().getUser() != null && cancelBill.getCustomer().getUser().getId() == currentUser.getId())
                               || (cancelBill.getCustomer() != null && currentUser.getEmail() != null && currentUser.getEmail().equalsIgnoreCase(cancelBill.getCustomer().getCustomerEmail()));
                if (!isManager && !isOwner) {
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }
                
                // If bill is already Paid, CANNOT cancel!
                if ("Paid".equalsIgnoreCase(cancelBill.getStatus())) {
                    response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + cancelBillId + "&error=cannotCancelPaid");
                    return;
                }

                if ("Cancelled".equalsIgnoreCase(cancelBill.getStatus())) {
                    response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + cancelBillId);
                    return;
                }
                
                boolean updated = billDAO.updateBillStatus(cancelBillId, "Cancelled");
                if (updated) {
                    // Free up the room
                    List<BillDetail> cancelDetails = billDetailDAO.getBillDetailsByBillId(cancelBillId);
                    if (cancelDetails != null) {
                        for (BillDetail bd : cancelDetails) {
                            if (bd.getRoomId() != null) {
                                roomDAO.updateRoomStatus(bd.getRoomId(), "Available");
                            } else if (bd.getRoom() != null) {
                                roomDAO.updateRoomStatus(bd.getRoom().getId(), "Available");
                            }
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/bills?action=" + cancelReturnAction + "&cancelled=1");
                } else {
                    response.sendRedirect(request.getContextPath() + "/bills?action=" + cancelReturnAction + "&error=cancelFailed");
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
            int billId = ParamUtil.getInt(request, "billId", 0);
            if (billId == 0) {
                billId = ParamUtil.getInt(request, "id", 0);
            }
            String rawMethod = ParamUtil.getString(request, "paymentMethod", "Cash");
            String paymentMethod = "Cash";
            if ("transfer".equalsIgnoreCase(rawMethod) || "BankTransfer".equalsIgnoreCase(rawMethod) || "qr".equalsIgnoreCase(rawMethod)) {
                paymentMethod = "BankTransfer";
            } else if ("card".equalsIgnoreCase(rawMethod)) {
                paymentMethod = "Card";
            }

            Bill payBill = billDAO.getBillById(billId);
            if (payBill == null) {
                response.sendRedirect(request.getContextPath() + "/bills?action=list");
                return;
            }

            boolean canPay = "Admin".equalsIgnoreCase(currentUser.getRole()) 
                          || "Receptionist".equalsIgnoreCase(currentUser.getRole())
                          || (payBill.getUserId() == currentUser.getId())
                          || (payBill.getCustomer() != null && payBill.getCustomer().getUser() != null && payBill.getCustomer().getUser().getId() == currentUser.getId())
                          || (payBill.getCustomer() != null && currentUser.getEmail() != null && currentUser.getEmail().equalsIgnoreCase(payBill.getCustomer().getCustomerEmail()));
            if (!canPay) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }

            if ("Paid".equalsIgnoreCase(payBill.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + billId + "&paid=1");
                return;
            }

            if ("Cancelled".equalsIgnoreCase(payBill.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + billId + "&error=billCancelled");
                return;
            }

            boolean paid = billDAO.markBillPaid(billId, paymentMethod);
            if (paid) {
                List<BillDetail> payDetails = billDetailDAO.getBillDetailsByBillId(billId);
                if (payDetails != null) {
                    for (BillDetail detail : payDetails) {
                        if (detail.getRoomId() != null) {
                            roomDAO.updateRoomStatus(detail.getRoomId(), "Available");
                        } else if (detail.getRoom() != null) {
                            roomDAO.updateRoomStatus(detail.getRoom().getId(), "Available");
                        }
                    }
                }
            }
            response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + billId
                    + (paid ? "&paid=1" : "&error=paymentFailed"));
            return;

        } else if ("addService".equals(action)) {
            int billId = Integer.parseInt(request.getParameter("billId"));
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            Bill bill = billDAO.getBillById(billId);
            if (bill == null || "Paid".equalsIgnoreCase(bill.getStatus()) || "Cancelled".equalsIgnoreCase(bill.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + billId + "&error=cannotModifyFinalizedBill");
                return;
            }

            Service service = serviceDAO.getServiceById(serviceId);
            if (service != null) {
                // 1. Insert service into BillDetails
                BillDetail serviceDetail = new BillDetail();
                serviceDetail.setBillId(billId);
                serviceDetail.setServiceId(serviceId);
                serviceDetail.setQuantity(quantity);
                serviceDetail.setPrice(service.getPrice());
                billDetailDAO.insertBillDetail(serviceDetail);

                // 2. Update Bill Total Amount with 8% VAT
                double addedWithTax = (service.getPrice() * quantity) * 1.08;
                double newTotal = bill.getTotalAmount() + addedWithTax;
                billDAO.updateBillTotal(billId, newTotal);
            }

            response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + billId);
        }
    }
}
