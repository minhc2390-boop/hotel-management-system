<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Đăng ký thành viên - Nestora Hotel & Resort</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <script>document.documentElement.setAttribute('data-theme', localStorage.getItem('nestora_theme') || 'light');</script>
    <style>
        /* Custom styling for luxury registration page */
        .register-container {
            min-height: 100vh;
            display: grid;
            grid-template-columns: minmax(450px, 45vw) 1fr;
            background: var(--canvas);
        }
        .register-visual {
            position: relative;
            background: url('<%= request.getContextPath() %>/assets/room_suite.jpg') no-repeat center center/cover;
            padding: 48px;
            color: #fff;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .register-visual::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: linear-gradient(135deg, rgba(15, 23, 42, 0.9), rgba(23, 105, 224, 0.4));
            z-index: 1;
        }
        .register-visual-content {
            position: relative;
            z-index: 2;
            max-width: 480px;
            margin-top: auto;
            margin-bottom: auto;
        }
        .register-visual-content h2 {
            font-size: 32px;
            font-weight: 800;
            line-height: 1.25;
            margin-bottom: 16px;
        }
        .register-visual-content p {
            font-size: 15px;
            color: rgba(255,255,255,0.85);
            line-height: 1.6;
        }
        .register-panel {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 24px;
            background: var(--canvas);
        }
        .register-card {
            width: min(100%, 500px);
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: 16px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.05);
        }
        .register-card h1 {
            font-size: 26px;
            font-weight: 800;
            color: var(--navy);
            margin: 0 0 8px;
        }
        .register-card > p {
            color: var(--muted);
            font-size: 14px;
            margin: 0 0 28px;
        }
        .input-icon-group {
            position: relative;
        }
        .input-icon-group .form-control {
            padding-left: 42px;
        }
        .input-icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            width: 18px;
            height: 18px;
            color: var(--muted);
            pointer-events: none;
        }
        .form-control:focus + .input-icon {
            color: var(--brand);
        }
        .btn-submit-full {
            width: 100%;
            min-height: 46px;
            margin-top: 10px;
            font-size: 14px;
            font-weight: 700;
        }
        @media (max-width: 900px) {
            .register-container { grid-template-columns: 1fr; }
            .register-visual { display: none; }
        }
    </style>
</head>
<body class="client-body">

<div class="register-container">
    <!-- Cột bên trái hiển thị ảnh quảng bá sang trọng -->
    <div class="register-visual">
        <a class="brand" href="<%= request.getContextPath() %>/home" aria-label="Về trang chủ Nestora" style="position: relative; z-index: 2;">
            <div class="brand-logo">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 21V8l8-5 8 5v13"/><path d="M8 21v-7h8v7"/></svg>
            </div>
            <div class="brand-name">
                <strong style="color: #fff;">NESTORA</strong>
                <small style="color: #c5a880; font-weight: 700; letter-spacing: 0.22em;">HOTEL & RESORT</small>
            </div>
        </a>
        <div class="register-visual-content">
            <h2>Gia nhập thành viên Nestora Club</h2>
            <p>Đăng ký tài khoản trực tuyến ngay hôm nay để nhận các đặc quyền ưu đãi dành riêng cho hội viên, tích lũy điểm thưởng và hưởng mức giá tốt nhất khi đặt phòng trực tiếp tại website của chúng tôi.</p>
        </div>
        <div style="position: relative; z-index: 2; font-size: 12px; color: rgba(255,255,255,0.6);">
            &copy; 2026 Nestora Hotel & Resort. Bảo lưu mọi quyền.
        </div>
    </div>

    <!-- Cột bên phải chứa form đăng ký -->
    <div class="register-panel">
        <div class="register-card">
            <h1>Đăng ký thành viên</h1>
            <p>Trải nghiệm dịch vụ nghỉ dưỡng thượng hạng cùng Nestora.</p>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error" style="margin-bottom: 20px;">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <form action="<%= request.getContextPath() %>/register" method="POST" autocomplete="off">
                <div class="form-grid" style="grid-template-columns: 1fr;">
                    <!-- Họ và tên -->
                    <div class="form-group">
                        <label class="form-label" for="reg-fullName">Họ và tên *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="text" id="reg-fullName" name="fullName" placeholder="Ví dụ: Nguyễn Văn A" required value="<%= request.getAttribute("regFullName") != null ? request.getAttribute("regFullName") : "" %>">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </div>
                    </div>
                    
                    <!-- Tên đăng nhập / Username -->
                    <div class="form-group">
                        <label class="form-label" for="reg-username">Tên đăng nhập *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="text" id="reg-username" name="username" placeholder="Nhập tên đăng nhập" required value="<%= request.getAttribute("regUsername") != null ? request.getAttribute("regUsername") : "" %>">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="4"/><path d="M16 8v5a3 3 0 0 0 6 0v-1a10 10 0 1 0-3.92 7.94"/></svg>
                        </div>
                    </div>
                    
                    <!-- Email -->
                    <div class="form-group">
                        <label class="form-label" for="reg-email">Địa chỉ Email *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="email" id="reg-email" name="email" placeholder="example@gmail.com" required value="<%= request.getAttribute("regEmail") != null ? request.getAttribute("regEmail") : "" %>">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        </div>
                    </div>
                    
                    <!-- Số điện thoại -->
                    <div class="form-group">
                        <label class="form-label" for="reg-phone">Số điện thoại *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="tel" id="reg-phone" name="phone" placeholder="Nhập số điện thoại" required value="<%= request.getAttribute("regPhone") != null ? request.getAttribute("regPhone") : "" %>">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                        </div>
                    </div>
                    
                    <!-- Mật khẩu -->
                    <div class="form-group">
                        <label class="form-label" for="reg-password">Mật khẩu *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="password" id="reg-password" name="password" placeholder="Nhập mật khẩu" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        </div>
                    </div>
                    
                    <!-- Xác nhận mật khẩu -->
                    <div class="form-group">
                        <label class="form-label" for="reg-confirmPassword">Xác nhận mật khẩu *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="password" id="reg-confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        </div>
                    </div>
                </div>

                <button class="btn btn-primary btn-submit-full" type="submit">Hoàn tất đăng ký</button>
                
                <div style="text-align: center; margin-top: 24px; font-size: 13px; color: var(--muted);">
                    Đã có tài khoản thành viên? 
                    <a href="<%= request.getContextPath() %>/login" style="color: var(--brand); font-weight: 700;">Đăng nhập ngay</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="<%= request.getContextPath() %>/js/app.js"></script>
</body>
</html>
