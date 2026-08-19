<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%!
  private String roomEscape(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
  }
%>
<%
  request.setCharacterEncoding("UTF-8");
  response.setCharacterEncoding("UTF-8");

  HttpSession sess = request.getSession(false);
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
  if (currentUser == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
  }
  if (!"Admin".equalsIgnoreCase(currentUser.getRole())) {
    response.sendRedirect(request.getContextPath() + "/rooms?action=map");
    return;
  }
  List<Room> rooms = (List<Room>) request.getAttribute("rooms");
  NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
  boolean isAdmin = "Admin".equalsIgnoreCase(currentUser.getRole());
  boolean isStaff = isAdmin || "Receptionist".equalsIgnoreCase(currentUser.getRole());
  String activeMenu = "rooms";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Danh sách phòng - Nestora</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
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
            <div class="breadcrumb">Vận hành / Danh sách phòng</div>
            <h1 class="page-title">Danh sách phòng & Trang thiết bị</h1>
            <p class="page-desc">Quản lý trạng thái, danh mục trang thiết bị cố định và kiểm tra hư hao từng phòng.</p>
          </div>
          <div class="page-actions">
            <a class="btn btn-outline" href="<%= request.getContextPath() %>/equipments?action=list">🛠️ Tất cả thiết bị</a>
            <a class="btn btn-outline" href="<%= request.getContextPath() %>/rooms?action=map">🗺️ Sơ đồ phòng</a>
            <% if (isStaff) { %>
              <a class="btn btn-primary" href="<%= request.getContextPath() %>/rooms?action=add">+ Thêm phòng mới</a>
            <% } %>
          </div>
        </div>

        <section class="surface">
          <div class="table-tools">
            <div class="search-box">
              <input type="search" placeholder="Tìm theo mã phòng, loại phòng hoặc mô tả..." data-table-search>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="7"></circle>
                <path d="M20 20l-3.5-3.5"></path>
              </svg>
            </div>
            <div class="admin-filter-group">
              <select class="admin-filter-select" data-admin-filter aria-label="Lọc trạng thái phòng">
                <option value="">Tất cả trạng thái</option>
                <option value="Phòng trống">Phòng trống</option>
                <option value="Đang sử dụng">Đang sử dụng</option>
                <option value="Dọn dẹp">Dọn dẹp</option>
                <option value="Đã đặt">Đã đặt</option>
                <option value="Bảo trì">Bảo trì</option>
              </select>
            </div>
            <div class="table-meta"><span><%= rooms != null ? rooms.size() : 0 %> phòng</span></div>
          </div>

          <% if (rooms != null && !rooms.isEmpty()) { %>
            <div class="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>MÃ PHÒNG</th>
                    <th>LOẠI PHÒNG</th>
                    <th>GIÁ / NGÀY</th>
                    <th>SỨC CHỨA</th>
                    <th>TRẠNG THÁI</th>
                    <th>THIẾT BỊ PHÒNG</th>
                    <th>THAO TÁC</th>
                  </tr>
                </thead>
                <tbody>
                  <% for (Room r : rooms) { %>
                    <tr>
                      <td class="table-primary">#<%= roomEscape(r.getRoomNumber()) %></td>
                      <td class="table-strong"><%= r.getRoomType() != null ? roomEscape(r.getRoomType().getName()) : "—" %></td>
                      <td><%= r.getRoomType() != null ? money.format(r.getRoomType().getPricePerDay()) : "—" %></td>
                      <td><%= r.getRoomType() != null ? r.getRoomType().getCapacity() + " người" : "—" %></td>
                      <td>
                        <% if ("Available".equalsIgnoreCase(r.getStatus())) { %>
                          <span class="status success">Phòng trống</span>
                        <% } else if ("Occupied".equalsIgnoreCase(r.getStatus())) { %>
                          <span class="status primary" style="background:#dbeafe;color:#1e40af;">Đang sử dụng</span>
                        <% } else if ("Cleaning".equalsIgnoreCase(r.getStatus())) { %>
                          <span class="status warning" style="background:#fef3c7;color:#b45309;">Dọn dẹp</span>
                        <% } else if ("Booked".equalsIgnoreCase(r.getStatus())) { %>
                          <span class="status info">Đã đặt</span>
                        <% } else if ("Maintenance".equalsIgnoreCase(r.getStatus())) { %>
                          <span class="status danger" style="background:#fee2e2;color:#dc2626;">Bảo trì</span>
                        <% } else { %>
                          <span class="status"><%= roomEscape(r.getStatus()) %></span>
                        <% } %>
                      </td>
                      <td>
                        <a class="btn btn-outline" style="font-size:12px;padding:4px 10px;display:inline-flex;align-items:center;gap:4px"
                           href="<%= request.getContextPath() %>/rooms?action=edit&id=<%= r.getId() %>#equipments">
                          <span>📦 Kiểm tra thiết bị</span>
                        </a>
                      </td>
                      <td>
                        <div class="row-actions">
                          <a class="btn btn-outline" href="<%= request.getContextPath() %>/rooms?action=edit&id=<%= r.getId() %>">Chỉnh sửa</a>
                          <% if (isAdmin) { %>
                            <a class="btn btn-danger" href="<%= request.getContextPath() %>/rooms?action=delete&id=<%= r.getId() %>" onclick="return confirm('Xóa phòng này và tất cả thiết bị liên quan?');">Xóa</a>
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
              <strong>Chưa có phòng nào trong hệ thống</strong>
              <span>Hãy thêm phòng đầu tiên vào hệ thống.</span>
            </div>
          <% } %>
        </section>
      </div>
    </section>
  </main>
</div>
<script src="<%= request.getContextPath() %>/js/app.js"></script>
</body>
</html>
