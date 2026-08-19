<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Equipment" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="com.hotel.dao.EquipmentDAO" %>
<%@ page import="com.hotel.dao.RoomDAO" %>
<%@ page import="java.util.List" %>
<%!
    private String equipEscape(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
    if (currentUser == null || !"Admin".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    String activeMenu = "equipments";
    List<Equipment> equipments = (List<Equipment>) request.getAttribute("equipments");
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    if (equipments == null) {
        EquipmentDAO equipmentDAO = new EquipmentDAO();
        equipments = equipmentDAO.getAllEquipments();
    }
    if (rooms == null) {
        RoomDAO roomDAO = new RoomDAO();
        rooms = roomDAO.getAllRooms();
    }
    String keyword = (String) request.getAttribute("keyword");
    Integer selectedRoomId = (Integer) request.getAttribute("selectedRoomId");
    if (selectedRoomId == null) selectedRoomId = 0;
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    if (selectedStatus == null) selectedStatus = "";
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Quản lý thiết bị phòng - Nestora</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
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
                <div class="breadcrumb">Vận hành / Quản lý thiết bị</div>
                <h1 class="page-title">Quản lý &amp; Kiểm tra thiết bị từng phòng</h1>
                <p class="page-desc">Theo dõi trang thiết bị cố định được trang bị cho từng phòng khách sạn, tình trạng hoạt động và kiểm tra hư hao.</p>
              </div>
              <div class="page-actions">
                <a class="btn btn-primary" href="<%= request.getContextPath() %>/equipments?action=add<%= selectedRoomId > 0 ? "&roomId=" + selectedRoomId : "" %>">
                  + Thêm thiết bị mới
                </a>
              </div>
            </div>

            <section class="surface">
              <div class="table-tools">
                <form method="get" action="<%= request.getContextPath() %>/equipments" accept-charset="UTF-8" style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;flex:1">
                  <div class="search-box" style="flex:1;min-width:220px">
                    <input type="search" name="keyword" placeholder="Tìm theo tên thiết bị, phòng hoặc mô tả..." value="<%= keyword != null ? equipEscape(keyword) : "" %>">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <circle cx="11" cy="11" r="7"></circle>
                      <path d="M20 20l-3.5-3.5"></path>
                    </svg>
                  </div>

                  <!-- Bộ lọc phòng -->
                  <div>
                    <select class="form-control" name="roomId" onchange="this.form.submit()" style="min-width:180px;height:40px">
                      <option value="0">Tất cả các phòng</option>
                      <% if (rooms != null) {
                          for (Room r : rooms) {
                            boolean isSel = selectedRoomId != null && selectedRoomId == r.getId();
                      %>
                        <option value="<%= r.getId() %>" <%= isSel ? "selected" : "" %>>
                          Phòng #<%= equipEscape(r.getRoomNumber()) %> (<%= r.getRoomType() != null ? equipEscape(r.getRoomType().getName()) : "" %>)
                        </option>
                      <% } } %>
                      <option value="-1" <%= selectedRoomId != null && selectedRoomId == -1 ? "selected" : "" %>>Kho chung / Chưa gán</option>
                    </select>
                  </div>

                  <!-- Bộ lọc tình trạng -->
                  <div>
                    <select class="form-control" name="status" onchange="this.form.submit()" style="min-width:160px;height:40px">
                      <option value="">Tất cả tình trạng</option>
                      <option value="Hoạt động tốt" <%= "Hoạt động tốt".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Hoạt động tốt</option>
                      <option value="Cần kiểm tra" <%= "Cần kiểm tra".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Cần kiểm tra</option>
                      <option value="Bảo trì" <%= "Bảo trì".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Bảo trì</option>
                      <option value="Hỏng" <%= "Hỏng".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Hỏng / Hư hao</option>
                    </select>
                  </div>

                  <button type="submit" class="btn btn-primary" style="height:40px">Lọc</button>
                  <a class="btn btn-outline" style="height:40px" href="<%= request.getContextPath() %>/equipments?action=list">Đặt lại</a>
                </form>

                <div class="table-meta"><%= equipments != null ? equipments.size() : 0 %> thiết bị</div>
              </div>

              <div class="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>MÃ TB</th>
                      <th>PHÒNG TRANG BỊ</th>
                      <th>TÊN THIẾT BỊ</th>
                      <th>SỐ LƯỢNG</th>
                      <th>ĐƠN VỊ</th>
                      <th>TÌNH TRẠNG / TRẠNG THÁI</th>
                      <th>GHI CHÚ HƯ HAO / VỊ TRÍ</th>
                      <th>THAO TÁC</th>
                    </tr>
                  </thead>
                  <tbody>
                    <% if (equipments != null && !equipments.isEmpty()) {
                        for (Equipment eq : equipments) {
                            String st = eq.getStatus() != null ? eq.getStatus() : "";
                            String statusClass = "success";
                            String lowerSt = st.toLowerCase();
                            if (lowerSt.contains("kiểm tra") || lowerSt.contains("bảo trì") || "maintenance".equalsIgnoreCase(st)) {
                                statusClass = "warning";
                            } else if (lowerSt.contains("hỏng") || "broken".equalsIgnoreCase(st) || "outofstock".equalsIgnoreCase(st)) {
                                statusClass = "danger";
                            }
                    %>
                      <tr>
                        <td class="table-primary">#TB<%= String.format("%03d", eq.getEquipmentId()) %></td>
                        <td>
                          <% if (eq.getRoom() != null) { %>
                            <a href="<%= request.getContextPath() %>/rooms?action=edit&id=<%= eq.getRoom().getId() %>#equipments" style="font-weight:700;color:var(--brand)">
                              Phòng #<%= equipEscape(eq.getRoom().getRoomNumber()) %>
                            </a>
                          <% } else { %>
                            <span class="text-muted" style="font-style:italic">Kho chung</span>
                          <% } %>
                        </td>
                        <td class="table-strong"><%= equipEscape(eq.getEquipmentName()) %></td>
                        <td><%= eq.getTotalQuantity() %></td>
                        <td><%= equipEscape(eq.getUnit()) %></td>
                        <td><span class="status <%= statusClass %>"><%= equipEscape(st.isEmpty() ? "Hoạt động tốt" : st) %></span></td>
                        <td><%= eq.getDescription() != null && !eq.getDescription().isEmpty() ? equipEscape(eq.getDescription()) : "—" %></td>
                        <td>
                          <div class="row-actions">
                            <a class="btn btn-outline" href="<%= request.getContextPath() %>/equipments?action=edit&id=<%= eq.getEquipmentId() %>">Sửa / Báo hỏng</a>
                            <a class="btn btn-danger" href="<%= request.getContextPath() %>/equipments?action=delete&id=<%= eq.getEquipmentId() %>" onclick="return confirm('Bạn có chắc chắn muốn xóa thiết bị <%= equipEscape(eq.getEquipmentName()) %>?');">Xóa</a>
                          </div>
                        </td>
                      </tr>
                    <% } } else { %>
                      <tr><td colspan="8" style="text-align:center;padding:32px 16px;color:var(--muted)">Không tìm thấy thiết bị nào phù hợp với bộ lọc.</td></tr>
                    <% } %>
                  </tbody>
                </table>
              </div>
            </section>
          </div>
        </section>
      </main>
    </div>
    <script src="<%= request.getContextPath() %>/js/app.js"></script>
  </body>
</html>