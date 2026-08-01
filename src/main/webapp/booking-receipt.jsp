<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.Booking" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Booking booking = (Booking) request.getAttribute("booking");
    if (booking == null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    
    // Tính số ngày lưu trú
    long diffMs = booking.getCheckOutDate().getTime() - booking.getCheckInDate().getTime();
    long days = diffMs / (1000 * 60 * 60 * 24);
    if (days <= 0) days = 1;
    
    double totalAmount = days * booking.getRoomPrice();
    
    NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    
    User currentUser = (User) session.getAttribute("currentUser");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Phiếu Đặt Phòng #DP<%= booking.getBookingId() %> - Nestora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        :root {
            --accent-gold: #c5a880;
            --accent-gold-dark: #b09168;
            --luxury-navy: #0f172a;
            --luxury-slate: #1e293b;
        }
        /* Header kính mờ đồng bộ */
        .luxury-header {
            height: 80px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 clamp(24px, 5vw, 80px);
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border-bottom: 1px solid rgba(220, 229, 241, 0.7);
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .luxury-brand {
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .luxury-brand .brand-logo {
            background: linear-gradient(135deg, var(--luxury-navy), var(--brand));
            box-shadow: 0 4px 12px rgba(15, 23, 42, 0.15);
        }
        .luxury-brand .brand-name strong {
            color: var(--luxury-navy);
            font-size: 21px;
            letter-spacing: 0.05em;
        }
        .luxury-brand .brand-name small {
            color: var(--accent-gold-dark);
            font-weight: 700;
            letter-spacing: 0.26em;
        }
        .luxury-nav a {
            padding: 10px 18px;
            border-radius: 8px;
            color: var(--text);
            font-size: 14px;
            font-weight: 600;
            transition: all 0.25s ease;
        }
        .luxury-nav a:hover {
            color: var(--brand);
            background: var(--brand-soft);
        }
        .luxury-nav a.nav-cta {
            background: linear-gradient(135deg, var(--brand), var(--brand-dark));
            color: #fff;
            box-shadow: 0 4px 12px rgba(23, 105, 224, 0.2);
        }
        .luxury-nav a.nav-cta:hover {
            background: var(--luxury-navy);
            transform: translateY(-1px);
        }

        .receipt-card {
            max-width: 650px;
            margin: 40px auto;
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            border: 1px solid var(--line);
            overflow: hidden;
        }
        .receipt-header {
            background: var(--navy);
            color: #fff;
            padding: 30px;
            text-align: center;
            position: relative;
        }
        .receipt-header .logo {
            font-size: 24px;
            font-weight: 800;
            letter-spacing: 0.1em;
            margin-bottom: 5px;
        }
        .receipt-header .title {
            font-size: 16px;
            opacity: 0.8;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .receipt-body {
            padding: 40px;
        }
        .receipt-section {
            margin-bottom: 30px;
            border-bottom: 1px dashed var(--line);
            padding-bottom: 20px;
        }
        .receipt-section:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }
        .receipt-section-title {
            font-size: 14px;
            color: var(--brand);
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 15px;
        }
        .receipt-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
            font-size: 15px;
        }
        .receipt-row span {
            color: var(--muted);
        }
        .receipt-row strong {
            color: var(--navy);
            text-align: right;
        }
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }
        .status-Pending { background: #fef3c7; color: #d97706; }
        .status-Confirmed { background: #d1fae5; color: #059669; }
        .status-CheckedIn { background: #dbeafe; color: #2563eb; }
        .status-CheckedOut { background: #f3f4f6; color: #4b5563; }
        .status-Cancelled { background: #fee2e2; color: #dc2626; }
        
        .receipt-total {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 18px;
            font-weight: 800;
            color: var(--navy);
            background: #f8fafc;
            padding: 20px;
            border-radius: 8px;
            margin-top: 20px;
        }
        .receipt-total .amount {
            color: var(--brand);
            font-size: 22px;
        }
        .receipt-actions {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 30px;
        }
        @media print {
            body { background: #fff; }
            .receipt-card { border: none; box-shadow: none; margin: 0; max-width: 100%; }
            .receipt-actions, .luxury-header { display: none !important; }
        }
    </style>
</head>
<body>
    <header class="luxury-header">
        <a href="<%= request.getContextPath() %>/home" class="luxury-brand">
            <div class="brand-logo">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 21V8l8-5 8 5v13"/><path d="M8 21v-7h8v7"/></svg>
            </div>
            <div class="brand-name">
                <strong>NESTORA</strong>
                <small>HOTEL & RESORT</small>
            </div>
        </a>
        <nav class="luxury-nav" style="display: flex; align-items: center; gap: 8px;">
            <a href="<%= request.getContextPath() %>/home">Trang chủ</a>
            <% if (currentUser != null) { %>
                <% if ("Admin".equals(currentUser.getRole()) || "Receptionist".equals(currentUser.getRole())) { %>
                    <a href="<%= request.getContextPath() %>/bookings?action=list">Trang quản trị</a>
                <% } else { %>
                    <a href="<%= request.getContextPath() %>/bookings?action=mybookings">Lịch sử đặt phòng</a>
                    <a href="<%= request.getContextPath() %>/profile">Hồ sơ thành viên</a>
                <% } %>
                <a href="<%= request.getContextPath() %>/logout" class="nav-cta">Đăng xuất</a>
            <% } else { %>
                <a href="<%= request.getContextPath() %>/login" class="nav-cta">Đăng nhập</a>
            <% } %>
        </nav>
    </header>

    <main class="public-content">
        <div class="receipt-card">
            <div class="receipt-header">
                <div class="logo">NESTORA HOTEL</div>
                <div class="title">Phiếu Xác Nhận Đặt Phòng</div>
            </div>
            <div class="receipt-body">
                <!-- Mã đặt phòng và Trạng thái -->
                <div class="receipt-section">
                    <div class="receipt-row">
                        <span>Mã đặt phòng</span>
                        <strong>#DP<%= booking.getBookingId() %></strong>
                    </div>
                    <div class="receipt-row">
                        <span>Trạng thái</span>
                        <strong>
                            <%
                                String statusText = "Chờ xác nhận";
                                if ("Confirmed".equals(booking.getStatus())) statusText = "Đã xác nhận";
                                else if ("CheckedIn".equals(booking.getStatus())) statusText = "Đã nhận phòng";
                                else if ("CheckedOut".equals(booking.getStatus())) statusText = "Đã trả phòng";
                                else if ("Cancelled".equals(booking.getStatus())) statusText = "Đã hủy";
                            %>
                            <span class="status-badge status-<%= booking.getStatus() %>"><%= statusText %></span>
                        </strong>
                    </div>
                    <div class="receipt-row">
                        <span>Ngày đặt phiếu</span>
                        <strong><%= sdf.format(booking.getCheckInDate()) %></strong>
                    </div>
                </div>

                <!-- Thông tin khách hàng -->
                <div class="receipt-section">
                    <div class="receipt-section-title">Thông tin khách lưu trú</div>
                    <div class="receipt-row">
                        <span>Họ và tên</span>
                        <strong><%= booking.getCustomer().getCustomerName() %></strong>
                    </div>
                    <div class="receipt-row">
                        <span>Số điện thoại</span>
                        <strong><%= booking.getCustomer().getCustomerPhone() != null ? booking.getCustomer().getCustomerPhone() : "N/A" %></strong>
                    </div>
                    <div class="receipt-row">
                        <span>Email</span>
                        <strong><%= booking.getCustomer().getCustomerEmail() != null ? booking.getCustomer().getCustomerEmail() : "N/A" %></strong>
                    </div>
                    <% if (booking.getCustomer().getCustomerCccd() != null && !booking.getCustomer().getCustomerCccd().isEmpty()) { %>
                    <div class="receipt-row">
                        <span>Số CCCD/CMND</span>
                        <strong><%= booking.getCustomer().getCustomerCccd() %></strong>
                    </div>
                    <% } %>
                </div>

                <!-- Chi tiết phòng và thời gian lưu trú -->
                <div class="receipt-section">
                    <div class="receipt-section-title">Chi tiết đặt phòng</div>
                    <div class="receipt-row">
                        <span>Phòng số</span>
                        <strong>Phòng <%= booking.getRoom().getRoomNumber() %></strong>
                    </div>
                    <div class="receipt-row">
                        <span>Loại phòng</span>
                        <strong><%= booking.getRoom().getRoomType().getName() %></strong>
                    </div>
                    <div class="receipt-row">
                        <span>Giá mỗi đêm</span>
                        <strong><%= money.format(booking.getRoomPrice()) %></strong>
                    </div>
                    <div class="receipt-row">
                        <span>Thời gian nhận phòng</span>
                        <strong><%= sdf.format(booking.getCheckInDate()) %> (từ 14:00)</strong>
                    </div>
                    <div class="receipt-row">
                        <span>Thời gian trả phòng</span>
                        <strong><%= sdf.format(booking.getCheckOutDate()) %> (trước 12:00)</strong>
                    </div>
                    <div class="receipt-row">
                        <span>Tổng số ngày lưu trú</span>
                        <strong><%= days %> ngày</strong>
                    </div>
                    <% if (booking.getNote() != null && !booking.getNote().isEmpty()) { %>
                    <div class="receipt-row">
                        <span>Ghi chú</span>
                        <strong style="font-weight: normal; font-style: italic; max-width: 70%; text-align: right;"><%= booking.getNote() %></strong>
                    </div>
                    <% } %>
                </div>

                <!-- Tổng thanh toán dự kiến -->
                <div class="receipt-total">
                    <span>Tổng tạm tính</span>
                    <span class="amount"><%= money.format(totalAmount) %></span>
                </div>

                <!-- Hành động -->
                <div class="receipt-actions">
                    <button class="btn btn-outline" onclick="window.print()">🖨️ In phiếu đặt</button>
                    <% if (currentUser == null || "Customer".equals(currentUser.getRole())) { %>
                        <a href="<%= request.getContextPath() %>/home" class="btn btn-primary">Quay lại Trang chủ</a>
                    <% } else { %>
                        <a href="<%= request.getContextPath() %>/bookings?action=list" class="btn btn-primary">Về danh sách đặt phòng</a>
                    <% } %>
                </div>
            </div>
        </div>
    </main>
    <script src="<%= request.getContextPath() %>/js/app.js"></script>
</body>
</html>
