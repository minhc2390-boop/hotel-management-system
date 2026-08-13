<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="com.hotel.model.Service" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
    List<Room> availableRooms = (List<Room>) request.getAttribute("availableRooms");
    List<Service> services = (List<Service>) request.getAttribute("services");
    NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Nestora Hotel & Resort - Nghỉ dưỡng đẳng cấp</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        /* CSS bổ sung để tạo giao diện sang trọng chuẩn 3-4 sao */
        :root {
            --accent-gold: #c5a880;
            --accent-gold-dark: #b09168;
            --luxury-navy: #0f172a;
            --luxury-slate: #1e293b;
        }

        /* Header trong suốt kính mờ */
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

        /* Hero Section Thượng Hạng với Slider ảnh chạy động */
        .luxury-hero {
            position: relative;
            border-radius: 16px;
            padding: clamp(60px, 8vw, 120px) clamp(30px, 6vw, 80px);
            color: #fff;
            margin-bottom: 40px;
            overflow: hidden;
            box-shadow: 0 12px 36px rgba(15, 23, 42, 0.12);
        }
        .hero-slider {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 0;
        }
        .hero-slide {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-size: cover;
            background-position: center;
            opacity: 0;
            transition: opacity 1.2s ease-in-out;
        }
        .hero-slide.active {
            opacity: 1;
        }
        .luxury-hero::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(15, 23, 42, 0.8), rgba(15, 23, 42, 0.45));
            z-index: 1;
        }
        .hero-content {
            position: relative;
            z-index: 2;
            max-width: 720px;
        }
        /* Chỉ số slide dots */
        .hero-dots {
            position: absolute;
            bottom: 24px;
            right: 32px;
            display: flex;
            gap: 8px;
            z-index: 2;
        }
        .hero-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.4);
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .hero-dot.active {
            background: var(--accent-gold);
            transform: scale(1.3);
        }
        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            background: rgba(197, 168, 128, 0.25);
            border: 1px solid var(--accent-gold);
            border-radius: 99px;
            font-size: 12px;
            font-weight: 700;
            color: var(--accent-gold);
            text-transform: uppercase;
            letter-spacing: 0.1em;
            margin-bottom: 24px;
        }
        .luxury-hero h1 {
            font-size: clamp(32px, 4.5vw, 56px);
            font-weight: 800;
            line-height: 1.15;
            letter-spacing: -0.02em;
            margin: 0 0 18px;
            color: #ffffff;
            text-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        .luxury-hero p {
            font-size: clamp(15px, 1.8vw, 18px);
            line-height: 1.7;
            color: rgba(255, 255, 255, 0.88);
            margin: 0 0 32px;
        }
        .hero-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: linear-gradient(135deg, var(--accent-gold), var(--accent-gold-dark));
            color: var(--luxury-navy);
            padding: 14px 28px;
            border-radius: 8px;
            font-weight: 700;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            transition: all 0.3s ease;
            box-shadow: 0 6px 20px rgba(197, 168, 128, 0.3);
        }
        .hero-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(197, 168, 128, 0.5);
            background: #ffffff;
            color: var(--luxury-navy);
        }

        /* Section Tiêu đề */
        .section-header {
            text-align: center;
            max-width: 600px;
            margin: 0 auto 36px;
        }
        .section-subtitle {
            font-size: 12px;
            font-weight: 700;
            color: var(--accent-gold-dark);
            text-transform: uppercase;
            letter-spacing: 0.2em;
            margin-bottom: 8px;
            display: block;
        }
        .section-title {
            font-size: clamp(24px, 2.5vw, 32px);
            font-weight: 800;
            color: var(--luxury-navy);
            margin: 0;
        }

        /* Thiết kế Phòng Nghỉ Sang Trọng */
        .luxury-card-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 28px;
            margin-bottom: 56px;
        }
        .luxury-card {
            background: #ffffff;
            border: 1px solid rgba(224, 231, 240, 0.8);
            border-radius: 14px;
            box-shadow: 0 10px 30px rgba(28, 52, 84, 0.04);
            overflow: hidden;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            flex-direction: column;
        }
        .luxury-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 20px 40px rgba(15, 23, 42, 0.08);
            border-color: #cbd5e1;
        }
        .luxury-card-img-wrap {
            position: relative;
            height: 220px;
            overflow: hidden;
        }
        .luxury-card-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.6s ease;
        }
        .luxury-card:hover .luxury-card-img {
            transform: scale(1.08);
        }
        .luxury-card-badge {
            position: absolute;
            top: 14px;
            left: 14px;
            background: rgba(22, 163, 106, 0.9);
            color: #fff;
            font-size: 11px;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 4px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .luxury-card-body {
            padding: 22px;
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .luxury-card-type {
            font-size: 11px;
            font-weight: 700;
            color: var(--accent-gold-dark);
            text-transform: uppercase;
            letter-spacing: 0.1em;
            margin-bottom: 6px;
        }
        .luxury-card-title {
            font-size: 18px;
            font-weight: 800;
            color: var(--luxury-navy);
            margin: 0 0 10px;
        }
        .luxury-card-meta {
            display: flex;
            gap: 16px;
            font-size: 13px;
            color: var(--muted);
            margin-bottom: 14px;
            border-bottom: 1px dashed var(--line);
            padding-bottom: 12px;
        }
        .luxury-card-meta span {
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .luxury-card-meta svg {
            width: 14px;
            height: 14px;
            color: var(--accent-gold-dark);
        }
        .luxury-card-desc {
            font-size: 13px;
            color: #576880;
            line-height: 1.6;
            margin-bottom: 20px;
            min-height: 40px;
        }
        .luxury-card-foot {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            margin-top: auto;
        }
        .luxury-card-price-wrap {
            display: flex;
            flex-direction: column;
        }
        .luxury-card-price-wrap span {
            font-size: 11px;
            color: var(--muted);
        }
        .luxury-card-price {
            font-size: 18px;
            font-weight: 800;
            color: var(--brand);
        }
        .luxury-card-btn {
            background: linear-gradient(135deg, var(--luxury-navy), var(--luxury-slate));
            color: #fff;
            padding: 10px 20px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 12px;
            transition: all 0.25s ease;
        }
        .luxury-card-btn:hover {
            background: var(--brand);
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(23, 105, 224, 0.2);
        }

        /* Section Tiện ích và Đặc quyền */
        .features-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 56px;
        }
        .feature-card {
            background: #ffffff;
            border: 1px solid rgba(220, 229, 241, 0.6);
            border-radius: 12px;
            padding: 24px;
            text-align: center;
            transition: all 0.3s ease;
        }
        .feature-card:hover {
            border-color: var(--accent-gold);
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(197, 168, 128, 0.08);
        }
        .feature-icon-wrap {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: var(--brand-soft);
            color: var(--brand);
            display: grid;
            place-items: center;
            margin: 0 auto 16px;
        }
        .feature-icon-wrap svg {
            width: 22px;
            height: 22px;
        }
        .feature-card h4 {
            margin: 0 0 8px;
            font-size: 15px;
            font-weight: 700;
            color: var(--luxury-navy);
        }
        .feature-card p {
            margin: 0;
            font-size: 12px;
            color: var(--muted);
            line-height: 1.5;
        }

        /* Dịch vụ cao cấp */
        .services-section {
            background: var(--luxury-navy);
            color: #fff;
            border-radius: 16px;
            padding: 48px;
            margin-bottom: 56px;
        }
        .services-section .section-title {
            color: #ffffff;
        }
        .services-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 24px;
            margin-top: 36px;
        }
        .service-luxury-card {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 12px;
            padding: 24px;
            transition: all 0.3s ease;
        }
        .service-luxury-card:hover {
            background: rgba(255, 255, 255, 0.08);
            border-color: var(--accent-gold);
            transform: translateY(-2px);
        }
        .service-luxury-title {
            font-size: 16px;
            font-weight: 700;
            color: #ffffff;
            margin: 0 0 8px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .service-luxury-title svg {
            width: 18px;
            height: 18px;
            color: var(--accent-gold);
        }
        .service-luxury-price {
            font-size: 15px;
            font-weight: 700;
            color: var(--accent-gold);
            margin-bottom: 12px;
        }
        .service-luxury-desc {
            font-size: 12px;
            color: rgba(255, 255, 255, 0.7);
            line-height: 1.6;
            margin: 0;
        }

        @media (max-width: 900px) {
            .features-grid { grid-template-columns: repeat(2, 1fr); }
            .services-grid { grid-template-columns: 1fr; }
        }
        @media (max-width: 640px) {
            .features-grid { grid-template-columns: 1fr; }
            .luxury-header { flex-direction: column; height: auto; padding: 16px; gap: 12px; }
            .luxury-nav { flex-wrap: wrap; justify-content: center; gap: 6px; }
        }
        /* Banner chạy ngang quảng cáo (Ticker) */
        .luxury-ticker {
            background: linear-gradient(90deg, var(--luxury-navy), var(--brand-dark));
            color: var(--accent-gold);
            height: 38px;
            display: flex;
            align-items: center;
            overflow: hidden;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 0.05em;
            border-bottom: 1px solid rgba(197, 168, 128, 0.2);
            position: relative;
            z-index: 101;
        }
        .ticker-wrap {
            width: 100%;
            overflow: hidden;
            white-space: nowrap;
        }
        .ticker-content {
            display: inline-block;
            padding-left: 100%;
            animation: ticker 25s linear infinite;
        }
        @keyframes ticker {
            0% { transform: translate3d(0, 0, 0); }
            100% { transform: translate3d(-100%, 0, 0); }
        }
        .luxury-ticker:hover .ticker-content {
            animation-play-state: paused;
        }
    </style>
</head>
<body class="client-body">

<!-- Banner quảng cáo chạy ngang (Ticker) -->
<div class="luxury-ticker">
    <div class="ticker-wrap">
        <div class="ticker-content">
            ✦ CHÀO MỪNG QUÝ KHÁCH ĐẾN VỚI NESTORA HOTEL & RESORT - KHU NGHỈ DƯỠNG TIÊU CHUẨN 3 SAO QUỐC TẾ ✦ GIẢM NGAY 15% CHO KHÁCH HÀNG ĐẶT PHÒNG TRỰC TUYẾN TRÊN WEBSITE ✦ MIỄN PHÍ BUFFET SÁNG THƯỢNG HẠNG VÀ DỊCH VỤ DỌN PHÒNG HÀNG NGÀY ✦ HOTLINE HỖ TRỢ ĐẶT PHÒNG 24/7: +84 (0) 258 3567 890 ✦
        </div>
    </div>
</div>

<%@ include file="WEB-INF/jspf/client-header.jspf" %>

<main class="public-content" style="max-width: 1200px; margin: 0 auto; padding: 24px 16px;">
    
    <!-- Hero Banner Thượng Hạng với Slider ảnh chạy động -->
    <section class="luxury-hero">
        <div class="hero-slider">
            <div class="hero-slide active" style="background-image: url('<%= request.getContextPath() %>/assets/hotel_lobby.jpg');"></div>
            <div class="hero-slide" style="background-image: url('<%= request.getContextPath() %>/assets/room_suite.jpg');"></div>
            <div class="hero-slide" style="background-image: url('<%= request.getContextPath() %>/assets/room_deluxe.jpg');"></div>
            <div class="hero-slide" style="background-image: url('<%= request.getContextPath() %>/assets/room_standard.jpg');"></div>
        </div>
        
        <div class="hero-content">
            <div class="hero-badge">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 14px; height: 14px;"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                Tiêu chuẩn nghỉ dưỡng 3 sao quốc tế
            </div>
            <h1>Nestora Hotel & Resort</h1>
            <p>Nơi kiến tạo những khoảnh khắc nghỉ ngơi đích thực. Trải nghiệm không gian sang trọng, dịch vụ chuyên nghiệp và lòng hiếu khách trọn vẹn tại vị trí đắc địa nhất thành phố.</p>
            <a href="#phong-nghi" class="hero-btn">
                Khám phá phòng ngay
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="width: 16px; height: 16px;"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
            </a>
        </div>
        
        <div class="hero-dots">
            <span class="hero-dot active" onclick="setSlide(0)"></span>
            <span class="hero-dot" onclick="setSlide(1)"></span>
            <span class="hero-dot" onclick="setSlide(2)"></span>
            <span class="hero-dot" onclick="setSlide(3)"></span>
        </div>
    </section>

    <!-- Tiện ích & Đặc quyền -->
    <section class="features-grid">
        <div class="feature-card">
            <div class="feature-icon-wrap">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            </div>
            <h4>An ninh 24/7</h4>
            <p>Hệ thống giám sát tối tân và bảo vệ chuyên nghiệp đảm bảo sự an tâm tuyệt đối.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon-wrap">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </div>
            <h4>Hỗ trợ 24h</h4>
            <p>Đội ngũ lễ tân thân thiện sẵn sàng phục vụ và giải đáp mọi yêu cầu của quý khách.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon-wrap">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 12.55a11 11 0 0 1 14.08 0"/><path d="M1.42 9a16 16 0 0 1 21.16 0"/><path d="M8.53 16.11a6 6 0 0 1 6.95 0"/><circle cx="12" cy="20" r="1"/></svg>
            </div>
            <h4>Wifi tốc độ cao</h4>
            <p>Đường truyền internet cáp quang phủ sóng toàn bộ khuôn viên, kết nối không giới hạn.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon-wrap">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
            </div>
            <h4>Tiện nghi cao cấp</h4>
            <p>Trang thiết bị vệ sinh nhập khẩu và hệ thống điều hòa thông minh trong mỗi phòng.</p>
        </div>
    </section>

    <!-- Danh sách phòng nghỉ -->
    <section id="phong-nghi" style="scroll-margin-top: 100px;">
        <div class="section-header">
            <span class="section-subtitle">Lựa chọn lưu trú</span>
            <h2 class="section-title">Phòng Nghỉ Khả Dụng</h2>
        </div>

        <% if (availableRooms != null && !availableRooms.isEmpty()) { %>
            <div class="luxury-card-grid">
                <% 
                    for (Room r : availableRooms) { 
                        // Lựa chọn ảnh chất lượng cao tương ứng với loại phòng
                        String imgPath = "room_standard.jpg";
                        String typeName = r.getRoomType().getName().toLowerCase();
                        if (typeName.contains("double") || typeName.contains("deluxe")) {
                            imgPath = "room_deluxe.jpg";
                        } else if (typeName.contains("suite") || typeName.contains("president")) {
                            imgPath = "room_suite.jpg";
                        }
                %>
                    <div class="luxury-card">
                        <div class="luxury-card-img-wrap">
                            <a href="<%= request.getContextPath() %>/rooms?action=bookForm&roomId=<%= r.getId() %>">
                                <img class="luxury-card-img" src="<%= request.getContextPath() %>/assets/<%= imgPath %>" alt="<%= r.getRoomType().getName() %>">
                            </a>
                            <%
                                boolean isAvailable = !"Occupied".equalsIgnoreCase(r.getStatus()) && !"Maintenance".equalsIgnoreCase(r.getStatus());
                                String statusBadgeText = isAvailable ? "Còn phòng" : "Kín phòng";
                                String badgeBgColor = isAvailable ? "rgba(22, 163, 106, 0.9)" : "rgba(217, 119, 6, 0.9)";
                            %>
                            <span class="luxury-card-badge" style="background: <%= badgeBgColor %>;">
                            <%= statusBadgeText %>
                            </span>
                        </div>
                        <div class="luxury-card-body">
                            <div>
                                <span class="luxury-card-type"><%= r.getRoomType().getName() %></span>
                                <h3 class="luxury-card-title">
                                    <a href="<%= request.getContextPath() %>/rooms?action=bookForm&roomId=<%= r.getId() %>" style="color: inherit; text-decoration: none;">Phòng số <%= r.getRoomNumber() %></a>
                                </h3>
                                <div class="luxury-card-meta">
                                    <span>
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                        Tối đa <%= r.getRoomType().getCapacity() %> khách
                                    </span>
                                    <span>
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                                        Tầng <%= r.getRoomNumber().substring(0, 1) %>
                                    </span>
                                </div>
                                <p class="luxury-card-desc"><%= r.getDescription() != null ? r.getDescription() : r.getRoomType().getDescription() %></p>
                                <div class="equipment-tags" style="display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 16px;">
                                    <span style="font-size: 11px; background: rgba(23, 105, 224, 0.08); color: var(--brand); padding: 3px 8px; border-radius: 4px; font-weight: 600;">📺 Smart TV 4K</span>
                                    <span style="font-size: 11px; background: rgba(23, 105, 224, 0.08); color: var(--brand); padding: 3px 8px; border-radius: 4px; font-weight: 600;">❄️ Máy lạnh Inverter</span>
                                    <span style="font-size: 11px; background: rgba(23, 105, 224, 0.08); color: var(--brand); padding: 3px 8px; border-radius: 4px; font-weight: 600;">💨 Máy sấy tóc</span>
                                    <span style="font-size: 11px; background: rgba(23, 105, 224, 0.08); color: var(--brand); padding: 3px 8px; border-radius: 4px; font-weight: 600;">🧊 Tủ lạnh Mini Bar</span>
                                    <span style="font-size: 11px; background: rgba(23, 105, 224, 0.08); color: var(--brand); padding: 3px 8px; border-radius: 4px; font-weight: 600;">☕ Bình đun siêu tốc</span>
                                    <span style="font-size: 11px; background: rgba(23, 105, 224, 0.08); color: var(--brand); padding: 3px 8px; border-radius: 4px; font-weight: 600;">🔒 Két sắt</span>
                                </div>
                            </div>
                            <div class="luxury-card-foot">
                                <div class="luxury-card-price-wrap">
                                    <span>Giá mỗi đêm</span>
                                    <strong class="luxury-card-price"><%= money.format(r.getRoomType().getPricePerDay()) %></strong>
                                </div>
                                <% if (isAvailable) { %>
                                    <a class="luxury-card-btn" href="<%= request.getContextPath() %>/rooms?action=bookForm&roomId=<%= r.getId() %>">Đặt ngay</a>
                                <% } else { %>
                                    <span class="luxury-card-btn" style="background: #94a3b8; cursor: not-allowed; opacity: 0.85;">Kín phòng</span>
                                <% } %>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty" style="padding: 60px 20px; background: #fff; border-radius: 12px; border: 1px solid var(--line); margin-bottom: 56px;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="width: 48px; height: 48px; color: var(--muted); margin: 0 auto 16px;"><circle cx="12" cy="12" r="10"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                <strong>Hiện tại khách sạn đã kín phòng</strong>
                <p style="margin: 6px 0 0; font-size: 13px; color: var(--muted);">Quý khách vui lòng liên hệ lễ tân để biết thêm thông tin đặt trước.</p>
            </div>
        <% } %>
    </section>

    <!-- Dịch vụ đẳng cấp -->
    <% if (services != null && !services.isEmpty()) { %>
        <section class="services-section">
            <div class="section-header" style="text-align: left; margin: 0 0 24px;">
                <span class="section-subtitle" style="color: var(--accent-gold);">Đặc quyền lưu trú</span>
                <h2 class="section-title">Dịch Vụ Đi Kèm</h2>
            </div>
            <p style="color: rgba(255, 255, 255, 0.7); max-width: 600px; font-size: 14px; margin: 0 0 24px;">Chúng tôi cung cấp các gói dịch vụ tiện ích chất lượng cao nhằm mang lại sự tiện nghi trọn vẹn nhất cho kỳ nghỉ của bạn.</p>
            
            <div class="services-grid">
                <% 
                    for (Service s : services) { 
                        // Icon tương ứng cho dịch vụ
                        String iconSvg = "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\"><circle cx=\"12\" cy=\"12\" r=\"10\"/><path d=\"M12 8v4l3 3\"/></svg>";
                        String sName = s.getName().toLowerCase();
                        if (sName.contains("giặt") || sName.contains("laundry")) {
                            iconSvg = "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\"><circle cx=\"12\" cy=\"12\" r=\"10\"/><path d=\"M8 12a4 4 0 1 0 8 0 4 4 0 1 0-8 0\"/><path d=\"M12 12a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z\"/></svg>";
                        } else if (sName.contains("sáng") || sName.contains("breakfast") || sName.contains("ăn")) {
                            iconSvg = "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\"><path d=\"M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6\"/></svg>";
                        } else if (sName.contains("xe") || sName.contains("rental") || sName.contains("motor")) {
                            iconSvg = "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\"><circle cx=\"5.5\" cy=\"17.5\" r=\"2.5\"/><circle cx=\"18.5\" cy=\"17.5\" r=\"2.5\"/><path d=\"M3 17.5L8 10h8.5l4 7.5\"/><path d=\"M12 10v7.5M16.5 10H14\"/></svg>";
                        }
                %>
                    <div class="service-luxury-card">
                        <h4 class="service-luxury-title">
                            <%= iconSvg %>
                            <%= s.getName() %>
                        </h4>
                        <div class="service-luxury-price">Giá: <%= money.format(s.getPrice()) %> / <%= s.getUnit() != null ? s.getUnit() : "Lượt" %></div>
                        <p class="service-luxury-desc"><%= s.getDescription() != null ? s.getDescription() : "Dịch vụ chất lượng cao phục vụ tại chỗ." %></p>
                        <% if (sName.contains("giặt") || sName.contains("laundry")) { %>
                            <a href="<%= request.getContextPath() %>/laundry?action=clientBook" class="btn btn-primary" style="margin-top: 14px; width: 100%; display: inline-block; text-align: center; padding: 10px 16px; font-weight: 600;">🧺 Tạo đơn giặt ủi ngay</a>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </section>
    <% } %>

</main>

<%@ include file="WEB-INF/jspf/client-footer.jspf" %>

<script>
    // JS điều khiển Slideshow ảnh nền Hero
    let currentSlide = 0;
    const slides = document.querySelectorAll('.hero-slide');
    const dots = document.querySelectorAll('.hero-dot');
    
    function showSlide(index) {
        if (slides.length === 0) return;
        slides.forEach(slide => slide.classList.remove('active'));
        dots.forEach(dot => dot.classList.remove('active'));
        
        slides[index].classList.add('active');
        dots[index].classList.add('active');
        currentSlide = index;
    }
    
    function setSlide(index) {
        showSlide(index);
        resetTimer();
    }
    
    function nextSlide() {
        if (slides.length === 0) return;
        let next = (currentSlide + 1) % slides.length;
        showSlide(next);
    }
    
    let slideTimer = setInterval(nextSlide, 5000);
    
    function resetTimer() {
        clearInterval(slideTimer);
        slideTimer = setInterval(nextSlide, 5000);
    }
</script>
</body>
</html>
