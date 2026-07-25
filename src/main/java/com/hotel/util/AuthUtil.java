package com.hotel.util;

import com.hotel.model.User;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

public class AuthUtil {

    private static final String USER_SESSION_KEY = "currentUser";

    /**
     * Lưu thông tin người dùng vào session sau khi đăng nhập thành công.
     */
    public static void setUser(HttpServletRequest request, User user) {
        HttpSession session = request.getSession(true);
        session.setAttribute(USER_SESSION_KEY, user);
    }

    /**
     * Lấy thông tin người dùng hiện tại từ session.
     */
    public static User getUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (User) session.getAttribute(USER_SESSION_KEY);
        }
        return null;
    }

    /**
     * Kiểm tra xem người dùng đã đăng nhập hay chưa.
     */
    public static boolean isAuthenticated(HttpServletRequest request) {
        return getUser(request) != null;
    }

    /**
     * Kiểm tra xem người dùng có quyền quản lý (Admin) hay không.
     */
    public static boolean isManager(HttpServletRequest request) {
        User user = getUser(request);
        return user != null && "Admin".equalsIgnoreCase(user.getRole());
    }

    /**
     * Đăng xuất và xóa sạch session của người dùng.
     */
    public static void clear(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.removeAttribute(USER_SESSION_KEY);
            session.invalidate();
        }
    }
}
