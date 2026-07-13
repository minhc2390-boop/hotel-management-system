<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Bill" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = (sess != null) ? (User) sess.getAttribute("currentUser") : null;
    List<Bill> bills = (List<Bill>) request.getAttribute("bills");
    
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    SimpleDateFormat dateOnly = new SimpleDateFormat("dd/MM/yyyy");

    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn đặt phòng của tôi - Luxury Hotel</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <header>
        <div class="navbar">
            <div class="logo">🏨 LUXURY<span>HOTEL</span></div>
            <ul class="nav-links">
                <li><a href="<%= request.getContextPath() %>/home">Trang chủ</a></li>
                <li><a href="<%= request.getContextPath() %>/bills?action=mybills" class="active">Phòng đã đặt</a></li>
                <li class="user-info">
                    <span>Xin chào, <strong><%= currentUser.getFullName() %></strong></span>
                </li>
                <li><a href="<%= request.getContextPath() %>/logout" class="btn-logout">Đăng xuất</a></li>
            </ul>
        </div>
    </header>

    <div class="container">
        <h2 class="section-title">Phòng đã đặt của bạn</h2>

        <% if (bills != null && !bills.isEmpty()) { %>
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Mã đơn</th>
                            <th>Ngày lập đơn</th>
                            <th>Ngày nhận phòng</th>
                            <th>Ngày trả phòng</th>
                            <th>Tổng chi phí</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Bill bill : bills) { %>
                            <tr>
                                <td>#<%= bill.getId() %></td>
                                <td><%= df.format(bill.getCreatedAt()) %></td>
                                <td><%= dateOnly.format(bill.getCheckInDate()) %></td>
                                <td><%= bill.getCheckOutDate() != null ? dateOnly.format(bill.getCheckOutDate()) : "-" %></td>
                                <td style="font-weight: 600; color: var(--accent);">
                                    <%= currencyFormat.format(bill.getTotalAmount()) %>
                                </td>
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
                                        Xem chi tiết
                                    </a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } else { %>
            <div style="text-align: center; padding: 4rem 2rem; background: white; border-radius: var(--radius-md); border: 1px solid var(--border);">
                <div style="font-size: 3rem; margin-bottom: 1rem;">🛏️</div>
                <h3>Bạn chưa đặt phòng nào</h3>
                <p style="color: var(--text-light); margin-top: 0.5rem; margin-bottom: 1.5rem;">Hãy khám phá các phòng trống của chúng tôi và chọn phòng nghỉ phù hợp.</p>
                <a href="<%= request.getContextPath() %>/home" class="btn btn-primary">Đặt phòng ngay</a>
            </div>
        <% } %>
    </div>

    <footer>
        <p>&copy; 2026 Luxury Hotel. Phát triển bởi Antigravity Pair Programmer.</p>
    </footer>

</body>
</html>
