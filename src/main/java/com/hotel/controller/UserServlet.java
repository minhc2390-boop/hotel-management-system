package com.hotel.controller;

import com.hotel.dao.UserDAO;
import com.hotel.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "UserServlet", urlPatterns = {"/users"})
public class UserServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        switch (action) {
            case "list":
                List<User> users = userDAO.getAllUsers();
                request.setAttribute("users", users);
                request.getRequestDispatcher("/admin/customers.jsp").forward(request, response);
                break;

            case "employees":
                if (!"Admin".equals(currentUser.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }
                List<User> allUsers = userDAO.getAllUsers();
                List<User> employees = new java.util.ArrayList<>();
                if (allUsers != null) {
                    for (User u : allUsers) {
                        if ("Admin".equals(u.getRole()) || "Receptionist".equals(u.getRole())) {
                            employees.add(u);
                        }
                    }
                }
                request.setAttribute("employees", employees);
                request.getRequestDispatcher("/admin/employees.jsp").forward(request, response);
                break;

            case "add":
                request.getRequestDispatcher("/admin/customer-form.jsp").forward(request, response);
                break;

            case "edit":
                int editId = Integer.parseInt(request.getParameter("id"));
                User userToEdit = userDAO.getUserById(editId);
                request.setAttribute("user", userToEdit);
                request.getRequestDispatcher("/admin/customer-form.jsp").forward(request, response);
                break;

            case "delete":
                if ("Admin".equals(currentUser.getRole())) {
                    int deleteId = Integer.parseInt(request.getParameter("id"));
                    userDAO.deleteUser(deleteId);
                }
                String referer = request.getHeader("referer");
                if (referer != null && referer.contains("action=employees")) {
                    response.sendRedirect(request.getContextPath() + "/users?action=employees");
                } else {
                    response.sendRedirect(request.getContextPath() + "/users?action=list");
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/users?action=list");
                break;
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
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        if ("insert".equals(action)) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String role = request.getParameter("role");

            // Chỉ Admin mới được phân bổ quyền (gán vai trò bất kỳ), Lễ tân chỉ được tạo Khách hàng
            if (currentUser == null || !"Admin".equals(currentUser.getRole())) {
                role = "Customer";
            } else if (role == null || role.isEmpty()) {
                role = "Customer";
            }

            User user = new User(username, password, fullName, email, phone, role);
            userDAO.register(user);
            
            if ("Admin".equals(currentUser.getRole()) && ("Admin".equals(role) || "Receptionist".equals(role))) {
                response.sendRedirect(request.getContextPath() + "/users?action=employees");
            } else {
                response.sendRedirect(request.getContextPath() + "/users?action=list");
            }

        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            User existingUser = userDAO.getUserById(id);
            if (existingUser != null) {
                String fullName = request.getParameter("fullName");
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String role = request.getParameter("role");
                String newPassword = request.getParameter("password");

                existingUser.setFullName(fullName);
                existingUser.setEmail(email);
                existingUser.setPhone(phone);
                
                // Chỉ Admin mới có quyền thay đổi vai trò (phân bổ quyền)
                if (currentUser != null && "Admin".equals(currentUser.getRole())) {
                    if (role != null && !role.isEmpty()) {
                        existingUser.setRole(role);
                    }
                }
                
                if (newPassword != null && !newPassword.trim().isEmpty()) {
                    existingUser.setPassword(newPassword);
                }

                userDAO.updateUser(existingUser);
                
                if ("Admin".equals(currentUser.getRole()) && ("Admin".equals(existingUser.getRole()) || "Receptionist".equals(existingUser.getRole()))) {
                    response.sendRedirect(request.getContextPath() + "/users?action=employees");
                    return;
                }
            }
            response.sendRedirect(request.getContextPath() + "/users?action=list");
        }
    }
}
