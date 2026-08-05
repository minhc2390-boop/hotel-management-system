package com.hotel.controller;

import com.hotel.dao.UserDAO;
import com.hotel.dao.BookingDAO;
import com.hotel.model.User;
import com.hotel.model.Booking;
import com.hotel.util.AuthUtil;
import com.hotel.util.ParamUtil;

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
    private final BookingDAO bookingDAO = new BookingDAO();

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
            case "guests": {
                List<com.hotel.model.Customer> customers = new com.hotel.dao.CustomerDAO().getAllCustomers();
                request.setAttribute("customers", customers);
                request.getRequestDispatcher("/admin/guests.jsp").forward(request, response);
                break;
            }
            case "guestDetail": {
                int guestId = Integer.parseInt(request.getParameter("id"));
                com.hotel.model.Customer guest = new com.hotel.dao.CustomerDAO().getCustomerById(guestId);
                List<Booking> guestBookings = bookingDAO.getBookingsByCustomerId(guestId);
                
                double guestSpent = 0;
                if (guestBookings != null) {
                    for (Booking b : guestBookings) {
                        if (!"Cancelled".equals(b.getStatus())) {
                            long diffMs = b.getCheckOutDate().getTime() - b.getCheckInDate().getTime();
                            long days = diffMs / (1000 * 60 * 60 * 24);
                            if (days <= 0) days = 1;
                            guestSpent += b.getRoomPrice() * days;
                        }
                    }
                }
                int guestPoints = (int) (guestSpent / 100000);
                
                request.setAttribute("guest", guest);
                request.setAttribute("bookings", guestBookings);
                request.setAttribute("spent", guestSpent);
                request.setAttribute("points", guestPoints);
                request.getRequestDispatcher("/admin/guest-profile.jsp").forward(request, response);
                break;
            }
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
        response.setCharacterEncoding("UTF-8");

        String action = ParamUtil.getString(request, "action", "");

        HttpSession session = request.getSession(false);
        User currentUser = AuthUtil.getUser(request);

        if (currentUser == null || (!"Admin".equalsIgnoreCase(currentUser.getRole()) && !"Receptionist".equalsIgnoreCase(currentUser.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        if ("insert".equals(action)) {
            String username = ParamUtil.getString(request, "username", "");
            String password = ParamUtil.getString(request, "password", "");
            String fullName = ParamUtil.getString(request, "fullName", "");
            String email = ParamUtil.getString(request, "email", "");
            String phone = ParamUtil.getString(request, "phone", "");
            String role = ParamUtil.getString(request, "role", "Customer");

            // Chỉ Admin mới được phân bổ quyền (gán vai trò bất kỳ), Lễ tân chỉ được tạo Khách hàng
            if (!"Admin".equalsIgnoreCase(currentUser.getRole())) {
                role = "Customer";
            }

            if (username.isEmpty() || password.isEmpty() || fullName.isEmpty() || email.isEmpty()) {
                request.setAttribute("error", "Vui lòng điền đầy đủ Tên đăng nhập, Mật khẩu, Họ tên và Email!");
                request.getRequestDispatcher("/admin/customer-form.jsp").forward(request, response);
                return;
            }

            // Check if username/email already exists
            User existingByUsername = userDAO.findByEmailOrUsername(username);
            User existingByEmail = userDAO.findByEmailOrUsername(email);
            if (existingByUsername != null || existingByEmail != null) {
                request.setAttribute("error", "Tên đăng nhập hoặc Email này đã tồn tại trong hệ thống!");
                User draftUser = new User(username, password, fullName, email, phone, role);
                request.setAttribute("user", draftUser);
                request.getRequestDispatcher("/admin/customer-form.jsp").forward(request, response);
                return;
            }

            User user = new User(username, password, fullName, email, phone, role);
            boolean success = userDAO.register(user);

            if (success) {
                if ("Admin".equalsIgnoreCase(currentUser.getRole()) && ("Admin".equalsIgnoreCase(role) || "Receptionist".equalsIgnoreCase(role))) {
                    response.sendRedirect(request.getContextPath() + "/users?action=employees");
                } else {
                    response.sendRedirect(request.getContextPath() + "/users?action=list");
                }
            } else {
                request.setAttribute("error", "Lưu tài khoản thất bại! Vui lòng thử lại.");
                User draftUser = new User(username, password, fullName, email, phone, role);
                request.setAttribute("user", draftUser);
                request.getRequestDispatcher("/admin/customer-form.jsp").forward(request, response);
            }

        } else if ("update".equals(action)) {
            int id = ParamUtil.getInt(request, "id", 0);
            User existingUser = userDAO.getUserById(id);
            if (existingUser != null) {
                String fullName = ParamUtil.getString(request, "fullName", "");
                String email = ParamUtil.getString(request, "email", "");
                String phone = ParamUtil.getString(request, "phone", "");
                String role = ParamUtil.getString(request, "role", "");
                String newPassword = ParamUtil.getString(request, "password", "");

                existingUser.setFullName(fullName);
                existingUser.setEmail(email);
                existingUser.setPhone(phone);
                
                // Chỉ Admin mới có quyền thay đổi vai trò (phân bổ quyền)
                if ("Admin".equalsIgnoreCase(currentUser.getRole())) {
                    if (role != null && !role.isEmpty()) {
                        existingUser.setRole(role);
                    }
                }
                
                if (newPassword != null && !newPassword.trim().isEmpty()) {
                    existingUser.setPassword(newPassword);
                }

                userDAO.updateUser(existingUser);
                
                if ("Admin".equalsIgnoreCase(currentUser.getRole()) && ("Admin".equalsIgnoreCase(existingUser.getRole()) || "Receptionist".equalsIgnoreCase(existingUser.getRole()))) {
                    response.sendRedirect(request.getContextPath() + "/users?action=employees");
                    return;
                }
            }
            response.sendRedirect(request.getContextPath() + "/users?action=list");
        }
    }
}
