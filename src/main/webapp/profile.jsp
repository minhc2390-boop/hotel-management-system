<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Booking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    SimpleDateFormat d = new SimpleDateFormat("dd/MM/yyyy");

    int totalBookings = (Integer) request.getAttribute("totalBookings");
    double totalSpent = (Double) request.getAttribute("totalSpent");
    String tier = (String) request.getAttribute("membershipTier");
    String tierName = (String) request.getAttribute("membershipTierName");
    double discount = (Double) request.getAttribute("membershipDiscount");
    int loyaltyPoints = (Integer) request.getAttribute("loyaltyPoints");
    double nextTierTarget = (Double) request.getAttribute("nextTierTarget");
    String nextTierName = (String) request.getAttribute("nextTierName");
    double progressPercent = (Double) request.getAttribute("progressPercent");

    // Dynamic membership card gradient based on tier
    String cardGradient = "linear-gradient(135deg, #a87e43, #d4af37, #8a6421)"; // Gold default
    String cardTextColor = "#ffffff";
    String shadowColor = "rgba(212, 175, 55, 0.3)";

    if ("Bronze".equals(tier)) {
        cardGradient = "linear-gradient(135deg, #805c36, #ba916c, #573a1c)";
        shadowColor = "rgba(186, 145, 108, 0.25)";
    } else if ("Silver".equals(tier)) {
        cardGradient = "linear-gradient(135deg, #757F9A, #D7DDE8, #bdc3c7)";
        cardTextColor = "#2c3e50";
        shadowColor = "rgba(117, 127, 154, 0.25)";
    } else if ("Gold".equals(tier)) {
        cardGradient = "linear-gradient(135deg, #a87e43, #d4af37, #8a6421)";
        shadowColor = "rgba(212, 175, 55, 0.3)";
    } else if ("Platinum".equals(tier)) {
        cardGradient = "linear-gradient(135deg, #0f2027, #203a43, #2c5364)";
        shadowColor = "rgba(44, 83, 100, 0.4)";
    } else if ("Diamond".equals(tier)) {
        cardGradient = "linear-gradient(135deg, #a1c4fd, #ffffff, #c2e9fb)";
        cardTextColor = "#1a365d";
        shadowColor = "rgba(161, 196, 253, 0.5)";
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Hồ sơ thành viên - Nestora Club</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .profile-wrapper {
            display: grid;
            grid-template-columns: 380px 1fr;
            gap: 32px;
            align-items: start;
            margin-top: 24px;
        }

        /* Virtual VIP Card Design */
        .vip-card {
            background: <%= cardGradient %>;
            color: <%= cardTextColor %>;
            border-radius: 20px;
            padding: 28px;
            position: relative;
            height: 230px;
            box-shadow: 0 12px 30px <%= shadowColor %>;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .vip-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 16px 36px <%= shadowColor %>;
        }
        .vip-card::after {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: linear-gradient(to bottom right, rgba(255,255,255,0.15) 0%, rgba(255,255,255,0) 50%);
            transform: rotate(30deg);
            pointer-events: none;
        }
        .card-brand {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .card-brand-text {
            font-size: 11px;
            letter-spacing: 0.15em;
            font-weight: 700;
            opacity: 0.9;
        }
        .card-chip {
            width: 42px;
            height: 32px;
            background: linear-gradient(135deg, #ecd599, #bfa054);
            border-radius: 6px;
            position: relative;
            box-shadow: inset 0 1px 1px rgba(255,255,255,0.5);
        }
        .card-chip::before {
            content: '';
            position: absolute;
            top: 6px; left: 8px; right: 8px; bottom: 6px;
            border: 1px solid rgba(0,0,0,0.15);
            border-radius: 2px;
        }
        .card-number {
            font-size: 18px;
            font-weight: 600;
            letter-spacing: 2px;
            font-family: 'Courier New', Courier, monospace;
            margin: 16px 0;
            opacity: 0.95;
        }
        .card-footer {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
        }
        .card-holder {
            font-size: 15px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .card-tier {
            font-size: 14px;
            font-weight: 800;
            letter-spacing: 1px;
            text-transform: uppercase;
            background: rgba(255,255,255,0.2);
            padding: 4px 10px;
            border-radius: 12px;
            border: 1px solid rgba(255,255,255,0.3);
        }

        /* Loyalty Points and Level Progress */
        .loyalty-stats {
            margin-top: 24px;
            padding: 24px;
        }
        .stat-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
        }
        .stat-label {
            color: var(--muted);
            font-size: 13px;
        }
        .stat-val {
            font-weight: 700;
            color: var(--navy);
            font-size: 15px;
        }
        .progress-bar-container {
            height: 8px;
            background: var(--line);
            border-radius: 4px;
            overflow: hidden;
            margin: 12px 0 6px;
        }
        .progress-bar-fill {
            height: 100%;
            background: var(--brand);
            border-radius: 4px;
            width: <%= progressPercent %>%;
        }

        .badge-status {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
        }
        .badge-Pending { background: #fef3c7; color: #d97706; }
        .badge-Confirmed { background: #d1fae5; color: #059669; }
        .badge-CheckedIn { background: #dbeafe; color: #2563eb; }
        .badge-CheckedOut { background: #f3f4f6; color: #4b5563; }
        .badge-Cancelled { background: #fee2e2; color: #dc2626; }
    </style>
</head>
<body class="client-body">
<%@ include file="WEB-INF/jspf/client-header.jspf" %>

<main class="client-main">
    
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-error" style="margin-top: 10px;"><%= request.getAttribute("error") %></div>
    <% } %>
    <% if (request.getAttribute("success") != null) { %>
        <div class="alert alert-success" style="margin-top: 10px;"><%= request.getAttribute("success") %></div>
    <% } %>

    <div class="profile-wrapper">
        <!-- Cột trái: Membership VIP Card và điểm tích luỹ -->
        <div>
            <div class="vip-card">
                <div class="card-brand">
                    <span class="card-brand-text">NESTORA CLUB</span>
                    <div class="card-chip"></div>
                </div>
                <div class="card-number">
                    NST-<%= String.format("%05d", currentUser.getId()) %>-CLUB
                </div>
                <div class="card-footer">
                    <div>
                        <div style="font-size: 8px; opacity: 0.7; text-transform: uppercase;">Chủ thẻ</div>
                        <div class="card-holder"><%= currentUser.getFullName() %></div>
                    </div>
                    <span class="card-tier"><%= tier %></span>
                </div>
            </div>

            <!-- Thống kê điểm thưởng & tiến trình cấp độ -->
            <div class="surface loyalty-stats">
                <h3 style="font-size: 16px; color: var(--navy); margin-bottom: 16px; border-bottom: 1px solid var(--line); padding-bottom: 8px;">Đặc quyền hội viên</h3>
                <div class="stat-row">
                    <span class="stat-label">Hạng thành viên</span>
                    <span class="stat-val" style="color: var(--brand);"><%= tierName %></span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">Điểm tích lũy</span>
                    <span class="stat-val"><%= loyaltyPoints %> điểm</span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">Tổng tích lũy chi tiêu</span>
                    <span class="stat-val" style="color: var(--success);"><%= money.format(totalSpent) %></span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">Ưu đãi giảm giá</span>
                    <span class="stat-val"><%= discount %>% giá phòng</span>
                </div>

                <% if (nextTierTarget > 0) { %>
                    <div style="margin-top: 20px;">
                        <div style="display: flex; justify-content: space-between; font-size: 11px; color: var(--muted);">
                            <span>Tiến trình lên hạng <%= nextTierName %></span>
                            <span><%= Math.round(progressPercent) %>%</span>
                        </div>
                        <div class="progress-bar-container">
                            <div class="progress-bar-fill"></div>
                        </div>
                        <p style="font-size: 11px; color: var(--muted); margin-top: 4px;">
                            Còn thiếu <strong><%= money.format(nextTierTarget - totalSpent) %></strong> để lên hạng tiếp theo.
                        </p>
                    </div>
                <% } else { %>
                    <p style="font-size: 11px; color: var(--success); font-weight: 600; margin-top: 20px; text-align: center;">
                        🎉 Bạn đã đạt cấp độ VIP cao nhất!
                    </p>
                <% } %>
            </div>
        </div>

        <!-- Cột phải: Form cập nhật thông tin cá nhân và mật khẩu -->
        <div class="surface surface-pad">
            <h2 class="form-title" style="margin-bottom: 24px;">Thông tin tài khoản thành viên</h2>
            <form action="<%= request.getContextPath() %>/profile" method="POST">
                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Tên đăng nhập (không thể sửa)</label>
                        <input class="form-control" value="<%= currentUser.getUsername() %>" readonly style="background: var(--canvas)">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Họ và tên *</label>
                        <input class="form-control" name="fullName" value="<%= currentUser.getFullName() %>" required placeholder="Nhập họ và tên">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Email *</label>
                        <input class="form-control" type="email" name="email" value="<%= currentUser.getEmail() %>" required placeholder="example@email.com">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Số điện thoại</label>
                        <input class="form-control" name="phone" value="<%= currentUser.getPhone() != null ? currentUser.getPhone() : "" %>" placeholder="Nhập số điện thoại">
                    </div>
                </div>

                <h3 class="form-title" style="margin: 32px 0 20px 0; border-top: 1px solid var(--line); padding-top: 24px;">Đổi mật khẩu</h3>
                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">Mật khẩu hiện tại</label>
                        <input class="form-control" type="password" name="currentPassword" placeholder="Nhập mật khẩu hiện tại">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Mật khẩu mới</label>
                        <input class="form-control" type="password" name="newPassword" placeholder="Nhập mật khẩu mới">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Xác nhận mật khẩu mới</label>
                        <input class="form-control" type="password" name="confirmPassword" placeholder="Xác nhận mật khẩu mới">
                    </div>
                </div>

                <div style="margin-top: 32px; display: flex; justify-content: flex-end;">
                    <button type="submit" class="btn btn-primary">Cập nhật hồ sơ</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Lịch sử đặt phòng gần đây -->
    <section class="surface" style="margin-top: 32px; padding: 24px;">
        <h3 style="font-size: 16px; color: var(--navy); margin-bottom: 16px;">Đơn đặt phòng gần đây</h3>
        <% if (bookings != null && !bookings.isEmpty()) { %>
        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th>MÃ ĐẶT PHÒNG</th>
                    <th>PHÒNG</th>
                    <th>LOẠI PHÒNG</th>
                    <th>ĐƠN GIÁ</th>
                    <th>NHẬN PHÒNG</th>
                    <th>TRẢ PHÒNG</th>
                    <th>TRẠNG THÁI</th>
                    <th>HÓA ĐƠN</th>
                </tr>
                </thead>
                <tbody>
                <%
                    int limit = 0;
                    for (Booking b : bookings) {
                        if (limit++ >= 5) break; // Chỉ hiển thị tối đa 5 đơn gần đây
                        String statusText = "Chờ xác nhận";
                        if ("Confirmed".equals(b.getStatus())) statusText = "Đã xác nhận";
                        else if ("CheckedIn".equals(b.getStatus())) statusText = "Đang ở";
                        else if ("CheckedOut".equals(b.getStatus())) statusText = "Đã trả phòng";
                        else if ("Cancelled".equals(b.getStatus())) statusText = "Đã hủy";
                %>
                <tr>
                    <td class="table-primary">#DP<%= b.getBookingId() %></td>
                    <td class="table-strong">Phòng <%= b.getRoom().getRoomNumber() %></td>
                    <td><%= b.getRoom().getRoomType().getName() %></td>
                    <td class="table-strong text-primary"><%= money.format(b.getRoomPrice()) %></td>
                    <td><%= d.format(b.getCheckInDate()) %></td>
                    <td><%= d.format(b.getCheckOutDate()) %></td>
                    <td>
                        <span class="badge-status badge-<%= b.getStatus() %>"><%= statusText %></span>
                    </td>
                    <td>
                        <a class="btn btn-outline" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/bookings?action=receipt&id=<%= b.getBookingId() %>">Xem biên nhận</a>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } else { %>
        <p style="text-align: center; color: var(--muted); padding: 16px 0;">Bạn chưa có đơn đặt phòng nào.</p>
        <% } %>
    </section>
</main>
<%@ include file="WEB-INF/jspf/client-footer.jspf" %>
</body>
</html>
