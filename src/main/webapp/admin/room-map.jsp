<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="com.hotel.dao.RoomDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User)sess.getAttribute("currentUser") : null;
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    String activeMenu = "roomMap";
    RoomDAO roomDAO = new RoomDAO();
    roomDAO.syncRoomStatuses();
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    if (rooms == null) {
        rooms = roomDAO.getAllRooms();
    }
    NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>Sơ đồ phòng - Nestora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css" />
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
                <h1 class="page-title">Sơ đồ phòng</h1>
                <p class="page-desc">Theo dõi trạng thái phòng theo từng tầng và cập nhật dọn dẹp, bảo trì.</p>
              </div>
              <div class="page-actions">
                <a class="btn btn-primary" href="<%= request.getContextPath() %>/rooms?action=add">＋ Thêm phòng</a>
              </div>
            </div>
            <section class="surface surface-pad">
              <div class="surface-head" style="padding: 0 0 16px">
                <div>
                  <h2 class="surface-title">Danh sách phòng thực tế</h2>
                  <p class="surface-subtitle"><%= rooms != null ? rooms.size() : 0 %> phòng đang quản lý trên hệ thống</p>
                </div>
              </div>
              <div class="room-map-grid">
                <% if (rooms != null && !rooms.isEmpty()) {
                    for (Room r : rooms) {
                        String dotColor = "#16a36a"; // Available
                        String statusLabel = "Trống";
                        if ("Occupied".equalsIgnoreCase(r.getStatus())) {
                            dotColor = "#1769e0";
                            statusLabel = "Đang sử dụng";
                        } else if ("Cleaning".equalsIgnoreCase(r.getStatus())) {
                            dotColor = "#f59e0b";
                            statusLabel = "Dọn dẹp";
                        } else if ("Maintenance".equalsIgnoreCase(r.getStatus())) {
                            dotColor = "#ff4163";
                            statusLabel = "Bảo trì";
                        } else if ("Booked".equalsIgnoreCase(r.getStatus())) {
                            dotColor = "#8b5cf6";
                            statusLabel = "Đã đặt";
                        }
                %>
                  <a href="<%= request.getContextPath() %>/rooms?action=edit&id=<%= r.getId() %>" class="room-tile" style="text-decoration: none; color: inherit;">
                    <span class="room-dot" style="background: <%= dotColor %>"></span>
                    <div class="room-no">Phòng <%= r.getRoomNumber() %></div>
                    <div class="room-type"><%= r.getRoomType() != null ? r.getRoomType().getName() : "-" %></div>
                    <div class="room-person" style="font-weight: 700; color: <%= dotColor %>"><%= statusLabel %></div>
                    <div class="room-price"><%= r.getRoomType() != null ? money.format(r.getRoomType().getPricePerDay()) : "-" %></div>
                  </a>
                <% } } else { %>
                  <div class="empty">Chưa có phòng nào trong hệ thống</div>
                <% } %>
              </div>
            </section>
          </div>
        </section>
          </div>
        </section>
      </main>
    </div>
    <script src="<%= request.getContextPath() %>/js/app.js"></script>
  </body>
</html>
