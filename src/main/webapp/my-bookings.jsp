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
    int bookingTotal = bookings != null ? bookings.size() : 0;
    int bookingActive = 0;
    int bookingCompleted = 0;
    int bookingCancelled = 0;
    if (bookings != null) {
        for (Booking summaryBooking : bookings) {
            String summaryStatus = summaryBooking.getStatus();
            if ("Cancelled".equalsIgnoreCase(summaryStatus)) bookingCancelled++;
            else if ("CheckedOut".equalsIgnoreCase(summaryStatus) || "Completed".equalsIgnoreCase(summaryStatus)) bookingCompleted++;
            else bookingActive++;
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Phòng đã đặt - Nestora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .booking-history-header { align-items: flex-end; }
        .history-overview {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 14px;
            margin: 22px 0;
        }
        .history-stat {
            padding: 18px 20px;
            border: 1px solid var(--line);
            border-radius: 13px;
            background: var(--surface);
            box-shadow: var(--shadow);
        }
        .history-stat span { display: block; color: var(--muted); font-size: 11px; font-weight: 600; }
        .history-stat strong { display: block; margin-top: 6px; color: var(--text); font-size: 25px; }
        .history-stat.primary { border-color: color-mix(in srgb, var(--brand) 26%, var(--line)); background: var(--brand-soft); }
        .history-stat.primary strong { color: var(--brand); }
        .booking-history-surface { overflow: hidden; border-radius: 15px; }
        .booking-history-table { min-width: 980px; }
        .booking-history-table th { padding-top: 15px; padding-bottom: 15px; }
        .booking-history-table td { padding-top: 18px; padding-bottom: 18px; }
        .booking-code { display: inline-flex; color: var(--brand); font-weight: 800; letter-spacing: .02em; }
        .booking-room { display: flex; align-items: center; gap: 11px; min-width: 142px; }
        .booking-room-icon {
            width: 38px; height: 38px; display: grid; place-items: center; flex: 0 0 38px;
            border-radius: 10px; color: var(--brand); background: var(--brand-soft); font-weight: 800;
        }
        .booking-room strong { display: block; }
        .booking-date { white-space: nowrap; color: var(--text); font-weight: 600; }
        .booking-status {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            min-height: 28px;
            padding: 0 10px;
            border: 1px solid transparent;
            border-radius: 99px;
            font-size: 10px;
            font-weight: 800;
            white-space: nowrap;
        }
        .booking-status::before { content: ''; width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
        .booking-status.pending { color: var(--warning); background: var(--warning-bg); border-color: color-mix(in srgb, var(--warning) 22%, transparent); }
        .booking-status.confirmed { color: var(--success); background: var(--success-bg); border-color: color-mix(in srgb, var(--success) 22%, transparent); }
        .booking-status.checked-in { color: var(--brand); background: var(--brand-soft); border-color: color-mix(in srgb, var(--brand) 22%, transparent); }
        .booking-status.completed { color: var(--muted); background: var(--canvas); border-color: var(--line); }
        .booking-status.cancelled { color: var(--danger); background: var(--danger-bg); border-color: color-mix(in srgb, var(--danger) 22%, transparent); }
        .history-actions { display: flex; gap: 7px; flex-wrap: wrap; min-width: 155px; }
        .history-action { min-height: 34px; padding: 0 11px; font-size: 10px; }
        @media (max-width: 760px) {
            .history-overview { grid-template-columns: repeat(2, minmax(0, 1fr)); }
            .booking-history-header { align-items: flex-start; flex-direction: column; }
        }
        @media (max-width: 430px) {
            .history-overview { grid-template-columns: 1fr; }
        }
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
    <div class="client-page-head booking-history-header">
        <div>
            <p class="client-eyebrow">Tài khoản khách hàng</p>
            <h1 class="client-page-title">Đơn đặt phòng của bạn</h1>
            <p class="client-page-desc">Theo dõi lịch sử đặt phòng, trạng thái thanh toán và kỳ lưu trú tại Nestora.</p>
        </div>
        <a class="btn btn-primary" href="<%= request.getContextPath() %>/home#phong-nghi">+ Đặt thêm phòng</a>
    </div>

    <div class="history-overview" aria-label="Tổng quan lịch sử đặt phòng">
        <div class="history-stat primary"><span>Tổng đặt phòng</span><strong><%= bookingTotal %></strong></div>
        <div class="history-stat"><span>Đang xử lý / lưu trú</span><strong><%= bookingActive %></strong></div>
        <div class="history-stat"><span>Đã hoàn tất</span><strong><%= bookingCompleted %></strong></div>
        <div class="history-stat"><span>Đã hủy</span><strong><%= bookingCancelled %></strong></div>
    </div>
    
    <section class="surface booking-history-surface">
        <% if (bookings != null && !bookings.isEmpty()) { %>
        <div class="table-wrap">
            <table class="booking-history-table">
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
                        String statusText = "Chưa thanh toán";
                        String statusClass = "pending";
                        if ("Confirmed".equalsIgnoreCase(b.getStatus())) {
                            statusText = "Đã xác nhận";
                            statusClass = "confirmed";
                        } else if ("CheckedIn".equalsIgnoreCase(b.getStatus())) {
                            statusText = "Đang lưu trú";
                            statusClass = "checked-in";
                        } else if ("CheckedOut".equalsIgnoreCase(b.getStatus()) || "Completed".equalsIgnoreCase(b.getStatus())) {
                            statusText = "Đã trả phòng";
                            statusClass = "completed";
                        } else if ("Cancelled".equalsIgnoreCase(b.getStatus())) {
                            statusText = "Đã hủy";
                            statusClass = "cancelled";
                        }
                %>
                <tr>
                    <td><span class="booking-code">#DP<%= b.getBookingId() %></span></td>
                    <td>
                        <div class="booking-room">
                            <span class="booking-room-icon" aria-hidden="true">P</span>
                            <strong>Phòng <%= b.getRoom().getRoomNumber() %></strong>
                        </div>
                    </td>
                    <td><%= b.getRoom().getRoomType().getName() %></td>
                    <td class="table-strong text-primary"><%= money.format(b.getRoomPrice()) %></td>
                    <td><span class="booking-date"><%= d.format(b.getCheckInDate()) %></span></td>
                    <td><span class="booking-date"><%= d.format(b.getCheckOutDate()) %></span></td>
                    <td>
                        <span class="booking-status <%= statusClass %>"><%= statusText %></span>
                    </td>
                    <td>
                        <div class="history-actions">
                            <a class="btn btn-outline history-action" href="<%= request.getContextPath() %>/bookings?action=receipt&id=<%= b.getBookingId() %>">Xem phiếu</a>
                            <% if ("Pending".equalsIgnoreCase(b.getStatus()) || "Confirmed".equalsIgnoreCase(b.getStatus())) { %>
                                <button class="btn btn-danger history-action" type="button"
                                        data-cancel-booking data-booking-id="<%= b.getBookingId() %>"
                                        data-cancel-url="<%= request.getContextPath() %>/bookings">Hủy</button>
                            <% } else if ("CheckedOut".equalsIgnoreCase(b.getStatus()) && reviewedBookingIds.contains(b.getBookingId())) { %>
                                <a class="btn btn-outline history-action" href="<%= request.getContextPath() %>/feedbacks?action=view&bookingId=<%= b.getBookingId() %>">Xem đánh giá</a>
                            <% } else if ("CheckedOut".equalsIgnoreCase(b.getStatus())) { %>
                                <a class="btn btn-primary history-action" href="<%= request.getContextPath() %>/feedbacks?action=add&bookingId=<%= b.getBookingId() %>">Đánh giá</a>
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
