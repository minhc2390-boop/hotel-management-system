package com.hotel.controller;

import com.hotel.dao.UserDAO;
import com.hotel.model.User;
import com.hotel.util.AuthUtil;
import com.hotel.util.ParamUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "AuthServlet", urlPatterns = {"/login", "/logout"})
public class AuthServlet extends HttpServlet {
    
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        
        if ("/logout".equals(path)) {
            AuthUtil.clear(request);
            response.sendRedirect(request.getContextPath() + "/login");
        } else {
            // Check if user is already logged in
            if (AuthUtil.isAuthenticated(request)) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String loginKey = ParamUtil.getString(request, "email", "");
        if (loginKey.isEmpty()) {
            loginKey = ParamUtil.getString(request, "username", "");
        }
        String password = ParamUtil.getString(request, "password", "");

        if (loginKey.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập Email/Tên đăng nhập và Mật khẩu!");
            request.setAttribute("email", loginKey);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.login(loginKey, password);
        
        if (user != null) {
            AuthUtil.setUser(request, user);
            response.sendRedirect(request.getContextPath() + "/home");
        } else {
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            request.setAttribute("email", loginKey);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
