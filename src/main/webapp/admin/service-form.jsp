<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Service" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = (sess != null) ? (User) sess.getAttribute("currentUser") : null;
    
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }

    Service service = (Service) request.getAttribute("service"); // Null if Add, Not Null if Edit
    boolean isEdit = (service != null);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Sửa thông tin dịch vụ" : "Thêm dịch vụ mới" %> - Luxury Hotel</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <header>
        <div class="navbar">
            <div class="logo">🏨 LUXURY<span>HOTEL</span> <span style="font-size: 0.9rem; font-weight: normal; background-color: var(--accent); padding: 0.15rem 0.5rem; border-radius: var(--radius-sm); margin-left: 0.5rem;">ADMIN PANEL</span></div>
            <ul class="nav-links">
                <li><a href="<%= request.getContextPath() %>/home">Bảng điều khiển</a></li>
                <li><a href="<%= request.getContextPath() %>/rooms?action=list">Quản lý phòng</a></li>
                <li><a href="<%= request.getContextPath() %>/services?action=list" class="active">Quản lý dịch vụ</a></li>
                <li><a href="<%= request.getContextPath() %>/bills?action=list">Quản lý hóa đơn</a></li>
                <li class="user-info">
                    <span>Xin chào, <strong><%= currentUser.getFullName() %></strong></span>
                </li>
                <li><a href="<%= request.getContextPath() %>/logout" class="btn-logout">Đăng xuất</a></li>
            </ul>
        </div>
    </header>

    <div class="container" style="max-width: 600px;">
        <h2 class="section-title"><%= isEdit ? "Cập nhật thông tin dịch vụ" : "Thêm dịch vụ mới" %></h2>

        <div class="panel">
            <form action="<%= request.getContextPath() %>/services" method="POST">
                <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
                <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= service.getId() %>">
                <% } %>

                <div class="form-group">
                    <label class="form-label" for="name">Tên dịch vụ</label>
                    <input type="text" id="name" name="name" class="form-control" required
                           placeholder="Ví dụ: Giặt ủi, Buffet sáng, Spa..."
                           value="<%= isEdit ? service.getName() : "" %>">
                </div>

                <div class="form-group">
                    <label class="form-label" for="price">Giá dịch vụ (VNĐ)</label>
                    <input type="number" id="price" name="price" class="form-control" required min="0" step="5000"
                           placeholder="Ví dụ: 100000"
                           value="<%= isEdit ? (int) service.getPrice() : "" %>">
                </div>

                <div class="form-group">
                    <label class="form-label" for="description">Mô tả dịch vụ</label>
                    <textarea id="description" name="description" class="form-control" rows="4" 
                              placeholder="Chi tiết mô tả về dịch vụ..."><%= isEdit && service.getDescription() != null ? service.getDescription() : "" %></textarea>
                </div>

                <div style="display: flex; gap: 1rem; justify-content: flex-end; margin-top: 2rem;">
                    <a href="<%= request.getContextPath() %>/services?action=list" class="btn btn-secondary">Hủy bỏ</a>
                    <button type="submit" class="btn btn-primary">
                        <%= isEdit ? "Lưu thay đổi" : "Thêm dịch vụ" %>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <footer>
        <p>&copy; 2026 Luxury Hotel. Phát triển bởi Antigravity Pair Programmer.</p>
    </footer>

</body>
</html>
