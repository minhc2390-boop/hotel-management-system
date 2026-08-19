package com.hotel.util;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

/**
 * Utility hỗ trợ gửi email qua Gmail SMTP (JavaMail API)
 */
public class EmailUtil {

    private static String smtpHost = "smtp.gmail.com";
    private static String smtpPort = "587";
    private static String senderEmail = "nestora.hotel.resort@gmail.com";
    private static String senderPassword = "your-app-password";
    private static String senderName = "Nestora Hotel & Resort";
    private static boolean starttlsEnable = true;
    private static boolean authEnable = true;

    static {
        loadEmailConfig();
    }

    /**
     * Nạp thông tin cấu hình từ file email.properties trong classpath
     */
    public static void loadEmailConfig() {
        try (InputStream input = EmailUtil.class.getClassLoader().getResourceAsStream("email.properties")) {
            if (input != null) {
                Properties prop = new Properties();
                prop.load(input);

                if (prop.getProperty("mail.smtp.host") != null) {
                    smtpHost = prop.getProperty("mail.smtp.host").trim();
                }
                if (prop.getProperty("mail.smtp.port") != null) {
                    smtpPort = prop.getProperty("mail.smtp.port").trim();
                }
                if (prop.getProperty("mail.sender.email") != null) {
                    senderEmail = prop.getProperty("mail.sender.email").trim();
                }
                if (prop.getProperty("mail.sender.password") != null) {
                    // Loại bỏ khoảng trắng thường gặp khi copy từ Google (ví dụ: "abcd efgh ijkl mnop")
                    senderPassword = prop.getProperty("mail.sender.password").replaceAll("\\s+", "").trim();
                }
                if (prop.getProperty("mail.sender.name") != null) {
                    senderName = prop.getProperty("mail.sender.name").trim();
                }
                if (prop.getProperty("mail.smtp.starttls.enable") != null) {
                    starttlsEnable = Boolean.parseBoolean(prop.getProperty("mail.smtp.starttls.enable").trim());
                }
                if (prop.getProperty("mail.smtp.auth") != null) {
                    authEnable = Boolean.parseBoolean(prop.getProperty("mail.smtp.auth").trim());
                }

                System.out.println("[EmailUtil] Đã tải cấu hình Email từ email.properties thành công (Email: " + senderEmail + ")");
            } else {
                System.out.println("[EmailUtil] Không tìm thấy email.properties, sử dụng cấu hình mặc định.");
            }
        } catch (Exception e) {
            System.err.println("[EmailUtil] Lỗi khi nạp email.properties: " + e.getMessage());
        }
    }

