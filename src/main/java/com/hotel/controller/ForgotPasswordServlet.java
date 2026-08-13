package com.hotel.controller;

import com.hotel.dao.UserDAO;
import com.hotel.model.User;
import com.hotel.util.EmailUtil;
import com.hotel.util.ParamUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password", "/reset-password"})
public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    // Dữ liệu Lưu trữ Token khôi phục mật khẩu trong bộ nhớ đệm
    public static class ResetTokenData {
        private final String email;
        private final long expiryTime; // Thời điểm hết hạn (ms)

        public ResetTokenData(String email, long expiryTime) {
            this.email = email;
            this.expiryTime = expiryTime;
        }

        public String getEmail() {
            return email;
        }

        public boolean isExpired() {
            return System.currentTimeMillis() > expiryTime;
        }
    }

    // Map chứa danh sách các Token active: Token -> ResetTokenData
    private static final Map<String, ResetTokenData> tokenStore = new ConcurrentHashMap<>();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/reset-password".equals(path)) {
            String token = ParamUtil.getString(request, "token", "");
            if (token.isEmpty()) {
                request.setAttribute("error", "Mã khôi phục không hợp lệ hoặc không tồn tại!");
                request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
                return;
            }

            ResetTokenData tokenData = tokenStore.get(token);
            if (tokenData == null || tokenData.isExpired()) {
                if (tokenData != null && tokenData.isExpired()) {
                    tokenStore.remove(token);
                }
                request.setAttribute("error", "Liên kết khôi phục mật khẩu đã hết hạn (sau 15 phút) hoặc không hợp lệ. Vui lòng gửi lại yêu cầu!");
                request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
                return;
            }

            request.setAttribute("token", token);
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
        } else {
            // Path: /forgot-password
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();

        if ("/reset-password".equals(path)) {
            handleResetPassword(request, response);
        } else {
            handleForgotPassword(request, response);
        }
    }

    private void handleForgotPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = ParamUtil.getString(request, "email", "");

        if (email.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập địa chỉ Email của bạn!");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        User user = userDAO.findByEmail(email);
        if (user == null) {
            request.setAttribute("error", "Email này chưa được đăng ký trong hệ thống!");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        // Tạo token ngẫu nhiên và cấu hình hết hạn sau 15 phút (15 * 60 * 1000 ms)
        String token = UUID.randomUUID().toString();
        long expiryTime = System.currentTimeMillis() + (15 * 60 * 1000);
        tokenStore.put(token, new ResetTokenData(user.getEmail(), expiryTime));

        // Xây dựng link khôi phục mật khẩu đầy đủ
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();

        String domain;
        if (("http".equals(scheme) && serverPort == 80) || ("https".equals(scheme) && serverPort == 443)) {
            domain = scheme + "://" + serverName + contextPath;
        } else {
            domain = scheme + "://" + serverName + ":" + serverPort + contextPath;
        }

        String resetLink = domain + "/reset-password?token=" + token;

        // Gửi email khôi phục mật khẩu qua JavaMail API
        boolean emailSent = EmailUtil.sendResetPasswordEmail(user.getEmail(), resetLink);

        if (emailSent) {
            request.setAttribute("success", "Đã gửi hướng dẫn khôi phục mật khẩu tới email " + user.getEmail() + ". Vui lòng kiểm tra hộp thư (liên kết có hiệu lực 15 phút)!");
        } else {
            // Hỗ trợ hiển thị link cho môi trường thử nghiệm/dev khi chưa cài đặt App Password Gmail
            request.setAttribute("success", "Yêu cầu khôi phục thành công! (Môi trường Dev: <a href='" + resetLink + "'>Link đặt lại mật khẩu</a>)");
        }

        request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
    }

    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = ParamUtil.getString(request, "token", "");
        String newPassword = ParamUtil.getString(request, "newPassword", "");
        String confirmPassword = ParamUtil.getString(request, "confirmPassword", "");

        if (token.isEmpty()) {
            request.setAttribute("error", "Mã khôi phục không hợp lệ!");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        ResetTokenData tokenData = tokenStore.get(token);
        if (tokenData == null || tokenData.isExpired()) {
            if (tokenData != null && tokenData.isExpired()) {
                tokenStore.remove(token);
            }
            request.setAttribute("error", "Liên kết khôi phục mật khẩu đã hết hạn hoặc không tồn tại!");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        if (newPassword.isEmpty() || confirmPassword.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập mật khẩu mới và xác nhận mật khẩu!");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không trùng khớp!");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }

        if (newPassword.length() < 6) {
            request.setAttribute("error", "Mật khẩu mới phải chứa ít nhất 6 ký tự!");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }

        // Lấy thông tin user và cập nhật mật khẩu mới (UserDAO.updateUser sẽ tự động mã hóa băm mật khẩu)
        User user = userDAO.findByEmail(tokenData.getEmail());
        if (user != null) {
            user.setPassword(newPassword);
            boolean updated = userDAO.updateUser(user);
            if (updated) {
                // Xóa token sau khi đổi mật khẩu thành công
                tokenStore.remove(token);

                request.setAttribute("success", "Đặt lại mật khẩu thành công! Vui lòng đăng nhập bằng mật khẩu mới.");
                request.setAttribute("activeTab", "login");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
        }

        request.setAttribute("error", "Có lỗi xảy ra trong quá trình cập nhật mật khẩu. Vui lòng thử lại!");
        request.setAttribute("token", token);
        request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
    }
}
