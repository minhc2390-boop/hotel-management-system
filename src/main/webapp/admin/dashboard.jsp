<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="com.hotel.model.Bill" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = (sess != null) ? (User) sess.getAttribute("currentUser") : null;
    
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }

    // Stats
    int totalRooms = (Integer) request.getAttribute("totalRooms");
    long availableRooms = (Long) request.getAttribute("availableRooms");
    long bookedRooms = (Long) request.getAttribute("bookedRooms");
    long maintenanceRooms = (Long) request.getAttribute("maintenanceRooms");
    int totalUsers = (Integer) request.getAttribute("totalUsers");
    int totalBills = (Integer) request.getAttribute("totalBills");
    double totalRevenue = (Double) request.getAttribute("totalRevenue");
    
    List<Bill> recentBills = (List<Bill>) request.getAttribute("bills");
    
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảng quản trị - Luxury Hotel</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <header>
        <div class="navbar">
            <div class="logo">🏨 LUXURY<span>HOTEL</span> <span style="font-size: 0.9rem; font-weight: normal; background-color: var(--accent); padding: 0.15rem 0.5rem; border-radius: var(--radius-sm); margin-left: 0.5rem;">ADMIN PANEL</span></div>
            <ul class="nav-links">
                <li><a href="<%= request.getContextPath() %>/home" class="active">Bảng điều khiển</a></li>
                <li><a href="<%= request.getContextPath() %>/rooms?action=list">Quản lý phòng</a></li>
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
            <h2 class="section-title" style="margin-bottom: 0;">Thống kê tổng quan</h2>
            <a href="<%= request.getContextPath() %>/home" class="btn btn-secondary" style="font-size: 0.9rem;">
                👁️ Xem trang Khách hàng
            </a>
        </div>

        <!-- Dashboard Stats Grid -->
        <div class="dashboard-grid">
            <div class="dash-card accent">
                <span class="dash-card-title">Doanh thu phòng (Paid)</span>
                <span class="dash-card-value" style="color: var(--accent); font-size: 1.6rem;"><%= currencyFormat.format(totalRevenue) %></span>
            </div>
            <div class="dash-card info">
                <span class="dash-card-title">Phòng trống sẵn sàng</span>
                <span class="dash-card-value"><%= availableRooms %> / <%= totalRooms %></span>
            </div>
            <div class="dash-card success">
                <span class="dash-card-title">Phòng đang thuê</span>
                <span class="dash-card-value"><%= bookedRooms %></span>
            </div>
            <div class="dash-card danger">
                <span class="dash-card-title">Phòng bảo trì</span>
                <span class="dash-card-value"><%= maintenanceRooms %></span>
            </div>
            <div class="dash-card">
                <span class="dash-card-title">Tổng số tài khoản</span>
                <span class="dash-card-value"><%= totalUsers %></span>
            </div>
        </div>

        <!-- Recent Booking Activities -->
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
            <h3 style="font-weight: 700; color: var(--primary);">Hoạt động đặt phòng gần đây</h3>
            <a href="<%= request.getContextPath() %>/bills?action=list" style="color: var(--accent); font-weight: 600; font-size: 0.95rem;">Xem tất cả hóa đơn &rarr;</a>
        </div>

        <% if (recentBills != null && !recentBills.isEmpty()) { %>
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Mã đơn</th>
                            <th>Khách hàng</th>
                            <th>Ngày lập</th>
                            <th>Check-in</th>
                            <th>Check-out</th>
                            <th>Tổng tiền</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            int limit = Math.min(recentBills.size(), 5);
                            for (int i = 0; i < limit; i++) {
                                Bill bill = recentBills.get(i);
                        %>
                            <tr>
                                <td>#<%= bill.getId() %></td>
                                <td>
                                    <div style="font-weight: 600;"><%= bill.getUser().getFullName() %></div>
                                    <div style="font-size: 0.8rem; color: var(--text-light);"><%= bill.getUser().getEmail() %></div>
                                </td>
                                <td><%= df.format(bill.getCreatedAt()) %></td>
                                <td><%= new SimpleDateFormat("dd/MM/yyyy").format(bill.getCheckInDate()) %></td>
                                <td><%= bill.getCheckOutDate() != null ? new SimpleDateFormat("dd/MM/yyyy").format(bill.getCheckOutDate()) : "-" %></td>
                                <td style="font-weight: 600; color: var(--accent);"><%= currencyFormat.format(bill.getTotalAmount()) %></td>
                                <td>
                                    <% if ("Paid".equals(bill.getStatus())) { %>
                                        <span class="badge badge-paid">Đã thanh toán</span>
                                    <% } else if ("Unpaid".equals(bill.getStatus())) { %>
                                        <span class="badge badge-unpaid">Chưa thanh toán</span>
                                    <% } else { %>
                                        <span class="badge badge-cancelled">Đã hủy</span>
                                    <% } %>
                                </td>
                                <td>
                                    <a href="<%= request.getContextPath() %>/bills?action=detail&id=<%= bill.getId() %>" class="btn btn-secondary" style="padding: 0.35rem 0.75rem; font-size: 0.85rem;">
                                        Xử lý
                                    </a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } else { %>
            <div style="text-align: center; padding: 3rem; background: white; border-radius: var(--radius-md); border: 1px solid var(--border);">
                <p style="color: var(--text-light);">Chưa có hoạt động giao dịch nào.</p>
            </div>
        <% } %>
    </div>

    <footer>
        <p>&copy; 2026 Luxury Hotel. Phát triển bởi Antigravity Pair Programmer.</p>
    </footer>

</body>
</html>
