<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<% 
  HttpSession sess = request.getSession(false); 
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null; 
  if (currentUser == null) {
      response.sendRedirect(request.getContextPath() + "/login");
      return;
  }
  String activeMenu = "profile"; 
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Hồ sơ cá nhân - Nestora</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
  <style>
    .profile-container {
        display: grid;
        grid-template-columns: 320px 1fr;
        gap: 24px;
        align-items: start;
    }
    .profile-card {
        text-align: center;
        padding: 32px 24px;
    }
    .profile-avatar {
        width: 96px;
        height: 96px;
        border-radius: 50%;
        background: var(--brand-soft);
        color: var(--brand);
        font-size: 36px;
        font-weight: 700;
        display: grid;
        place-items: center;
        margin: 0 auto 16px;
        border: 3px solid var(--brand);
        box-shadow: 0 4px 10px rgba(23, 105, 224, 0.15);
    }
    .profile-name {
        font-size: 20px;
        font-weight: 700;
        color: var(--navy);
        margin-bottom: 6px;
    }
    .profile-role {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 600;
        margin-bottom: 24px;
    }
    .profile-role.admin {
        background: var(--danger-bg);
        color: var(--danger);
    }
    .profile-role.receptionist {
        background: var(--warning-bg);
        color: var(--warning);
    }
    .profile-info-list {
        text-align: left;
        border-top: 1px solid var(--line);
        padding-top: 20px;
    }
    .profile-info-item {
        display: flex;
        justify-content: space-between;
        margin-bottom: 12px;
        font-size: 13px;
    }
    .profile-info-item span:first-child {
        color: var(--muted);
    }
    .profile-info-item span:last-child {
        font-weight: 600;
        color: var(--text);
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
            <div class="breadcrumb">Hệ thống / Tài khoản</div>
            <h1 class="page-title">Hồ sơ cá nhân</h1>
            <p class="page-desc">Quản lý thông tin tài khoản và cập nhật mật khẩu của bạn.</p>
          </div>
        </div>

        <% if (request.getAttribute("error") != null) { %>
          <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
          <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>

        <div class="profile-container">
          <!-- Card bên trái -->
          <div class="surface profile-card">
            <div class="profile-avatar">
              <%= currentUser.getFullName().length() > 0 ? currentUser.getFullName().substring(0, 1).toUpperCase() : "U" %>
            </div>
            <h2 class="profile-name"><%= currentUser.getFullName() %></h2>
            <span class="profile-role <%= currentUser.getRole().toLowerCase() %>">
              <%= "Admin".equals(currentUser.getRole()) ? "Quản trị viên" : "Nhân viên Lễ tân" %>
            </span>

            <div class="profile-info-list">
              <div class="profile-info-item">
                <span>Tên đăng nhập</span>
                <span><%= currentUser.getUsername() %></span>
              </div>
              <div class="profile-info-item">
                <span>Trạng thái</span>
                <span style="color: var(--success)">● Đang hoạt động</span>
              </div>
              <div class="profile-info-item">
                <span>Ngày tham gia</span>
                <span><%= currentUser.getCreatedAt() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(currentUser.getCreatedAt()) : "-" %></span>
              </div>
            </div>
          </div>

          <!-- Form bên phải -->
          <div class="surface surface-pad">
            <h3 class="form-title" style="margin-bottom: 20px;">Cập nhật thông tin cá nhân</h3>
            <form action="<%= request.getContextPath() %>/profile" method="POST">
              <div class="form-grid">
                <div class="form-group">
                  <label class="form-label">Tên đăng nhập (không thể sửa)</label>
                  <input class="form-control" value="<%= currentUser.getUsername() %>" readonly style="background: var(--canvas)">
                </div>

                <div class="form-group">
                  <label class="form-label">Họ và tên *</label>
                  <input class="form-control" name="fullName" value="<%= currentUser.getFullName() %>" required placeholder="Nhập họ và tên">
                </div>

                <div class="form-group">
                  <label class="form-label">Email *</label>
                  <input class="form-control" type="email" name="email" value="<%= currentUser.getEmail() %>" required placeholder="example@email.com">
                </div>

                <div class="form-group">
                  <label class="form-label">Số điện thoại</label>
                  <input class="form-control" name="phone" value="<%= currentUser.getPhone() != null ? currentUser.getPhone() : "" %>" placeholder="Nhập số điện thoại">
                </div>
              </div>

              <h3 class="form-title" style="margin: 32px 0 20px 0; border-top: 1px solid var(--line); padding-top: 24px;">Đổi mật khẩu</h3>
              <div class="form-grid">
                <div class="form-group">
                  <label class="form-label">Mật khẩu hiện tại</label>
                  <input class="form-control" type="password" name="currentPassword" placeholder="Nhập mật khẩu hiện tại">
                </div>

                <div class="form-group">
                  <label class="form-label">Mật khẩu mới</label>
                  <input class="form-control" type="password" name="newPassword" placeholder="Nhập mật khẩu mới">
                </div>

                <div class="form-group">
                  <label class="form-label">Xác nhận mật khẩu mới</label>
                  <input class="form-control" type="password" name="confirmPassword" placeholder="Xác nhận mật khẩu mới">
                </div>
              </div>

              <div style="margin-top: 32px; display: flex; gap: 12px; justify-content: flex-end;">
                <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </section>
  </main>
</div>
<script src="<%= request.getContextPath() %>/js/app.js"></script>
</body>
</html>
