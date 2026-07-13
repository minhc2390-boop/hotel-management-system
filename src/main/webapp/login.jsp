<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - Hotel Manage</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
    <div class="container" style="display: flex; align-items: center; justify-content: center; min-height: 80vh;">
        <div class="auth-container">
            <div class="auth-header">
                <h2>🏨 LUXURY HOTEL</h2>
                <p style="color: var(--text-light); margin-top: 0.5rem;">Quản lý khách sạn thông minh</p>
            </div>
            
            <% 
                String error = (String) request.getAttribute("error"); 
                if (error != null) { 
            %>
                <div class="error-message">
                    <%= error %>
                </div>
            <% 
                } 
            %>

            <% 
                String success = (String) request.getAttribute("success"); 
                if (success != null) { 
            %>
                <div class="success-message">
                    <%= success %>
                </div>
            <% 
                } 
            %>

            <form action="<%= request.getContextPath() %>/login" method="POST">
                <div class="form-group">
                    <label class="form-label" for="username">Tên đăng nhập</label>
                    <input type="text" id="username" name="username" class="form-control" 
                           placeholder="Nhập tên đăng nhập..." required 
                           value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>">
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="password">Mật khẩu</label>
                    <input type="password" id="password" name="password" class="form-control" 
                           placeholder="Nhập mật khẩu..." required>
                </div>
                
                <button type="submit" class="btn btn-primary btn-block" style="margin-top: 1.5rem;">
                    ĐĂNG NHẬP
                </button>
            </form>
            
            <div style="margin-top: 1.5rem; text-align: center; font-size: 0.9rem; color: var(--text-light);">
                <p>Tài khoản dùng thử:</p>
                <div style="background-color: var(--bg); padding: 0.5rem; border-radius: var(--radius-sm); margin-top: 0.5rem; text-align: left; font-family: monospace;">
                    <div>Admin: <strong>admin</strong> / password: <strong>admin123</strong></div>
                    <div>Lễ tân: <strong>receptionist</strong> / password: <strong>rep123</strong></div>
                    <div>Khách hàng: <strong>customer</strong> / password: <strong>cus123</strong></div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
