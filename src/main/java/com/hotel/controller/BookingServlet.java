package com.hotel.controller;

import com.hotel.dao.BookingDAO;
import com.hotel.dao.CustomerDAO;
import com.hotel.dao.FeedbackDAO;
import com.hotel.dao.RoomDAO;
import com.hotel.model.Booking;
import com.hotel.model.Customer;
import com.hotel.model.Room;
import com.hotel.model.User;
import com.hotel.util.AuthUtil;
import com.hotel.util.ParamUtil;
import com.hotel.dao.UserDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@WebServlet(name = "BookingServlet", urlPatterns = {"/bookings"})
public class BookingServlet extends HttpServlet {
    private final BookingDAO bookingDAO = new BookingDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final UserDAO userDAO = new UserDAO();
    private final FeedbackDAO feedbackDAO = new FeedbackDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = ParamUtil.getString(request, "action", "list");

        // 1. Cho phép khách vãng lai (không đăng nhập) xem và đặt phòng
        if ("book".equalsIgnoreCase(action) || "bookForm".equalsIgnoreCase(action) || "form".equalsIgnoreCase(action)) {
            int bookRoomId = ParamUtil.getInt(request, "roomId", 0);
            Room bookRoom = roomDAO.getRoomById(bookRoomId);
            if (bookRoom == null) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
            request.setAttribute("room", bookRoom);
            request.getRequestDispatcher("/booking.jsp").forward(request, response);
            return;
        }

        User currentUser = AuthUtil.getUser(request);

        // 2. Cho phép xem phiếu đặt phòng (receipt) cho cả khách vãng lai lẫn người dùng đã đăng nhập
        if ("receipt".equals(action)) {
            int id = ParamUtil.getInt(request, "id", 0);
            Booking booking = bookingDAO.getBookingById(id);
            if (booking == null) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
            // Bảo mật: Nếu đăng nhập dưới dạng Customer, chỉ xem được phiếu đặt của chính mình (hoặc có email khớp/liên kết tài khoản)
            if (currentUser != null && "Customer".equals(currentUser.getRole())) {
                boolean isOwnBooking = (booking.getCreatedBy() != null && booking.getCreatedBy().getId() == currentUser.getId()) ||
                                       (booking.getCustomer() != null && booking.getCustomer().getUser() != null && booking.getCustomer().getUser().getId() == currentUser.getId()) ||
                                       (booking.getCustomer() != null && currentUser.getEmail() != null && currentUser.getEmail().equalsIgnoreCase(booking.getCustomer().getCustomerEmail()));
                if (!isOwnBooking) {
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }
            } else if (currentUser != null && !"Admin".equalsIgnoreCase(currentUser.getRole())) {
                // Nhân viên (Receptionist/Staff) chỉ được xem phiếu của đơn do chính mình tạo
                boolean isOwnBooking = booking.getCreatedBy() != null && booking.getCreatedBy().getId() == currentUser.getId();
                if (!isOwnBooking) {
                    response.sendRedirect(request.getContextPath() + "/bookings?action=list&error=permissionDenied");
                    return;
                }
            }
            request.setAttribute("booking", booking);
            request.getRequestDispatcher("/booking-receipt.jsp").forward(request, response);
            return;
        }

