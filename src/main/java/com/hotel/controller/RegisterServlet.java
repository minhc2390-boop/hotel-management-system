package com.hotel.controller;

import com.hotel.dao.UserDAO;
import com.hotel.model.User;
import com.hotel.util.ParamUtil;

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
        request.setAttribute("activeTab", "register");
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String username = ParamUtil.getString(request, "username", "");
        String password = ParamUtil.getString(request, "password", "");
        String confirmPassword = ParamUtil.getString(request, "confirmPassword", "");
        String fullName = ParamUtil.getString(request, "fullName", "");
        String email = ParamUtil.getString(request, "email", "");
        String phone = ParamUtil.getString(request, "phone", "");

        // Keep values in case of error
        request.setAttribute("regUsername", username);
        request.setAttribute("regFullName", fullName);
        request.setAttribute("regEmail", email);
        request.setAttribute("regPhone", phone);
        request.setAttribute("activeTab", "register");

        if (username.isEmpty() || password.isEmpty() || fullName.isEmpty() || email.isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ Họ tên, Tên đăng nhập, Email và Mật khẩu!");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        // Check if username/email already exists
        if (userDAO.findByEmailOrUsername(username) != null || userDAO.findByEmailOrUsername(email) != null) {
            request.setAttribute("error", "Tên đăng nhập hoặc Email này đã tồn tại trong hệ thống!");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        User user = new User(username, password, fullName, email, phone, "Customer");
        boolean success = userDAO.register(user);

        if (success) {
            try {
                com.hotel.dao.CustomerDAO customerDAO = new com.hotel.dao.CustomerDAO();
                customerDAO.findOrCreateCustomer(fullName, phone, email, null, user);
            } catch (Exception e) {
                e.printStackTrace();
            }
            request.setAttribute("success", "Đăng ký tài khoản thành công! Vui lòng đăng nhập bằng tài khoản vừa tạo.");
            request.setAttribute("activeTab", "login");
            request.setAttribute("email", username);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Đăng ký thất bại! Vui lòng kiểm tra lại thông tin.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
