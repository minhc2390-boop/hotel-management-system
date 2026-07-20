<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Bill" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%
  HttpSession sess = request.getSession(false);
  User currentUser = (sess != null) ? (User) sess.getAttribute("currentUser") : null;
  if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
    response.sendRedirect(request.getContextPath() + "/home"); return;
  }
  Integer totalRoomsObj = (Integer) request.getAttribute("totalRooms");
  Long availableObj = (Long) request.getAttribute("availableRooms");
  Long bookedObj = (Long) request.getAttribute("bookedRooms");
  Long maintenanceObj = (Long) request.getAttribute("maintenanceRooms");
  Integer totalUsersObj = (Integer) request.getAttribute("totalUsers");
  Integer totalBillsObj = (Integer) request.getAttribute("totalBills");
  Double revenueObj = (Double) request.getAttribute("totalRevenue");
  int totalRooms = totalRoomsObj != null ? totalRoomsObj : 0;
  long availableRooms = availableObj != null ? availableObj : 0;
  long bookedRooms = bookedObj != null ? bookedObj : 0;
  long maintenanceRooms = maintenanceObj != null ? maintenanceObj : 0;
  int totalUsers = totalUsersObj != null ? totalUsersObj : 0;
  int totalBills = totalBillsObj != null ? totalBillsObj : 0;
  double totalRevenue = revenueObj != null ? revenueObj : 0;
  List<Bill> recentBills = (List<Bill>) request.getAttribute("bills");
  NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi","VN"));
  SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm");
  String activeMenu = "dashboard";

  // Tính toán doanh thu 7 ngày gần đây
  java.time.LocalDate today = java.time.LocalDate.now();
  double[] dailyRev7 = new double[7];
  String[] dailyLabels7 = new String[7];
  java.time.format.DateTimeFormatter fmt7 = java.time.format.DateTimeFormatter.ofPattern("dd/MM");
  double maxDayRevenue7 = 100000; // Tránh chia cho 0

  for (int i = 0; i < 7; i++) {
      java.time.LocalDate date = today.minusDays(6 - i);
      dailyLabels7[i] = date.format(fmt7);
      
      double dayTotal = 0;
      if (recentBills != null) {
          for (Bill b : recentBills) {
              if ("Paid".equals(b.getStatus())) {
                  java.time.LocalDate billDate = b.getCreatedAt().toLocalDateTime().toLocalDate();
                  if (billDate.equals(date)) {
                      dayTotal += b.getTotalAmount();
                  }
              }
          }
      }
      dailyRev7[i] = dayTotal;
      if (dayTotal > maxDayRevenue7) {
          maxDayRevenue7 = dayTotal;
      }
  }
