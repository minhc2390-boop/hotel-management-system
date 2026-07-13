<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Bill" %>
<%@ page import="com.hotel.model.BillDetail" %>
<%@ page import="com.hotel.model.Service" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = (sess != null) ? (User) sess.getAttribute("currentUser") : null;
    Bill bill = (Bill) request.getAttribute("bill");
    List<BillDetail> details = (List<BillDetail>) request.getAttribute("details");
    List<Service> services = (List<Service>) request.getAttribute("services");
    
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    SimpleDateFormat dateOnly = new SimpleDateFormat("dd/MM/yyyy");

    if (currentUser == null || bill == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    boolean isAdminOrRep = "Admin".equals(currentUser.getRole()) || "Receptionist".equals(currentUser.getRole());
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết hóa đơn #<%= bill.getId() %> - Luxury Hotel</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <header>
        <div class="navbar">
            <div class="logo">🏨 LUXURY<span>HOTEL</span></div>
            <ul class="nav-links">
                <li><a href="<%= request.getContextPath() %>/home">Trang chủ</a></li>
                <% if (isAdminOrRep) { %>
                    <li><a href="<%= request.getContextPath() %>/home" class="active">Bảng điều khiển</a></li>
                <% } else { %>
                    <li><a href="<%= request.getContextPath() %>/bills?action=mybills" class="active">Phòng đã đặt</a></li>
                <% } %>
                <li class="user-info">
                    <span>Xin chào, <strong><%= currentUser.getFullName() %></strong></span>
                </li>
                <li><a href="<%= request.getContextPath() %>/logout" class="btn-logout">Đăng xuất</a></li>
            </ul>
        </div>
    </header>

    <div class="container">
        <h2 class="section-title">Chi tiết đơn hàng #<%= bill.getId() %></h2>

        <div class="bill-container">
            <!-- Left Panel: Bill Items & Ordered Services -->
            <div>
                <div class="panel">
                    <h3 class="panel-title">Hạng mục thanh toán</h3>
                    <div class="table-responsive" style="box-shadow: none; border-radius: 0; border: none;">
                        <table style="width: 100%;">
                            <thead>
                                <tr>
                                    <th>Hạng mục</th>
                                    <th>Giá đơn vị</th>
                                    <th>Số lượng / Số ngày</th>
                                    <th style="text-align: right;">Thành tiền</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    if (details != null) {
                                        for (BillDetail bd : details) { 
                                            double lineTotal = bd.getPrice() * bd.getQuantity();
                                %>
                                    <tr>
                                        <td>
                                            <% if (bd.getRoomId() != null) { %>
                                                🏨 Phòng <%= bd.getRoom() != null ? bd.getRoom().getRoomNumber() : bd.getRoomId() %> (Thuê phòng)
                                            <% } else if (bd.getServiceId() != null) { %>
                                                🛎️ <%= bd.getService() != null ? bd.getService().getName() : bd.getServiceId() %> (Dịch vụ)
                                            <% } else { %>
                                                Khác
                                            <% } %>
                                        </td>
                                        <td><%= currencyFormat.format(bd.getPrice()) %></td>
                                        <td><%= bd.getQuantity() %></td>
                                        <td style="text-align: right; font-weight: 600;">
                                            <%= currencyFormat.format(lineTotal) %>
                                        </td>
                                    </tr>
                                <% 
                                        } 
                                    } 
                                %>
                            </tbody>
                        </table>
                    </div>

                    <div class="total-amount-large">
                        Tổng cộng: <%= currencyFormat.format(bill.getTotalAmount()) %>
                    </div>
                </div>

                <!-- Order Services Form (Only if Unpaid) -->
                <% if ("Unpaid".equals(bill.getStatus())) { %>
                    <div class="panel">
                        <h3 class="panel-title">Gọi thêm dịch vụ khách sạn</h3>
                        <form action="<%= request.getContextPath() %>/bills" method="POST">
                            <input type="hidden" name="action" value="addService">
                            <input type="hidden" name="billId" value="<%= bill.getId() %>">
                            
                            <div style="display: grid; grid-template-columns: 2fr 1fr 1fr; gap: 1.5rem; align-items: flex-end;">
                                <div class="form-group" style="margin-bottom: 0;">
                                    <label class="form-label" for="serviceId">Chọn dịch vụ</label>
                                    <select id="serviceId" name="serviceId" class="form-control" required>
                                        <option value="">-- Chọn dịch vụ --</option>
                                        <% 
                                            if (services != null) {
                                                for (Service s : services) {
                                        %>
                                            <option value="<%= s.getId() %>">
                                                <%= s.getName() %> - <%= currencyFormat.format(s.getPrice()) %>
                                            </option>
                                        <% 
                                                }
                                            } 
                                        %>
                                    </select>
                                </div>
                                <div class="form-group" style="margin-bottom: 0;">
                                    <label class="form-label" for="quantity">Số lượng</label>
                                    <input type="number" id="quantity" name="quantity" class="form-control" min="1" value="1" required>
                                </div>
                                <button type="submit" class="btn btn-primary">Thêm dịch vụ</button>
                            </div>
                        </form>
                    </div>
                <% } %>
            </div>

            <!-- Right Panel: Customer Info & Status -->
            <div>
                <div class="panel">
                    <h3 class="panel-title">Thông tin chung</h3>
                    <div class="info-list" style="margin-bottom: 1.5rem;">
                        <div class="info-item">
                            <span class="info-label">Trạng thái đơn:</span>
                            <span>
                                <% if ("Paid".equals(bill.getStatus())) { %>
                                    <span class="badge badge-paid">Đã thanh toán</span>
                                <% } else if ("Unpaid".equals(bill.getStatus())) { %>
                                    <span class="badge badge-unpaid">Chưa thanh toán</span>
                                <% } else { %>
                                    <span class="badge badge-cancelled">Đã hủy</span>
                                <% } %>
                            </span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Ngày tạo:</span>
                            <span class="info-value"><%= df.format(bill.getCreatedAt()) %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Ngày nhận phòng:</span>
                            <span class="info-value"><%= dateOnly.format(bill.getCheckInDate()) %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Ngày trả phòng:</span>
                            <span class="info-value"><%= dateOnly.format(bill.getCheckOutDate()) %></span>
                        </div>
                    </div>

                    <h3 class="panel-title" style="font-size: 1.1rem; margin-top: 1.5rem;">Khách hàng</h3>
                    <div class="info-list" style="margin-bottom: 2rem;">
                        <div class="info-item">
                            <span class="info-label">Họ tên:</span>
                            <span class="info-value"><%= bill.getUser().getFullName() %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Email:</span>
                            <span class="info-value" style="font-size: 0.85rem;"><%= bill.getUser().getEmail() %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Điện thoại:</span>
                            <span class="info-value"><%= bill.getUser().getPhone() != null ? bill.getUser().getPhone() : "Chưa có" %></span>
                        </div>
                    </div>

                    <!-- Actions -->
                    <div style="display: flex; flex-direction: column; gap: 0.75rem;">
                        <% if ("Unpaid".equals(bill.getStatus())) { %>
                            <% if (isAdminOrRep) { %>
                                <a href="<%= request.getContextPath() %>/bills?action=pay&id=<%= bill.getId() %>" 
                                   class="btn btn-primary btn-block" style="background-color: var(--success); color: white;">
                                    💳 Xác nhận thanh toán
                                </a>
                            <% } %>
                            <a href="<%= request.getContextPath() %>/bills?action=cancel&id=<%= bill.getId() %>" 
                               class="btn btn-danger btn-block" 
                               onclick="return confirm('Bạn có chắc chắn muốn hủy đơn hàng này?');">
                                ❌ Hủy đơn phòng
                            </a>
                        <% } %>
                        
                        <% if (isAdminOrRep) { %>
                            <a href="<%= request.getContextPath() %>/bills?action=list" class="btn btn-secondary btn-block">Quay lại danh sách</a>
                        <% } else { %>
                            <a href="<%= request.getContextPath() %>/bills?action=mybills" class="btn btn-secondary btn-block">Quay lại đơn của tôi</a>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer>
        <p>&copy; 2026 Luxury Hotel. Phát triển bởi Antigravity Pair Programmer.</p>
    </footer>

</body>
</html>
