<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Equipment" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User)sess.getAttribute("currentUser") : null;
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    Equipment equipment = (Equipment) request.getAttribute("equipment");
    boolean isEdit = equipment != null;
    String activeMenu = "equipments";
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title><%= isEdit ? "Cập nhật thiết bị" : "Thêm thiết bị mới" %> - Nestora</title>
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
                <div class="breadcrumb">Vận hành / Quản lý thiết bị / <%= isEdit ? "Cập nhật" : "Thêm mới" %></div>
                <h1 class="page-title"><%= isEdit ? "Cập nhật thông tin thiết bị" : "Thêm thiết bị mới" %></h1>
                <p class="page-desc">Nhập thông tin tên thiết bị cố định (Tivi, Máy lạnh, Máy sấy...), số lượng và trạng thái.</p>
              </div>
            </div>
            <section class="surface surface-pad form-surface">
              <h2 class="form-title">Thông tin thiết bị cố định</h2>
              <form action="<%= request.getContextPath() %>/equipments" method="post">
                <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
                <% if (isEdit) { %>
                  <input type="hidden" name="id" value="<%= equipment.getEquipmentId() %>">
                <% } %>
                <div class="form-grid">
                  <div class="form-group">
                    <label class="form-label" for="name">Tên thiết bị *</label>
                    <input class="form-control" id="name" name="name" placeholder="Ví dụ: Tivi Smart 4K, Máy lạnh Daikin, Máy sấy tóc..." required value="<%= isEdit ? equipment.getEquipmentName() : "" %>" />
                  </div>
                  <div class="form-group">
                    <label class="form-label" for="totalQuantity">Số lượng trang bị *</label>
                    <input class="form-control" type="number" id="totalQuantity" name="totalQuantity" min="1" value="<%= isEdit ? equipment.getTotalQuantity() : 1 %>" required />
                  </div>
                  <div class="form-group">
                    <label class="form-label" for="unit">Đơn vị tính</label>
                    <select class="form-control" id="unit" name="unit">
                      <option value="Cái" <%= isEdit && "Cái".equalsIgnoreCase(equipment.getUnit()) ? "selected" : "" %>>Cái</option>
                      <option value="Bộ" <%= isEdit && "Bộ".equalsIgnoreCase(equipment.getUnit()) ? "selected" : "" %>>Bộ</option>
                      <option value="Chiếc" <%= isEdit && "Chiếc".equalsIgnoreCase(equipment.getUnit()) ? "selected" : "" %>>Chiếc</option>
                    </select>
                  </div>
                  <div class="form-group">
                    <label class="form-label" for="status">Trạng thái thiết bị</label>
                    <select class="form-control" id="status" name="status">
                      <option value="Hoạt động tốt" <%= isEdit && "Hoạt động tốt".equalsIgnoreCase(equipment.getStatus()) ? "selected" : "" %>>Hoạt động tốt</option>
                      <option value="Cần kiểm tra" <%= isEdit && "Cần kiểm tra".equalsIgnoreCase(equipment.getStatus()) ? "selected" : "" %>>Cần kiểm tra</option>
                      <option value="Bảo trì" <%= isEdit && "Bảo trì".equalsIgnoreCase(equipment.getStatus()) ? "selected" : "" %>>Bảo trì</option>
                      <option value="Hỏng" <%= isEdit && "Hỏng".equalsIgnoreCase(equipment.getStatus()) ? "selected" : "" %>>Hỏng</option>
                    </select>
                  </div>
                  <div class="form-group full">
                    <label class="form-label" for="description">Mô tả / Vị trí cố định</label>
                    <textarea class="form-control" id="description" name="description" placeholder="Thông số kỹ thuật, nhãn hiệu, phòng trang bị cố định..."><%= isEdit && equipment.getDescription() != null ? equipment.getDescription() : "" %></textarea>
                  </div>
                </div>
                <div class="form-actions">
                  <a class="btn btn-outline" href="<%= request.getContextPath() %>/equipments?action=list">Hủy</a>
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
