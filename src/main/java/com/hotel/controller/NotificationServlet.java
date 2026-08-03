package com.hotel.controller;

import com.hotel.dao.NotificationDAO;
import com.hotel.model.HotelNotification;
import com.hotel.model.User;
import com.hotel.util.AuthUtil;
import com.hotel.util.ParamUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet(name = "NotificationServlet", urlPatterns = {"/admin/notifications", "/notifications"})
public class NotificationServlet extends HttpServlet {

    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminOrManager(request)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String action = ParamUtil.getString(request, "action", "list");

        switch (action) {
            case "list":
                List<HotelNotification> notifications = notificationDAO.getAllNotifications();
                request.setAttribute("notifications", notifications);
                request.getRequestDispatcher("/admin/notification-list.jsp").forward(request, response);
                break;
            case "add":
                if (!isAdmin(request)) {
                    response.sendRedirect(request.getContextPath() + "/admin/notifications?action=list&denied=1");
                    return;
                }
                request.setAttribute("notification", new HotelNotification());
                request.setAttribute("isEdit", false);
                request.getRequestDispatcher("/admin/notification-form.jsp").forward(request, response);
                break;
            case "edit":
                if (!isAdmin(request)) {
                    response.sendRedirect(request.getContextPath() + "/admin/notifications?action=list&denied=1");
                    return;
                }
                int id = ParamUtil.getInt(request, "id", 0);
                HotelNotification item = notificationDAO.getById(id);
                if (item == null) {
                    response.sendRedirect(request.getContextPath() + "/admin/notifications?action=list");
                    return;
                }
                request.setAttribute("notification", item);
                request.setAttribute("isEdit", true);
                request.getRequestDispatcher("/admin/notification-form.jsp").forward(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/notifications?action=list");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/admin/notifications?action=list&denied=1");
            return;
        }

        String action = ParamUtil.getString(request, "action", "");

        if ("delete".equals(action)) {
            int id = ParamUtil.getInt(request, "id", 0);
            notificationDAO.delete(id);
            response.sendRedirect(request.getContextPath() + "/admin/notifications?action=list&deleted=1");
            return;
        }

        int id = ParamUtil.getInt(request, "id", 0);
        HotelNotification item = (id > 0) ? notificationDAO.getById(id) : new HotelNotification();
        if (item == null) {
            item = new HotelNotification();
        }

        User currentUser = AuthUtil.getUser(request);
        String title = ParamUtil.getString(request, "title", "");
        String content = ParamUtil.getString(request, "content", "");
        String type = ParamUtil.getString(request, "type", "INFO");
        boolean isActive = "on".equalsIgnoreCase(request.getParameter("isActive"))
                || "true".equalsIgnoreCase(request.getParameter("isActive"))
                || "1".equals(request.getParameter("isActive"));

        item.setTitle(title);
        item.setContent(content);
        item.setType(type);
        item.setIsActive(isActive);

        if (id == 0 && currentUser != null) {
            item.setCreatedBy(currentUser.getId());
            item.setCreatedAt(LocalDateTime.now());
        }

        String error = validate(item);
        if (error != null) {
            request.setAttribute("notification", item);
            request.setAttribute("isEdit", id > 0);
            request.setAttribute("error", error);
            request.getRequestDispatcher("/admin/notification-form.jsp").forward(request, response);
            return;
        }

        boolean success;
        if ("insert".equals(action) || id == 0) {
            success = notificationDAO.insert(item);
        } else {
            success = notificationDAO.update(item);
        }

        if (!success) {
            request.setAttribute("notification", item);
            request.setAttribute("isEdit", id > 0);
            request.setAttribute("error", "Không thể lưu thông báo. Vui lòng thử lại.");
            request.getRequestDispatcher("/admin/notification-form.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/notifications?action=list&saved=1");
    }

    private String validate(HotelNotification item) {
        if (item.getTitle() == null || item.getTitle().trim().isEmpty()) {
            return "Vui lòng nhập tiêu đề thông báo.";
        }
        if (item.getTitle().length() > 200) {
            return "Tiêu đề không được vượt quá 200 ký tự.";
        }
        if (item.getContent() == null || item.getContent().trim().isEmpty()) {
            return "Vui lòng nhập nội dung thông báo.";
        }
        if (!"INFO".equals(item.getType()) && !"WARNING".equals(item.getType()) &&
            !"SUCCESS".equals(item.getType()) && !"ERROR".equals(item.getType())) {
            return "Loại thông báo không hợp lệ (Phải là INFO, WARNING, SUCCESS, hoặc ERROR).";
        }
        return null;
    }    private boolean isAdmin(HttpServletRequest request) {
        User user = AuthUtil.getUser(request);
        return user != null && "Admin".equalsIgnoreCase(user.getRole());
    }



    private boolean isAdminOrManager(HttpServletRequest request) {
        User user = AuthUtil.getUser(request);
        return user != null && ("Admin".equalsIgnoreCase(user.getRole()) || "Receptionist".equalsIgnoreCase(user.getRole()));
    }
}