        // Kiểm tra đăng nhập cho các chức năng còn lại
        if (!AuthUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Khách hàng tự xem lịch sử đặt phòng của mình
        if (currentUser != null && ("mybookings".equals(action) || ("list".equals(action) && "Customer".equals(currentUser.getRole())))) {
            List<Booking> myBookings = bookingDAO.getBookingsByUserId(currentUser.getId(), currentUser.getEmail());
            request.setAttribute("bookings", myBookings);
            request.setAttribute("reviewedBookingIds",
                    feedbackDAO.getReviewedBookingIdsForUser(currentUser.getId()));
            request.getRequestDispatcher("/my-bookings.jsp").forward(request, response);
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
                List<Booking> allBookings = bookingDAO.getBookingsByRole(currentUser);
                
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
                List<Room> availableRooms = roomDAO.getAllRooms();
                request.setAttribute("customers", customers);
                request.setAttribute("rooms", availableRooms);
                request.getRequestDispatcher("/admin/booking-form.jsp").forward(request, response);
                break;

            case "edit":
                int editId = ParamUtil.getInt(request, "id", 0);
                Booking booking = bookingDAO.getBookingById(editId);
                if (booking == null) {
                    response.sendRedirect(request.getContextPath() + "/bookings?action=list");
                    return;
                }
                if (!"Admin".equalsIgnoreCase(currentUser.getRole())) {
                    if (booking.getCreatedBy() == null || booking.getCreatedBy().getId() != currentUser.getId()) {
                        response.sendRedirect(request.getContextPath() + "/bookings?action=list&error=permissionDenied");
                        return;
                    }
                }
                request.setAttribute("booking", booking);
                request.setAttribute("customers", customerDAO.getAllCustomers());
                request.setAttribute("rooms", roomDAO.getAllRooms()); // Lấy tất cả phòng để Admin có thể đổi phòng
                request.getRequestDispatcher("/admin/booking-form.jsp").forward(request, response);
                break;

            case "delete":
                int deleteId = ParamUtil.getInt(request, "id", 0);
                Booking deleteBooking = bookingDAO.getBookingById(deleteId);
                if (deleteBooking != null) {
                    if (!"Admin".equalsIgnoreCase(currentUser.getRole())) {
                        if (deleteBooking.getCreatedBy() == null || deleteBooking.getCreatedBy().getId() != currentUser.getId()) {
                            response.sendRedirect(request.getContextPath() + "/bookings?action=list&error=permissionDenied");
                            return;
                        }
                    }
                    bookingDAO.deleteBooking(deleteId);
                    roomDAO.updateRoomStatus(deleteBooking.getRoom().getId(), "Available");
                }
                response.sendRedirect(request.getContextPath() + "/bookings?action=list");
                break;

            case "checkin":
                int checkinId = ParamUtil.getInt(request, "id", 0);
                Booking checkinBooking = bookingDAO.getBookingById(checkinId);
                if (checkinBooking != null && !"Admin".equalsIgnoreCase(currentUser.getRole())) {
                    if (checkinBooking.getCreatedBy() == null || checkinBooking.getCreatedBy().getId() != currentUser.getId()) {
                        response.sendRedirect(request.getContextPath() + "/bookings?action=list&mode=checkin&error=permissionDenied");
                        return;
                    }
                }
                boolean checkinSuccess = bookingDAO.checkInBookings(java.util.Collections.singletonList(checkinId));
                if (checkinSuccess && checkinBooking != null && checkinBooking.getRoom() != null) {
                    roomDAO.updateRoomStatus(checkinBooking.getRoom().getId(), "Booked");
                }
                response.sendRedirect(request.getContextPath() + "/bookings?action=list&mode=checkin");
                break;

            case "checkout":
                int checkoutId = ParamUtil.getInt(request, "id", 0);
                String targetRoomStatus = ParamUtil.getString(request, "roomStatus", "Maintenance");
                if (!"Available".equalsIgnoreCase(targetRoomStatus) && !"Maintenance".equalsIgnoreCase(targetRoomStatus)) {
                    targetRoomStatus = "Maintenance";
                }
                Booking checkoutBooking = bookingDAO.getBookingById(checkoutId);
                if (checkoutBooking != null && !"Admin".equalsIgnoreCase(currentUser.getRole())) {
                    if (checkoutBooking.getCreatedBy() == null || checkoutBooking.getCreatedBy().getId() != currentUser.getId()) {
                        response.sendRedirect(request.getContextPath() + "/bookings?action=list&mode=checkout&error=permissionDenied");
                        return;
                    }
                }
                int singleBillId = bookingDAO.checkOutBookings(
                        java.util.Collections.singletonList(checkoutId), currentUser.getId(), targetRoomStatus);
                if (singleBillId > 0) {
                    if (checkoutBooking != null && checkoutBooking.getRoom() != null) {
                        roomDAO.updateRoomStatus(checkoutBooking.getRoom().getId(), targetRoomStatus);
                    }
                    response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + singleBillId);
                    return;
                }
                response.sendRedirect(request.getContextPath()
                        + "/bookings?action=list&mode=checkout&error=bulkFailed");
                break;

            case "cancel":
                String cancelReturnAction = "Customer".equals(currentUser.getRole()) ? "mybookings" : "list";
                response.sendRedirect(request.getContextPath()
                        + "/bookings?action=" + cancelReturnAction + "&error=cancelReasonRequired");
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

        if ("cancel".equals(action)) {
            int bookingId = ParamUtil.getInt(request, "bookingId", 0);
            String cancellationReason = ParamUtil.getString(request, "cancellationReason", "");
            Booking booking = bookingDAO.getBookingById(bookingId);
            boolean isManager = currentUser != null
                    && ("Admin".equals(currentUser.getRole()) || "Receptionist".equals(currentUser.getRole()));
            boolean isOwner = currentUser != null && booking != null
                    && ((booking.getCreatedBy() != null
                            && booking.getCreatedBy().getId() == currentUser.getId())
                        || (booking.getCustomer() != null && booking.getCustomer().getUser() != null
                            && booking.getCustomer().getUser().getId() == currentUser.getId())
                        || (booking.getCustomer() != null && currentUser.getEmail() != null
                            && currentUser.getEmail().equalsIgnoreCase(booking.getCustomer().getCustomerEmail())));
            String returnAction = isManager ? "list" : "mybookings";

            if (booking == null || (!isManager && !isOwner)) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
            if (cancellationReason.length() < 3 || cancellationReason.length() > 500) {
                response.sendRedirect(request.getContextPath()
                        + "/bookings?action=" + returnAction + "&error=invalidCancelReason");
                return;
            }

            if (!"Pending".equalsIgnoreCase(booking.getStatus()) && !"Confirmed".equalsIgnoreCase(booking.getStatus())) {
                response.sendRedirect(request.getContextPath()
                        + "/bookings?action=" + returnAction + "&error=cannotCancelPaid");
                return;
            }

            boolean cancelled = bookingDAO.cancelBooking(bookingId, cancellationReason);
            response.sendRedirect(request.getContextPath()
                    + "/bookings?action=" + returnAction
                    + (cancelled ? "&cancelled=1" : "&error=cancelFailed"));
            return;
        }

        if ("bulkCheckin".equals(action) || "bulkCheckout".equals(action)) {
            if (currentUser == null || (!"Admin".equals(currentUser.getRole())
                    && !"Receptionist".equals(currentUser.getRole()))) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }

            List<Integer> bookingIds = getRequestedBookingIds(request);
            String mode = "bulkCheckout".equals(action) ? "checkout" : "checkin";
            if (bookingIds.isEmpty()) {
                response.sendRedirect(request.getContextPath()
                        + "/bookings?action=list&mode=" + mode + "&error=noSelection");
                return;
            }

            // Phân quyền: Nhân viên chỉ được xử lý hàng loạt các đơn do chính mình tạo
            if (!"Admin".equalsIgnoreCase(currentUser.getRole())) {
                List<Integer> allowedIds = new ArrayList<>();
                for (Integer bId : bookingIds) {
                    Booking b = bookingDAO.getBookingById(bId);
                    if (b != null && b.getCreatedBy() != null && b.getCreatedBy().getId() == currentUser.getId()) {
                        allowedIds.add(bId);
                    }
                }
                bookingIds = allowedIds;
                if (bookingIds.isEmpty()) {
                    response.sendRedirect(request.getContextPath()
                            + "/bookings?action=list&mode=" + mode + "&error=permissionDenied");
                    return;
                }
            }

            if ("bulkCheckin".equals(action)) {
                boolean success = bookingDAO.checkInBookings(bookingIds);
                if (success) {
                    for (Integer bId : bookingIds) {
                        Booking b = bookingDAO.getBookingById(bId);
                        if (b != null && b.getRoom() != null) {
                            roomDAO.updateRoomStatus(b.getRoom().getId(), "Booked");
                        }
                    }
                }
                response.sendRedirect(request.getContextPath()
                        + "/bookings?action=list&mode=checkin&"
                        + (success ? "processed=" + bookingIds.size() : "error=bulkFailed"));
                return;
            }

            String targetRoomStatus = ParamUtil.getString(request, "roomStatus", "Maintenance");
            if (!"Available".equalsIgnoreCase(targetRoomStatus) && !"Maintenance".equalsIgnoreCase(targetRoomStatus)) {
                targetRoomStatus = "Maintenance";
            }
            int billId = bookingDAO.checkOutBookings(bookingIds, currentUser.getId(), targetRoomStatus);
            if (billId > 0) {
                for (Integer bId : bookingIds) {
                    Booking b = bookingDAO.getBookingById(bId);
                    if (b != null && b.getRoom() != null) {
                        roomDAO.updateRoomStatus(b.getRoom().getId(), targetRoomStatus);
                    }
                }
                response.sendRedirect(request.getContextPath() + "/bills?action=detail&id=" + billId);
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/bookings?action=list&mode=checkout&error=bulkFailed");
            }
            return;
        }

