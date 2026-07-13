<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="com.hotel.model.Service" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = (sess != null) ? (User) sess.getAttribute("currentUser") : null;
    List<Room> availableRooms = (List<Room>) request.getAttribute("availableRooms");
    List<Service> services = (List<Service>) request.getAttribute("services");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Luxury Hotel - Trang chủ</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <header>
        <div class="navbar">
            <div class="logo">🏨 LUXURY<span>HOTEL</span></div>
            <ul class="nav-links">
                <li><a href="<%= request.getContextPath() %>/home" class="active">Trang chủ</a></li>
                <% if (currentUser != null) { %>
                    <% if ("Admin".equals(currentUser.getRole()) || "Receptionist".equals(currentUser.getRole())) { %>
                        <li><a href="<%= request.getContextPath() %>/home">Bảng điều khiển</a></li>
                    <% } else { %>
                        <li><a href="<%= request.getContextPath() %>/bills?action=mybills">Phòng đã đặt</a></li>
                    <% } %>
                    <li class="user-info">
                        <span>Xin chào, <strong><%= currentUser.getFullName() %></strong> (<%= currentUser.getRole() %>)</span>
                    </li>
                    <li><a href="<%= request.getContextPath() %>/logout" class="btn-logout">Đăng xuất</a></li>
                <% } else { %>
                    <li><a href="<%= request.getContextPath() %>/login" class="btn btn-primary" style="padding: 0.4rem 1rem;">Đăng nhập</a></li>
                <% } %>
            </ul>
        </div>
    </header>

    <div class="container">
        <!-- Hero Section -->
        <div class="hero">
            <h1>Chào mừng đến với Luxury Hotel</h1>
            <p>Trải nghiệm dịch vụ nghỉ dưỡng đẳng cấp 5 sao với đầy đủ tiện nghi, hồ bơi vô cực, ẩm thực thượng hạng và dịch vụ chăm sóc khách hàng tận tâm.</p>
            <% if (currentUser == null) { %>
                <a href="<%= request.getContextPath() %>/login" class="btn btn-primary">Đặt phòng ngay</a>
            <% } %>
        </div>

        <!-- Available Rooms Section -->
        <h2 class="section-title">Danh sách phòng trống</h2>
        <div class="room-grid">
            <% 
                if (availableRooms != null && !availableRooms.isEmpty()) {
                    for (Room room : availableRooms) {
            %>
                <div class="room-card">
                    <div class="room-card-image">
                        <span class="badge badge-available room-badge">Sẵn sàng</span>
                    </div>
                    <div class="room-card-content">
                        <div class="room-type-title">Phòng <%= room.getRoomNumber() %> - <%= room.getRoomType().getName() %></div>
                        <div class="room-price">
                            <%= currencyFormat.format(room.getRoomType().getPricePerDay()) %><span>/ngày</span>
                        </div>
                        <div class="room-capacity">
                            👥 Tối đa: <%= room.getRoomType().getCapacity() %> người
                        </div>
                        <p class="room-desc">
                            <%= room.getDescription() != null ? room.getDescription() : room.getRoomType().getDescription() %>
                        </p>
                        
                        <% if (currentUser != null) { %>
                            <a href="<%= request.getContextPath() %>/rooms?action=bookForm&roomId=<%= room.getId() %>" class="btn btn-primary btn-block">
                                Đặt phòng này
                            </a>
                        <% } else { %>
                            <a href="<%= request.getContextPath() %>/login" class="btn btn-secondary btn-block">
                                Đăng nhập để đặt phòng
                            </a>
                        <% } %>
                    </div>
                </div>
            <% 
                    }
                } else {
            %>
                <div style="grid-column: 1/-1; text-align: center; padding: 3rem; background: white; border-radius: var(--radius-md); border: 1px solid var(--border);">
                    <p style="color: var(--text-light); font-size: 1.1rem;">Hiện tại khách sạn đã hết phòng trống. Vui lòng quay lại sau!</p>
                </div>
            <% } %>
        </div>

        <!-- Services Section -->
        <h2 class="section-title">Dịch vụ đi kèm</h2>
        <div class="room-grid">
            <% 
                if (services != null && !services.isEmpty()) {
                    for (Service service : services) {
            %>
                <div class="room-card" style="min-height: auto;">
                    <div class="room-card-content">
                        <div style="font-size: 1.5rem; margin-bottom: 0.5rem;">🛎️</div>
                        <div class="room-type-title"><%= service.getName() %></div>
                        <div class="room-price" style="font-size: 1.25rem;">
                            <%= currencyFormat.format(service.getPrice()) %>
                        </div>
                        <p class="room-desc" style="margin-bottom: 0;">
                            <%= service.getDescription() %>
                        </p>
                    </div>
                </div>
            <% 
                    }
                } else {
            %>
                <p style="color: var(--text-light); grid-column: 1/-1; text-align: center;">Chưa có dịch vụ nào.</p>
            <% } %>
        </div>
    </div>

    <footer>
        <p>&copy; 2026 Luxury Hotel. Phát triển bởi Antigravity Pair Programmer.</p>
    </footer>

</body>
</html>
