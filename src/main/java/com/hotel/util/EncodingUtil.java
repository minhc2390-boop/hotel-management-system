package com.hotel.util;

import java.nio.charset.StandardCharsets;

/**
 * Tiện ích tự động nhận diện và khôi phục ký tự Tiếng Việt (chống lỗi vỡ font / Mojibake)
 * cho toàn bộ Database, Web form input và hiển thị giao diện.
 */
public class EncodingUtil {

    private static final String[] MOJIBAKE_PATTERNS = {
        "\u00C3\u00A1", "\u00C3\u00A0", "\u00C3\u00A3", "\u00C3\u00A2", "\u00C3\u00A9", "\u00C3\u00A8", "\u00C3\u00AA",
        "\u00C3\u00AD", "\u00C3\u00AC", "\u00C3\u00B3", "\u00C3\u00B2", "\u00C3\u00B4", "\u00C3\u00B5", "\u00C3\u00B9",
        "\u00C3\u00BA", "\u00C3\u00BD", "\u00E1\u00BA", "\u00E1\u00BB", "\u00C4\u2018", "\u00C4\u0110", "\u00C4\u0091",
        "\u00C4\u0192", "\u00C4\u0083", "\u00C6\u00B0", "\u00C6\u00A1", "\u00C3\u20AC", "\u00C3\u0081", "\u00C3\u201A",
        "\u00C3\u0192", "\u00C3\u02C6", "\u00C3\u2030", "\u00C3\u0160", "\u00C3\u0152", "\u00C3\u008D", "\u00C3\u2019",
        "\u00C3\u201C", "\u00C3\u201D", "\u00C3\u2122", "\u00C3\u0161", "\u00C3\u009D", "\u00E2\u20AC",
        "áº", "á»", "Ä‘", "Äƒ", "Æ°", "Æ¡", "Ã¡", "Ã ", "Ã£", "Ã¢", "Ã©", "Ã¨", "Ãª", "Ã­", "Ã¬", "Ã³", "Ã²", "Ã´", "Ã¹", "Ãº", "Ã½"
    };

    /**
     * Chuyển ký tự từ dạng giải mã Windows-1252 / ISO-8859-1 trở về đúng byte gốc UTF-8.
     */
    public static byte charToByte(char c) {
        if (c <= 0xFF) {
            return (byte) c;
        }
        switch (c) {
            case '\u20AC': return (byte) 0x80;
            case '\u201A': return (byte) 0x82;
            case '\u0192': return (byte) 0x83;
            case '\u201E': return (byte) 0x84;
            case '\u2026': return (byte) 0x85;
            case '\u2020': return (byte) 0x86;
            case '\u2021': return (byte) 0x87;
            case '\u02C6': return (byte) 0x88;
            case '\u2030': return (byte) 0x89;
            case '\u0160': return (byte) 0x8A;
            case '\u2039': return (byte) 0x8B;
            case '\u0152': return (byte) 0x8C;
            case '\u017D': return (byte) 0x8E;
            case '\u2018': return (byte) 0x91;
            case '\u2019': return (byte) 0x92;
            case '\u201C': return (byte) 0x93;
            case '\u201D': return (byte) 0x94;
            case '\u2022': return (byte) 0x95;
            case '\u2013': return (byte) 0x96;
            case '\u2014': return (byte) 0x97;
            case '\u02DC': return (byte) 0x98;
            case '\u2122': return (byte) 0x99;
            case '\u0161': return (byte) 0x9A;
            case '\u203A': return (byte) 0x9B;
            case '\u0153': return (byte) 0x9C;
            case '\u017E': return (byte) 0x9E;
            case '\u0178': return (byte) 0x9F;
            default: return (byte) (c & 0xFF);
        }
    }

    /**
     * Kiểm tra chuỗi có chứa mẫu ký tự lỗi Mojibake hay không.
     */
    public static boolean hasMojibake(String s) {
        if (s == null || s.isEmpty()) return false;
        for (String pattern : MOJIBAKE_PATTERNS) {
            if (s.contains(pattern)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Tự động sửa lỗi Tiếng Việt nếu chuỗi bị vỡ mã / Mojibake.
     * Nếu chuỗi đã chuẩn Unicode thì giữ nguyên không đổi.
     */
    public static String fixEncoding(String str) {
        if (str == null || str.trim().isEmpty()) {
            return str == null ? "" : str;
        }

        String s = str.trim();

        // Xử lý nhiều tầng nếu bị double-encoding
        int maxPasses = 2;
        while (hasMojibake(s) && maxPasses-- > 0) {
            try {
                byte[] bytes = new byte[s.length()];
                for (int i = 0; i < s.length(); i++) {
                    bytes[i] = charToByte(s.charAt(i));
                }
                String decoded = new String(bytes, StandardCharsets.UTF_8);
                if (!decoded.contains("\uFFFD")) {
                    s = decoded;
                } else {
                    break;
                }
            } catch (Exception ignored) {
                break;
            }
        }

        return s;
    }
}
