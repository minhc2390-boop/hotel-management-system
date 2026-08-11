package com.hotel.util;

import com.hotel.model.User;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
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
    // Mã hóa chuỗi mật khẩu thô thành chuỗi băm SHA-256 (Hex 64 ký tự)
    public static String hashPassword(String rawPassword) {
        if (rawPassword == null || rawPassword.trim().isEmpty()) {
            return "";
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(rawPassword.getBytes(StandardCharsets.UTF_8));
            
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return rawPassword;
        }
    }

    // Kiểm tra mật khẩu thô khi nhập vào có khớp với mật khẩu đã mã hóa hay không
    public static boolean verifyPassword(String rawPassword, String hashedPassword) {
        if (rawPassword == null || hashedPassword == null) {
            return false;
        }
        String hashedInput = hashPassword(rawPassword);
        // Kiểm tra khớp hash hoặc khớp chuỗi thô (Hỗ trợ tài khoản cũ chưa mã hóa)
        return hashedInput.equalsIgnoreCase(hashedPassword) || rawPassword.equals(hashedPassword);
    }
}
