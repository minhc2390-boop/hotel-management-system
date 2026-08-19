<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="com.hotel.dao.SystemSettingDAO" %>
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

    SystemSettingDAO sysDAO = new SystemSettingDAO();
    String bankId = sysDAO.getBankId();
    String bankAccount = sysDAO.getBankAccount();
    String bankName = sysDAO.getBankName();

    boolean isMember = (currentUser != null && "Customer".equalsIgnoreCase(currentUser.getRole()));
    String memberTierName = "Hội viên Đồng";
    double memberDiscountRate = 0.0; // 0%, 5%, 10%, 15%
    if (isMember) {
        com.hotel.dao.BookingDAO bDao = new com.hotel.dao.BookingDAO();
        java.util.List<com.hotel.model.Booking> userBookings = bDao.getBookingsByUserId(currentUser.getId(), currentUser.getEmail());
        double userSpent = 0;
        if (userBookings != null) {
            for (com.hotel.model.Booking b : userBookings) {
                if ("CheckedOut".equals(b.getStatus())) {
                    long diffMs = b.getCheckOutDate().getTime() - b.getCheckInDate().getTime();
                    long days = diffMs / (1000 * 60 * 60 * 24);
                    if (days <= 0) days = 1;
                    userSpent += b.getRoomPrice() * days;
                }
            }
        }
        if (userSpent >= 100000000) {
            memberTierName = "Hội viên Kim Cương";
            memberDiscountRate = 0.15;
        } else if (userSpent >= 50000000) {
            memberTierName = "Hội viên Bạch kim";
            memberDiscountRate = 0.10;
        } else if (userSpent >= 20000000) {
            memberTierName = "Hội viên Vàng";
            memberDiscountRate = 0.05;
        } else if (userSpent >= 10000000) {
            memberTierName = "Hội viên Bạc";
            memberDiscountRate = 0.0;
        }
    }

    String userCccd = "";
    if (currentUser != null) {
        try {
            com.hotel.dao.CustomerDAO custDao = new com.hotel.dao.CustomerDAO();
            com.hotel.model.Customer cust = custDao.getCustomerByUserId(currentUser.getId());
            if (cust != null && cust.getCustomerCccd() != null) {
                userCccd = cust.getCustomerCccd();
            }
        } catch (Exception ignored) {}
    }
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
            grid-template-columns: 1.05fr 1.15fr;
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
            height: 250px;
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
        .summary-body { padding: 26px; }
        .summary-title-wrap {
            border-bottom: 1px dashed var(--line);
            padding-bottom: 16px;
            margin-bottom: 18px;
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
            font-size: 22px;
            font-weight: 800;
            color: var(--luxury-navy);
            margin: 0;
        }
        .summary-details {
            display: flex;
            flex-direction: column;
            gap: 12px;
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
            padding: 28px 32px;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
            height: fit-content;
        }
        .form-card-title { font-size: 20px; font-weight: 800; color: var(--luxury-navy); margin: 0 0 4px; }
        .form-card-desc { font-size: 13px; color: var(--muted); margin: 0 0 20px; }
        
        .input-icon-group { position: relative; }
        .input-icon-group .form-control { padding-left: 42px; }
        .input-icon {
            position: absolute; left: 14px; top: 50%;
            transform: translateY(-50%); width: 18px; height: 18px;
            color: var(--muted); pointer-events: none;
        }

        .member-banner {
            background: linear-gradient(135deg, #eff6ff, #f0fdf4);
            border: 1.5px solid #60a5fa;
            border-radius: 12px;
            padding: 16px 18px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .member-banner-icon { font-size: 30px; flex-shrink: 0; }
        .member-banner-title { font-weight: 800; font-size: 14px; color: #1e3a8a; }
        .member-banner-desc { font-size: 13px; color: #334155; margin-top: 2px; line-height: 1.4; }

        .guest-banner {
            background: #fffbeb;
            border: 1.5px solid #fde047;
            border-radius: 12px;
            padding: 14px 18px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
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
        .payment-row { display: flex; justify-content: space-between; align-items: center; font-size: 14px; }
        .total-amount { font-size: 16px; font-weight: 800; color: var(--brand); }
        .deposit-row { border-top: 1px dashed rgba(23, 105, 224, 0.2); padding-top: 8px; margin-top: 2px; }
        .deposit-amount { font-size: 20px; font-weight: 800; color: #dc2626; }

        /* KHUNG VIETQR THANH TOÁN CỌC (CHỈ HIỆN CHO KHÁCH VÃNG LAI) */
        #transfer-qr-container {
            display: none;
            margin-top: 18px;
            margin-bottom: 24px;
            border: 1.5px dashed var(--brand);
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            background: #f8fafc;
            animation: qrFadeIn 0.35s ease;
        }
        @keyframes qrFadeIn {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .qr-wrapper {
            background: #fff;
            padding: 12px;
            border-radius: 10px;
            display: inline-block;
            box-shadow: 0 4px 14px rgba(23,105,224,0.12);
            margin-bottom: 12px;
        }
        .qr-bank-details {
            font-size: 13px;
            color: var(--luxury-navy);
            line-height: 1.6;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 12px 16px;
            text-align: left;
            margin-top: 10px;
        }
        .copy-btn {
            padding: 2px 8px;
            font-size: 11px;
            font-weight: 600;
            border-radius: 4px;
            background: #f1f5f9;
            border: 1px solid #cbd5e1;
            color: var(--brand);
            cursor: pointer;
            margin-left: 6px;
            transition: all 0.2s ease;
        }
        .copy-btn:hover {
            background: var(--brand);
            color: #ffffff;
            border-color: var(--brand);
        }

        .btn-large {
            height: 48px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 15px;
            border-radius: 8px;
            transition: all 0.25s ease;
        }

        @media (max-width: 900px) { .booking-layout { grid-template-columns: 1fr; } }
    </style>
</head>
<body class="client-body">

<%@ include file="WEB-INF/jspf/client-header.jspf" %>

<main class="public-content" style="max-width: 1200px; margin: 0 auto; padding: 24px 16px;">
    
    <div class="page-head" style="margin-bottom: 24px;">
        <div class="breadcrumb">Trang chủ / Phòng nghỉ / Đặt phòng</div>
        <h1 class="page-title">Xác nhận Đặt phòng #<%= room.getRoomNumber() %></h1>
        <p class="page-desc">
            <%= isMember 
                ? "Chào mừng Hội viên! Quý khách được giữ chỗ miễn cọc và thanh toán khi đến nhận phòng." 
                : "Quý khách vui lòng chọn thời gian lưu trú và chuyển khoản cọc 20% qua VietQR để xác nhận giữ phòng." %>
        </p>
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
                        <span>Giá niêm yết mỗi đêm</span>
                        <strong class="price"><%= money.format(room.getRoomType().getPricePerDay()) %></strong>
                    </div>
                    <% if (isMember && memberDiscountRate > 0) { %>
                    <div class="summary-line" style="background: #f0fdf4; padding: 8px 12px; border-radius: 6px; border: 1px dashed #4ade80;">
                        <span style="color: #15803d; font-weight: 600;">Giá ưu đãi <%= memberTierName %> (-<%= (int)(memberDiscountRate * 100) %>%):</span>
                        <strong style="color: #15803d; font-size: 16px;"><%= money.format(room.getRoomType().getPricePerDay() * (1.0 - memberDiscountRate)) %>/đêm</strong>
                    </div>
                    <% } %>
                    <div class="summary-line">
                        <span>Sức chứa tiêu chuẩn</span>
                        <strong>Tối đa <%= room.getRoomType().getCapacity() %> khách</strong>
                    </div>
                    <div class="summary-line" style="flex-direction: column; align-items: flex-start; gap: 4px;">
                        <span>Mô tả phòng:</span>
                        <strong style="font-weight: 500; color: #576880; line-height: 1.5; font-size: 13px;">
                            <%= room.getDescription() != null ? room.getDescription() : room.getRoomType().getDescription() %>
                        </strong>
                    </div>
                    <div class="summary-line" style="flex-direction: column; align-items: flex-start; gap: 6px; border-top: 1px dashed var(--line); padding-top: 12px; margin-top: 6px;">
                        <span style="font-weight: 700; color: var(--luxury-navy);">Trang bị tiện nghi:</span>
                        <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                            <span style="font-size: 11px; background: rgba(23, 105, 224, 0.08); color: var(--brand); padding: 3px 8px; border-radius: 4px; font-weight: 600;">📺 Smart TV 4K</span>
                            <span style="font-size: 11px; background: rgba(23, 105, 224, 0.08); color: var(--brand); padding: 3px 8px; border-radius: 4px; font-weight: 600;">❄️ Máy lạnh Inverter</span>
                            <span style="font-size: 11px; background: rgba(23, 105, 224, 0.08); color: var(--brand); padding: 3px 8px; border-radius: 4px; font-weight: 600;">💨 Máy sấy tóc</span>
                            <span style="font-size: 11px; background: rgba(23, 105, 224, 0.08); color: var(--brand); padding: 3px 8px; border-radius: 4px; font-weight: 600;">🧊 Tủ lạnh Mini Bar</span>
                            <span style="font-size: 11px; background: rgba(23, 105, 224, 0.08); color: var(--brand); padding: 3px 8px; border-radius: 4px; font-weight: 600;">☕ Bình đun siêu tốc</span>
                            <span style="font-size: 11px; background: rgba(23, 105, 224, 0.08); color: var(--brand); padding: 3px 8px; border-radius: 4px; font-weight: 600;">🚿 Bình nóng lạnh 24/7</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Cột bên phải: Form đặt phòng & Xử lý Cọc -->
        <section class="form-card">
            
            <% if (isMember) { %>
            <!-- BANNER DÀNH CHO HỘI VIÊN ĐÃ ĐĂNG NHẬP -->
            <div class="member-banner">
                <div class="member-banner-icon">👑</div>
                <div>
                    <div class="member-banner-title">Đặc quyền <%= memberTierName %>: MIỄN CỌC GIỮ PHÒNG</div>
                    <div class="member-banner-desc">
                        Xin chào <strong><%= currentUser.getFullName() %></strong>! Quý khách được giữ phòng <strong>không cần cọc trước</strong> (thanh toán 100% khi nhận phòng).
                        <% if (memberDiscountRate > 0) { %>
                            <span style="display: inline-block; background: #dcfce7; color: #15803d; font-weight: 700; padding: 1px 7px; border-radius: 4px; font-size: 11px; margin-left: 4px;">Ưu đãi giảm <%= (int)(memberDiscountRate * 100) %>%</span>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } else { %>
            <!-- BANNER DÀNH CHO KHÁCH VÃNG LAI -->
            <div class="guest-banner">
                <div style="display: flex; align-items: center; gap: 8px;">
                    <span style="font-size: 20px;">💳</span>
                    <span style="font-size: 13px; color: #78350f; font-weight: 500;">
                        Khách vãng lai chuyển khoản <strong>cọc 20% qua VietQR</strong> để khóa phòng ngay.
                    </span>
                </div>
                <a href="<%= request.getContextPath() %>/login" style="font-size: 12px; font-weight: 700; color: var(--brand); background: #ffffff; border: 1px solid var(--brand); padding: 4px 10px; border-radius: 6px; text-decoration: none;">Đăng nhập để Miễn cọc ›</a>
            </div>
            <% } %>

            <h2 class="form-card-title">Thông tin Đặt phòng</h2>
            <p class="form-card-desc">Vui lòng kiểm tra và điền thông tin người lưu trú.</p>

            <form action="<%= request.getContextPath() %>/bookings" method="post" id="bookingForm">
                <input type="hidden" name="action" value="insert">
                <input type="hidden" name="roomId" value="<%= room.getId() %>">

                <div class="form-grid" style="grid-template-columns: 1fr;">
                    <div class="form-group">
                        <label class="form-label" for="customerName">Họ và tên người nhận phòng *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="text" id="customerName" name="customerName" 
                                   value="<%= currentUser != null && currentUser.getFullName() != null ? currentUser.getFullName() : "" %>" 
                                   placeholder="Nhập họ và tên đầy đủ" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="customerEmail">Địa chỉ Email nhận phiếu đặt *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="email" id="customerEmail" name="customerEmail" 
                                   value="<%= currentUser != null && currentUser.getEmail() != null ? currentUser.getEmail() : "" %>" 
                                   placeholder="example@gmail.com" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        </div>
                    </div>

                    <!-- Thời gian nhận/trả phòng -->
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
                            <input class="form-control" type="text" id="customerCccd" name="customerCccd" 
                                   value="<%= userCccd %>" 
                                   placeholder="Nhập số CCCD để làm thủ tục nhận phòng" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="guestCount">Số lượng khách *</label>
                        <div class="input-icon-group">
                            <input class="form-control" type="number" id="guestCount" name="guestCount" min="1" max="<%= room.getRoomType().getCapacity() > 0 ? room.getRoomType().getCapacity() : 10 %>" value="1" required>
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="note">Ghi chú / Yêu cầu đặc biệt</label>
                        <textarea class="form-control" id="note" name="note" rows="2" placeholder="Ví dụ: Giường phụ, check-in sớm, tầng cao..."></textarea>
                    </div>
                </div>

                <!-- Báo lỗi thời gian -->
                <div id="dateError" class="alert alert-error hidden" style="margin-top: 14px;">
                    Thời gian trả phòng phải sau thời gian nhận phòng!
                </div>

                <!-- BẢNG TÍNH TOÁN TIỀN PHÒNG & CỌC -->
                <div class="total-payment-box">
                    <div class="payment-row">
                        <span class="total-label">Tạm tính tiền phòng:</span>
                        <strong id="estimatedSubtotal" style="color: var(--text);">0 ₫</strong>
                    </div>
                    <% if (isMember && memberDiscountRate > 0) { %>
                    <div class="payment-row" style="color: #16a34a;">
                        <span class="total-label">Giảm giá <%= memberTierName %> (<%= (int)(memberDiscountRate * 100) %>%):</span>
                        <strong id="estimatedDiscount">- 0 ₫</strong>
                    </div>
                    <% } %>
                    <div class="payment-row">
                        <span class="total-label" style="color: #b45309;">Thuế GTGT / VAT (8%):</span>
                        <strong id="estimatedTax" style="color: #b45309;">+ 0 ₫</strong>
                    </div>
                    <div class="payment-row" style="border-top: 1px dashed #cbd5e1; padding-top: 8px;">
                        <span class="total-label"><strong>Tổng tiền lưu trú (Đã gồm VAT):</strong></span>
                        <strong id="estimatedTotal" class="total-amount">0 ₫</strong>
                    </div>
                    <% if (!isMember) { %>
                    <div class="payment-row deposit-row">
                        <span class="deposit-label" style="color: #dc2626; font-weight: 700;">Tiền cọc giữ chỗ (20%):</span>
                        <strong id="estimatedDeposit" class="deposit-amount">0 ₫</strong>
                    </div>
                    <% } else { %>
                    <div class="payment-row deposit-row">
                        <span class="deposit-label" style="color: #15803d; font-weight: 700;">Đặc quyền Thành viên:</span>
                        <strong style="color: #15803d; font-size: 15px;">MIỄN CỌC TRƯỚC</strong>
                    </div>
                    <% } %>
                </div>

                <% if (!isMember) { %>
                <!-- KHUNG HIỂN THỊ VIETQR DÀNH CHO KHÁCH VÃNG LAI -->
                <div id="transfer-qr-container">
                    <span class="form-label" style="color: var(--brand); font-weight: 800; font-size: 15px; margin-bottom: 12px; display: block;">
                        MÃ QR THANH TOÁN CỌC 20% (VIETQR)
                    </span>
                    <div class="qr-wrapper">
                        <img id="vietqr-image" src="" alt="VietQR Payment Code" style="width: 190px; height: 190px; display: block; margin: 0 auto;" />
                    </div>
                    <div class="qr-bank-details">
                        <div>Ngân hàng: <strong><%= bankId %> Bank</strong></div>
                        <div>
                            Số TK: <strong id="val-account-no"><%= bankAccount %></strong>
                            <button type="button" class="copy-btn" onclick="copyText('<%= bankAccount %>', 'Đã sao chép Số tài khoản!')">Sao chép</button>
                        </div>
                        <div>Chủ TK: <strong><%= bankName %></strong></div>
                        <div>
                            Số tiền cọc: <strong id="val-deposit-amount" style="color: #dc2626;">0 ₫</strong>
                            <button type="button" class="copy-btn" onclick="copyDepositAmount()">Sao chép</button>
                        </div>
                        <div>
                            Nội dung: <strong id="val-transfer-note">Nestora P<%= room.getRoomNumber() %> Coc 20%</strong>
                            <button type="button" class="copy-btn" onclick="copyTransferNote()">Sao chép</button>
                        </div>
                    </div>
                    <div style="font-size: 12px; color: #64748b; margin-top: 10px;">
                        Quý khách quét mã QR trên app ngân hàng để chuyển cọc. Sau khi chuyển xong, bấm nút xác nhận bên dưới.
                    </div>
                </div>
                <% } %>

                <div class="form-actions" style="display: flex; flex-direction: column; gap: 10px; margin-top: 20px;">
                    <% if (isMember) { %>
                    <button type="submit" id="btnSubmitBooking" class="btn btn-primary btn-large" style="width: 100%; cursor: pointer;">
                        ✓ Xác nhận giữ phòng (Thanh toán khi nhận phòng)
                    </button>
                    <% } else { %>
                    <button type="submit" id="btnSubmitBooking" class="btn btn-success btn-large" style="width: 100%; cursor: pointer; background: #16a34a; border-color: #16a34a;">
                        ✓ Tôi đã chuyển cọc 20% & Hoàn tất đặt phòng
                    </button>
                    <% } %>
                    <a class="btn btn-outline btn-large" href="<%= request.getContextPath() %>/home" style="text-align: center; width: 100%;">Quay lại danh sách phòng</a>
                </div>
            </form>
        </section>
    </div>
</main>

<%@ include file="WEB-INF/jspf/client-footer.jspf" %>

<script>
    const pricePerDay = <%= (long) (room != null && room.getRoomType() != null ? room.getRoomType().getPricePerDay() : 0) %>;
    const roomNo = '<%= room != null && room.getRoomNumber() != null ? room.getRoomNumber() : "" %>';
    const isMember = <%= isMember %>;
    const memberDiscountRate = <%= memberDiscountRate %>;

    const checkInInput = document.getElementById('checkInDate');
    const checkOutInput = document.getElementById('checkOutDate');
    const subtotalEl = document.getElementById('estimatedSubtotal');
    const discountEl = document.getElementById('estimatedDiscount');
    const taxEl = document.getElementById('estimatedTax');
    const totalEl = document.getElementById('estimatedTotal');
    const depositEl = document.getElementById('estimatedDeposit');
    const errorEl = document.getElementById('dateError');
    const qrContainer = document.getElementById('transfer-qr-container');

    let currentCalculatedDeposit = 0;
    let currentTransferNote = 'Nestora P' + roomNo + ' Coc 20%';

    // Khởi tạo ngày mặc định: Nhận phòng Hôm nay 14:00, Trả phòng Ngày mai 12:00
    try {
        let now = new Date();
        let tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);

        function formatDateTimeLocal(d, hour, min) {
            let year = d.getFullYear();
            let month = String(d.getMonth() + 1).padStart(2, '0');
            let day = String(d.getDate()).padStart(2, '0');
            let h = String(hour).padStart(2, '0');
            let m = String(min).padStart(2, '0');
            return year + '-' + month + '-' + day + 'T' + h + ':' + m;
        }

        let currentIso = formatDateTimeLocal(now, now.getHours(), now.getMinutes());
        if (checkInInput) checkInInput.min = currentIso;
        if (checkOutInput) checkOutInput.min = currentIso;

        if (checkInInput && !checkInInput.value) {
            checkInInput.value = formatDateTimeLocal(now, 14, 0);
        }
        if (checkOutInput && !checkOutInput.value) {
            checkOutInput.value = formatDateTimeLocal(tomorrow, 12, 0);
        }
    } catch (e) {
        console.error(e);
    }

    if (checkInInput) {
        checkInInput.addEventListener('input', calculateBooking);
        checkInInput.addEventListener('change', calculateBooking);
    }
    if (checkOutInput) {
        checkOutInput.addEventListener('input', calculateBooking);
        checkOutInput.addEventListener('change', calculateBooking);
    }

    function calculateBooking() {
        if (!checkInInput || !checkOutInput) return;

        let checkInVal = checkInInput.value;
        let checkOutVal = checkOutInput.value;

        if (!checkInVal || !checkOutVal) {
            if (errorEl) errorEl.classList.add('hidden');
            if (subtotalEl) subtotalEl.textContent = '0 ₫';
            if (discountEl) discountEl.textContent = '- 0 ₫';
            if (taxEl) taxEl.textContent = '+ 0 ₫';
            if (totalEl) totalEl.textContent = '0 ₫';
            if (depositEl) depositEl.textContent = '0 ₫';
            if (qrContainer) qrContainer.style.display = 'none';
            return;
        }

        let checkInDate = new Date(checkInVal);
        let checkOutDate = new Date(checkOutVal);

        if (isNaN(checkInDate.getTime()) || isNaN(checkOutDate.getTime()) || checkOutDate <= checkInDate) {
            if (errorEl) errorEl.classList.remove('hidden');
            if (subtotalEl) subtotalEl.textContent = '0 ₫';
            if (discountEl) discountEl.textContent = '- 0 ₫';
            if (taxEl) taxEl.textContent = '+ 0 ₫';
            if (totalEl) totalEl.textContent = '0 ₫';
            if (depositEl) depositEl.textContent = '0 ₫';
            if (qrContainer) qrContainer.style.display = 'none';
            return;
        }

        if (errorEl) errorEl.classList.add('hidden');

        // Tính số đêm lưu trú
        let diffMs = checkOutDate - checkInDate;
        let days = Math.ceil(diffMs / (1000 * 60 * 60 * 24));
        if (days <= 0) days = 1;

        let subtotal = days * pricePerDay;
        let discount = Math.round(subtotal * memberDiscountRate);
        let afterDiscount = subtotal - discount;
        let tax = Math.round(afterDiscount * 0.08); // Thuế 8%
        let total = afterDiscount + tax;
        let deposit = Math.round(total * 0.20); // Cọc 20%
        currentCalculatedDeposit = deposit;

        let fmt = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });
        if (subtotalEl) subtotalEl.textContent = fmt.format(subtotal) + ' (' + days + ' đêm)';
        if (discountEl) discountEl.textContent = '- ' + fmt.format(discount);
        if (taxEl) taxEl.textContent = '+ ' + fmt.format(tax);
        if (totalEl) totalEl.textContent = fmt.format(total);
        if (depositEl) depositEl.textContent = fmt.format(deposit);

        let depositValDisplay = document.getElementById('val-deposit-amount');
        if (depositValDisplay) depositValDisplay.textContent = fmt.format(deposit);

        // Chỉ hiển thị QR VietQR cọc 20% nếu là Khách vãng lai (Chưa đăng nhập)
        if (!isMember && qrContainer) {
            var bankId = '<%= bankId %>';
            var accountNo = '<%= bankAccount %>';
            var accountName = '<%= bankName.replace("'", "\\'") %>';
            var template = 'qr_only';
            var addInfoText = 'Nestora P' + roomNo + ' Coc 20%';
            currentTransferNote = addInfoText;

            var qrUrl = 'https://img.vietqr.io/image/' + bankId + '-' + accountNo + '-' + template + '.png'
                      + '?amount=' + deposit 
                      + '&addInfo=' + encodeURIComponent(addInfoText) 
                      + '&accountName=' + encodeURIComponent(accountName);

            var qrImg = document.getElementById('vietqr-image');
            if (qrImg) {
                qrImg.src = qrUrl;
            }
            qrContainer.style.display = 'block';
        }
    }

    function copyText(text, successMsg) {
        if (navigator.clipboard) {
            navigator.clipboard.writeText(text).then(function() {
                alert(successMsg || 'Đã sao chép!');
            });
        } else {
            prompt('Nhấn Ctrl+C để sao chép:', text);
        }
    }

    function copyDepositAmount() {
        copyText(currentCalculatedDeposit.toString(), 'Đã sao chép số tiền cọc: ' + currentCalculatedDeposit + 'đ');
    }

    function copyTransferNote() {
        copyText(currentTransferNote, 'Đã sao chép nội dung chuyển khoản: ' + currentTransferNote);
    }

    calculateBooking();
    document.addEventListener('DOMContentLoaded', calculateBooking);
</script>
</body>
</html>