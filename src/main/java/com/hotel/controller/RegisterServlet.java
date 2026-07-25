package com.hotel.controller;

import com.hotel.dao.UserDAO;
import com.hotel.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        // Keep values in case of error
        request.setAttribute("regUsername", username);
        request.setAttribute("regFullName", fullName);
        request.setAttribute("regEmail", email);
        request.setAttribute("regPhone", phone);

        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            fullName == null || fullName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ các thông tin bắt buộc!");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Check if username/email already exists by fetching users or trying to save
        User user = new User(username, password, fullName, email, phone, "Customer");
        boolean success = userDAO.register(user);

        if (success) {
            request.setAttribute("success", "Đăng ký thành công tài khoản hội viên Nestora Club! Vui lòng đăng nhập.");
            request.setAttribute("activeTab", "login");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Đăng ký thất bại! Tên đăng nhập hoặc Email có thể đã tồn tại.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}
