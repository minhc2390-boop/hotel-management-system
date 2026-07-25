<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Booking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
    
    String mode = (String) request.getAttribute("mode");
    if (mode == null) {
        mode = "";
    }
    
    String activeMenu = "bookings";
    if ("checkin".equals(mode)) {
        activeMenu = "checkin";
    } else if ("checkout".equals(mode)) {
        activeMenu = "checkout";
    }
    
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    
    User currentUserCheck = (User) session.getAttribute("currentUser");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Đặt phòng - Nestora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
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
        .table-actions {
            display: flex;
            gap: 8px;
            align-items: center;
        }
    </style>
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
                        <div class="breadcrumb">Vận hành / <%= "checkin".equals(mode) ? "Nhận phòng" : ("checkout".equals(mode) ? "Trả phòng" : "Đặt phòng") %></div>
                        <h1 class="page-title">
                            <%= "checkin".equals(mode) ? "Danh sách chờ nhận phòng" : ("checkout".equals(mode) ? "Danh sách chờ trả phòng" : "Danh sách đặt phòng") %>
                        </h1>
                        <p class="page-desc">
                            <%= "checkin".equals(mode) ? "Xem danh sách và thực hiện thủ tục nhận phòng cho khách hàng." : ("checkout".equals(mode) ? "Thực hiện thủ tục trả phòng và thanh toán hóa đơn." : "Theo dõi lịch đặt và quản lý trạng thái nhận/trả phòng.") %>
                        </p>
                    </div>
                    <div class="page-actions">
                        <a class="btn btn-primary" href="<%= request.getContextPath() %>/bookings?action=add">＋ Tạo mới đặt phòng</a>
                    </div>
                </div>

                <section class="surface">
                    <div class="table-tools">
                        <div class="search-box">
                            <input type="search" placeholder="Tìm kiếm...">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="11" cy="11" r="7"/>
                                <path d="M20 20l-3.5-3.5"/>
                            </svg>
                        </div>
                        <div class="table-meta"><%= bookings != null ? bookings.size() : 0 %> đặt phòng</div>
                    </div>
                    
                    <div class="table-wrap">
                        <table>
                            <thead>
                            <tr>
                                <th>MÃ ĐẶT PHÒNG</th>
                                <th>KHÁCH HÀNG</th>
                                <th>PHÒNG</th>
                                <th>GIÁ ĐẶT</th>
                                <th>NHẬN PHÒNG</th>
                                <th>TRẢ PHÒNG</th>
                                <th>TRẠNG THÁI</th>
                                <th>THAO TÁC</th>
                            </tr>
                            </thead>
                            <tbody>
                            <%
                                if (bookings != null && !bookings.isEmpty()) {
                                    for (Booking b : bookings) {
                                        String statusText = "Chờ xác nhận";
                                        if ("Confirmed".equals(b.getStatus())) statusText = "Đã xác nhận";
                                        else if ("CheckedIn".equals(b.getStatus())) statusText = "Đã nhận phòng";
                                        else if ("CheckedOut".equals(b.getStatus())) statusText = "Đã trả phòng";
                                        else if ("Cancelled".equals(b.getStatus())) statusText = "Đã hủy";
                            %>
                            <tr>
                                <td class="table-primary">#DP<%= b.getBookingId() %></td>
                                <td>
                                    <div class="table-strong"><%= b.getCustomer().getCustomerName() %></div>
                                    <div style="font-size:11px; color:var(--muted);"><%= b.getCustomer().getCustomerPhone() %></div>
                                </td>
                                <td>
                                    <div class="table-strong">P.<%= b.getRoom().getRoomNumber() %></div>
                                    <div style="font-size:11px; color:var(--muted);"><%= b.getRoom().getRoomType().getName() %></div>
                                </td>
                                <td class="table-strong text-primary"><%= money.format(b.getRoomPrice()) %></td>
                                <td><%= sdf.format(b.getCheckInDate()) %></td>
                                <td><%= sdf.format(b.getCheckOutDate()) %></td>
                                <td>
                                    <span class="badge-status badge-<%= b.getStatus() %>"><%= statusText %></span>
                                </td>
                                <td>
                                    <div class="table-actions">
                                        <!-- Xem phiếu đặt phòng -->
                                        <a class="btn btn-outline" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/bookings?action=receipt&id=<%= b.getBookingId() %>">📄 Phiếu</a>
                                        
                                        <!-- Cập nhật trạng thái nghiệp vụ -->
                                        <% if ("Pending".equals(b.getStatus()) || "Confirmed".equals(b.getStatus())) { %>
                                            <a class="btn btn-primary" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/bookings?action=checkin&id=<%= b.getBookingId() %>">Nhận phòng</a>
                                        <% } else if ("CheckedIn".equals(b.getStatus())) { %>
                                            <a class="btn btn-success" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/bookings?action=checkout&id=<%= b.getBookingId() %>">Trả phòng</a>
                                        <% } %>

                                        <!-- Hủy phòng nếu chưa nhận phòng và chưa hủy -->
                                        <% if (!"CheckedOut".equals(b.getStatus()) && !"Cancelled".equals(b.getStatus())) { %>
                                            <a class="btn btn-danger" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/bookings?action=cancel&id=<%= b.getBookingId() %>" onclick="return confirm('Bạn có chắc muốn hủy đặt phòng này?')">Hủy</a>
                                        <% } %>

                                        <!-- Sửa và Xóa -->
                                        <a class="btn btn-outline btn-icon" href="<%= request.getContextPath() %>/bookings?action=edit&id=<%= b.getBookingId() %>">✎</a>
                                        <a class="btn btn-outline btn-icon" href="<%= request.getContextPath() %>/bookings?action=delete&id=<%= b.getBookingId() %>" onclick="return confirm('Xóa lịch sử đặt phòng này?')">×</a>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="8" style="text-align: center; color: var(--muted); padding: 20px;">Không có dữ liệu đặt phòng nào.</td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </section>
            </div>
        </section>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/app.js"></script>
</body>
</html>