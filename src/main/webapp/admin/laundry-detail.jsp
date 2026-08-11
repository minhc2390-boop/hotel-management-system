<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Laundry" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = (sess != null) ? (User) sess.getAttribute("currentUser") : null;
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    String activeMenu = "laundry";
    Laundry laundry = (Laundry) request.getAttribute("laundry");
    if (laundry == null) {
        response.sendRedirect(request.getContextPath() + "/laundry?action=list");
        return;
    }
    NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết đơn giặt ủi #<%= laundry.getId() %> - Nestora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .detail-card {
            background: var(--surface);
            border-radius: 8px;
            padding: 24px;
            border: 1px solid var(--line);
            max-width: 700px;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px dashed var(--line);
        }
        .detail-row:last-child {
            border-bottom: none;
        }
        .detail-label {
            color: var(--muted);
            font-weight: 600;
        }
        .detail-value {
            font-weight: 600;
            color: var(--text);
        }
        .badge {
            display: inline-block;
            padding: 4px 10px;
            font-size: 12px;
            font-weight: 600;
            border-radius: 12px;
            text-align: center;
        }
        .badge-success {
            color: var(--success);
            background-color: var(--success-bg);
            border: 1px solid var(--line);
        }
        .badge-warning {
            color: var(--warning);
            background-color: var(--warning-bg);
            border: 1px solid var(--line);
        }
        .notes-box {
            background: rgba(0,0,0,0.03);
            border-left: 4px solid var(--brand);
            padding: 14px;
            border-radius: 6px;
            margin-top: 10px;
            white-space: pre-line;
            line-height: 1.6;
        }
    </style>
</head>
<body>
<div class="admin-layout">
    <%@ include file="../WEB-INF/jspf/admin-sidebar.jspf" %>
    <main class="main-shell">
        <%@ include file="../WEB-INF/jspf/admin-topbar.jspf" %>
        <section class="content">
            <div class="content-inner">
                <div class="page-head">
                    <div>
                        <div class="breadcrumb">Dịch vụ / Giặt ủi / Chi tiết đơn #<%= laundry.getId() %></div>
                        <h1 class="page-title">Chi tiết đơn giặt ủi #<%= laundry.getId() %></h1>
                        <p class="page-desc">Thông tin khách hàng, chi tiết loại dịch vụ và ghi chú hướng dẫn.</p>
                    </div>
                    <div class="page-actions">
                        <a class="btn btn-primary" href="<%= request.getContextPath() %>/laundry?action=edit&id=<%= laundry.getId() %>">Chỉnh sửa đơn</a>
                        <a class="btn btn-outline" href="<%= request.getContextPath() %>/laundry?action=list">← Trở về danh sách</a>
                    </div>
                </div>

                <div class="detail-card">
                    <div class="detail-row">
                        <span class="detail-label">Mã đơn hàng:</span>
                        <span class="detail-value">#<%= laundry.getId() %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Tên khách hàng:</span>
                        <span class="detail-value"><%= laundry.getCustomerName() %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Số phòng:</span>
                        <span class="detail-value">Phòng <%= laundry.getRoomNumber() %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Loại dịch vụ:</span>
                        <span class="detail-value"><%= laundry.getServiceType() %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Số lượng món:</span>
                        <span class="detail-value"><%= laundry.getQuantity() %> món</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Tổng chi phí:</span>
                        <span class="detail-value" style="color: var(--brand); font-size: 16px;"><%= money.format(laundry.getTotalPrice()) %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Trạng thái xử lý:</span>
                        <span class="detail-value">
                            <% if (laundry.isCompleted()) { %>
                                <span class="badge badge-success">Đã hoàn thành</span>
                            <% } else { %>
                                <span class="badge badge-warning">Chưa hoàn thành</span>
                            <% } %>
                        </span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Thời gian tạo:</span>
                        <span class="detail-value"><%= laundry.getCreatedDate() != null ? dtf.format(laundry.getCreatedDate()) : "-" %></span>
                    </div>

                    <!-- Ghi chú / Lưu ý -->
                    <div style="margin-top: 20px;">
                        <span class="detail-label">Ghi chú (Lưu ý xử lý):</span>
                        <div class="notes-box">
                            <%= (laundry.getNotes() != null && !laundry.getNotes().trim().isEmpty()) ? laundry.getNotes() : "Không có ghi chú đặc biệt." %>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/app.js"></script>
</body>
</html>
