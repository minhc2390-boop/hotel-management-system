<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đặt lại mật khẩu - Nestora Hotel & Resort</title>
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

    .recovery-icon {
      width: 64px;
      height: 64px;
      display: grid;
      place-items: center;
      margin: 0 auto 16px;
      border-radius: 20px;
      color: var(--brand);
      background: var(--brand-soft);
      box-shadow: inset 0 0 0 1px color-mix(in srgb, var(--brand) 18%, transparent);
    }
    .recovery-icon svg { width: 30px; height: 30px; }
    .recovery-kicker {
      display: inline-block;
      margin-bottom: 7px;
      color: var(--brand);
      font-size: 10px;
      font-weight: 800;
      letter-spacing: .16em;
      text-transform: uppercase;
    }
    .password-field .form-control { padding-right: 44px; }
    .password-toggle {
      position: absolute;
      top: 50%;
      right: 9px;
      width: 34px;
      height: 34px;
      display: grid;
      place-items: center;
      transform: translateY(-50%);
      border: 0;
      border-radius: 8px;
      color: var(--muted);
      background: transparent;
    }
    .password-toggle:hover { color: var(--brand); background: var(--brand-soft); }
    .password-toggle svg { width: 18px; height: 18px; }
    .password-rules {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 7px 12px;
      margin: 12px 0 18px;
      padding: 13px 14px;
      border: 1px solid var(--line);
      border-radius: 10px;
      color: var(--muted);
      background: var(--canvas);
      font-size: 11px;
    }
    .password-rule::before { content: '○'; margin-right: 6px; color: var(--muted); }
    .password-rule.valid { color: var(--success); }
    .password-rule.valid::before { content: '✓'; color: var(--success); }
    .password-match { min-height: 18px; margin-top: 6px; color: var(--muted); font-size: 11px; }
    .password-match.valid { color: var(--success); }
    .password-match.invalid { color: var(--danger); }
    @media (max-width: 520px) {
      .login-card { padding: 28px 22px 24px; }
      .login-page { align-items: flex-start; padding-top: 28px; }
      .password-rules { grid-template-columns: 1fr; }
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
      <div class="recovery-icon" aria-hidden="true">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="10" width="18" height="11" rx="2"/><path d="M7 10V7a5 5 0 0 1 10 0v3"/><path d="M12 14v3"/></svg>
      </div>
      <span class="recovery-kicker">Bảo mật tài khoản</span>
      <h3>Đặt lại mật khẩu</h3>
      <p>Vui lòng nhập mật khẩu mới cho tài khoản của bạn.</p>
    </div>

    <% String error = (String) request.getAttribute("error"); if (error != null) { %>
      <div class="alert alert-error" role="alert" style="margin-bottom: 20px;"><%= error %></div>
    <% } %>
    <% String success = (String) request.getAttribute("success"); if (success != null) { %>
      <div class="alert alert-success" role="status" style="margin-bottom: 20px;"><%= success %></div>
    <% } %>

    <form action="<%= request.getContextPath() %>/reset-password" method="POST" accept-charset="UTF-8">
      <input type="hidden" name="token" value="<%= request.getAttribute("token") != null ? request.getAttribute("token") : request.getParameter("token") %>">

      <div class="form-group" style="margin-bottom: 16px;">
        <label class="form-label" for="newPassword">Mật khẩu mới *</label>
        <div class="input-icon-group password-field">
          <input class="form-control" type="password" id="newPassword" name="newPassword" minlength="6" autocomplete="new-password" placeholder="Nhập mật khẩu mới (ít nhất 6 ký tự)" required>
          <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
          <button class="password-toggle" type="button" data-password-toggle="newPassword" aria-label="Hiện mật khẩu">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></svg>
          </button>
        </div>
      </div>

      <div class="password-rules" aria-label="Gợi ý tạo mật khẩu mạnh">
        <span class="password-rule" data-password-rule="length">Ít nhất 6 ký tự</span>
        <span class="password-rule" data-password-rule="letter">Có chữ cái</span>
        <span class="password-rule" data-password-rule="number">Có chữ số</span>
        <span class="password-rule" data-password-rule="space">Không chứa khoảng trắng</span>
      </div>

      <div class="form-group">
        <label class="form-label" for="confirmPassword">Xác nhận mật khẩu mới *</label>
        <div class="input-icon-group password-field">
          <input class="form-control" type="password" id="confirmPassword" name="confirmPassword" minlength="6" autocomplete="new-password" placeholder="Nhập lại mật khẩu mới" required>
          <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
          <button class="password-toggle" type="button" data-password-toggle="confirmPassword" aria-label="Hiện mật khẩu xác nhận">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></svg>
          </button>
        </div>
        <div class="password-match" id="passwordMatch" aria-live="polite"></div>
      </div>

      <button class="btn btn-primary btn-submit-full" type="submit">Lưu mật khẩu mới</button>
    </form>

    <div class="login-footer-card">
      Quay lại <a href="<%= request.getContextPath() %>/login">Đăng nhập</a>
    </div>
  </div>
</div>

<script src="<%= request.getContextPath() %>/js/app.js"></script>
<script>
  const newPasswordInput = document.getElementById('newPassword');
  const confirmPasswordInput = document.getElementById('confirmPassword');
  const passwordMatch = document.getElementById('passwordMatch');

  document.querySelectorAll('[data-password-toggle]').forEach(button => {
    button.addEventListener('click', () => {
      const input = document.getElementById(button.dataset.passwordToggle);
      const showPassword = input.type === 'password';
      input.type = showPassword ? 'text' : 'password';
      button.setAttribute('aria-label', showPassword ? 'Ẩn mật khẩu' : 'Hiện mật khẩu');
    });
  });

  function updatePasswordGuide() {
    const password = newPasswordInput.value;
    const rules = {
      length: password.length >= 6,
      letter: /[A-Za-zÀ-ỹ]/.test(password),
      number: /\d/.test(password),
      space: password.length > 0 && !/\s/.test(password)
    };
    Object.keys(rules).forEach(rule => {
      const element = document.querySelector('[data-password-rule="' + rule + '"]');
      if (element) element.classList.toggle('valid', rules[rule]);
    });

    const confirmation = confirmPasswordInput.value;
    passwordMatch.className = 'password-match';
    if (!confirmation) {
      passwordMatch.textContent = '';
    } else if (password === confirmation) {
      passwordMatch.textContent = '✓ Mật khẩu xác nhận đã khớp.';
      passwordMatch.classList.add('valid');
    } else {
      passwordMatch.textContent = 'Mật khẩu xác nhận chưa khớp.';
      passwordMatch.classList.add('invalid');
    }
  }

  newPasswordInput.addEventListener('input', updatePasswordGuide);
  confirmPasswordInput.addEventListener('input', updatePasswordGuide);
</script>
</body>
</html>
