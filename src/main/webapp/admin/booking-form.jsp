<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Booking" %>
<%@ page import="com.hotel.model.Customer" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
    String activeMenu = "bookings";

    Booking booking = (Booking) request.getAttribute("booking");
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");

    boolean isEdit = (booking != null);
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    String checkInVal = "";
    String checkOutVal = "";
    String noteVal = "";
    String phoneVal = "";
    String cccdVal = "";
    if (isEdit) {
        if (booking.getCheckInDate() != null) checkInVal = sdf.format(booking.getCheckInDate());
        if (booking.getCheckOutDate() != null) checkOutVal = sdf.format(booking.getCheckOutDate());
        if (booking.getNote() != null) noteVal = booking.getNote();
        if (booking.getCustomer().getCustomerPhone() != null) phoneVal = booking.getCustomer().getCustomerPhone();
        if (booking.getCustomer().getCustomerCccd() != null) cccdVal = booking.getCustomer().getCustomerCccd();
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title><%= isEdit ? "Cập nhật đặt phòng" : "Tạo phiếu đặt phòng" %> - Nestora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        /* Custom styling to make the booking form premium and beautiful */
        .form-section-card {
            border: 1px solid var(--line);
            border-radius: 12px;
            padding: 24px;
            background: #fafbfc;
            margin-bottom: 24px;
            transition: all 0.3s ease;
        }
        .form-section-card:hover {
            box-shadow: 0 6px 18px rgba(28, 52, 84, 0.04);
            border-color: #cbd5e1;
        }
        .form-section-title {
            font-size: 15px;
            font-weight: 700;
            color: var(--navy);
            margin-bottom: 18px;
            display: flex;
            align-items: center;
            gap: 8px;
            border-bottom: 1px solid var(--line);
            padding-bottom: 10px;
        }
        .form-section-title svg {
            width: 18px;
            height: 18px;
            color: var(--brand);
        }
        .required-star {
            color: var(--danger);
            margin-left: 2px;
        }
        .input-with-icon {
            position: relative;
        }
        .input-with-icon .form-control {
            padding-left: 42px;
        }
        .input-with-icon .input-field-icon {
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
        .form-control:focus + .input-field-icon {
            color: var(--brand);
        }
        .animated-section {
            animation: fadeIn 0.4s ease-out;
        }
        .booking-date-grid {
            align-items: end;
        }
        .booking-room-picker {
            margin-top: 4px;
            padding-top: 20px;
            border-top: 1px solid var(--line);
            animation: fadeIn 0.35s ease-out;
        }
        .booking-room-picker[hidden] {
            display: none;
        }
        .booking-room-picker-head {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 18px;
            margin-bottom: 16px;
        }
        .booking-room-picker-title {
            margin: 0 0 5px;
            color: var(--navy);
            font-size: 15px;
            font-weight: 700;
        }
        .booking-room-picker-subtitle {
            margin: 0;
            color: var(--muted);
            font-size: 12px;
            line-height: 1.5;
        }
        .booking-room-legend {
            display: flex;
            align-items: center;
            gap: 14px;
            flex-shrink: 0;
            color: var(--muted);
            font-size: 11px;
        }
        .booking-room-legend-item {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            white-space: nowrap;
        }
        .booking-room-legend-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #16a36a;
        }
        .booking-room-legend-dot.unavailable {
            background: #a8b2c1;
        }
        .booking-room-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(175px, 1fr));
            gap: 12px;
        }
        .booking-room-card {
            position: relative;
            min-height: 132px;
            padding: 17px;
            border: 1px solid var(--line);
            border-radius: 11px;
            background: var(--surface);
            color: var(--text);
            font: inherit;
            text-align: left;
            box-shadow: 0 3px 10px rgba(28, 52, 84, 0.035);
            cursor: pointer;
            transition: border-color 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease, background 0.2s ease;
        }
        .booking-room-card:not(:disabled):hover {
            transform: translateY(-2px);
            border-color: #93b8f2;
            box-shadow: 0 9px 22px rgba(23, 105, 224, 0.1);
        }
        .booking-room-card:focus-visible {
            outline: 3px solid rgba(23, 105, 224, 0.2);
            outline-offset: 2px;
        }
        .booking-room-card.is-selected {
            border-color: var(--brand);
            background: #f4f8ff;
            box-shadow: 0 0 0 2px rgba(23, 105, 224, 0.13), 0 9px 22px rgba(23, 105, 224, 0.1);
        }
        .booking-room-card.is-unavailable {
            border-color: #d7dde6;
            background: #eef1f5;
            color: #8d98a7;
            box-shadow: none;
            cursor: not-allowed;
            filter: grayscale(0.35);
            opacity: 0.68;
        }
        .booking-room-card-dot {
            position: absolute;
            top: 14px;
            right: 14px;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #16a36a;
        }
        .booking-room-card.is-unavailable .booking-room-card-dot {
            background: #9aa5b3;
        }
        .booking-room-card-number {
            margin: 0 20px 9px 0;
            color: var(--navy);
            font-size: 15px;
            font-weight: 700;
        }
        .booking-room-card.is-unavailable .booking-room-card-number {
            color: #7f8997;
        }
        .booking-room-card-type,
        .booking-room-card-status {
            margin-bottom: 7px;
            color: #8b9cb2;
            font-size: 11px;
            line-height: 1.35;
        }
        .booking-room-card-status {
            color: #6f8198;
        }
        .booking-room-card-price {
            color: var(--brand);
            font-size: 12px;
            font-weight: 700;
        }
        .booking-room-card.is-unavailable .booking-room-card-type,
        .booking-room-card.is-unavailable .booking-room-card-status,
        .booking-room-card.is-unavailable .booking-room-card-price {
            color: #919ba8;
        }
        .booking-room-selection-error {
            min-height: 18px;
            margin: 10px 0 0;
            color: var(--danger);
            font-size: 11px;
            font-weight: 600;
        }
        .booking-room-empty {
            grid-column: 1 / -1;
            padding: 24px;
            border: 1px dashed var(--line);
            border-radius: 10px;
            color: var(--muted);
            font-size: 12px;
            text-align: center;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(6px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @media (max-width: 760px) {
            .booking-room-picker-head {
                flex-direction: column;
            }
            .booking-room-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }
        @media (max-width: 460px) {
            .booking-room-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
    <script>
        function toggleNewCustomerFields() {
            var select = document.getElementById("customerId");
            var newCustSection = document.getElementById("newCustomerSection");
            var nameField = document.getElementById("customerName");
            var emailField = document.getElementById("customerEmail");
            
            if (select.value === "0") {
                newCustSection.style.display = "block";
                nameField.required = true;
                emailField.required = false;
            } else {
                newCustSection.style.display = "none";
                nameField.required = false;
                emailField.required = false;
                
                var selectedOption = select.options[select.selectedIndex];
                var phone = selectedOption.getAttribute("data-phone");
                var cccd = selectedOption.getAttribute("data-cccd");
                document.getElementById("customerPhone").value = phone || "";
                document.getElementById("customerCccd").value = cccd || "";
            }
        }
    </script>
</head>
<body>
<div class="admin-layout">
    <%@ include file="../WEB-INF/jspf/admin-sidebar.jspf" %>
    <main class="main-shell">
        <%@ include file="../WEB-INF/jspf/admin-topbar.jspf" %>
        <section class="content">
            <div class="content-inner">
                <div class="page-head">
                    <div>
                        <div class="breadcrumb">Vận hành / Đặt phòng / <%= isEdit ? "Cập nhật" : "Tạo mới" %></div>
                        <h1 class="page-title"><%= isEdit ? "Cập nhật đặt phòng" : "Tạo phiếu đặt phòng" %></h1>
                        <p class="page-desc">Vui lòng điền đầy đủ thông tin bên dưới để thực hiện ghi nhận đặt phòng.</p>
                    </div>
                </div>

                <div class="surface surface-pad form-surface" style="border: 0; box-shadow: none; background: transparent; padding: 0;">
                    <form action="<%= request.getContextPath() %>/bookings" method="post">
                        <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
                        <% if (isEdit) { %>
                            <input type="hidden" name="bookingId" value="<%= booking.getBookingId() %>">
                        <% } %>

                        <!-- SECTION 1: KHÁCH HÀNG & LIÊN HỆ -->
                        <div class="form-section-card">
                            <h3 class="form-section-title">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                Thông tin Khách hàng & Liên hệ
                            </h3>
                            <div class="form-grid">
                                <!-- Chọn khách hàng -->
                                <div class="form-group">
                                    <label class="form-label" for="customerId">Khách hàng lưu trú <span class="required-star">*</span></label>
                                    <div class="input-with-icon">
                                        <select class="form-control" id="customerId" name="customerId" onchange="toggleNewCustomerFields()" required>
                                            <% if (!isEdit) { %>
                                                <option value="0">-- Thêm khách hàng mới (Nhập ở dưới) --</option>
                                            <% } %>
                                            <%
                                                if (customers != null) {
                                                    for (Customer c : customers) {
                                                        boolean selected = isEdit && booking.getCustomer().getCustomerId() == c.getCustomerId();
                                            %>
                                            <option value="<%= c.getCustomerId() %>" <%= selected ? "selected" : "" %>
                                                    data-phone="<%= c.getCustomerPhone() != null ? c.getCustomerPhone() : "" %>"
                                                    data-cccd="<%= c.getCustomerCccd() != null ? c.getCustomerCccd() : "" %>">
                                                <%= c.getCustomerName() %>
                                            </option>
                                            <%
                                                    }
                                                }
                                            %>
                                        </select>
                                        <svg class="input-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                    </div>
                                </div>

                                <!-- Số điện thoại -->
                                <div class="form-group">
                                    <label class="form-label" for="customerPhone">Số điện thoại liên hệ <span class="required-star">*</span></label>
                                    <div class="input-with-icon">
                                        <input class="form-control" type="tel" id="customerPhone" name="customerPhone" placeholder="Nhập số điện thoại" required value="<%= phoneVal %>">
                                        <svg class="input-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                                    </div>
                                </div>

                                <!-- Căn cước công dân -->
                                <div class="form-group">
                                    <label class="form-label" for="customerCccd">Số Căn cước công dân (CCCD) <span class="required-star">*</span></label>
                                    <div class="input-with-icon">
                                        <input class="form-control" type="text" id="customerCccd" name="customerCccd" placeholder="Nhập số CCCD" required value="<%= cccdVal %>">
                                        <svg class="input-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="16" rx="2" ry="2"/><line x1="7" y1="8" x2="17" y2="8"/><line x1="7" y1="12" x2="17" y2="12"/><line x1="7" y1="16" x2="13" y2="16"/></svg>
                                    </div>
                                </div>
                            </div>

                            <!-- Phần thông tin khách hàng mới (Hiện/Ẩn động) -->
                            <div id="newCustomerSection" class="animated-section" style="margin-top: 15px; display: <%= isEdit ? "none" : "block" %>;">
                                <div style="font-size: 13px; font-weight: 700; color: var(--brand); margin-bottom: 12px; text-transform: uppercase;">Thông tin khách hàng mới</div>
                                <div class="form-grid">
                                    <div class="form-group">
                                        <label class="form-label" for="customerName">Họ và tên khách hàng *</label>
                                        <div class="input-with-icon">
                                            <input class="form-control" type="text" id="customerName" name="customerName" placeholder="Ví dụ: Nguyễn Văn A" <%= !isEdit ? "required" : "" %>>
                                            <svg class="input-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label" for="customerEmail">Địa chỉ Email</label>
                                        <div class="input-with-icon">
                                            <input class="form-control" type="email" id="customerEmail" name="customerEmail" placeholder="example@gmail.com (Không bắt buộc)">
                                            <svg class="input-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- SECTION 2: PHÒNG & LỊCH TRÌNH -->
                        <div class="form-section-card">
                            <h3 class="form-section-title">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                Chọn Phòng & Lịch trình lưu trú
                            </h3>
                            <div class="form-grid booking-date-grid">
                                <!-- Ngày nhận phòng -->
                                <div class="form-group">
                                    <label class="form-label" for="checkInDate">Ngày nhận phòng <span class="required-star">*</span></label>
                                    <div class="input-with-icon">
                                        <input class="form-control" type="date" id="checkInDate" name="checkInDate" required value="<%= checkInVal %>">
                                        <svg class="input-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                    </div>
                                </div>

                                <!-- Ngày trả phòng -->
                                <div class="form-group">
                                    <label class="form-label" for="checkOutDate">Ngày trả phòng <span class="required-star">*</span></label>
                                    <div class="input-with-icon">
                                        <input class="form-control" type="date" id="checkOutDate" name="checkOutDate" required value="<%= checkOutVal %>">
                                        <svg class="input-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                    </div>
                                </div>

                                <% if (isEdit) { %>
                                <!-- Trạng thái -->
                                <div class="form-group">
                                    <label class="form-label" for="status">Trạng thái đặt phòng <span class="required-star">*</span></label>
                                    <div class="input-with-icon">
                                        <select class="form-control" id="status" name="status" required>
                                            <option value="Pending" <%= "Pending".equals(booking.getStatus()) ? "selected" : "" %>>Chờ xác nhận (Pending)</option>
                                            <option value="Confirmed" <%= "Confirmed".equals(booking.getStatus()) ? "selected" : "" %>>Đã xác nhận (Confirmed)</option>
                                            <option value="CheckedIn" <%= "CheckedIn".equals(booking.getStatus()) ? "selected" : "" %>>Đã nhận phòng (CheckedIn)</option>
                                            <option value="CheckedOut" <%= "CheckedOut".equals(booking.getStatus()) ? "selected" : "" %>>Đã trả phòng (CheckedOut)</option>
                                            <option value="Cancelled" <%= "Cancelled".equals(booking.getStatus()) ? "selected" : "" %>>Đã hủy (Cancelled)</option>
                                        </select>
                                        <svg class="input-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                    </div>
                                </div>
                                <% } %>
                            </div>

                            <%
                                int selectedRoomId = isEdit && booking.getRoom() != null ? booking.getRoom().getId() : 0;
                            %>
                            <% if (isEdit) { %>
                                <input type="hidden" id="roomId" name="roomId" value="<%= selectedRoomId %>">
                            <% } else { %>
                                <div id="selectedRoomInputs"></div>
                            <% } %>

                            <div class="booking-room-picker" id="bookingRoomPicker" hidden>
                                <div class="booking-room-picker-head">
                                    <div>
                                        <h4 class="booking-room-picker-title">Sơ đồ phòng khả dụng</h4>
                                        <p class="booking-room-picker-subtitle" id="bookingRoomPeriod">
                                            Chọn một hoặc nhiều phòng còn trống cho lịch lưu trú đã nhập.
                                        </p>
                                    </div>
                                    <div class="booking-room-legend" aria-label="Chú thích trạng thái phòng">
                                        <span class="booking-room-legend-item">
                                            <span class="booking-room-legend-dot"></span>
                                            Có thể chọn
                                        </span>
                                        <span class="booking-room-legend-item">
                                            <span class="booking-room-legend-dot unavailable"></span>
                                            Không khả dụng
                                        </span>
                                    </div>
                                </div>

                                <div class="booking-room-grid"
                                     id="bookingRoomGrid"
                                     role="listbox"
                                     aria-label="Chọn phòng"
                                     aria-multiselectable="<%= !isEdit %>">
                                    <%
                                        if (rooms != null && !rooms.isEmpty()) {
                                            for (Room r : rooms) {
                                                boolean selected = selectedRoomId == r.getId();
                                                boolean available = "Available".equalsIgnoreCase(r.getStatus());
                                                boolean selectable = available || selected;
                                                String statusText = "Phòng trống";
                                                if ("Booked".equalsIgnoreCase(r.getStatus())) {
                                                    statusText = "Đang thuê";
                                                } else if ("Maintenance".equalsIgnoreCase(r.getStatus())) {
                                                    statusText = "Bảo trì";
                                                } else if (!available) {
                                                    statusText = r.getStatus();
                                                }
                                    %>
                                    <button type="button"
                                            class="booking-room-card<%= selected ? " is-selected" : "" %><%= !selectable ? " is-unavailable" : "" %>"
                                            data-room-id="<%= r.getId() %>"
                                            data-room-number="<%= r.getRoomNumber() %>"
                                            role="option"
                                            aria-selected="<%= selected %>"
                                            aria-disabled="<%= !selectable %>"
                                            <%= !selectable ? "disabled" : "" %>>
                                        <span class="booking-room-card-dot" aria-hidden="true"></span>
                                        <div class="booking-room-card-number">Phòng <%= r.getRoomNumber() %></div>
                                        <div class="booking-room-card-type"><%= r.getRoomType() != null ? r.getRoomType().getName() : "Chưa phân loại" %></div>
                                        <div class="booking-room-card-status"><%= statusText %></div>
                                        <div class="booking-room-card-price"><%= r.getRoomType() != null ? money.format(r.getRoomType().getPricePerDay()) : "0 đ" %> / ngày</div>
                                    </button>
                                    <%
                                            }
                                        } else {
                                    %>
                                    <div class="booking-room-empty">Chưa có phòng nào trong hệ thống.</div>
                                    <% } %>
                                </div>
                                <p class="booking-room-selection-error" id="bookingRoomSelectionError" role="alert" aria-live="polite"></p>
                            </div>
                        </div>

                        <!-- SECTION 3: THÔNG TIN BỔ SUNG & GHI CHÚ -->
                        <div class="form-section-card">
                            <h3 class="form-section-title">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                                Yêu cầu đặc biệt & Ghi chú
                            </h3>
                            <div class="form-group full">
                                <label class="form-label" for="note">Nội dung ghi chú</label>
                                <textarea class="form-control" id="note" name="note" rows="3" placeholder="Nhập các yêu cầu đặc biệt của khách (ví dụ: tầng cao, hướng nhìn, hỗ trợ bữa ăn...)"><%= noteVal %></textarea>
                            </div>
                        </div>

                        <!-- Các nút hành động -->
                        <div class="form-actions" style="margin-top: 10px;">
                            <a class="btn btn-outline" style="min-height: 44px; padding: 0 24px;" href="<%= request.getContextPath() %>/bookings?action=list">Quay lại</a>
                            <button class="btn btn-primary" style="min-height: 44px; padding: 0 30px;" type="submit">Lưu đặt phòng</button>
                        </div>
                    </form>
                </div>
            </div>
        </section>
    </main>
</div>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        toggleNewCustomerFields();

        var form = document.querySelector('form[action$="/bookings"]');
        var checkInInput = document.getElementById("checkInDate");
        var checkOutInput = document.getElementById("checkOutDate");
        var roomInput = document.getElementById("roomId");
        var selectedRoomInputs = document.getElementById("selectedRoomInputs");
        var roomPicker = document.getElementById("bookingRoomPicker");
        var roomPeriod = document.getElementById("bookingRoomPeriod");
        var selectionError = document.getElementById("bookingRoomSelectionError");
        var roomCards = Array.prototype.slice.call(document.querySelectorAll(".booking-room-card:not(:disabled)"));
        var isEditMode = <%= isEdit %>;

        function formatDateVi(value) {
            if (!value) return "";
            var parts = value.split("-");
            return parts.length === 3 ? parts[2] + "/" + parts[1] + "/" + parts[0] : value;
        }

        function getSelectedCards() {
            return roomCards.filter(function(card) {
                return card.classList.contains("is-selected");
            });
        }

        function syncSelectedRoomInputs() {
            var selectedCards = getSelectedCards();
            if (isEditMode) {
                roomInput.value = selectedCards.length
                        ? selectedCards[0].getAttribute("data-room-id")
                        : "";
                return;
            }

            selectedRoomInputs.innerHTML = "";
            selectedCards.forEach(function(card) {
                var input = document.createElement("input");
                input.type = "hidden";
                input.name = "roomIds";
                input.value = card.getAttribute("data-room-id");
                selectedRoomInputs.appendChild(input);
            });
        }

        function updateSelectionMessage() {
            var selectedCards = getSelectedCards();
            if (!selectedCards.length) {
                selectionError.textContent = "";
                return;
            }

            var roomNumbers = selectedCards.map(function(card) {
                return card.getAttribute("data-room-number");
            });
            selectionError.textContent = "Đã chọn " + selectedCards.length
                    + " phòng: " + roomNumbers.join(", ") + ".";
            selectionError.style.color = "var(--brand)";
        }

        function clearRoomSelection() {
            roomCards.forEach(function(card) {
                card.classList.remove("is-selected");
                card.setAttribute("aria-selected", "false");
            });
            syncSelectedRoomInputs();
        }

        function showRoomPicker(clearSelection) {
            var checkIn = checkInInput.value;
            var checkOut = checkOutInput.value;

            checkOutInput.min = checkIn || "";
            checkOutInput.setCustomValidity("");

            if (!checkIn || !checkOut) {
                roomPicker.hidden = true;
                selectionError.textContent = "";
                if (clearSelection) clearRoomSelection();
                return false;
            }

            if (checkOut <= checkIn) {
                roomPicker.hidden = true;
                checkOutInput.setCustomValidity("Ngày trả phòng phải sau ngày nhận phòng.");
                checkOutInput.reportValidity();
                if (clearSelection) clearRoomSelection();
                return false;
            }

            if (clearSelection) clearRoomSelection();
            roomPeriod.textContent = "Chọn phòng cho kỳ lưu trú từ " + formatDateVi(checkIn) + " đến " + formatDateVi(checkOut) + ".";
            roomPicker.hidden = false;
            selectionError.textContent = "";
            return true;
        }

        roomCards.forEach(function(card) {
            card.addEventListener("click", function() {
                if (isEditMode) {
                    roomCards.forEach(function(item) {
                        item.classList.remove("is-selected");
                        item.setAttribute("aria-selected", "false");
                    });
                    card.classList.add("is-selected");
                    card.setAttribute("aria-selected", "true");
                } else {
                    var selected = card.classList.toggle("is-selected");
                    card.setAttribute("aria-selected", selected ? "true" : "false");
                }
                syncSelectedRoomInputs();
                updateSelectionMessage();
            });
        });

        checkInInput.addEventListener("change", function() {
            selectionError.style.color = "var(--danger)";
            showRoomPicker(true);
        });
        checkOutInput.addEventListener("change", function() {
            selectionError.style.color = "var(--danger)";
            showRoomPicker(true);
        });

        form.addEventListener("submit", function(event) {
            selectionError.style.color = "var(--danger)";
            if (!showRoomPicker(false)) {
                event.preventDefault();
                return;
            }
            syncSelectedRoomInputs();
            if (!getSelectedCards().length) {
                event.preventDefault();
                selectionError.textContent = "Vui lòng chọn ít nhất một phòng khả dụng trước khi lưu đặt phòng.";
                roomPicker.scrollIntoView({ behavior: "smooth", block: "center" });
            }
        });

        syncSelectedRoomInputs();
        updateSelectionMessage();
        showRoomPicker(false);
    });
</script>
</body>
</html>
