<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="com.hotel.dao.RoomDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<% 
  HttpSession sess = request.getSession(false); 
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null; 
  String activeMenu = "roomMap"; 

  List<Room> rooms = (List<Room>) request.getAttribute("rooms");
  if (rooms == null) {
      rooms = new RoomDAO().getAllRooms();
  }
  NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi","VN"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Sơ đồ phòng - Nestora</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
  <style>
    .room-tile-link {
      text-decoration: none;
      color: inherit;
      display: block;
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
            <div class="breadcrumb">Vận hành / Sơ đồ phòng</div>
            <h1 class="page-title">Sơ đồ phòng thực tế</h1>
            <p class="page-desc">Cập nhật trực tiếp trạng thái phòng theo cơ sở dữ liệu.</p>
          </div>
          <div class="page-actions">
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/rooms?action=add">＋ Thêm phòng mới</a>
          </div>
        </div>

        <section class="surface surface-pad">
          <div class="surface-head" style="padding:0 0 16px">
            <div>
              <h2 class="surface-title">Danh sách phòng hiện tại</h2>
              <p class="surface-subtitle"><%= rooms != null ? rooms.size() : 0 %> phòng trong hệ thống</p>
            </div>
          </div>

          <div class="room-map-grid">
            <% if (rooms != null && !rooms.isEmpty()) {
                 for (Room r : rooms) {
                     String statusClass = "#16a36a"; // Available -> Green
                     String statusText = "Phòng trống";

                     if ("Booked".equals(r.getStatus())) {
                         statusClass = "#1769e0"; // Booked -> Blue
                         statusText = "Đang thuê";
                     } else if ("Maintenance".equals(r.getStatus())) {
                         statusClass = "#ff4163"; // Maintenance -> Red
                         statusText = "Bảo trì";
                     }
            %>
              <div class="room-tile">
                <span class="room-dot" style="background:<%= statusClass %>"></span>
                <div class="room-no">Phòng <%= r.getRoomNumber() %></div>
                <div class="room-type"><%= r.getRoomType() != null ? r.getRoomType().getName() : "Chưa phân loại" %></div>
                <div class="room-person"><%= statusText %></div>
                <div class="room-price"><%= r.getRoomType() != null ? money.format(r.getRoomType().getPricePerDay()) : "0 đ" %> / ngày</div>
              </div>
            <%   }
               } else { 
            %>
              <div style="grid-column: 1 / -1; text-align: center; padding: 30px; color: var(--muted);">
                Chưa có phòng nào trong CSDL.
              </div>
            <% } %>
          </div>
        </section>
      </div>
    </section>
  </main>
</div>
<script src="<%= request.getContextPath() %>/js/app.js"></script>
</body>
</html>