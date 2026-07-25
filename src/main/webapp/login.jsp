<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
  String activeTab = (String) request.getAttribute("activeTab");
  if (activeTab == null) {
      activeTab = request.getParameter("tab");
  }
  if (activeTab == null) {
      activeTab = "login";
  }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tài khoản - Nestora Hotel Manager</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
  <style>
    /* CSS override for login page */
    .login-page {
      min-height: 100vh;
      width: 100%;
      background: linear-gradient(135deg, rgba(23, 35, 60, 0.75), rgba(23, 105, 224, 0.45)), 
                  url('<%= request.getContextPath() %>/assets/hotel_bg.jpg') no-repeat center center;
      background-size: cover;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
    }
    
    .login-card {
      width: min(100%, 460px);
      background: rgba(255, 255, 255, 0.96);
      backdrop-filter: blur(8px);
      -webkit-backdrop-filter: blur(8px);
      border-radius: 16px;
      box-shadow: 0 15px 35px rgba(23, 35, 60, 0.25);
      border: 1px solid rgba(255, 255, 255, 0.3);
      padding: 35px 40px 30px;
      transition: all 0.3s ease;
    }
    
    .brand-center {
      display: flex;
      flex-direction: column;
      align-items: center;
      margin-bottom: 25px;
      text-align: center;
    }
    
    .brand-center .brand-logo {
      background: var(--brand);
      color: #fff;
      box-shadow: 0 8px 16px rgba(23, 105, 224, 0.25);
      width: 48px;
      height: 48px;
      border-radius: 12px;
      display: grid;
      place-items: center;
      margin-bottom: 10px;
    }
    
    .brand-center .brand-logo svg {
      width: 26px;
      height: 26px;
    }
    
    .brand-center .brand-name strong {
      color: var(--navy);
      font-size: 18px;
      letter-spacing: 0.05em;
    }
    
    .brand-center .brand-name small {
      color: var(--brand);
      font-weight: 700;
      font-size: 10px;
      letter-spacing: 0.2em;
    }
    
    .login-tabs {
      display: flex;
      border-bottom: 2px solid var(--line);
      margin-bottom: 25px;
    }
    
    .tab-btn {
      flex: 1;
      padding: 10px 0;
      text-align: center;
      background: none;
      border: none;
      font-weight: 600;
      font-size: 14px;
      color: var(--muted);
      cursor: pointer;
      position: relative;
      transition: color 0.2s;
    }
    
    .tab-btn:hover {
      color: var(--navy);
    }
    
    .tab-btn.active {
      color: var(--brand);
    }
    
    .tab-btn.active::after {
      content: '';
      position: absolute;
      bottom: -2px;
      left: 0;
      width: 100%;
      height: 2px;
      background: var(--brand);
      border-radius: 2px;
    }
    
    .form-container {
      display: none;
    }
    
    .form-container.active {
      display: block;
      animation: fadeIn 0.4s ease;
    }
    
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(8px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    .form-actions {
      margin-top: 22px;
    }
    
    .btn-submit-full {
      width: 100% !important;
      display: block !important;
      height: 44px;
      margin-top: 22px;
    }
    
    .login-footer-card {
      margin-top: 25px;
      border-top: 1px solid var(--line);
      padding-top: 15px;
      text-align: center;
      font-size: 11px;
      color: var(--muted);
    }
    
    .input-icon-group {
      position: relative;
    }
    
    .input-icon-group .form-control {
      padding-left: 40px;
    }
    
    .input-icon-group .input-icon {
      position: absolute;
      left: 14px;
      top: 50%;
      transform: translateY(-50%);
      color: var(--muted);
      pointer-events: none;
      width: 16px;
      height: 16px;
    }
    
    .input-icon-group .form-control:focus + .input-icon {
      color: var(--brand);
    }
  </style>
</head>
<body>
<div class="login-page">
  <div class="login-card">
    <div class="brand-center">
      <div class="brand-logo">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 21V8l8-5 8 5v13"/><path d="M8 21v-7h8v7M8 10h.01M12 10h.01M16 10h.01"/></svg>
      </div>
      <div class="brand-name"><strong>NESTORA</strong><small>HOTEL MANAGER</small></div>
    </div>
    
    <div class="login-tabs">
      <button type="button" class="tab-btn <%= "login".equals(activeTab) ? "active" : "" %>" id="btn-login" onclick="switchTab('login')">Đăng nhập</button>
      <button type="button" class="tab-btn <%= "register".equals(activeTab) ? "active" : "" %>" id="btn-register" onclick="switchTab('register')">Đăng ký</button>
    </div>

    <% String error = (String) request.getAttribute("error"); if (error != null) { %>
      <div class="alert alert-error"><%= error %></div>
    <% } %>
    <% String success = (String) request.getAttribute("success"); if (success != null) { %>
      <div class="alert alert-success"><%= success %></div>
    <% } %>

    <!-- FORM ĐĂNG NHẬP -->
    <div id="form-login" class="form-container <%= "login".equals(activeTab) ? "active" : "" %>">
      <form action="<%= request.getContextPath() %>/login" method="POST" autocomplete="on">
        <div class="form-group">
          <label class="form-label" for="email">Email hoặc Tên đăng nhập</label>
          <div class="input-icon-group">
            <input class="form-control" type="text" id="email" name="email" placeholder="Nhập email hoặc tên đăng nhập" required value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>">
            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
          </div>
        </div>
        <div class="form-group">
          <label class="form-label" for="password">Mật khẩu</label>
          <div class="input-icon-group">
            <input class="form-control" type="password" id="password" name="password" placeholder="Nhập mật khẩu" required>
            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
          </div>
        </div>
        <div class="login-options">
          <label><input type="checkbox" name="remember"> Ghi nhớ đăng nhập</label>
          <a href="#">Quên mật khẩu?</a>
        </div>
        <button class="btn btn-primary btn-submit-full" type="submit">Đăng nhập</button>
      </form>
    </div>

    <!-- FORM ĐĂNG KÝ -->
    <div id="form-register" class="form-container <%= "register".equals(activeTab) ? "active" : "" %>">
      <form action="<%= request.getContextPath() %>/register" method="POST" autocomplete="off">
        <div class="form-group">
          <label class="form-label" for="reg-fullName">Họ và tên *</label>
          <div class="input-icon-group">
            <input class="form-control" type="text" id="reg-fullName" name="fullName" placeholder="Nguyễn Văn A" required value="<%= request.getAttribute("regFullName") != null ? request.getAttribute("regFullName") : "" %>">
            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
          </div>
        </div>
        
        <div class="form-group">
          <label class="form-label" for="reg-username">Tên đăng nhập *</label>
          <div class="input-icon-group">
            <input class="form-control" type="text" id="reg-username" name="username" placeholder="Nhập tên đăng nhập" required value="<%= request.getAttribute("regUsername") != null ? request.getAttribute("regUsername") : "" %>">
            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="4"/><path d="M16 8v5a3 3 0 0 0 6 0v-1a10 10 0 1 0-3.92 7.94"/></svg>
          </div>
        </div>
        
        <div class="form-group">
          <label class="form-label" for="reg-email">Email *</label>
          <div class="input-icon-group">
            <input class="form-control" type="email" id="reg-email" name="email" placeholder="example@gmail.com" required value="<%= request.getAttribute("regEmail") != null ? request.getAttribute("regEmail") : "" %>">
            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
          </div>
        </div>
        
        <div class="form-group">
          <label class="form-label" for="reg-phone">Số điện thoại</label>
          <div class="input-icon-group">
            <input class="form-control" type="tel" id="reg-phone" name="phone" placeholder="Số điện thoại" value="<%= request.getAttribute("regPhone") != null ? request.getAttribute("regPhone") : "" %>">
            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
          </div>
        </div>
        
        <div class="form-group">
          <label class="form-label" for="reg-password">Mật khẩu *</label>
          <div class="input-icon-group">
            <input class="form-control" type="password" id="reg-password" name="password" placeholder="Nhập mật khẩu" required>
            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label" for="reg-confirmPassword">Xác nhận mật khẩu *</label>
          <div class="input-icon-group">
            <input class="form-control" type="password" id="reg-confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu" required>
            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
          </div>
        </div>

        <button class="btn btn-primary btn-submit-full" type="submit">Đăng ký</button>
      </form>
    </div>

    <div class="login-footer-card">
      © 2026 Nestora Hotel · Nền tảng quản trị nội bộ
    </div>
  </div>
</div>

<script>
  function switchTab(tab) {
      // Hide all forms
      document.querySelectorAll('.form-container').forEach(form => form.classList.remove('active'));
      // Deactivate all tab buttons
      document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
      
      // Activate selected
      document.getElementById('form-' + tab).classList.add('active');
      document.getElementById('btn-' + tab).classList.add('active');
  }

  // Set default tab based on server attribute
  document.addEventListener("DOMContentLoaded", function() {
      var activeTab = '<%= activeTab %>';
      switchTab(activeTab);
  });
</script>
</body>
</html>