%>
<!DOCTYPE html>
<html lang="vi"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Tổng quan - Nestora</title><link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head><body>
<div class="admin-layout">
  <%@ include file="../WEB-INF/jspf/admin-sidebar.jspf" %>
  <main class="main-shell">
    <%@ include file="../WEB-INF/jspf/admin-topbar.jspf" %>
    <section class="content"><div class="content-inner">
      <div class="page-head">
        <div><div class="breadcrumb">Trang chủ / Tổng quan</div><h1 class="page-title">Chào buổi sáng, <%= currentUser.getFullName() %>!</h1><p class="page-desc">Dưới đây là tình hình hoạt động khách sạn hôm nay.</p></div>
        <div class="page-actions"><a class="btn btn-primary" href="<%= request.getContextPath() %>/admin/booking-form.jsp">＋ Tạo đặt phòng</a></div>
      </div>

      <div class="stat-grid">
        <div class="stat-card"><div class="stat-label">Tỷ lệ lấp đầy</div><div class="stat-value"><%= totalRooms > 0 ? Math.round(bookedRooms * 100.0 / totalRooms) : 0 %>%</div><div class="stat-change">↗ Theo dữ liệu phòng hiện tại</div></div>
        <div class="stat-card"><div class="stat-label">Phòng đang thuê</div><div class="stat-value"><%= bookedRooms %></div><div class="stat-change">Trong tổng số <%= totalRooms %> phòng</div></div>
        <div class="stat-card"><div class="stat-label">Phòng trống</div><div class="stat-value"><%= availableRooms %></div><div class="stat-change">Sẵn sàng nhận khách</div></div>
        <div class="stat-card"><div class="stat-label">Doanh thu đã thu</div><div class="stat-value"><%= money.format(totalRevenue) %></div><div class="stat-change">Từ hóa đơn đã thanh toán</div></div>
      </div>

      <div class="dashboard-grid">
        <section class="surface">
          <div class="surface-head"><div><h2 class="surface-title">Doanh thu 7 ngày gần đây</h2><p class="surface-subtitle">Biểu đồ thể hiện doanh thu thực tế từ backend.</p></div><a href="<%= request.getContextPath() %>/admin/profits.jsp" class="table-primary">Xem chi tiết</a></div>
          <div class="chart-area">
            <% for (int i = 0; i < 7; i++) { 
                int height = (int) Math.round(dailyRev7[i] * 100.0 / maxDayRevenue7);
            %>
              <div class="chart-col" title="Ngày <%= dailyLabels7[i] %>: <%= money.format(dailyRev7[i]) %>">
                <div class="chart-bar <%= i == 6 ? "primary" : "" %>" style="height:<%= height %>%"></div>
              </div>
            <% } %>
          </div>
        </section>
        <section class="surface">
          <div class="surface-head"><div><h2 class="surface-title">Phân bố phòng hôm nay</h2><p class="surface-subtitle">Cập nhật trực tiếp từ dữ liệu phòng</p></div></div>
          <ul class="mini-list">
            <li><div class="mini-main"><strong>Phòng đang thuê</strong><span>Khách đang lưu trú</span></div><span class="status info"><%= bookedRooms %></span></li>
            <li><div class="mini-main"><strong>Phòng trống</strong><span>Sẵn sàng nhận khách</span></div><span class="status success"><%= availableRooms %></span></li>
            <li><div class="mini-main"><strong>Đang bảo trì</strong><span>Cần xử lý kỹ thuật</span></div><span class="status warning"><%= maintenanceRooms %></span></li>
            <li><div class="mini-main"><strong>Tài khoản hệ thống</strong><span>Nhân viên và khách hàng</span></div><span class="status purple"><%= totalUsers %></span></li>
            <li><div class="mini-main"><strong>Tổng hóa đơn</strong><span>Đã phát sinh trong hệ thống</span></div><span class="status info"><%= totalBills %></span></li>
          </ul>
        </section>
      </div>

      <section class="surface" style="margin-top:18px">
        <div class="surface-head"><div><h2 class="surface-title">Đặt phòng gần đây</h2><p class="surface-subtitle">Dữ liệu thật từ danh sách hóa đơn/đặt phòng</p></div><a class="table-primary" href="<%= request.getContextPath() %>/bills?action=list">Xem tất cả</a></div>
        <% if (recentBills != null && !recentBills.isEmpty()) { %>
        <div class="table-wrap"><table><thead><tr><th>Mã đơn</th><th>Khách hàng</th><th>Ngày tạo</th><th>Tổng tiền</th><th>Trạng thái</th><th></th></tr></thead><tbody>
        <% int limit = Math.min(recentBills.size(), 5); for (int i=0;i<limit;i++){ Bill b=recentBills.get(i); %>
          <tr><td class="table-primary">#<%= b.getId() %></td><td><span class="table-strong"><%= b.getUser().getFullName() %></span><br><span class="text-muted"><%= b.getUser().getEmail() %></span></td><td><%= dateTime.format(b.getCreatedAt()) %></td><td class="table-strong"><%= money.format(b.getTotalAmount()) %></td><td><% if("Paid".equals(b.getStatus())){%><span class="status success">Đã thanh toán</span><%}else if("Unpaid".equals(b.getStatus())){%><span class="status info">Chưa thanh toán</span><%}else{%><span class="status danger">Đã hủy</span><%}%></td><td><a class="btn btn-outline btn-icon" href="<%= request.getContextPath() %>/bills?action=detail&id=<%= b.getId() %>">›</a></td></tr>
        <% } %></tbody></table></div>
        <% } else { %><div class="empty"><strong>Chưa có đặt phòng gần đây</strong>Dữ liệu sẽ hiển thị khi hệ thống có giao dịch.</div><% } %>
      </section>
    </div></section>
  </main>
</div>
<script src="<%= request.getContextPath() %>/js/app.js"></script>
</body></html>
