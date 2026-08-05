package com.hotel.util;

import javax.servlet.http.HttpServletRequest;

public class ParamUtil {

    /**
     * Lấy giá trị chuỗi từ request parameter. Trả về defaultValue nếu rỗng hoặc null.
     */
    public static String getString(HttpServletRequest request, String name, String defaultValue) {
        String val = request.getParameter(name);
        if (val == null || val.trim().isEmpty()) {
            return defaultValue;
        }
        String str = val.trim();
        try {
            if (str.contains("Ã") || str.contains("Â") || str.contains("áº") || str.contains("á»") || str.contains("Æ°") || str.contains("Ä‘")) {
                byte[] bytes = str.getBytes("ISO-8859-1");
                String decoded = new String(bytes, "UTF-8");
                if (!decoded.contains("ï¿½") && !decoded.contains("\uFFFD")) {
                    return decoded;
                }
            }
        } catch (Exception e) {}
        return str;
    }

    /**
     * Lấy giá trị số nguyên từ request parameter. Trả về defaultValue nếu lỗi định dạng hoặc null.
     */
    public static int getInt(HttpServletRequest request, String name, int defaultValue) {
        String val = request.getParameter(name);
        if (val == null || val.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /**
     * Lấy giá trị boolean từ request parameter.
     */
    public static boolean getBoolean(HttpServletRequest request, String name, boolean defaultValue) {
        String val = request.getParameter(name);
        if (val == null || val.trim().isEmpty()) {
            return defaultValue;
        }
        return Boolean.parseBoolean(val.trim());
    }

    /**
     * Lấy giá trị số thực double từ request parameter. Trả về defaultValue nếu lỗi định dạng hoặc null.
     */
    public static double getDouble(HttpServletRequest request, String name, double defaultValue) {
        String val = request.getParameter(name);
        if (val == null || val.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Double.parseDouble(val.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
