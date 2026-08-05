package com.hotel.controller;

import com.hotel.dao.BookingDAO;
import com.hotel.dao.UserDAO;
import com.hotel.model.Booking;
import com.hotel.model.User;
import com.hotel.util.AuthUtil;
import com.hotel.util.ParamUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        if (!AuthUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = AuthUtil.getUser(request);
        // Refresh user info from database to make sure it's up to date
        User freshUser = userDAO.getUserById(currentUser.getId());
        if (freshUser != null) {
            currentUser = freshUser;
            AuthUtil.setUser(request, freshUser);
        }

        if ("Customer".equals(currentUser.getRole())) {
            // For registered online Customers (Members), calculate membership statistics
            List<Booking> bookings = bookingDAO.getBookingsByUserId(currentUser.getId(), currentUser.getEmail());
            
            int totalBookings = 0;
            double totalSpent = 0;
            
            if (bookings != null) {
                totalBookings = bookings.size();
                for (Booking b : bookings) {
                    // 🎯 ĐÃ SỬA: Chỉ cộng tiền khi đơn ở trạng thái "CheckedOut" (Đã trả phòng)
                    if ("CheckedOut".equals(b.getStatus())) {
                        long diffMs = b.getCheckOutDate().getTime() - b.getCheckInDate().getTime();
                        long days = diffMs / (1000 * 60 * 60 * 24);
                        if (days <= 0) days = 1;
                        totalSpent += b.getRoomPrice() * days;
                    }
                }
            }

            // Membership tiers:
            // Bronze: < 10,000,000 VND
            // Silver: 10,000,000 - 20,000,000 VND (0% discount)
            // Gold: 20,000,000 - 50,000,000 VND (5% discount)
            // Platinum: 50,000,000 - 100,000,000 VND (10% discount)
            // Diamond: >= 100,000,000 VND (15% discount)
            String tier = "Bronze";
            String tierName = "Hội viên Đồng";
            double discount = 0;
            double nextTierTarget = 10000000;
            String nextTierName = "Bạc";

            if (totalSpent >= 100000000) {
                tier = "Diamond";
                tierName = "Hội viên Kim Cương";
                discount = 0.15;
                nextTierTarget = -1; // Max tier
                nextTierName = "";
            } else if (totalSpent >= 50000000) {
                tier = "Platinum";
                tierName = "Hội viên Bạch kim";
                discount = 0.10;
                nextTierTarget = 100000000;
                nextTierName = "Kim Cương";
            } else if (totalSpent >= 20000000) {
                tier = "Gold";
                tierName = "Hội viên Vàng";
                discount = 0.05;
                nextTierTarget = 50000000;
                nextTierName = "Bạch kim";
            } else if (totalSpent >= 10000000) {
                tier = "Silver";
                tierName = "Hội viên Bạc";
                discount = 0.0;
                nextTierTarget = 20000000;
                nextTierName = "Vàng";
            }

            int loyaltyPoints = (int) (totalSpent / 100000); // 1 point per 100k VND spent
            double progressPercent = 100;
            if (nextTierTarget > 0) {
                progressPercent = (totalSpent / nextTierTarget) * 100;
                if (progressPercent > 100) progressPercent = 100;
            }

            request.setAttribute("totalBookings", totalBookings);
            request.setAttribute("totalSpent", totalSpent);
            request.setAttribute("membershipTier", tier);
            request.setAttribute("membershipTierName", tierName);
            request.setAttribute("membershipDiscount", discount * 100);
            request.setAttribute("loyaltyPoints", loyaltyPoints);
            request.setAttribute("nextTierTarget", nextTierTarget);
            request.setAttribute("nextTierName", nextTierName);
            request.setAttribute("progressPercent", progressPercent);
            request.setAttribute("bookings", bookings);

            request.getRequestDispatcher("/profile.jsp").forward(request, response);
        } else {
            // Admin and Receptionist (Staff) profiles
            request.getRequestDispatcher("/admin/profile.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        if (!AuthUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = AuthUtil.getUser(request);
        User userToUpdate = userDAO.getUserById(currentUser.getId());

        if (userToUpdate == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String fullName = ParamUtil.getString(request, "fullName", "");
        String email = ParamUtil.getString(request, "email", "");
        String phone = ParamUtil.getString(request, "phone", "");
        String currentPassword = ParamUtil.getString(request, "currentPassword", "");
        String newPassword = ParamUtil.getString(request, "newPassword", "");
        String confirmPassword = ParamUtil.getString(request, "confirmPassword", "");

        if (fullName.isEmpty() || email.isEmpty()) {
            request.setAttribute("error", "Họ tên và Email không được để trống!");
            doGet(request, response);
            return;
        }

        // Validate password change if requested
        if (!currentPassword.isEmpty() || !newPassword.isEmpty() || !confirmPassword.isEmpty()) {
            if (!userToUpdate.getPassword().equals(currentPassword)) {
                request.setAttribute("error", "Mật khẩu hiện tại không chính xác!");
                doGet(request, response);
                return;
            }
            if (newPassword.isEmpty()) {
                request.setAttribute("error", "Mật khẩu mới không được để trống!");
                doGet(request, response);
                return;
            }
            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
                doGet(request, response);
                return;
            }
            userToUpdate.setPassword(newPassword);
        }

        userToUpdate.setFullName(fullName);
        userToUpdate.setEmail(email);
        userToUpdate.setPhone(phone);

        boolean success = userDAO.updateUser(userToUpdate);
        if (success) {
            AuthUtil.setUser(request, userToUpdate); // Update session object
            request.setAttribute("success", "Cập nhật thông tin hồ sơ thành công!");
        } else {
            request.setAttribute("error", "Cập nhật thất bại. Email có thể đã được sử dụng!");
        }

        doGet(request, response);
    }
}