package com.hotel.controller;

import com.hotel.dao.BookingDAO;
import com.hotel.dao.CustomerDAO;
import com.hotel.dao.RoomDAO;
import com.hotel.model.Booking;
import com.hotel.model.Customer;
import com.hotel.model.Room;
import com.hotel.model.User;
import com.hotel.util.AuthUtil;
import com.hotel.util.ParamUtil;
import com.hotel.dao.BillDAO;
import com.hotel.dao.BillDetailDAO;
import com.hotel.dao.UserDAO;
import com.hotel.model.Bill;
import com.hotel.model.BillDetail;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet(name = "BookingServlet", urlPatterns = {"/bookings"})
public class BookingServlet extends HttpServlet {
    private final BookingDAO bookingDAO = new BookingDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final BillDAO billDAO = new BillDAO();
    private final BillDetailDAO billDetailDAO = new BillDetailDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = ParamUtil.getString(request, "action", "list");

        // Cho phép truy cập không đăng nhập đối với chức năng xem hóa đơn đặt phòng (receipt)
        if (!"receipt".equals(action)) {
            if (!AuthUtil.isAuthenticated(request)) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
        }

        User currentUser = AuthUtil.getUser(request);

        // Khách hàng tự xem lịch sử đặt phòng của mình
        if (currentUser != null && ("mybookings".equals(action) || ("list".equals(action) && "Customer".equals(currentUser.getRole())))) {
            List<Booking> myBookings = bookingDAO.getBookingsByUserId(currentUser.getId(), currentUser.getEmail());
            request.setAttribute("bookings", myBookings);
            request.getRequestDispatcher("/my-bookings.jsp").forward(request, response);
            return;
        }

        // Xem phiếu đặt phòng (cả Admin và Khách hàng đều xem được phiếu của họ)
        if ("receipt".equals(action)) {
            int id = ParamUtil.getInt(request, "id", 0);
            Booking booking = bookingDAO.getBookingById(id);
            if (booking == null) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
            // Bảo mật: Nếu đăng nhập dưới dạng Customer, chỉ xem được phiếu đặt của chính mình (hoặc có email khớp)
            boolean isOwnBooking = false;
            if (currentUser != null) {
                isOwnBooking = (booking.getCreatedBy() != null && booking.getCreatedBy().getId() == currentUser.getId()) ||
                               (booking.getCustomer() != null && currentUser.getEmail() != null && currentUser.getEmail().equalsIgnoreCase(booking.getCustomer().getCustomerEmail()));
            }
            if (currentUser != null && "Customer".equals(currentUser.getRole()) && !isOwnBooking) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
            request.setAttribute("booking", booking);
            request.getRequestDispatcher("/booking-receipt.jsp").forward(request, response);
            return;
        }

