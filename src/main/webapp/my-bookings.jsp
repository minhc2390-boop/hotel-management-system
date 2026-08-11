<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Booking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Collections" %>
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
    Set<Integer> reviewedBookingIds = (Set<Integer>) request.getAttribute("reviewedBookingIds");
    if (reviewedBookingIds == null) reviewedBookingIds = Collections.emptySet();
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
<body class="client-body">
<%@ include file="WEB-INF/jspf/client-header.jspf" %>

<main class="client-main">
    <% if ("success".equals(request.getParameter("feedback"))) { %>
        <div class="alert alert-success">Cảm ơn bạn! Đánh giá đã được gửi thành công.</div>
    <% } else if ("alreadySent".equals(request.getParameter("feedback"))) { %>
        <div class="alert alert-error">Phiếu đặt phòng này đã được đánh giá hoặc không thể gửi lại.</div>
    <% } else if ("notAllowed".equals(request.getParameter("feedback"))) { %>
        <div class="alert alert-error">Bạn chỉ có thể đánh giá phiếu của mình sau khi đã trả phòng.</div>
    <% } else if ("1".equals(request.getParameter("cancelled"))) { %>
        <div class="alert alert-success">Đã hủy đặt phòng và ghi nhận lý do hủy.</div>
    <% } else if ("cancelReasonRequired".equals(request.getParameter("error"))) { %>
        <div class="alert alert-error">Vui lòng dùng nút Hủy và nhập lý do hủy đặt phòng.</div>
    <% } else if ("invalidCancelReason".equals(request.getParameter("error"))) { %>
        <div class="alert alert-error">Lý do hủy phải có từ 3 đến 500 ký tự.</div>
    <% } else if ("cancelFailed".equals(request.getParameter("error"))) { %>
        <div class="alert alert-error">Không thể hủy đặt phòng ở trạng thái hiện tại.</div>
    <% } %>
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
                        <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                            <a class="btn btn-outline" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/bookings?action=receipt&id=<%= b.getBookingId() %>">Xem phiếu</a>
                            <% if ("Pending".equals(b.getStatus()) || "Confirmed".equals(b.getStatus())) { %>
                                <button class="btn btn-danger" type="button" style="padding: 4px 8px; font-size:12px;"
                                        data-cancel-booking data-booking-id="<%= b.getBookingId() %>"
                                        data-cancel-url="<%= request.getContextPath() %>/bookings">Hủy</button>
                            <% } else if ("CheckedOut".equals(b.getStatus()) && reviewedBookingIds.contains(b.getBookingId())) { %>
                                <a class="btn btn-outline" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/feedbacks?action=view&bookingId=<%= b.getBookingId() %>">Xem đánh giá</a>
                            <% } else if ("CheckedOut".equals(b.getStatus())) { %>
                                <a class="btn btn-primary" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/feedbacks?action=add&bookingId=<%= b.getBookingId() %>">Đánh giá</a>
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
<%@ include file="WEB-INF/jspf/client-footer.jspf" %>
</body>
</html>
