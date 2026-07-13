<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = (sess != null) ? (User) sess.getAttribute("currentUser") : null;
    
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }

    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    
    boolean isAdmin = "Admin".equals(currentUser.getRole());
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý phòng - Luxury Hotel</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <header>
        <div class="navbar">
            <div class="logo">🏨 LUXURY<span>HOTEL</span> <span style="font-size: 0.9rem; font-weight: normal; background-color: var(--accent); padding: 0.15rem 0.5rem; border-radius: var(--radius-sm); margin-left: 0.5rem;">ADMIN PANEL</span></div>
            <ul class="nav-links">
                <li><a href="<%= request.getContextPath() %>/home">Bảng điều khiển</a></li>
                <li><a href="<%= request.getContextPath() %>/rooms?action=list" class="active">Quản lý phòng</a></li>
                <li><a href="<%= request.getContextPath() %>/services?action=list">Quản lý dịch vụ</a></li>
                <li><a href="<%= request.getContextPath() %>/bills?action=list">Quản lý hóa đơn</a></li>
                <li class="user-info">
                    <span>Xin chào, <strong><%= currentUser.getFullName() %></strong></span>
                </li>
                <li><a href="<%= request.getContextPath() %>/logout" class="btn-logout">Đăng xuất</a></li>
            </ul>
        </div>
    </header>

    <div class="container">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem;">
            <h2 class="section-title" style="margin-bottom: 0;">Danh sách phòng khách sạn</h2>
            <% if (isAdmin) { %>
                <a href="<%= request.getContextPath() %>/rooms?action=add" class="btn btn-primary">
                    ➕ Thêm phòng mới
                </a>
            <% } %>
        </div>

        <% if (rooms != null && !rooms.isEmpty()) { %>
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Số phòng</th>
                            <th>Loại phòng</th>
                            <th>Giá thuê ngày</th>
                            <th>Sức chứa</th>
                            <th>Trạng thái</th>
                            <th>Mô tả phòng</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Room room : rooms) { %>
                            <tr>
                                <td><%= room.getId() %></td>
                                <td style="font-weight: 600;">Phòng <%= room.getRoomNumber() %></td>
                                <td><%= room.getRoomType().getName() %></td>
                                <td style="font-weight: 600; color: var(--accent);">
                                    <%= currencyFormat.format(room.getRoomType().getPricePerDay()) %>
                                </td>
                                <td>👥 <%= room.getRoomType().getCapacity() %> người</td>
                                <td>
                                    <% if ("Available".equals(room.getStatus())) { %>
                                        <span class="badge badge-available">Sẵn sàng</span>
                                    <% } else if ("Booked".equals(room.getStatus())) { %>
                                        <span class="badge badge-booked">Đã đặt / Thuê</span>
                                    <% } else { %>
                                        <span class="badge badge-maintenance">Bảo trì</span>
                                    <% } %>
                                </td>
                                <td>
                                    <span style="font-size: 0.9rem; color: var(--text-light);">
                                        <%= room.getDescription() != null ? room.getDescription() : "-" %>
                                    </span>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 0.5rem;">
                                        <a href="<%= request.getContextPath() %>/rooms?action=edit&id=<%= room.getId() %>" 
                                           class="btn btn-secondary" style="padding: 0.35rem 0.75rem; font-size: 0.85rem;">
                                            Sửa
                                        </a>
                                        <% if (isAdmin) { %>
                                            <a href="<%= request.getContextPath() %>/rooms?action=delete&id=<%= room.getId() %>" 
                                               class="btn btn-danger" style="padding: 0.35rem 0.75rem; font-size: 0.85rem;"
                                               onclick="return confirm('Bạn có chắc chắn muốn xóa phòng này?');">
                                                Xóa
                                            </a>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } else { %>
            <div style="text-align: center; padding: 4rem 2rem; background: white; border-radius: var(--radius-md); border: 1px solid var(--border);">
                <p style="color: var(--text-light); margin-bottom: 1.5rem;">Chưa có phòng nào trong hệ thống.</p>
                <% if (isAdmin) { %>
                    <a href="<%= request.getContextPath() %>/rooms?action=add" class="btn btn-primary">Thêm phòng ngay</a>
                <% } %>
            </div>
        <% } %>
    </div>

    <footer>
        <p>&copy; 2026 Luxury Hotel. Phát triển bởi Antigravity Pair Programmer.</p>
    </footer>

</body>
</html>
