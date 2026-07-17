<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đăng nhập - Nestora Hotel Manager</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<div class="login-page">
  <section class="login-visual">
    <div class="brand">
      <div class="brand-logo" aria-hidden="true"><img src="<%= request.getContextPath() %>/assets/icons/logo.svg" alt=""></div>
      <div class="brand-name"><strong>NESTORA</strong><small>HOTEL MANAGER</small></div>
    </div>

    <div class="login-copy">
      <div class="login-chip">VẬN HÀNH KHÁCH SẠN HIỆU QUẢ</div>
      <h1>Trải nghiệm, lưu trú,<br>trong tầm kiểm soát.</h1>
      <p>Nền tảng quản lý đồng bộ cho đội ngũ lễ tân và quản lý khách sạn hiện đại.</p>
      <div class="login-metrics">
        <div class="login-metric"><strong>60+</strong><span>Phòng vận hành</span></div>
        <div class="login-metric"><strong>1.2K</strong><span>Khách hàng</span></div>
        <div class="login-metric"><strong>99.9%</strong><span>Ổn định</span></div>
      </div>
    </div>
  </section>

  <section class="login-panel">
    <div class="login-form-wrap">
      <h2>Chào mừng trở lại</h2>
      <p>Đăng nhập để tiếp tục quản lý khách sạn.</p>
      <% String error = (String) request.getAttribute("error"); if (error != null) { %>
        <div class="alert alert-error"><%= error %></div>
      <% } %>
      <% String success = (String) request.getAttribute("success"); if (success != null) { %>
        <div class="alert alert-success"><%= success %></div>
      <% } %>
      <form action="<%= request.getContextPath() %>/login" method="POST" autocomplete="on">
        <div class="form-group">
          <label class="form-label" for="username">Tên đăng nhập</label>
          <input class="form-control" type="text" id="username" name="username" placeholder="Nhập tên đăng nhập" required value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>">
        </div>
        <div class="form-group">
          <label class="form-label" for="password">Mật khẩu</label>
          <input class="form-control" type="password" id="password" name="password" placeholder="Nhập mật khẩu" required>
        </div>
        <div class="login-options">
          <label><input type="checkbox" name="remember"> Ghi nhớ đăng nhập</label>
          <a href="#">Quên mật khẩu?</a>
        </div>
        <button class="btn btn-primary btn-block" type="submit" style="height:42px;">Đăng nhập</button>
      </form>
      <div class="login-footer">© 2026 Nestora Hotel Manager · Hệ thống nội bộ</div>
    </div>
  </section>
</div>
</body>
</html>