        // Quyền Admin / Receptionist cho các chức năng quản trị bên dưới
        if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        switch (action) {
            case "list":
                String mode = ParamUtil.getString(request, "mode", "");
                List<Booking> allBookings = bookingDAO.getAllBookings();
                
                if (allBookings != null) {
                    if ("checkin".equals(mode)) {
                        // Chỉ giữ lại các đơn đặt phòng chờ nhận phòng (Pending, Confirmed)
                        allBookings.removeIf(b -> !"Pending".equals(b.getStatus()) && !"Confirmed".equals(b.getStatus()));
                    } else if ("checkout".equals(mode)) {
                        // Chỉ giữ lại các đơn đặt phòng đang lưu trú (CheckedIn)
                        allBookings.removeIf(b -> !"CheckedIn".equals(b.getStatus()));
                    }
                }
                
                request.setAttribute("bookings", allBookings);
                request.setAttribute("mode", mode);
                request.getRequestDispatcher("/admin/bookings.jsp").forward(request, response);
                break;

            case "add":
                List<Customer> customers = customerDAO.getAllCustomers();
                List<Room> availableRooms = roomDAO.getAvailableRooms();
                request.setAttribute("customers", customers);
                request.setAttribute("rooms", availableRooms);
                request.getRequestDispatcher("/admin/booking-form.jsp").forward(request, response);
                break;

            case "edit":
                int editId = ParamUtil.getInt(request, "id", 0);
                Booking booking = bookingDAO.getBookingById(editId);
                request.setAttribute("booking", booking);
                request.setAttribute("customers", customerDAO.getAllCustomers());
                request.setAttribute("rooms", roomDAO.getAllRooms()); // Lấy tất cả phòng để Admin có thể đổi phòng
                request.getRequestDispatcher("/admin/booking-form.jsp").forward(request, response);
                break;

            case "delete":
                int deleteId = ParamUtil.getInt(request, "id", 0);
                Booking deleteBooking = bookingDAO.getBookingById(deleteId);
                if (deleteBooking != null) {
                    bookingDAO.deleteBooking(deleteId);
                    roomDAO.updateRoomStatus(deleteBooking.getRoom().getId(), "Available");
                }
                response.sendRedirect(request.getContextPath() + "/bookings?action=list");
                break;

            case "checkin":
                int checkinId = ParamUtil.getInt(request, "id", 0);
                Booking checkinBooking = bookingDAO.getBookingById(checkinId);
                if (checkinBooking != null) {
                    bookingDAO.updateBookingStatus(checkinId, "CheckedIn");
                    roomDAO.updateRoomStatus(checkinBooking.getRoom().getId(), "Occupied");
                }
                response.sendRedirect(request.getContextPath() + "/bookings?action=list");
                break;

            case "checkout":
                int checkoutId = ParamUtil.getInt(request, "id", 0);
                Booking checkoutBooking = bookingDAO.getBookingById(checkoutId);
                if (checkoutBooking != null) {
                    // 1. Tạo Hóa đơn (Bill) mới từ thông tin Booking
                    Bill bill = new Bill();
                    
                    User billCreator = checkoutBooking.getCreatedBy();
                    if (billCreator == null) {
                        billCreator = userDAO.getUserById(1); // Mặc định gán admin nếu đặt phòng cũ không có người tạo
                    }
                    bill.setUser(billCreator);
                    bill.setCustomer(checkoutBooking.getCustomer()); // Lưu thông tin khách hàng lưu trú thực tế vào hóa đơn
                    bill.setCheckInDate(checkoutBooking.getCheckInDate());
                    bill.setCheckOutDate(checkoutBooking.getCheckOutDate());
                    
                    // Tính số ngày lưu trú thực tế
                    long diffMs = checkoutBooking.getCheckOutDate().getTime() - checkoutBooking.getCheckInDate().getTime();
                    long days = diffMs / (1000 * 60 * 60 * 24);
                    if (days <= 0) days = 1;
                    
                    double totalRoomCharge = days * checkoutBooking.getRoomPrice();
                    bill.setTotalAmount(totalRoomCharge);
                    bill.setStatus("Unpaid");
                    
                    int billId = billDAO.insertBill(bill);
                    if (billId > 0) {
                        // 2. Tạo Chi tiết hóa đơn (BillDetail) tiền phòng
                        BillDetail roomChargeDetail = new BillDetail();
                        roomChargeDetail.setBillId(billId);
                        roomChargeDetail.setRoom(checkoutBooking.getRoom());
                        roomChargeDetail.setQuantity((int) days);
                        roomChargeDetail.setPrice(checkoutBooking.getRoomPrice());
                        billDetailDAO.insertBillDetail(roomChargeDetail);
                    }
                    
                    // 3. Cập nhật trạng thái Booking và Phòng
                    bookingDAO.updateBookingStatus(checkoutId, "CheckedOut");
                    roomDAO.updateRoomStatus(checkoutBooking.getRoom().getId(), "Available");
                    
                    if (billId > 0) {
                        // Chuyển hướng thẳng tới trang hóa đơn chi tiết
                        response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + billId);
                        return;
                    }
                }
                response.sendRedirect(request.getContextPath() + "/bookings?action=list");
                break;

