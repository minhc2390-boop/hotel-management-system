<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = (sess != null) ? (User) sess.getAttribute("currentUser") : null;
    Room room = (Room) request.getAttribute("room");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));

    if (currentUser == null || room == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác nhận Đặt phòng - Luxury Hotel</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <header>
        <div class="navbar">
            <div class="logo">🏨 LUXURY<span>HOTEL</span></div>
            <ul class="nav-links">
                <li><a href="<%= request.getContextPath() %>/home">Trang chủ</a></li>
                <li><a href="<%= request.getContextPath() %>/bills?action=mybills">Phòng đã đặt</a></li>
                <li class="user-info">
                    <span>Xin chào, <strong><%= currentUser.getFullName() %></strong></span>
                </li>
                <li><a href="<%= request.getContextPath() %>/logout" class="btn-logout">Đăng xuất</a></li>
            </ul>
        </div>
    </header>

    <div class="container" style="max-width: 800px;">
        <h2 class="section-title">Xác nhận đặt phòng</h2>

        <div class="panel">
            <h3 class="panel-title">Thông tin phòng chọn đặt</h3>
            <div class="info-list" style="margin-bottom: 2rem;">
                <div class="info-item">
                    <span class="info-label">Số phòng:</span>
                    <span class="info-value">Phòng <%= room.getRoomNumber() %></span>
                </div>
                <div class="info-item">
                    <span class="info-label">Loại phòng:</span>
                    <span class="info-value"><%= room.getRoomType().getName() %></span>
                </div>
                <div class="info-item">
                    <span class="info-label">Giá mỗi ngày:</span>
                    <span class="info-value" style="color: var(--accent);"><%= currencyFormat.format(room.getRoomType().getPricePerDay()) %></span>
                </div>
                <div class="info-item">
                    <span class="info-label">Số người tối đa:</span>
                    <span class="info-value"><%= room.getRoomType().getCapacity() %> người</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Mô tả:</span>
                    <span class="info-value" style="font-weight: normal;"><%= room.getDescription() != null ? room.getDescription() : room.getRoomType().getDescription() %></span>
                </div>
            </div>

            <form action="<%= request.getContextPath() %>/bills" method="POST" id="bookingForm">
                <input type="hidden" name="action" value="createBooking">
                <input type="hidden" name="roomId" value="<%= room.getId() %>">

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; margin-bottom: 1.5rem;">
                    <div class="form-group">
                        <label class="form-label" for="checkInDate">Ngày nhận phòng (Check-in)</label>
                        <input type="date" id="checkInDate" name="checkInDate" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="checkOutDate">Ngày trả phòng (Check-out)</label>
                        <input type="date" id="checkOutDate" name="checkOutDate" class="form-control" required>
                    </div>
                </div>

                <div id="dateError" class="error-message" style="display: none; margin-bottom: 1.5rem;">
                    Ngày trả phòng phải sau ngày nhận phòng ít nhất 1 ngày!
                </div>

                <div style="background-color: var(--bg); padding: 1rem; border-radius: var(--radius-sm); margin-bottom: 1.5rem; text-align: right;">
                    <span style="font-size: 0.95rem; color: var(--text-light);">Tạm tính:</span>
                    <h3 id="estimatedTotal" style="color: var(--accent); margin-top: 0.25rem;"><%= currencyFormat.format(room.getRoomType().getPricePerDay()) %> (1 ngày)</h3>
                </div>

                <div style="display: flex; gap: 1rem; justify-content: flex-end;">
                    <a href="<%= request.getContextPath() %>/home" class="btn btn-secondary">Hủy bỏ</a>
                    <button type="submit" class="btn btn-primary">Xác nhận & Thanh toán sau</button>
                </div>
            </form>
        </div>
    </div>

    <footer>
        <p>&copy; 2026 Luxury Hotel. Phát triển bởi Antigravity Pair Programmer.</p>
    </footer>

    <script>
        const pricePerDay = <%= room.getRoomType().getPricePerDay() %>;
        const checkInInput = document.getElementById('checkInDate');
        const checkOutInput = document.getElementById('checkOutDate');
        const errorDiv = document.getElementById('dateError');
        const totalHeader = document.getElementById('estimatedTotal');
        const form = document.getElementById('bookingForm');

        // Set default check-in to today, check-out to tomorrow
        const today = new Date();
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);

        const formatDate = (date) => {
            const yyyy = date.getFullYear();
            const mm = String(date.getMonth() + 1).padStart(2, '0');
            const dd = String(date.getDate()).padStart(2, '0');
            return `${yyyy}-${mm}-${dd}`;
        };

        checkInInput.value = formatDate(today);
        checkInInput.min = formatDate(today);
        checkOutInput.value = formatDate(tomorrow);
        checkOutInput.min = formatDate(tomorrow);

        function updateEstimate() {
            const checkIn = new Date(checkInInput.value);
            const checkOut = new Date(checkOutInput.value);
            
            if (isNaN(checkIn.getTime()) || isNaN(checkOut.getTime())) {
                return;
            }

            const diffTime = checkOut.getTime() - checkIn.getTime();
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

            if (diffDays <= 0) {
                errorDiv.style.display = 'block';
                totalHeader.innerHTML = 'Giá trị ngày không hợp lệ';
            } else {
                errorDiv.style.display = 'none';
                const total = diffDays * pricePerDay;
                const formatter = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });
                totalHeader.innerHTML = `${formatter.format(total)} (${diffDays} ngày)`;
            }
        }

        checkInInput.addEventListener('change', () => {
            // Check-out must be after check-in
            const checkInVal = new Date(checkInInput.value);
            const nextDay = new Date(checkInVal);
            nextDay.setDate(nextDay.getDate() + 1);
            checkOutInput.min = formatDate(nextDay);
            
            if (new Date(checkOutInput.value) <= checkInVal) {
                checkOutInput.value = formatDate(nextDay);
            }
            updateEstimate();
        });

        checkOutInput.addEventListener('change', updateEstimate);

        form.addEventListener('submit', (e) => {
            const checkIn = new Date(checkInInput.value);
            const checkOut = new Date(checkOutInput.value);
            if (checkOut <= checkIn) {
                e.preventDefault();
                errorDiv.style.display = 'block';
            }
        });
    </script>
</body>
</html>
