<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Booking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    SimpleDateFormat d = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Phòng đã đặt - Nestora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .badge-status {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
        }
        .badge-Pending { background: #fef3c7; color: #d97706; }
        .badge-Confirmed { background: #d1fae5; color: #059669; }
        .badge-CheckedIn { background: #dbeafe; color: #2563eb; }
        .badge-CheckedOut { background: #f3f4f6; color: #4b5563; }
        .badge-Cancelled { background: #fee2e2; color: #dc2626; }
    </style>
</head>
<body>
<header class="public-header">
    <a href="<%= request.getContextPath() %>/home" class="public-brand">
        <div class="brand-logo">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 21V8l8-5 8 5v13"/><path d="M8 21v-7h8v7"/></svg>
        </div>
        <div class="brand-name"><strong>NESTORA</strong><small>HOTEL MANAGER</small></div>
    </a>
    <nav class="public-nav">
        <a href="<%= request.getContextPath() %>/home">Trang chủ</a>
        <a class="active" href="<%= request.getContextPath() %>/bookings?action=mybookings">Phòng đã đặt</a>
        <a href="<%= request.getContextPath() %>/profile">Hồ sơ thành viên</a>
        <a href="<%= request.getContextPath() %>/logout">Đăng xuất</a>
    </nav>
</header>

<main class="public-content">
    <div class="page-head">
        <div>
            <h1 class="page-title">Đơn đặt phòng của bạn</h1>
            <p class="page-desc">Theo dõi các phòng đã đặt và trạng thái xử lý lưu trú.</p>
        </div>
    </div>
    
    <section class="surface">
        <% if (bookings != null && !bookings.isEmpty()) { %>
        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th>MÃ ĐẶT PHÒNG</th>
                    <th>PHÒNG</th>
                    <th>LOẠI PHÒNG</th>
                    <th>ĐƠN GIÁ</th>
                    <th>NHẬN PHÒNG</th>
                    <th>TRẢ PHÒNG</th>
                    <th>TRẠNG THÁI</th>
                    <th>THAO TÁC</th>
                </tr>
                </thead>
                <tbody>
                <%
                    for (Booking b : bookings) {
                        String statusText = "Chờ xác nhận";
                        if ("Confirmed".equals(b.getStatus())) statusText = "Đã xác nhận";
                        else if ("CheckedIn".equals(b.getStatus())) statusText = "Đã nhận phòng";
                        else if ("CheckedOut".equals(b.getStatus())) statusText = "Đã trả phòng";
                        else if ("Cancelled".equals(b.getStatus())) statusText = "Đã hủy";
                %>
                <tr>
                    <td class="table-primary">#DP<%= b.getBookingId() %></td>
                    <td class="table-strong">Phòng <%= b.getRoom().getRoomNumber() %></td>
                    <td><%= b.getRoom().getRoomType().getName() %></td>
                    <td class="table-strong text-primary"><%= money.format(b.getRoomPrice()) %></td>
                    <td><%= d.format(b.getCheckInDate()) %></td>
                    <td><%= d.format(b.getCheckOutDate()) %></td>
                    <td>
                        <span class="badge-status badge-<%= b.getStatus() %>"><%= statusText %></span>
                    </td>
                    <td>
                        <div style="display: flex; gap: 8px;">
                            <a class="btn btn-outline" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/bookings?action=receipt&id=<%= b.getBookingId() %>">Xem phiếu</a>
                            <% if ("Pending".equals(b.getStatus()) || "Confirmed".equals(b.getStatus())) { %>
                                <a class="btn btn-danger" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/bookings?action=cancel&id=<%= b.getBookingId() %>" onclick="return confirm('Bạn có chắc muốn hủy đặt phòng này?')">Hủy</a>
                            <% } %>
                        </div>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } else { %>
        <div class="empty">
            <strong>Bạn chưa đặt phòng nào</strong>
            <p style="margin-top: 6px; color: var(--muted);">Hãy khám phá các phòng trống của chúng tôi.</p>
            <a class="btn btn-primary" style="margin-top:12px" href="<%= request.getContextPath() %>/home">Đặt phòng ngay</a>
        </div>
        <% } %>
    </section>
</main>
<script src="<%= request.getContextPath() %>/js/app.js"></script>
</body>
</html>
