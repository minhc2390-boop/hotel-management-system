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
        }
        .summary-body { padding: 30px; }
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
        .summary-line span { color: var(--muted); }
        .summary-line strong { color: var(--luxury-navy); font-weight: 700; }
        .summary-line strong.price { font-size: 18px; color: var(--brand); font-weight: 800; }

        .form-card {
            background: #ffffff;
            border: 1px solid rgba(220, 229, 241, 0.8);
            border-radius: 16px;
            padding: 30px 40px;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
            height: fit-content;
        }
        .form-card-title { font-size: 20px; font-weight: 800; color: var(--luxury-navy); margin: 0 0 6px; }
        .form-card-desc { font-size: 13px; color: var(--muted); margin: 0 0 24px; }
        
        .input-icon-group { position: relative; }
        .input-icon-group .form-control { padding-left: 42px; }
        .input-icon {
            position: absolute; left: 14px; top: 50%;
            transform: translateY(-50%); width: 18px; height: 18px;
            color: var(--muted); pointer-events: none;
        }

        .total-payment-box {
            background: var(--brand-soft);
            border-radius: 10px;
            padding: 16px 20px;
            margin-top: 20px;
            margin-bottom: 20px;
            border: 1px dashed rgba(23, 105, 224, 0.25);
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .payment-row { display: flex; justify-content: space-between; align-items: center; }
        .total-amount { font-size: 16px; font-weight: 700; color: var(--luxury-navy); }
        .deposit-row { border-top: 1px dashed rgba(23, 105, 224, 0.2); padding-top: 6px; }
        .deposit-amount { font-size: 20px; font-weight: 800; color: #dc2626; }

        /* KHUNG VIETQR THANH TOÁN CỌC */
        #transfer-qr-container {
            display: none; /* Mặc định ẩn, khi chọn đủ ngày mới hiện */
            margin-top: 18px;
            margin-bottom: 24px;
            border: 1px dashed var(--brand);
            border-radius: 10px;
            padding: 18px;
            text-align: center;
            background: var(--brand-soft);
            animation: qrFadeIn 0.35s ease;
        }
        @keyframes qrFadeIn {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .qr-wrapper {
            background: #fff;
            padding: 10px;
            border-radius: 8px;
            display: inline-block;
            box-shadow: 0 4px 12px rgba(23,105,224,0.08);
            margin-bottom: 10px;
        }
        .qr-bank-details { font-size: 12px; color: var(--luxury-navy); line-height: 1.5; }
        .qr-bank-details strong { color: var(--brand-dark); }

        .form-actions { display: grid; grid-template-columns: 1fr 2fr; gap: 12px; }
        .btn-large { height: 48px; display: inline-flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px; }

        @media (max-width: 900px) { .booking-layout { grid-template-columns: 1fr; } }
    </style>
</head>
<body class="client-body">

<%@ include file="WEB-INF/jspf/client-header.jspf" %>

<main class="public-content" style="max-width: 1200px; margin: 0 auto; padding: 24px 16px;">
    
    <div class="page-head" style="margin-bottom: 24px;">
        <div class="breadcrumb">Trang chủ / Phòng nghỉ / Đặt phòng</div>
        <h1 class="page-title">Xác nhận Đặt phòng</h1>
        <p class="page-desc">Quý khách vui lòng chọn thời gian lưu trú và quét mã QR chuyển khoản cọc 20% bên dưới.</p>
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

        <!-- Cột bên phải: Form đặt phòng & QR Cọc -->
        <section class="form-card">
            <h2 class="form-card-title">Chi tiết Đặt phòng</h2>
            <p class="form-card-desc">Quý khách thực hiện đặt chỗ trực tuyến nhanh chóng.</p>

            <form action="<%= request.getContextPath() %>/bookings" method="post" id="bookingForm">
                <input type="hidden" name="action" value="insert">
                <input type="hidden" name="roomId" value="<%= room.getId() %>">

                <div class="form-grid" style="grid-template-columns: 1fr;">
                    <% if (currentUser == null) { %>
                    <div class="form-group">
                        <label class="form-label" for="customerName">Họ và tên của bạn *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="text" id="customerName" name="customerName" placeholder="Nhập họ và tên đầy đủ của bạn" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="customerEmail">Địa chỉ Email</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="email" id="customerEmail" name="customerEmail" placeholder="example@gmail.com (Không bắt buộc)">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        </div>
                    </div>
                    <% } %>

                    <!-- Thời gian nhận/trả phòng KHÔNG SET MẶC ĐỊNH -->
                    <div class="form-group">
                        <label class="form-label" for="checkInDate">Thời gian nhận phòng *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="datetime-local" id="checkInDate" name="checkInDate" required onchange="calculateBooking()">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="checkOutDate">Thời gian trả phòng *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="datetime-local" id="checkOutDate" name="checkOutDate" required onchange="calculateBooking()">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="customerPhone">Số điện thoại liên hệ *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="tel" id="customerPhone" name="customerPhone" placeholder="Nhập số điện thoại liên hệ" value="<%= currentUser != null && currentUser.getPhone() != null ? currentUser.getPhone() : "" %>" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="customerCccd">Số Căn cước công dân (CCCD) *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="text" id="customerCccd" name="customerCccd" placeholder="Nhập số CCCD để làm thủ tục" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="guestCount">Số lượng khách lưu trú *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="number" id="guestCount" name="guestCount" min="1" max="<%= room.getRoomType().getCapacity() > 0 ? room.getRoomType().getCapacity() : 10 %>" value="1" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="note">Yêu cầu đặc biệt (Ghi chú)</label>
                        <textarea class="form-control" id="note" name="note" rows="3" placeholder="Ví dụ: Giường phụ, check-in sớm, tầng cao..."></textarea>
                    </div>
                </div>

                <!-- Báo lỗi thời gian -->
                <div id="dateError" class="alert alert-error hidden" style="margin-top: 14px;">
                    Thời gian trả phòng phải sau thời gian nhận phòng!
                </div>

                <!-- Tạm tính tiền phòng & Tiền cọc 20% -->
                <div class="total-payment-box">
                    <div class="payment-row">
                        <span class="total-label">Tổng tiền phòng ước tính:</span>
                        <strong id="estimatedTotal" class="total-amount">0 ₫</strong>
                    </div>
                    <div class="payment-row deposit-row">
                        <span class="deposit-label" style="color: #dc2626; font-weight: 700;">Tiền cọc giữ chỗ (20%):</span>
                        <strong id="estimatedDeposit" class="deposit-amount">0 ₫</strong>
                    </div>
                </div>

                <!-- KHUNG HIỂN THỊ VIETQR TỰ ĐỘNG CHUẨN ĐÚNG THEO PAYMENT.JSP -->
                <div id="transfer-qr-container">
                    <span class="form-label" style="color: var(--brand); font-weight: 700; margin-bottom: 10px; display: block;">MÃ QR THANH TOÁN CỌC (VIETQR)</span>
                    <div class="qr-wrapper">
                        <img id="vietqr-image" src="" alt="VietQR Payment Code" style="width: 180px; height: 180px; display: block; margin: 0 auto;" />
                    </div>
                    <div class="qr-bank-details">
                        Ngân hàng: <strong>MB Bank (Quân Đội)</strong><br>
                        Số TK: <strong>1903567890123</strong><br>
                        Chủ TK: <strong>CONG TY NESTORA HOTEL</strong>
                    </div>
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
    const roomNo = '<%= room.getRoomNumber() %>';

    const checkInInput = document.getElementById('checkInDate');
    const checkOutInput = document.getElementById('checkOutDate');
    const totalEl = document.getElementById('estimatedTotal');
    const depositEl = document.getElementById('estimatedDeposit');
    const errorEl = document.getElementById('dateError');
    const qrContainer = document.getElementById('transfer-qr-container');

    function calculateBooking() {
        let checkInVal = checkInInput.value;
        let checkOutVal = checkOutInput.value;

        // Nếu chưa chọn đủ 2 ngày thì không làm gì hết và ẩn QR
        if (!checkInVal || !checkOutVal) {
            errorEl.classList.add('hidden');
            totalEl.textContent = '0 ₫';
            depositEl.textContent = '0 ₫';
            qrContainer.style.display = 'none';
            return;
        }

        let checkInDate = new Date(checkInVal);
        let checkOutDate = new Date(checkOutVal);

        if (isNaN(checkInDate) || isNaN(checkOutDate) || checkOutDate <= checkInDate) {
            errorEl.classList.remove('hidden');
            totalEl.textContent = '0 ₫';
            depositEl.textContent = '0 ₫';
            qrContainer.style.display = 'none';
            return;
        }

        errorEl.classList.add('hidden');

        // Tính số đêm
        let diffMs = checkOutDate - checkInDate;
        let days = Math.ceil(diffMs / (1000 * 60 * 60 * 24));
        if (days <= 0) days = 1;

        let total = days * pricePerDay;
        let deposit = Math.round(total * 0.20); // Cọc 20%

        let fmt = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });
        totalEl.textContent = fmt.format(total) + ' (' + days + ' đêm)';
        depositEl.textContent = fmt.format(deposit);

        // --- CẤU HÌNH TẠO MÃ VIETQR DỰA TRÊN PAYMENT.JSP ---
        var bankId = 'MB';
        var accountNo = '1903567890123';
        var accountName = 'CONG TY NESTORA HOTEL';
        var template = 'qr_only';
        var addInfoText = 'Nestora P' + roomNo + ' Coc 20%';

        var qrUrl = 'https://img.vietqr.io/image/' + bankId + '-' + accountNo + '-' + template + '.png'
                  + '?amount=' + deposit 
                  + '&addInfo=' + encodeURIComponent(addInfoText) 
                  + '&accountName=' + encodeURIComponent(accountName);

        document.getElementById('vietqr-image').src = qrUrl;
        qrContainer.style.display = 'block';
    }
</script>
</body>
</html>