<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Booking" %>
<%@ page import="com.hotel.model.Customer" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
    String activeMenu = "bookings";

    Booking booking = (Booking) request.getAttribute("booking");
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");

    boolean isEdit = (booking != null);
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
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
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(6px); }
            to { opacity: 1; transform: translateY(0); }
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
                            <div class="form-grid">
                                <!-- Chọn phòng -->
                                <div class="form-group">
                                    <label class="form-label" for="roomId">Phòng chọn đặt <span class="required-star">*</span></label>
                                    <div class="input-with-icon">
                                        <select class="form-control" id="roomId" name="roomId" required>
                                            <option value="">-- Chọn phòng khả dụng --</option>
                                            <%
                                                if (rooms != null) {
                                                    for (Room r : rooms) {
                                                        boolean selected = isEdit && booking.getRoom().getId() == r.getId();
                                            %>
                                            <option value="<%= r.getId() %>" <%= selected ? "selected" : "" %>>
                                                Phòng <%= r.getRoomNumber() %> - <%= r.getRoomType().getName() %> (<%= r.getStatus() %>)
                                            </option>
                                            <%
                                                    }
                                                }
                                            %>
                                        </select>
                                        <svg class="input-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                                    </div>
                                </div>

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
    });
</script>
</body>
</html>