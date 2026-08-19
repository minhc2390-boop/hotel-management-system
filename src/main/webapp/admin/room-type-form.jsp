<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.RoomType" %>
<% 
  HttpSession sess = request.getSession(false); 
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null; 
  if (currentUser == null || !"Admin".equalsIgnoreCase(currentUser.getRole())) {
    response.sendRedirect(request.getContextPath() + "/roomtypes?action=list");
    return;
  }
  String activeMenu = "roomTypes"; 
  RoomType roomType = (RoomType) request.getAttribute("roomType");
  boolean isEdit = (roomType != null);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title><%= isEdit ? "Cập nhật loại phòng" : "Thêm loại phòng" %> - Nestora</title>
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
            <div class="breadcrumb">Vận hành / Loại phòng / <%= isEdit ? "Cập nhật" : "Thêm mới" %></div>
            <h1 class="page-title"><%= isEdit ? "Cập nhật loại phòng" : "Thêm loại phòng mới" %></h1>
            <p class="page-desc">Cấu hình thông tin tên, đơn giá và mô tả cho hạng phòng.</p>
          </div>
        </div>

        <section class="surface surface-pad form-surface">
          <h2 class="form-title">Thông tin loại phòng</h2>
          <form action="<%= request.getContextPath() %>/roomtypes" method="POST">
            <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
            <% if (isEdit) { %>
              <input type="hidden" name="id" value="<%= roomType.getId() %>">
            <% } %>

            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">Tên loại phòng *</label>
                <input class="form-control" name="name" placeholder="Ví dụ: Deluxe Double" required value="<%= isEdit ? roomType.getName() : "" %>">
              </div>

              <div class="form-group">
                <label class="form-label">Đơn giá theo ngày (VNĐ) *</label>
                <input class="form-control" type="number" step="1000" name="pricePerDay" placeholder="600000" required value="<%= isEdit ? String.format("%.0f", roomType.getPricePerDay()) : "" %>">
              </div>

              <div class="form-group">
                <label class="form-label">Sức chứa tối đa (khách) *</label>
                <input class="form-control" type="number" name="capacity" min="1" max="20" placeholder="2" required value="<%= isEdit ? roomType.getCapacity() : "2" %>">
              </div>

              <div class="form-group full">
                <label class="form-label">Mô tả loại phòng</label>
                <textarea class="form-control" name="description" rows="3" placeholder="Mô tả về trang thiết bị, tiện ích của loại phòng này..."><%= isEdit && roomType.getDescription() != null ? roomType.getDescription() : "" %></textarea>
              </div>
            </div>

            <div class="form-actions" style="margin-top:20px;">
              <a class="btn btn-outline" href="<%= request.getContextPath() %>/roomtypes?action=list">Hủy</a>
              <button class="btn btn-primary" type="submit"><%= isEdit ? "Cập nhật" : "Lưu loại phòng" %></button>
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