    /**
     * Gửi email khôi phục mật khẩu chứa link reset password.
     * @param toEmail Email người nhận
     * @param resetLink Đường link khôi phục mật khẩu (chứa token xác thực)
     * @return true nếu gửi thành công, false nếu có lỗi
     */
    public static boolean sendResetPasswordEmail(String toEmail, String resetLink) {
        String subject = "[Nestora Hotel] Yêu cầu khôi phục mật khẩu tài khoản";
        
        String content = "<div style=\"font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: 0 auto; padding: 30px 25px; border: 1px solid #e2e8f0; border-radius: 16px; background-color: #ffffff;\">"
                + "<div style=\"text-align: center; margin-bottom: 25px;\">"
                + "  <div style=\"display: inline-block; width: 46px; height: 46px; line-height: 46px; background-color: #1769e0; color: #ffffff; font-size: 22px; font-weight: bold; border-radius: 12px; margin-bottom: 10px;\">N</div>"
                + "  <h2 style=\"color: #17233c; margin: 0 0 5px 0; font-size: 22px; font-weight: 700; letter-spacing: 0.5px;\">NESTORA HOTEL &amp; RESORT</h2>"
                + "  <p style=\"color: #1769e0; font-weight: 700; font-size: 11px; letter-spacing: 2.5px; margin: 0; text-transform: uppercase;\">Khôi phục mật khẩu</p>"
                + "</div>"
                + "<hr style=\"border: none; border-top: 1px solid #edf2f7; margin: 20px 0;\">"
                + "<p style=\"font-size: 15px; color: #334155; line-height: 1.6; margin-bottom: 10px;\">Xin chào quý khách,</p>"
                + "<p style=\"font-size: 15px; color: #334155; line-height: 1.6;\">Hệ thống nhận được yêu cầu đặt lại mật khẩu cho tài khoản liên kết với địa chỉ email: <strong>" + toEmail + "</strong>.</p>"
                + "<p style=\"font-size: 15px; color: #334155; line-height: 1.6;\">Vui lòng nhấp vào nút xác nhận bên dưới để tạo mật khẩu mới:</p>"
                + "<div style=\"text-align: center; margin: 32px 0;\">"
                + "  <a href=\"" + resetLink + "\" target=\"_blank\" style=\"display: inline-block; padding: 13px 32px; background-color: #1769e0; color: #ffffff; text-decoration: none; font-weight: 600; font-size: 15px; border-radius: 8px; box-shadow: 0 4px 14px rgba(23, 105, 224, 0.35);\">ĐẶT LẠI MẬT KHẨU</a>"
                + "</div>"
                + "<div style=\"background-color: #f8fafc; border-left: 4px solid #1769e0; padding: 12px 16px; border-radius: 4px; margin: 20px 0;\">"
                + "  <p style=\"font-size: 13px; color: #475569; margin: 0; line-height: 1.5;\">⚠️ <strong>Lưu ý bảo mật:</strong></p>"
                + "  <p style=\"font-size: 13px; color: #64748b; margin: 4px 0 0 0; line-height: 1.5;\">• Liên kết có hiệu lực trong vòng <strong>15 phút</strong>.<br>• Nếu quý khách không thực hiện yêu cầu này, vui lòng bỏ qua thư này, tài khoản của bạn vẫn an toàn.</p>"
                + "</div>"
                + "<p style=\"font-size: 12px; color: #94a3b8; word-break: break-all; margin-top: 20px;\">Nếu không bấm được nút trên, hãy copy đường dẫn sau dán vào trình duyệt: <br><a href=\"" + resetLink + "\" style=\"color: #1769e0;\">" + resetLink + "</a></p>"
                + "<hr style=\"border: none; border-top: 1px solid #edf2f7; margin: 25px 0 15px 0;\">"
                + "<p style=\"font-size: 12px; color: #94a3b8; text-align: center; margin: 0;\">© 2026 Nestora Hotel & Resort. Mọi quyền được bảo lưu.</p>"
                + "</div>";

        return sendEmail(toEmail, subject, content);
    }

    /**
     * Gửi Email HTML qua JavaMail API sử dụng Gmail SMTP
     */
    public static boolean sendEmail(String recipientEmail, String subject, String htmlBody) {
        // Tải lại cấu hình mới nhất nếu có thay đổi
        loadEmailConfig();

        // Kiểm tra xem đã cấu hình mật khẩu thực tế chưa
        if (senderPassword == null || senderPassword.isEmpty() || "your-app-password".equalsIgnoreCase(senderPassword) || "your-16-char-app-password".equalsIgnoreCase(senderPassword)) {
            System.err.println("[EmailUtil] LỖI: Chưa cấu hình Mật khẩu ứng dụng (App Password) trong email.properties!");
            System.err.println("[EmailUtil] Vui lòng mở file src/main/resources/email.properties để điền Gmail và App Password 16 ký tự.");
            return false;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);
        props.put("mail.smtp.auth", String.valueOf(authEnable));
        props.put("mail.smtp.starttls.enable", String.valueOf(starttlsEnable));
        props.put("mail.smtp.starttls.required", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        props.put("mail.smtp.ssl.trust", smtpHost);

        // Timeout (10 giây) tránh treo luồng
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");
        props.put("mail.smtp.writetimeout", "10000");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(senderEmail, senderPassword);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(senderEmail, senderName, StandardCharsets.UTF_8.name()));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject(subject);
            message.setContent(htmlBody, "text/html; charset=UTF-8");

            Transport.send(message);
            System.out.println("[EmailUtil] => ĐÃ GỬI THÀNH CÔNG EMAIL TỚI: " + recipientEmail);
            return true;
        } catch (AuthenticationFailedException afe) {
            System.err.println("[EmailUtil] LỖI XÁC THỰC GMAIL (AuthenticationFailedException): Sai tài khoản Gmail hoặc Mật khẩu ứng dụng (App Password).");
            System.err.println("[EmailUtil] Chi tiết: " + afe.getMessage());
            return false;
        } catch (MessagingException me) {
            System.err.println("[EmailUtil] LỖI GỬI EMAIL (MessagingException): " + me.getMessage());
            me.printStackTrace();
            return false;
        } catch (Exception e) {
            System.err.println("[EmailUtil] LỖI KHÔNG XÁC ĐỊNH KHI GỬI EMAIL: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
