<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quên mật khẩu - Nestora Hotel & Resort</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
  <script>document.documentElement.setAttribute('data-theme', localStorage.getItem('nestora_theme') || 'light');</script>
  <style>
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
      background: color-mix(in srgb, var(--surface) 96%, transparent);
      backdrop-filter: blur(8px);
      -webkit-backdrop-filter: blur(8px);
      border-radius: 16px;
      box-shadow: 0 15px 35px rgba(23, 35, 60, 0.25);
      border: 1px solid var(--line);
      padding: 35px 40px 30px;
      transition: all 0.3s ease;
    }
    
    .brand-center {
      display: flex;
      flex-direction: column;
      align-items: center;
      margin-bottom: 25px;
      text-align: center;
      text-decoration: none;
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

    .form-header {
      text-align: center;
      margin-bottom: 22px;
    }

    .form-header h3 {
      font-size: 20px;
      color: var(--navy);
      margin: 0 0 6px 0;
      font-weight: 700;
    }

    .form-header p {
      font-size: 13px;
      color: var(--muted);
      margin: 0;
      line-height: 1.5;
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
      font-size: 12px;
      color: var(--muted);
    }

    .login-footer-card a {
      color: var(--brand);
      text-decoration: none;
      font-weight: 600;
    }

    .login-footer-card a:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body class="client-body">
<div class="login-page">
  <div class="login-card">
    <a class="brand-center" href="<%= request.getContextPath() %>/home" aria-label="Về trang chủ Nestora">
      <div class="brand-logo">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 21V8l8-5 8 5v13"/><path d="M8 21v-7h8v7M8 10h.01M12 10h.01M16 10h.01"/></svg>
      </div>
      <div class="brand-name"><strong>NESTORA</strong><small>HOTEL &amp; RESORT</small></div>
    </a>

    <div class="form-header">
      <h3>Quên mật khẩu?</h3>
      <p>Nhập địa chỉ email đăng ký tài khoản của bạn để nhận liên kết khôi phục mật khẩu (hiệu lực 15 phút).</p>
    </div>

    <% String error = (String) request.getAttribute("error"); if (error != null) { %>
      <div class="alert alert-error" style="margin-bottom: 20px;"><%= error %></div>
    <% } %>
    <% String success = (String) request.getAttribute("success"); if (success != null) { %>
      <div class="alert alert-success" style="margin-bottom: 20px;"><%= success %></div>
    <% } %>

    <form action="<%= request.getContextPath() %>/forgot-password" method="POST" accept-charset="UTF-8">
      <div class="form-group">
        <label class="form-label" for="email">Địa chỉ Email đăng ký *</label>
        <div class="input-icon-group">
          <input class="form-control" type="email" id="email" name="email" placeholder="example@gmail.com" required value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>">
          <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
        </div>
      </div>

      <button class="btn btn-primary btn-submit-full" type="submit">Gửi liên kết khôi phục</button>
    </form>

    <div class="login-footer-card">
      Quay lại <a href="<%= request.getContextPath() %>/login">Đăng nhập</a>
    </div>
  </div>
</div>

<script src="<%= request.getContextPath() %>/js/app.js"></script>
</body>
</html>