        if ("insert".equals(action)) {
            List<Integer> roomIds = getRequestedRoomIds(request);
            String checkInStr = ParamUtil.getString(request, "checkInDate", "");
            String checkOutStr = ParamUtil.getString(request, "checkOutDate", "");
            String note = ParamUtil.getString(request, "note", "");

            // Thông tin liên lạc khách hàng
            String customerName = ParamUtil.getString(request, "customerName", "");
            String customerPhone = ParamUtil.getString(request, "customerPhone", "");
            String customerEmail = ParamUtil.getString(request, "customerEmail", "");
            String customerCccd = ParamUtil.getString(request, "customerCccd", "");

            try {
                Date checkInDate = parseFlexibleDate(checkInStr);
                Date checkOutDate = parseFlexibleDate(checkOutStr);

                int firstRoomId = !roomIds.isEmpty() ? roomIds.get(0) : 0;

                if (roomIds.isEmpty() || checkInDate == null || checkOutDate == null || !checkOutDate.after(checkInDate)) {
                    if (currentUser != null && ("Admin".equals(currentUser.getRole()) || "Receptionist".equals(currentUser.getRole()))) {
                        response.sendRedirect(request.getContextPath() + "/bookings?action=add&error=invalidSelection");
                    } else if (firstRoomId > 0) {
                        response.sendRedirect(request.getContextPath() + "/rooms?action=bookForm&roomId=" + firstRoomId + "&error=invalidDate");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/home");
                    }
                    return;
                }

                List<Room> selectedRooms = new ArrayList<>();
                for (Integer roomId : roomIds) {
                    Room room = roomDAO.getRoomById(roomId);
                    if (room == null || !bookingDAO.isRoomAvailable(roomId, checkInDate, checkOutDate)) {
                        if (currentUser != null && ("Admin".equals(currentUser.getRole()) || "Receptionist".equals(currentUser.getRole()))) {
                            response.sendRedirect(request.getContextPath() + "/bookings?action=add&error=roomsUnavailable");
                        } else if (firstRoomId > 0) {
                            response.sendRedirect(request.getContextPath() + "/rooms?action=bookForm&roomId=" + firstRoomId + "&error=roomUnavailable");
                        } else {
                            response.sendRedirect(request.getContextPath() + "/home");
                        }
                        return;
                    }
                    selectedRooms.add(room);
                }

                Customer customer = null;
                String status = "Pending";
                User creator = currentUser;

                double memberDiscountRate = 0.0;

                if (currentUser == null) {
                    // Khách vãng lai không có tài khoản: TỰ ĐỘNG XÁC NHẬN ĐƠN VÌ ĐÃ CỌC 20%
                    status = "Confirmed";
                    String finalName = (customerName != null && !customerName.trim().isEmpty()) ? customerName.trim() : "Khách lưu trú";
                    String finalEmail = (customerEmail != null && !customerEmail.trim().isEmpty()) ? customerEmail.trim() : "";
                    String finalPhone = (customerPhone != null && !customerPhone.trim().isEmpty()) ? customerPhone.trim() : "";

                    User matchedUser = (!finalEmail.isEmpty()) ? userDAO.findByEmail(finalEmail) : null;
                    customer = customerDAO.findOrCreateCustomer(finalName, finalPhone, finalEmail, customerCccd, matchedUser);
                    creator = userDAO.getUserById(1); // Gán admin làm người đại diện tạo
                    if (creator == null) {
                        creator = userDAO.findByEmailOrUsername("admin");
                    }
                    String depositNote = "[Khách vãng lai - Đã cọc 20% VietQR]";
                    note = (note != null && !note.trim().isEmpty()) ? note.trim() + " " + depositNote : depositNote;
                } else if ("Customer".equals(currentUser.getRole())) {
                    // Khách hàng có tài khoản thành viên: Đặc quyền miễn cọc, lưu đơn ở trạng thái Pending
                    status = "Pending";
                    String finalName = (customerName != null && !customerName.trim().isEmpty())
                            ? customerName.trim()
                            : (currentUser.getFullName() != null && !currentUser.getFullName().isEmpty()
                                ? currentUser.getFullName() : "Khách lưu trú");
                    String finalEmail = (customerEmail != null && !customerEmail.trim().isEmpty())
                            ? customerEmail.trim()
                            : (currentUser.getEmail() != null ? currentUser.getEmail() : "");
                    String finalPhone = (customerPhone != null && !customerPhone.trim().isEmpty())
                            ? customerPhone.trim()
                            : (currentUser.getPhone() != null ? currentUser.getPhone() : "");

                    customer = customerDAO.findOrCreateCustomer(finalName, finalPhone, finalEmail, customerCccd, currentUser);
                    
                    // Tính chiết khấu thành viên theo hạng thẻ
                    memberDiscountRate = calculateMemberDiscountRate(currentUser.getId(), currentUser.getEmail());
                    String memberNote = "[Hội viên - Miễn cọc trước, thanh toán 100% khi nhận phòng]";
                    note = (note != null && !note.trim().isEmpty()) ? note.trim() + " " + memberNote : memberNote;
                } else {
                    // Admin/Receptionist tạo đơn tại quầy: Mặc định Confirmed
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
                            if (!customerEmail.isEmpty() && !customerEmail.equals(customer.getCustomerEmail())) {
                                customer.setCustomerEmail(customerEmail);
                                isChanged = true;
                            }
                            if (isChanged) {
                                customerDAO.insertCustomer(customer);
                            }
                        }
                    } else {
                        User matchedUser = (!customerEmail.isEmpty()) ? userDAO.findByEmail(customerEmail) : null;
                        customer = customerDAO.findOrCreateCustomer(customerName, customerPhone, customerEmail, customerCccd, matchedUser);
                    }
                    status = "Confirmed";
                }

