package com.hotel.util;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailUtil {

    // Cấu hình SMTP mặc định (Ví dụ: Gmail SMTP)
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587"; // TLS Port
    private static final String SENDER_EMAIL = "nestora.hotel.resort@gmail.com"; // Email gửi
    private static final String SENDER_PASSWORD = "your-app-password"; // App Password (Mật khẩu ứng dụng)

    /**
     * Gửi email khôi phục mật khẩu chứa link reset password.
     * @param toEmail Email người nhận
     * @param resetLink Đăng link khôi phục mật khẩu (chứa token)
     * @return true nếu gửi thành công, false nếu có lỗi (hoặc chạy trong môi trường demo/offline)
     */
    public static boolean sendResetPasswordEmail(String toEmail, String resetLink) {
        String subject = "[Nestora Hotel] Yêu cầu khôi phục mật khẩu";
        String content = "<div style=\"font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: 0 auto; padding: 25px; border: 1px solid #e2e8f0; border-radius: 12px; background-color: #ffffff;\">"
                + "<div style=\"text-align: center; margin-bottom: 25px;\">"
                + "<h2 style=\"color: #17233c; margin: 0;\">NESTORA HOTEL & RESORT</h2>"
                + "<p style=\"color: #1769e0; font-weight: bold; font-size: 12px; letter-spacing: 2px; margin-top: 5px;\">KHÔI PHỤC MẬT KHẨU</p>"
                + "</div>"
                + "<hr style=\"border: none; border-top: 1px solid #edf2f7; margin: 20px 0;\">"
                + "<p style=\"font-size: 15px; color: #334155; line-height: 1.6;\">Xin chào,</p>"
                + "<p style=\"font-size: 15px; color: #334155; line-height: 1.6;\">Chúng tôi nhận được yêu cầu khôi phục mật khẩu cho tài khoản liên kết với email này. Vui lòng bấm vào nút bên dưới để tiến hành đặt lại mật khẩu mới:</p>"
                + "<div style=\"text-align: center; margin: 30px 0;\">"
                + "<a href=\"" + resetLink + "\" style=\"display: inline-block; padding: 12px 28px; background-color: #1769e0; color: #ffffff; text-decoration: none; font-weight: 600; font-size: 15px; border-radius: 8px; box-shadow: 0 4px 12px rgba(23, 105, 224, 0.3);\">Khôi Phục Mật Khẩu</a>"
                + "</div>"
                + "<p style=\"font-size: 13px; color: #64748b; line-height: 1.5;\">⚠️ <strong>Lưu ý:</strong> Liên kết này chỉ có hiệu lực trong vòng <strong>15 phút</strong>. Nếu bạn không gửi yêu cầu này, vui lòng bỏ qua email này.</p>"
                + "<p style=\"font-size: 13px; color: #94a3b8; word-break: break-all; margin-top: 15px;\">Hoặc copy đường dẫn sau dán vào trình duyệt: <br><a href=\"" + resetLink + "\" style=\"color: #1769e0;\">" + resetLink + "</a></p>"
                + "<hr style=\"border: none; border-top: 1px solid #edf2f7; margin: 25px 0;\">"
                + "<p style=\"font-size: 12px; color: #94a3b8; text-align: center; margin: 0;\">© 2026 Nestora Hotel & Resort. All rights reserved.</p>"
                + "</div>";

        return sendEmail(toEmail, subject, content);
    }

    /**
     * Gửi Email HTML qua JavaMail API.
     */
    public static boolean sendEmail(String recipientEmail, String subject, String htmlBody) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL, "Nestora Hotel & Resort"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject(subject);
            message.setContent(htmlBody, "text/html; charset=UTF-8");

            Transport.send(message);
            System.out.println("[EmailUtil] Đã gửi thành công email tới: " + recipientEmail);
            return true;
        } catch (Exception e) {
            System.err.println("[EmailUtil] Gửi email thất bại (Chế độ phát triển / Chưa cấu hình SMTP App Password): " + e.getMessage());
            // Log mô phỏng link reset password ra console cho môi trường thử nghiệm
            return false;
        }
    }
}
