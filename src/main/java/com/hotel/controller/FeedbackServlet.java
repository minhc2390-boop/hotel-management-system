package com.hotel.controller;

import com.hotel.dao.BookingDAO;
import com.hotel.dao.FeedbackDAO;
import com.hotel.model.Booking;
import com.hotel.model.Feedback;
import com.hotel.model.User;
import com.hotel.util.AuthUtil;
import com.hotel.util.ParamUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;

@WebServlet(name = "FeedbackServlet", urlPatterns = {"/feedbacks"})
public class FeedbackServlet extends HttpServlet {

    private final FeedbackDAO feedbackDAO = new FeedbackDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!AuthUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = ParamUtil.getString(request, "action", "list");
        User currentUser = AuthUtil.getUser(request);

        if ("list".equals(action)) {
            if (!isManager(currentUser)) {
                response.sendRedirect(request.getContextPath() + "/bookings?action=mybookings");
                return;
            }
            request.setAttribute("feedbacks", feedbackDAO.getAll());
            request.getRequestDispatcher("/admin/feedbacks.jsp").forward(request, response);
            return;
        }

        int bookingId = ParamUtil.getInt(request, "bookingId", 0);
        Booking booking = bookingDAO.getBookingById(bookingId);
        if (!isEligibleOwner(booking, currentUser)) {
            response.sendRedirect(request.getContextPath() + "/bookings?action=mybookings&feedback=notAllowed");
            return;
        }

        Feedback existing = feedbackDAO.getByBookingId(bookingId);
        if ("view".equals(action) && existing != null) {
            request.setAttribute("booking", booking);
            request.setAttribute("feedback", existing);
            request.getRequestDispatcher("/feedback-form.jsp").forward(request, response);
            return;
        }

        if (!"add".equals(action) || existing != null) {
            response.sendRedirect(request.getContextPath()
                    + "/bookings?action=mybookings&feedback=" + (existing != null ? "alreadySent" : "notAllowed"));
            return;
        }

        request.setAttribute("booking", booking);
        request.getRequestDispatcher("/feedback-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!AuthUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = AuthUtil.getUser(request);
        if (!"Customer".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        int bookingId = ParamUtil.getInt(request, "bookingId", 0);
        int rating = ParamUtil.getInt(request, "rating", 0);
        String content = ParamUtil.getString(request, "content", "");
        Booking booking = bookingDAO.getBookingById(bookingId);

        String validationError = validate(booking, currentUser, rating, content);
        if (validationError != null) {
            request.setAttribute("booking", booking);
            request.setAttribute("rating", rating);
            request.setAttribute("content", content);
            request.setAttribute("error", validationError);
            request.getRequestDispatcher("/feedback-form.jsp").forward(request, response);
            return;
        }

        Feedback feedback = new Feedback(
                booking,
                currentUser,
                rating,
                content,
                new Timestamp(System.currentTimeMillis())
        );
        boolean success = feedbackDAO.insertForCheckedOutBooking(
                feedback, bookingId, currentUser.getId(), currentUser.getEmail());

        response.sendRedirect(request.getContextPath()
                + "/bookings?action=mybookings&feedback=" + (success ? "success" : "alreadySent"));
    }

    private String validate(Booking booking, User currentUser, int rating, String content) {
        if (!isEligibleOwner(booking, currentUser)) {
            return "Chỉ khách sở hữu phiếu đã trả phòng mới có thể gửi đánh giá.";
        }
        if (rating < 1 || rating > 5) {
            return "Vui lòng chọn mức đánh giá từ 1 đến 5 sao.";
        }
        if (content.length() < 10 || content.length() > 2000) {
            return "Nội dung góp ý phải có từ 10 đến 2000 ký tự.";
        }
        if (feedbackDAO.getByBookingId(booking.getBookingId()) != null) {
            return "Phiếu đặt phòng này đã được đánh giá.";
        }
        return null;
    }

    private boolean isEligibleOwner(Booking booking, User currentUser) {
        if (booking == null || currentUser == null
                || !"Customer".equalsIgnoreCase(currentUser.getRole())
                || !"CheckedOut".equals(booking.getStatus())) {
            return false;
        }
        if (booking.getCreatedBy() != null && booking.getCreatedBy().getId() == currentUser.getId()) {
            return true;
        }
        return booking.getCustomer() != null
                && currentUser.getEmail() != null
                && currentUser.getEmail().equalsIgnoreCase(booking.getCustomer().getCustomerEmail());
    }

    private boolean isManager(User user) {
        return user != null
                && ("Admin".equalsIgnoreCase(user.getRole())
                || "Receptionist".equalsIgnoreCase(user.getRole()));
    }
}
