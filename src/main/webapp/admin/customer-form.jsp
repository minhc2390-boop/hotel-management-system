<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<% 
  HttpSession sess = request.getSession(false); 
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null; 
  String activeMenu = "customers"; 
  User user = (User) request.getAttribute("user");
  boolean isEdit = (user != null);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title><%= isEdit ? "Cập nhật người dùng" : "Thêm mới người dùng" %> - Nestora</title>
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
            <div class="breadcrumb">Vận hành / Người dùng / <%= isEdit ? "Cập nhật" : "Thêm mới" %></div>
            <h1 class="page-title"><%= isEdit ? "Cập nhật người dùng" : "Thêm mới người dùng" %></h1>
            <p class="page-desc">Lưu hồ sơ tài khoản người dùng hoặc khách hàng trong hệ thống.</p>
          </div>
        </div>

        <section class="surface surface-pad form-surface">
          <h2 class="form-title">Thông tin tài khoản</h2>
          <form action="<%= request.getContextPath() %>/users" method="POST">
            <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
            <% if (isEdit) { %>
              <input type="hidden" name="id" value="<%= user.getId() %>">
            <% } %>

            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">Tên đăng nhập *</label>
                <input class="form-control" name="username" placeholder="Nhập tên đăng nhập" required <%= isEdit ? "readonly style='background:#f1f5f9;'" : "" %> value="<%= isEdit ? user.getUsername() : "" %>">
              </div>

              <div class="form-group">
                <label class="form-label">Mật khẩu <%= isEdit ? "(Để trống nếu không đổi)" : "*" %></label>
                <input class="form-control" type="password" name="password" placeholder="Nhập mật khẩu" <%= isEdit ? "" : "required" %>>
              </div>

              <div class="form-group">
                <label class="form-label">Họ và tên *</label>
                <input class="form-control" name="fullName" placeholder="Nhập họ và tên" required value="<%= isEdit ? user.getFullName() : "" %>">
              </div>

              <div class="form-group">
                <label class="form-label">Email *</label>
                <input class="form-control" type="email" name="email" placeholder="example@email.com" required value="<%= isEdit ? user.getEmail() : "" %>">
              </div>

              <div class="form-group">
                <label class="form-label">Số điện thoại</label>
                <input class="form-control" name="phone" placeholder="09xx xxx xxx" value="<%= isEdit && user.getPhone() != null ? user.getPhone() : "" %>">
              </div>

              <div class="form-group">
                <label class="form-label">Vai trò *</label>
                <% if (currentUser != null && "Admin".equals(currentUser.getRole())) { %>
                  <select class="form-control" name="role" required>
                    <option value="Customer" <%= isEdit && "Customer".equals(user.getRole()) ? "selected" : "" %>>Khách hàng (Customer)</option>
                    <option value="Receptionist" <%= isEdit && "Receptionist".equals(user.getRole()) ? "selected" : "" %>>Lễ tân (Receptionist)</option>
                    <option value="Admin" <%= isEdit && "Admin".equals(user.getRole()) ? "selected" : "" %>>Quản trị viên (Admin)</option>
                  </select>
                <% } else { %>
                  <input class="form-control" type="text" readonly style="background:#f1f5f9;" value="<%= isEdit ? ("Receptionist".equals(user.getRole()) ? "Lễ tân (Receptionist)" : ("Admin".equals(user.getRole()) ? "Quản trị viên (Admin)" : "Khách hàng (Customer)")) : "Khách hàng (Customer)" %>">
                  <input type="hidden" name="role" value="<%= isEdit ? user.getRole() : "Customer" %>">
                <% } %>
              </div>
            </div>

            <div class="form-actions" style="margin-top:20px;">
              <a class="btn btn-outline" href="<%= request.getContextPath() %>/users?action=list">Hủy</a>
              <button class="btn btn-primary" type="submit"><%= isEdit ? "Cập nhật" : "Lưu thông tin" %></button>
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