<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
    Room room = (Room) request.getAttribute("room");
    if (room == null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Đặt phòng <%= room.getRoomNumber() %> - Nestora Hotel & Resort</title>
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

        /* Layout Xác Nhận Đặt Phòng */
        .booking-layout {
            display: grid;
            grid-template-columns: 1.1fr 1fr;
            gap: 32px;
            margin-top: 24px;
            margin-bottom: 56px;
        }

        .summary-card {
            background: #ffffff;
            border: 1px solid rgba(220, 229, 241, 0.8);
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
            overflow: hidden;
            height: fit-content;
        }
        .summary-img-wrap {
            height: 260px;
            position: relative;
            overflow: hidden;
        }
        .summary-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .summary-badge {
            position: absolute;
            top: 16px;
            left: 16px;
            background: var(--accent-gold);
            color: var(--luxury-navy);
            font-size: 11px;
            font-weight: 800;
            padding: 5px 12px;
            border-radius: 4px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .summary-body {
            padding: 30px;
        }
        .summary-title-wrap {
            border-bottom: 1px dashed var(--line);
            padding-bottom: 20px;
            margin-bottom: 20px;
        }
        .summary-type {
            font-size: 12px;
            font-weight: 700;
            color: var(--accent-gold-dark);
            text-transform: uppercase;
            letter-spacing: 0.1em;
            margin-bottom: 4px;
            display: block;
        }
        .summary-title {
            font-size: 24px;
            font-weight: 800;
            color: var(--luxury-navy);
            margin: 0;
        }
        .summary-details {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }
        .summary-line {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 14px;
        }
        .summary-line span {
            color: var(--muted);
        }
        .summary-line strong {
            color: var(--luxury-navy);
            font-weight: 700;
        }
        .summary-line strong.price {
            font-size: 18px;
            color: var(--brand);
            font-weight: 800;
        }

        /* Form Đặt Phòng bên phải */
        .form-card {
            background: #ffffff;
            border: 1px solid rgba(220, 229, 241, 0.8);
            border-radius: 16px;
            padding: 30px 40px;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
            height: fit-content;
        }
        .form-card-title {
            font-size: 20px;
            font-weight: 800;
            color: var(--luxury-navy);
            margin: 0 0 6px;
        }
        .form-card-desc {
            font-size: 13px;
            color: var(--muted);
            margin: 0 0 24px;
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
            transition: color 0.2s;
        }
        .form-control:focus + .input-icon {
            color: var(--brand);
        }

        .total-payment-box {
            background: var(--brand-soft);
            border-radius: 10px;
            padding: 16px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 24px;
            margin-bottom: 24px;
            border: 1px dashed rgba(23, 105, 224, 0.25);
        }
        .total-label {
            font-size: 13px;
            font-weight: 600;
            color: var(--luxury-navy);
        }
        .total-amount {
            font-size: 22px;
            font-weight: 800;
            color: var(--brand);
        }

        .form-actions {
            display: grid;
            grid-template-columns: 1fr 2fr;
            gap: 12px;
        }
        .btn-large {
            height: 48px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 14px;
        }

        @media (max-width: 900px) {
            .booking-layout { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body class="client-body">

<%@ include file="WEB-INF/jspf/client-header.jspf" %>

<main class="public-content" style="max-width: 1200px; margin: 0 auto; padding: 24px 16px;">
    
    <div class="page-head" style="margin-bottom: 24px;">
        <div class="breadcrumb">Trang chủ / Phòng nghỉ / Đặt phòng</div>
        <h1 class="page-title">Xác nhận Đặt phòng</h1>
        <p class="page-desc">Quý khách vui lòng kiểm tra thông tin và chọn thời gian lưu trú bên dưới.</p>
    </div>

    <div class="booking-layout">
        <!-- Cột bên trái: Tóm tắt thông tin phòng -->
        <section class="summary-card">
            <% 
                String imgPath = "room_standard.jpg";
                String typeName = room.getRoomType().getName().toLowerCase();
                if (typeName.contains("double") || typeName.contains("deluxe")) {
                    imgPath = "room_deluxe.jpg";
                } else if (typeName.contains("suite") || typeName.contains("president")) {
                    imgPath = "room_suite.jpg";
                }
            %>
            <div class="summary-img-wrap">
                <img class="summary-img" src="<%= request.getContextPath() %>/assets/<%= imgPath %>" alt="<%= room.getRoomType().getName() %>">
                <span class="summary-badge">Phòng đang trống</span>
            </div>
            <div class="summary-body">
                <div class="summary-title-wrap">
                    <span class="summary-type"><%= room.getRoomType().getName() %></span>
                    <h2 class="summary-title">Phòng số <%= room.getRoomNumber() %></h2>
                </div>
                <div class="summary-details">
                    <div class="summary-line">
                        <span>Giá mỗi đêm</span>
                        <strong class="price"><%= money.format(room.getRoomType().getPricePerDay()) %></strong>
                    </div>
                    <div class="summary-line">
                        <span>Sức chứa tiêu chuẩn</span>
                        <strong>Tối đa <%= room.getRoomType().getCapacity() %> khách</strong>
                    </div>
                    <div class="summary-line" style="flex-direction: column; align-items: flex-start; gap: 4px;">
                        <span>Mô tả chi tiết phòng:</span>
                        <strong style="font-weight: 500; color: #576880; line-height: 1.5; font-size: 13px;">
                            <%= room.getDescription() != null ? room.getDescription() : room.getRoomType().getDescription() %>
                        </strong>
                    </div>
                </div>
            </div>
        </section>

        <!-- Cột bên phải: Form đặt phòng -->
        <section class="form-card">
            <h2 class="form-card-title">Chi tiết Đặt phòng</h2>
            <p class="form-card-desc">Quý khách thực hiện đặt chỗ trực tuyến nhanh chóng.</p>

            <form action="<%= request.getContextPath() %>/bookings" method="post" id="bookingForm">
                <input type="hidden" name="action" value="insert">
                <input type="hidden" name="roomId" value="<%= room.getId() %>">

                <div class="form-grid" style="grid-template-columns: 1fr;">
                    <% if (currentUser == null) { %>
                    <!-- Họ và tên (chỉ hiển thị khi chưa đăng nhập) -->
                    <div class="form-group">
                        <label class="form-label" for="customerName">Họ và tên của bạn *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="text" id="customerName" name="customerName" placeholder="Nhập họ và tên đầy đủ của bạn" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </div>
                    </div>

                    <!-- Địa chỉ Email (chỉ hiển thị khi chưa đăng nhập) -->
                    <div class="form-group">
                        <label class="form-label" for="customerEmail">Địa chỉ Email</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="email" id="customerEmail" name="customerEmail" placeholder="example@gmail.com (Không bắt buộc)">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        </div>
                    </div>
                    <% } %>

                    <!-- Ngày nhận phòng -->
                    <div class="form-group">
                        <label class="form-label" for="checkInDate">Ngày nhận phòng *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="date" id="checkInDate" name="checkInDate" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                        </div>
                    </div>

                    <!-- Ngày trả phòng -->
                    <div class="form-group">
                        <label class="form-label" for="checkOutDate">Ngày trả phòng *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="date" id="checkOutDate" name="checkOutDate" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                        </div>
                    </div>

                    <!-- Số điện thoại -->
                    <div class="form-group">
                        <label class="form-label" for="customerPhone">Số điện thoại liên hệ *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="tel" id="customerPhone" name="customerPhone" placeholder="Nhập số điện thoại liên hệ" value="<%= currentUser != null && currentUser.getPhone() != null ? currentUser.getPhone() : "" %>" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                        </div>
                    </div>

                    <!-- CCCD -->
                    <div class="form-group">
                        <label class="form-label" for="customerCccd">Số Căn cước công dân (CCCD) *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="text" id="customerCccd" name="customerCccd" placeholder="Nhập số CCCD để làm thủ tục" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </div>
                    </div>

                    <!-- Ghi chú -->
                    <div class="form-group">
                        <label class="form-label" for="note">Yêu cầu đặc biệt (Ghi chú)</label>
                        <textarea class="form-control" id="note" name="note" rows="3" placeholder="Ví dụ: Giường phụ, check-in sớm, tầng cao..."></textarea>
                    </div>
                </div>

                <!-- Báo lỗi ngày -->
                <div id="dateError" class="alert alert-error hidden" style="margin-top: 14px;">
                    Ngày trả phòng phải sau ngày nhận phòng tối thiểu 1 ngày.
                </div>

                <!-- Tạm tính tiền phòng -->
                <div class="total-payment-box">
                    <span class="total-label">Tổng tạm tính (Tiền phòng):</span>
                    <strong id="estimatedTotal" class="total-amount"><%= money.format(room.getRoomType().getPricePerDay()) %></strong>
                </div>

                <div class="form-actions">
                    <a class="btn btn-outline btn-large" href="<%= request.getContextPath() %>/home">Quay lại</a>
                    <button class="btn btn-primary btn-large" type="submit">Xác nhận đặt ngay</button>
                </div>
            </form>
        </section>
    </div>
</main>

<%@ include file="WEB-INF/jspf/client-footer.jspf" %>

<script>
    const pricePerDay = <%= room.getRoomType().getPricePerDay() %>;
    const checkInInput = document.getElementById('checkInDate');
    const checkOutInput = document.getElementById('checkOutDate');
    const totalEl = document.getElementById('estimatedTotal');
    const errorEl = document.getElementById('dateError');

    const formatDateStr = d => d.toISOString().slice(0, 10);

    // Mặc định ngày nhận là hôm nay, ngày trả là ngày mai
    let today = new Date();
    let tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    checkInInput.value = formatDateStr(today);
    checkInInput.min = formatDateStr(today);
    checkOutInput.value = formatDateStr(tomorrow);
    checkOutInput.min = formatDateStr(tomorrow);

    function calculateTotal() {
        let checkInDate = new Date(checkInInput.value);
        let checkOutDate = new Date(checkOutInput.value);
        let timeDiff = checkOutDate - checkInDate;
        let days = Math.ceil(timeDiff / (1000 * 3600 * 24));

        if (days <= 0 || isNaN(days)) {
            errorEl.classList.remove('hidden');
            totalEl.textContent = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(0);
            return;
        }
        
        errorEl.classList.add('hidden');
        let total = days * pricePerDay;
        totalEl.textContent = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(total) + ' (' + days + ' đêm)';
    }

    checkInInput.addEventListener('change', () => {
        let checkInDate = new Date(checkInInput.value);
        let minCheckOut = new Date(checkInDate);
        minCheckOut.setDate(minCheckOut.getDate() + 1);
        
        checkOutInput.min = formatDateStr(minCheckOut);
        
        if (new Date(checkOutInput.value) <= checkInDate) {
            checkOutInput.value = formatDateStr(minCheckOut);
        }
        calculateTotal();
    });

    checkOutInput.addEventListener('change', calculateTotal);
</script>
</body>
</html>