                if (customer == null) {
                    if (currentUser != null && ("Admin".equals(currentUser.getRole()) || "Receptionist".equals(currentUser.getRole()))) {
                        response.sendRedirect(request.getContextPath() + "/bookings?action=add");
                    } else if (firstRoomId > 0) {
                        response.sendRedirect(request.getContextPath() + "/rooms?action=bookForm&roomId=" + firstRoomId + "&error=customerCreateFailed");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/home");
                    }
                    return;
                }

                Timestamp checkInTimestamp = new Timestamp(checkInDate.getTime());
                Timestamp checkOutTimestamp = new Timestamp(checkOutDate.getTime());
                List<Booking> bookings = new ArrayList<>();
                for (Room room : selectedRooms) {
                    double finalRoomPrice = room.getRoomType().getPricePerDay();
                    if (memberDiscountRate > 0) {
                        finalRoomPrice = finalRoomPrice * (1.0 - memberDiscountRate);
                    }
                    bookings.add(new Booking(
                            customer,
                            room,
                            creator,
                            checkInTimestamp,
                            checkOutTimestamp,
                            status,
                            finalRoomPrice,
                            note
                    ));
                }

                boolean success = bookingDAO.insertBookings(bookings);
                if (success) {
                    if (bookings.size() == 1) {
                        response.sendRedirect(request.getContextPath()
                                + "/bookings?action=receipt&id=" + bookings.get(0).getBookingId());
                    } else if (currentUser != null
                            && ("Admin".equals(currentUser.getRole()) || "Receptionist".equals(currentUser.getRole()))) {
                        response.sendRedirect(request.getContextPath()
                                + "/bookings?action=list&createdCount=" + bookings.size());
                    } else {
                        response.sendRedirect(request.getContextPath()
                                + "/bookings?action=receipt&id=" + bookings.get(0).getBookingId());
                    }
                } else {
                    if (currentUser != null && ("Admin".equals(currentUser.getRole()) || "Receptionist".equals(currentUser.getRole()))) {
                        response.sendRedirect(request.getContextPath() + "/bookings?action=add&error=roomsUnavailable");
                    } else if (firstRoomId > 0) {
                        response.sendRedirect(request.getContextPath() + "/rooms?action=bookForm&roomId=" + firstRoomId + "&error=roomsUnavailable");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/home");
                    }
                }

            } catch (Exception e) {
                e.printStackTrace();
                int firstRoomId = !roomIds.isEmpty() ? roomIds.get(0) : 0;
                if (firstRoomId > 0) {
                    response.sendRedirect(request.getContextPath() + "/rooms?action=bookForm&roomId=" + firstRoomId + "&error=serverError");
                } else {
                    response.sendRedirect(request.getContextPath() + "/home");
                }
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

            try {
                Date checkInDate = parseFlexibleDate(checkInStr);
                Date checkOutDate = parseFlexibleDate(checkOutStr);

                Booking booking = bookingDAO.getBookingById(bookingId);
                if (booking == null) {
                    response.sendRedirect(request.getContextPath() + "/bookings?action=list");
                    return;
                }

                if (!"Admin".equalsIgnoreCase(currentUser.getRole())) {
                    if (booking.getCreatedBy() == null || booking.getCreatedBy().getId() != currentUser.getId()) {
                        response.sendRedirect(request.getContextPath() + "/bookings?action=list&error=permissionDenied");
                        return;
                    }
                }

                Room newRoom = roomDAO.getRoomById(roomId);
                Customer customer = customerDAO.getCustomerById(customerId);

                if (newRoom != null && customer != null) {
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

                    if ("CheckedIn".equalsIgnoreCase(status)) {
                        roomDAO.updateRoomStatus(newRoom.getId(), "Booked");
                    } else if ("CheckedOut".equalsIgnoreCase(status)) {
                        String rStatus = ParamUtil.getString(request, "roomStatus", "Maintenance");
                        if (!"Available".equalsIgnoreCase(rStatus) && !"Maintenance".equalsIgnoreCase(rStatus)) {
                            rStatus = "Maintenance";
                        }
                        roomDAO.updateRoomStatus(newRoom.getId(), rStatus);
                    }

                    bookingDAO.updateBooking(booking);
                }
                response.sendRedirect(request.getContextPath() + "/bookings?action=list");

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/bookings?action=list");
            }
        }
    }

    private List<Integer> getRequestedRoomIds(HttpServletRequest request) {
        String[] rawValues = request.getParameterValues("roomIds");
        if (rawValues == null || rawValues.length == 0) {
            rawValues = request.getParameterValues("roomId");
        }

        Set<Integer> uniqueIds = new LinkedHashSet<>();
        if (rawValues != null) {
            for (String rawValue : rawValues) {
                if (rawValue == null) {
                    continue;
                }
                for (String part : rawValue.split(",")) {
                    try {
                        int roomId = Integer.parseInt(part.trim());
                        if (roomId > 0) {
                            uniqueIds.add(roomId);
                        }
                    } catch (NumberFormatException ignored) {
                        // Invalid ids are discarded; an empty result is rejected by doPost.
                    }
                }
            }
        }
        return new ArrayList<>(uniqueIds);
    }

    private List<Integer> getRequestedBookingIds(HttpServletRequest request) {
        String[] rawValues = request.getParameterValues("bookingIds");
        Set<Integer> uniqueIds = new LinkedHashSet<>();
        if (rawValues != null) {
            for (String rawValue : rawValues) {
                if (rawValue == null) continue;
                for (String part : rawValue.split(",")) {
                    try {
                        int bookingId = Integer.parseInt(part.trim());
                        if (bookingId > 0) uniqueIds.add(bookingId);
                    } catch (NumberFormatException ignored) {
                        // Invalid booking ids are ignored and rejected if none remain.
                    }
                }
            }
        }
        return new ArrayList<>(uniqueIds);
    }

    private Date parseFlexibleDate(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) return null;
        String cleaned = dateStr.trim();
        String[] patterns = {
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd HH:mm",
            "yyyy-MM-dd",
            "dd/MM/yyyy HH:mm",
            "dd/MM/yyyy"
        };
        for (String p : patterns) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat(p);
                sdf.setLenient(true);
                return sdf.parse(cleaned);
            } catch (Exception ignored) {}
        }
        return null;
    }

    private double calculateMemberDiscountRate(int userId, String email) {
        if (userId <= 0) return 0.0;
        try {
            List<Booking> list = bookingDAO.getBookingsByUserId(userId, email);
            if (list == null || list.isEmpty()) return 0.0;
            double totalSpent = 0;
            for (Booking b : list) {
                if ("CheckedOut".equals(b.getStatus())) {
                    long diffMs = b.getCheckOutDate().getTime() - b.getCheckInDate().getTime();
                    long days = diffMs / (1000 * 60 * 60 * 24);
                    if (days <= 0) days = 1;
                    totalSpent += b.getRoomPrice() * days;
                }
            }
            if (totalSpent >= 100000000) return 0.15; // Diamond: 15%
            if (totalSpent >= 50000000) return 0.10;  // Platinum: 10%
            if (totalSpent >= 20000000) return 0.05;  // Gold: 5%
            return 0.0;
        } catch (Exception e) {
            return 0.0;
        }
    }
}
