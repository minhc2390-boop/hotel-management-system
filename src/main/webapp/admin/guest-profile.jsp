<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Customer" %>
<%@ page import="com.hotel.model.Booking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<% 
  HttpSession sess = request.getSession(false); 
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null; 
  if (currentUser == null || !"Admin".equalsIgnoreCase(currentUser.getRole())) {
      response.sendRedirect(request.getContextPath() + "/home");
      return;
  }
  
  String activeMenu = "customers"; 
  Customer guest = (Customer) request.getAttribute("guest");
  List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
  double totalSpent = (Double) request.getAttribute("spent");
  int loyaltyPoints = (Integer) request.getAttribute("points");

  NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
  SimpleDateFormat d = new SimpleDateFormat("dd/MM/yyyy HH:mm");

  // Calculate membership tier
  String tier = "Bronze";
  String tierName = "Hội viên Đồng";
  String tierClass = "bronze";
  if (totalSpent >= 100000000) {
      tier = "Diamond";
      tierName = "Hội viên Kim Cương";
      tierClass = "diamond";
  } else if (totalSpent >= 50000000) {
      tier = "Platinum";
      tierName = "Hội viên Bạch kim";
      tierClass = "platinum";
  } else if (totalSpent >= 20000000) {
      tier = "Gold";
      tierName = "Hội viên Vàng";
      tierClass = "gold";
  } else if (totalSpent >= 10000000) {
      tier = "Silver";
      tierName = "Hội viên Bạc";
      tierClass = "silver";
  }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Hồ sơ Khách hàng - <%= guest.getCustomerName() %></title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
  <style>
    .guest-grid {
      display: grid;
      grid-template-columns: 340px 1fr;
      gap: 24px;
      align-items: start;
    }
    .guest-card {
      text-align: center;
      padding: 32px 24px;
    }
    .guest-avatar {
      width: 80px;
      height: 80px;
      border-radius: 50%;
      background: var(--brand-soft);
      color: var(--brand);
      font-size: 32px;
      font-weight: 700;
      display: grid;
      place-items: center;
      margin: 0 auto 16px;
      border: 2px solid var(--brand);
    }
    .guest-name {
      font-size: 18px;
      font-weight: 700;
      color: var(--navy);
      margin-bottom: 8px;
    }
    .guest-tier {
      display: inline-block;
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      margin-bottom: 24px;
    }
    .guest-tier.bronze { background: #fdf2e9; color: #d35400; }
    .guest-tier.silver { background: #f2f3f4; color: #7f8c8d; }
    .guest-tier.gold { background: #fef9e7; color: #f1c40f; }
    .guest-tier.platinum { background: #ebf5fb; color: #2980b9; }
    .guest-tier.diamond { background: #eafaff; color: #0088cc; }

    .detail-list {
      text-align: left;
      border-top: 1px solid var(--line);
      padding-top: 20px;
    }
    .detail-item {
      margin-bottom: 16px;
    }
    .detail-label {
      font-size: 11px;
      color: var(--muted);
      text-transform: uppercase;
      font-weight: 600;
      margin-bottom: 4px;
    }
    .detail-value {
      font-size: 14px;
      font-weight: 600;
      color: var(--navy);
    }

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
<div class="admin-layout">
  <%@ include file="../WEB-INF/jspf/admin-sidebar.jspf" %>
  <main class="main-shell">
    <%@ include file="../WEB-INF/jspf/admin-topbar.jspf" %>
    <section class="content">
      <div class="content-inner">
        <div class="page-head">
          <div>
            <div class="breadcrumb">Vận hành / Khách hàng / Chi tiết hồ sơ</div>
            <h1 class="page-title">Hồ sơ Khách lưu trú</h1>
            <p class="page-desc">Thông tin cá nhân và lịch sử sử dụng dịch vụ tại khách sạn.</p>
          </div>
          <div class="page-actions">
            <a class="btn btn-outline" href="<%= request.getContextPath() %>/users?action=guests">← Quay lại danh sách</a>
          </div>
        </div>

        <div class="guest-grid">
          <!-- Cột bên trái: Thẻ tóm tắt thông tin khách -->
          <div class="surface guest-card">
            <div class="guest-avatar">
              <%= guest.getCustomerName().length() > 0 ? guest.getCustomerName().substring(0, 1).toUpperCase() : "G" %>
            </div>
            <h2 class="guest-name"><%= guest.getCustomerName() %></h2>
            <span class="guest-tier <%= tierClass %>"><%= tierName %></span>

              <div class="detail-item">
                <div class="detail-label">Tài khoản thành viên</div>
                <div class="detail-value">
                  <% if (guest.getUser() != null) { %>
                    <span style="color: var(--brand); font-weight:700;">@<%= guest.getUser().getUsername() %></span> (ID: #<%= guest.getUser().getId() %>)
                  <% } else { %>
                    <span style="color: var(--muted); font-style: italic;">Khách vãng lai (Chưa tạo tài khoản)</span>
                  <% } %>
                </div>
              </div>
              <div class="detail-item">
                <div class="detail-label">Mã khách hàng</div>
                <div class="detail-value">#GST<%= String.format("%04d", guest.getCustomerId()) %></div>
              </div>
              <div class="detail-item">
                <div class="detail-label">CCCD / Hộ chiếu</div>
                <div class="detail-value"><%= guest.getCustomerCccd() != null ? guest.getCustomerCccd() : "Chưa cập nhật" %></div>
              </div>
              <div class="detail-item">
                <div class="detail-label">Số điện thoại</div>
                <div class="detail-value"><%= guest.getCustomerPhone() != null ? guest.getCustomerPhone() : "Chưa cập nhật" %></div>
              </div>
              <div class="detail-item">
                <div class="detail-label">Email</div>
                <div class="detail-value"><%= guest.getCustomerEmail() != null ? guest.getCustomerEmail() : "Chưa cập nhật" %></div>
              </div>
            </div>
          </div>

          <!-- Cột bên phải: Thống kê & lịch sử đặt phòng -->
          <div>
            <div class="stat-grid" style="grid-template-columns: repeat(3, 1fr); margin-bottom: 24px;">
              <div class="stat-card">
                <div class="stat-label">Số lần đặt phòng</div>
                <div class="stat-value"><%= bookings != null ? bookings.size() : 0 %></div>
                <div class="stat-change">Đơn đặt trong hệ thống</div>
              </div>
              <div class="stat-card">
                <div class="stat-label">Tổng doanh thu tích lũy</div>
                <div class="stat-value" style="color: var(--success);"><%= money.format(totalSpent) %></div>
                <div class="stat-change">Trừ các hóa đơn đã hủy</div>
              </div>
              <div class="stat-card">
                <div class="stat-label">Điểm tích lũy</div>
                <div class="stat-value" style="color: var(--brand);"><%= loyaltyPoints %></div>
                <div class="stat-change">Căn cứ tính hạng thẻ</div>
              </div>
            </div>

            <section class="surface" style="padding: 24px;">
              <h3 style="font-size: 16px; color: var(--navy); margin-bottom: 16px;">Lịch sử đặt phòng lưu trú</h3>
              <% if (bookings != null && !bookings.isEmpty()) { %>
                <div class="table-wrap">
                  <table>
                    <thead>
                      <tr>
                        <th>MÃ ĐẶT PHÒNG</th>
                        <th>PHÒNG</th>
                        <th>LOẠI PHÒNG</th>
                        <th>ĐƠN GIÁ PHÒNG</th>
                        <th>NGÀY NHẬN PHÒNG</th>
                        <th>NGÀY TRẢ PHÒNG</th>
                        <th>TRẠNG THÁI</th>
                      </tr>
                    </thead>
                    <tbody>
                      <% 
                        for (Booking b : bookings) { 
                          String statusText = "Chờ xác nhận";
                          if ("Confirmed".equals(b.getStatus())) statusText = "Đã xác nhận";
                          else if ("CheckedIn".equals(b.getStatus())) statusText = "Đang ở";
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
                        </tr>
                      <% } %>
                    </tbody>
                  </table>
                </div>
              <% } else { %>
                <p style="text-align: center; color: var(--muted); padding: 24px 0;">Khách hàng này chưa có lượt đặt phòng nào.</p>
              <% } %>
            </section>
          </div>
        </div>
      </div>
    </section>
  </main>
</div>
<script src="<%= request.getContextPath() %>/js/app.js"></script>
</body>
</html>