            case "cancel":
                int cancelId = ParamUtil.getInt(request, "id", 0);
                Booking cancelBooking = bookingDAO.getBookingById(cancelId);
                if (cancelBooking != null) {
                    bookingDAO.updateBookingStatus(cancelId, "Cancelled");
                    roomDAO.updateRoomStatus(cancelBooking.getRoom().getId(), "Available");
                }
                if ("Customer".equals(currentUser.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/bookings?action=mybookings");
                } else {
                    response.sendRedirect(request.getContextPath() + "/bookings?action=list");
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/bookings?action=list");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = ParamUtil.getString(request, "action", "");

        // Cho phép không đăng nhập đối với hành động insert (khách vãng lai tự đặt phòng)
        if (!"insert".equals(action)) {
            if (!AuthUtil.isAuthenticated(request)) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
        }

        User currentUser = AuthUtil.getUser(request);

        if ("insert".equals(action)) {
            int roomId = ParamUtil.getInt(request, "roomId", 0);
            String checkInStr = ParamUtil.getString(request, "checkInDate", "");
            String checkOutStr = ParamUtil.getString(request, "checkOutDate", "");
            String note = ParamUtil.getString(request, "note", "");

            // Thông tin liên lạc khách hàng
            String customerName = ParamUtil.getString(request, "customerName", "");
            String customerPhone = ParamUtil.getString(request, "customerPhone", "");
            String customerEmail = ParamUtil.getString(request, "customerEmail", "");
            String customerCccd = ParamUtil.getString(request, "customerCccd", "");

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            try {
                Date checkInDate = sdf.parse(checkInStr);
                Date checkOutDate = sdf.parse(checkOutStr);

                Room room = roomDAO.getRoomById(roomId);
                if (room == null) {
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }

                Customer customer = null;
                String status = "Pending";
                User creator = currentUser;

                if (currentUser == null || "Customer".equals(currentUser.getRole())) {
                    // Khách tự đặt phòng online (vãng lai hoặc hội viên)
                    String finalName = (currentUser != null) ? currentUser.getFullName() : customerName;
                    String finalEmail = (currentUser != null) ? currentUser.getEmail() : customerEmail;
                    
                    customer = customerDAO.findOrCreateCustomer(finalName, customerPhone, finalEmail, customerCccd);
                    if (creator == null) {
                        creator = userDAO.getUserById(1); // Gán admin (ID = 1) làm người tạo mặc định cho đặt phòng vãng lai
                    }
                } else {
                    // Admin/Receptionist đặt phòng hộ khách hàng
                    int customerId = ParamUtil.getInt(request, "customerId", 0);
                    if (customerId > 0) {
                        customer = customerDAO.getCustomerById(customerId);
                        if (customer != null) {
                            boolean isChanged = false;
                            if (!customerPhone.isEmpty() && !customerPhone.equals(customer.getCustomerPhone())) {
                                customer.setCustomerPhone(customerPhone);
                                isChanged = true;
                            }
                            if (!customerCccd.isEmpty() && !customerCccd.equals(customer.getCustomerCccd())) {
                                customer.setCustomerCccd(customerCccd);
                                isChanged = true;
                            }
                            if (isChanged) {
                                customerDAO.insertCustomer(customer);
                            }
                        }
                    } else {
                        customer = customerDAO.findOrCreateCustomer(customerName, customerPhone, customerEmail, customerCccd);
                    }
                    status = "Confirmed"; // Admin đặt mặc định xác nhận luôn
                }

                if (customer == null) {
                    response.sendRedirect(request.getContextPath() + (currentUser != null ? "/bookings?action=add" : "/home"));
                    return;
                }

                Booking booking = new Booking(
                        customer,
                        room,
                        creator,
                        new Timestamp(checkInDate.getTime()),
                        new Timestamp(checkOutDate.getTime()),
                        status,
                        room.getRoomType().getPricePerDay(),
                        note
                );

                boolean success = bookingDAO.insertBooking(booking);
                if (success) {
                    roomDAO.updateRoomStatus(roomId, "Booked");
                    response.sendRedirect(request.getContextPath() + "/bookings?action=receipt&id=" + booking.getBookingId());
                } else {
                    response.sendRedirect(request.getContextPath() + "/home");
                }

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/home");
            }

        } else if ("update".equals(action)) {
            // Chỉ Admin/Receptionist được cập nhật đặt phòng
            if (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }

            int bookingId = ParamUtil.getInt(request, "bookingId", 0);
            int customerId = ParamUtil.getInt(request, "customerId", 0);
            int roomId = ParamUtil.getInt(request, "roomId", 0);
            String checkInStr = ParamUtil.getString(request, "checkInDate", "");
            String checkOutStr = ParamUtil.getString(request, "checkOutDate", "");
            String status = ParamUtil.getString(request, "status", "Confirmed");
            String note = ParamUtil.getString(request, "note", "");

            // Cập nhật thông tin khách hàng nếu cần
            String customerPhone = ParamUtil.getString(request, "customerPhone", "");
            String customerCccd = ParamUtil.getString(request, "customerCccd", "");

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            try {
                Date checkInDate = sdf.parse(checkInStr);
                Date checkOutDate = sdf.parse(checkOutStr);

                Booking booking = bookingDAO.getBookingById(bookingId);
                Room newRoom = roomDAO.getRoomById(roomId);
                Customer customer = customerDAO.getCustomerById(customerId);

                if (booking != null && newRoom != null && customer != null) {
                    // Cập nhật SĐT/CCCD
                    if (!customerPhone.isEmpty()) {
                        customer.setCustomerPhone(customerPhone);
                    }
                    if (!customerCccd.isEmpty()) {
                        customer.setCustomerCccd(customerCccd);
                    }
                    customerDAO.insertCustomer(customer); // merge

                    // Nếu đổi phòng
                    if (booking.getRoom().getId() != roomId) {
                        roomDAO.updateRoomStatus(booking.getRoom().getId(), "Available");
                        roomDAO.updateRoomStatus(roomId, "Booked");
                    }

                    booking.setCustomer(customer);
                    booking.setRoom(newRoom);
                    booking.setCheckInDate(new Timestamp(checkInDate.getTime()));
                    booking.setCheckOutDate(new Timestamp(checkOutDate.getTime()));
                    booking.setStatus(status);
                    booking.setRoomPrice(newRoom.getRoomType().getPricePerDay());
                    booking.setNote(note);

                    bookingDAO.updateBooking(booking);
                }
                response.sendRedirect(request.getContextPath() + "/bookings?action=list");

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/bookings?action=list");
            }
        }
    }
}
