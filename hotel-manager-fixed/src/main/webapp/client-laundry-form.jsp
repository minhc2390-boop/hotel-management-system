<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Laundry" %>
<%
    HttpSession clientSession = request.getSession(false);
    User currentUser = (clientSession != null) ? (User) clientSession.getAttribute("currentUser") : null;
    Laundry laundry = (Laundry) request.getAttribute("laundry");
    if (laundry == null) laundry = new Laundry();
    if (currentUser != null && (laundry.getCustomerName() == null || laundry.getCustomerName().trim().isEmpty())) {
        laundry.setCustomerName(currentUser.getFullName());
    }
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt dịch vụ Giặt Ủi - Nestora Hotel</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .laundry-container {
            max-width: 720px;
            margin: 40px auto;
            padding: 30px;
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            border: 1px solid var(--line);
        }
        .laundry-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--navy);
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .laundry-subtitle {
            color: var(--muted);
            font-size: 14px;
            margin-bottom: 24px;
            line-height: 1.5;
        }
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        @media (max-width: 600px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
        }
        .form-group {
            margin-bottom: 18px;
        }
        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 6px;
            font-size: 13px;
            color: var(--text);
        }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 11px 14px;
            border: 1px solid var(--line);
            border-radius: 8px;
            background: #fff;
            color: var(--text);
            font-family: inherit;
            font-size: 14px;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color: var(--brand);
            outline: none;
            box-shadow: 0 0 0 3px var(--brand-soft);
        }
        .example-box {
            font-size: 12px;
            color: var(--muted);
            margin-top: 8px;
            background: #f8fafc;
            padding: 10px 14px;
            border-radius: 8px;
            border-left: 3px solid var(--brand);
            line-height: 1.6;
        }
        .alert-success {
            padding: 14px 18px;
            margin-bottom: 20px;
            background: #d4edda;
            color: #155724;
            border-radius: 8px;
            border: 1px solid #c3e6cb;
            font-weight: 600;
        }
        .alert-error {
            padding: 14px 18px;
            margin-bottom: 20px;
            background: #f8d7da;
            color: #721c24;
            border-radius: 8px;
            border: 1px solid #f5c6cb;
            font-weight: 600;
        }
    </style>
</head>
<body class="client-body">
<%@ include file="WEB-INF/jspf/client-header.jspf" %>

<main class="client-main">
    <div class="laundry-container">
        <div class="laundry-title">
            <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="var(--brand)" stroke-width="2">
                <circle cx="12" cy="12" r="10"/><path d="M8 12a4 4 0 1 0 8 0 4 4 0 1 0-8 0"/><path d="M12 12a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z"/>
            </svg>
            Tạo Đơn Dịch Vụ Giặt Ủi
        </div>
        <p class="laundry-subtitle">Vui lòng điền thông tin bên dưới. Bộ phận lễ tân và giặt ủi của khách sạn sẽ tiếp nhận và đến lấy đồ tại phòng của quý khách.</p>

        <% if (request.getParameter("success") != null) { %>
            <div class="alert-success">
                ✓ Đã gửi yêu cầu giặt ủi thành công! Nhân viên khách sạn sẽ liên hệ và xử lý đồ giặt cho quý khách trong thời gian sớm nhất.
            </div>
        <% } %>

        <% if (error != null) { %>
            <div class="alert-error">
                ⚠ <%= error %>
            </div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/laundry" accept-charset="UTF-8">
            <input type="hidden" name="action" value="clientInsert">

            <div class="form-grid">
                <div class="form-group">
                    <label for="customerName">Họ và tên khách hàng <span style="color:red;">*</span></label>
                    <input type="text" id="customerName" name="customerName" required placeholder="Nhập họ tên của bạn" value="<%= laundry.getCustomerName() != null ? laundry.getCustomerName() : "" %>">
                </div>

                <div class="form-group">
                    <label for="roomNumber">Số phòng lưu trú <span style="color:red;">*</span></label>
                    <input type="text" id="roomNumber" name="roomNumber" required placeholder="Ví dụ: 101, 202..." value="<%= laundry.getRoomNumber() != null ? laundry.getRoomNumber() : "" %>">
                </div>
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label for="serviceType">Loại dịch vụ giặt ủi</label>
                    <select id="serviceType" name="serviceType">
                        <option value="Giặt sấy thông thường" <%= "Giặt sấy thông thường".equals(laundry.getServiceType()) ? "selected" : "" %>>Giặt sấy thông thường (45.000 VNĐ / món)</option>
                        <option value="Giặt khô (Dry Cleaning)" <%= "Giặt khô (Dry Cleaning)".equals(laundry.getServiceType()) ? "selected" : "" %>>Giặt khô (Dry Cleaning) (120.000 VNĐ / món)</option>
                        <option value="Ủi quần áo" <%= "Ủi quần áo".equals(laundry.getServiceType()) ? "selected" : "" %>>Ủi quần áo (30.000 VNĐ / món)</option>
                        <option value="Giặt hấp cao cấp" <%= "Giặt hấp cao cấp".equals(laundry.getServiceType()) ? "selected" : "" %>>Giặt hấp cao cấp (150.000 VNĐ / món)</option>
                        <option value="Tẩy vết bẩn đặc biệt" <%= "Tẩy vết bẩn đặc biệt".equals(laundry.getServiceType()) ? "selected" : "" %>>Tẩy vết bẩn đặc biệt (80.000 VNĐ / món)</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="quantity">Số lượng (món / kg)</label>
                    <input type="number" id="quantity" name="quantity" min="1" max="100" value="<%= laundry.getQuantity() > 0 ? laundry.getQuantity() : 1 %>">
                </div>
            </div>

            <!-- Trường Lưu ý theo yêu cầu 1.2 -->
            <div class="form-group">
                <label for="notes">Lưu ý đặc biệt cho đồ giặt</label>
                <textarea id="notes" name="notes" rows="4" placeholder="Nhập các yêu cầu hoặc lưu ý bảo quản quần áo..."><%= laundry.getNotes() != null ? laundry.getNotes() : "" %></textarea>
                <div class="example-box">
                    <strong>Gợi ý ví dụ:</strong><br>
                    • Không dùng nước nóng<br>
                    • Giặt riêng<br>
                    • Không sấy<br>
                    • Quần áo dễ phai màu
                </div>
            </div>

            <div style="margin-top: 24px; display: flex; gap: 14px;">
                <button type="submit" class="btn btn-primary" style="flex: 1; padding: 12px; font-size: 15px; font-weight: 600;">
                    🧺 Gửi yêu cầu giặt ủi ngay
                </button>
                <a href="<%= request.getContextPath() %>/home" class="btn btn-outline" style="padding: 12px 20px;">Trở về trang chủ</a>
            </div>
        </form>
    </div>
</main>

<%@ include file="WEB-INF/jspf/client-footer.jspf" %>
</body>
</html>
