<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Equipment" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="java.util.List" %>
<%!
    private String equipEscape(String value) {
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
    if (currentUser == null || !"Admin".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    Equipment equipment = (Equipment) request.getAttribute("equipment");
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    Integer defaultRoomId = (Integer) request.getAttribute("defaultRoomId");
    if (defaultRoomId == null) defaultRoomId = 0;

    int currentRoomId = 0;
    if (equipment != null && equipment.getRoom() != null) {
        currentRoomId = equipment.getRoom().getId();
    } else if (defaultRoomId > 0) {
        currentRoomId = defaultRoomId;
    }

    boolean isEdit = equipment != null;
    String activeMenu = "equipments";
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title><%= isEdit ? "Cập nhật thiết bị" : "Thêm thiết bị mới" %> - Nestora</title>
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
                <div class="breadcrumb">Vận hành / Quản lý thiết bị / <%= isEdit ? "Cập nhật" : "Thêm mới" %></div>
                <h1 class="page-title"><%= isEdit ? "Cập nhật thông tin thiết bị" : "Thêm thiết bị mới" %></h1>
                <p class="page-desc">Chỉ định phòng được trang bị, tên thiết bị, số lượng và kiểm tra tình trạng hư hao.</p>
              </div>
            </div>
            <section class="surface surface-pad form-surface">
              <h2 class="form-title">Thông tin thiết bị phòng</h2>
              <form action="<%= request.getContextPath() %>/equipments" method="post">
                <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
                <% if (isEdit) { %>
                  <input type="hidden" name="id" value="<%= equipment.getEquipmentId() %>">
                <% } %>
                <% if (defaultRoomId > 0) { %>
                  <input type="hidden" name="returnTo" value="room">
                <% } %>

                <div class="form-grid">
                  <!-- Phòng trang bị -->
                  <div class="form-group">
                    <label class="form-label" for="roomId">Phòng trang bị *</label>
                    <select class="form-control" id="roomId" name="roomId">
                      <option value="0">-- Kho chung / Chưa phân phòng --</option>
                      <% if (rooms != null) {
                          for (Room r : rooms) {
                            boolean isSelected = (currentRoomId == r.getId());
                      %>
                        <option value="<%= r.getId() %>" <%= isSelected ? "selected" : "" %>>
                          Phòng #<%= r.getRoomNumber() %> (<%= r.getRoomType() != null ? r.getRoomType().getName() : "" %>)
                        </option>
                      <% } } %>
                    </select>
                    <small class="form-hint">Chọn phòng cụ thể để kiểm tra tình trạng hư hao theo từng phòng.</small>
                  </div>

                  <!-- Tên thiết bị -->
                  <div class="form-group">
                    <label class="form-label" for="name">Tên thiết bị *</label>
                    <input class="form-control" id="name" name="name" placeholder="Ví dụ: Tivi Smart 4K 43 inch, Máy lạnh Daikin..." required value="<%= isEdit ? equipEscape(equipment.getEquipmentName()) : "" %>">
                  </div>

                  <!-- Số lượng -->
                  <div class="form-group">
                    <label class="form-label" for="totalQuantity">Số lượng trang bị *</label>
                    <input class="form-control" type="number" id="totalQuantity" name="totalQuantity" min="1" value="<%= isEdit ? equipment.getTotalQuantity() : 1 %>" required>
                  </div>

                  <!-- Đơn vị -->
                  <div class="form-group">
                    <label class="form-label" for="unit">Đơn vị tính</label>
                    <select class="form-control" id="unit" name="unit">
                      <option value="Cái" <%= isEdit && "Cái".equalsIgnoreCase(equipment.getUnit()) ? "selected" : "" %>>Cái</option>
                      <option value="Bộ" <%= isEdit && "Bộ".equalsIgnoreCase(equipment.getUnit()) ? "selected" : "" %>>Bộ</option>
                      <option value="Chiếc" <%= isEdit && "Chiếc".equalsIgnoreCase(equipment.getUnit()) ? "selected" : "" %>>Chiếc</option>
                    </select>
                  </div>

                  <!-- Tình trạng / Trạng thái -->
                  <div class="form-group">
                    <label class="form-label" for="status">Tình trạng kiểm tra / Hoạt động *</label>
                    <select class="form-control" id="status" name="status">
                      <option value="Hoạt động tốt" <%= isEdit && "Hoạt động tốt".equalsIgnoreCase(equipment.getStatus()) ? "selected" : "" %>>✅ Hoạt động tốt</option>
                      <option value="Cần kiểm tra" <%= isEdit && "Cần kiểm tra".equalsIgnoreCase(equipment.getStatus()) ? "selected" : "" %>>⚠️ Cần kiểm tra (Lờn nút, trầy xước...)</option>
                      <option value="Bảo trì" <%= isEdit && "Bảo trì".equalsIgnoreCase(equipment.getStatus()) ? "selected" : "" %>>🔧 Đang bảo trì / Sửa chữa</option>
                      <option value="Hỏng" <%= isEdit && "Hỏng".equalsIgnoreCase(equipment.getStatus()) ? "selected" : "" %>>❌ Hỏng / Hư hao (Cần thay mới)</option>
                    </select>
                  </div>

                  <!-- Mô tả & Ghi chú hư hao -->
                  <div class="form-group full">
                    <label class="form-label" for="description">Ghi chú tình trạng hư hao / Vị trí trang bị</label>
                    <textarea class="form-control" id="description" name="description" rows="3" placeholder="Ghi chú chi tiết: Remote bị lờn, vết nứt nhẹ góc máy, mới thay phụ kiện ngày..."><%= isEdit && equipment.getDescription() != null ? equipEscape(equipment.getDescription()) : "" %></textarea>
                  </div>
                </div>

                <div class="form-actions" style="display:flex;gap:10px;margin-top:20px">
                  <a class="btn btn-outline" href="<%= request.getContextPath() %>/equipments?action=list<%= currentRoomId > 0 ? "&roomId=" + currentRoomId : "" %>">Hủy</a>
                  <button class="btn btn-primary" type="submit"><%= isEdit ? "Lưu thay đổi" : "Tạo thiết bị" %></button>
                </div>
              </form>
            </section>
          </div>
        </section>
      </main>
    </div>
    <script src="<%= request.getContextPath() %>/js/app.js"></script>
  </body>
</html>
