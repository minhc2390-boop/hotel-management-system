package com.hotel.controller;

import com.hotel.dao.BillDAO;
import com.hotel.dao.BillDetailDAO;
import com.hotel.dao.RoomDAO;
import com.hotel.dao.UserDAO;
import com.hotel.model.Bill;
import com.hotel.model.BillDetail;
import com.hotel.model.Room;
import com.hotel.model.User;

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
import java.util.List;

@WebServlet(name = "BookingServlet", urlPatterns = {"/bookings"})
public class BookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final RoomDAO roomDAO = new RoomDAO();
    private final UserDAO userDAO = new UserDAO();
    private final BillDAO billDAO = new BillDAO();
    private final BillDetailDAO billDetailDAO = new BillDetailDAO();

    public BookingServlet() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // 1. Kiểm tra quyền truy cập Admin/Receptionist
        if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || "create".equals(action) || "add".equals(action)) {
            
            // 2. Lấy danh sách tất cả Khách hàng từ DB qua UserDAO
            List<User> userList = userDAO.getAllUsers();
            
            // 3. Lấy danh sách Phòng TRỐNG (Available) qua RoomDAO.getAvailableRooms()
            List<Room> availableRooms = roomDAO.getAvailableRooms();

            // 4. Set dữ liệu vào Request Scope
            request.setAttribute("userList", userList);
            request.setAttribute("users", userList); // Backup attribute name
            
            request.setAttribute("rooms", availableRooms);
            request.setAttribute("availableRooms", availableRooms); // Backup attribute name

            // 5. Forward sang trang JSP hiển thị Form
            request.getRequestDispatcher("/admin/booking-form.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/bookings?action=create");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if ("create".equals(action)) {
            try {
                int userId = Integer.parseInt(request.getParameter("userId"));
                int roomId = Integer.parseInt(request.getParameter("roomId"));
                String checkInStr = request.getParameter("checkInDate");
                String checkOutStr = request.getParameter("checkOutDate");

                SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
                java.util.Date checkIn = df.parse(checkInStr);
                java.util.Date checkOut = df.parse(checkOutStr);

                long diffMs = checkOut.getTime() - checkIn.getTime();
                long days = diffMs / (1000 * 60 * 60 * 24);
                if (days <= 0) days = 1;

                Room room = roomDAO.getRoomById(roomId);
                double roomPrice = (room != null && room.getRoomType() != null) ? room.getRoomType().getPricePerDay() : 0;
                double totalRoomCharge = days * roomPrice;

                // Tạo hoá đơn đặt phòng mới
                Bill bill = new Bill();
                bill.setUserId(userId);
                bill.setCheckInDate(new Timestamp(checkIn.getTime()));
                bill.setCheckOutDate(new Timestamp(checkOut.getTime()));
                bill.setTotalAmount(totalRoomCharge);
                bill.setStatus("Unpaid");

                int billId = billDAO.insertBill(bill);

                if (billId > 0) {
                    BillDetail roomChargeDetail = new BillDetail();
                    roomChargeDetail.setBillId(billId);
                    roomChargeDetail.setRoomId(roomId);
                    roomChargeDetail.setQuantity((int) days);
                    roomChargeDetail.setPrice(roomPrice);
                    billDetailDAO.insertBillDetail(roomChargeDetail);

                    // Cập nhật trạng thái phòng thành Booked
                    roomDAO.updateRoomStatus(roomId, "Booked");

                    response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + billId);
                } else {
                    response.sendRedirect(request.getContextPath() + "/bookings?action=create");
                }

            } catch (ParseException e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/bookings?action=create");
            }
        }
    }
}