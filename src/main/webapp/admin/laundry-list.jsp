<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Laundry" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = (sess != null) ? (User) sess.getAttribute("currentUser") : null;
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    String activeMenu = "laundry";
    List<Laundry> laundries = (List<Laundry>) request.getAttribute("laundries");
    String keyword = (String) request.getAttribute("keyword");
    String status = (String) request.getAttribute("status");
    if (keyword == null) keyword = "";
    if (status == null) status = "";

    NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý dịch vụ Giặt Ủi - Nestora</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .badge {
            display: inline-block;
            padding: 4px 10px;
            font-size: 12px;
            font-weight: 600;
            border-radius: 12px;
            text-align: center;
        }
        .badge-success {
            color: #155724;
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
        }
        .badge-warning {
            color: #856404;
            background-color: #fff3cd;
            border: 1px solid #ffeeba;
        }
        .filter-bar {
            display: flex;
            gap: 12px;
            margin-bottom: 20px;
            flex-wrap: wrap;
            align-items: center;
        }
        .filter-bar input, .filter-bar select {
            padding: 8px 12px;
            border: 1px solid var(--line);
            border-radius: 6px;
            background: var(--surface);
            color: var(--text);
        }
        .notes-cell {
            max-width: 250px;
            white-space: pre-line;
            font-size: 12px;
            color: var(--muted);
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
                        <div class="breadcrumb">Dịch vụ / Giặt ủi</div>
                        <h1 class="page-title">Quản lý Dịch vụ Giặt Ủi</h1>
                        <p class="page-desc">Theo dõi, cập nhật đơn giặt ủi và trạng thái xử lý cho khách lưu trú.</p>
                    </div>
                    <div class="page-actions">
                        <a class="btn btn-primary" href="<%= request.getContextPath() %>/laundry?action=add">＋ Thêm đơn giặt mới</a>
                    </div>
                </div>

                <% if (request.getParameter("saved") != null) { %>
                    <div style="padding: 12px 16px; margin-bottom: 16px; background: #d4edda; color: #155724; border-radius: 6px; border: 1px solid #c3e6cb;">
                        ✓ Lưu đơn giặt ủi thành công!
                    </div>
                <% } %>
                <% if (request.getParameter("deleted") != null) { %>
                    <div style="padding: 12px 16px; margin-bottom: 16px; background: #f8d7da; color: #721c24; border-radius: 6px; border: 1px solid #f5c6cb;">
                        ✓ Đã xóa đơn giặt ủi thành công!
                    </div>
                <% } %>
                <% if (request.getParameter("statusUpdated") != null) { %>
                    <div style="padding: 12px 16px; margin-bottom: 16px; background: #d1ecf1; color: #0c5460; border-radius: 6px; border: 1px solid #bee5eb;">
                        ✓ Cập nhật trạng thái thành công!
                    </div>
                <% } %>

                <form method="get" action="<%= request.getContextPath() %>/laundry" class="filter-bar">
                    <input type="hidden" name="action" value="list">
                    <input type="text" name="keyword" placeholder="Tìm tên khách, số phòng, ghi chú..." value="<%= keyword %>" style="min-width: 240px;">
                    <select name="status">
                        <option value="">-- Tất cả trạng thái --</option>
                        <option value="Chưa hoàn thành" <%= ("Chưa hoàn thành".equals(status) || "Chưa hoàn tất".equals(status)) ? "selected" : "" %>>Chưa hoàn thành</option>
                        <option value="Đã hoàn thành" <%= ("Đã hoàn thành".equals(status) || "Đã hoàn tất".equals(status)) ? "selected" : "" %>>Đã hoàn thành</option>
                    </select>
                    <button type="submit" class="btn btn-primary" style="padding: 8px 16px;">Lọc dữ liệu</button>
                    <a href="<%= request.getContextPath() %>/laundry?action=list" class="btn btn-outline" style="padding: 8px 16px;">Đặt lại</a>
                </form>

                <section class="surface">
                    <div class="surface-head">
                        <div>
                            <h2 class="surface-title">Danh sách đơn giặt ủi</h2>
                            <p class="surface-subtitle">Tổng số: <%= laundries != null ? laundries.size() : 0 %> đơn</p>
                        </div>
                    </div>

                    <% if (laundries != null && !laundries.isEmpty()) { %>
                        <div class="table-wrap">
                            <table>
                                <thead>
                                <tr>
                                    <th>Mã đơn</th>
                                    <th>Khách hàng</th>
                                    <th>Số phòng</th>
                                    <th>Loại dịch vụ</th>
                                    <th>Số lượng</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                    <th>Ghi chú (Lưu ý)</th>
                                    <th>Ngày tạo</th>
                                    <th>Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% for (Laundry l : laundries) { %>
                                    <tr>
                                        <td class="table-primary">#<%= l.getId() %></td>
                                        <td><span class="table-strong"><%= l.getCustomerName() %></span></td>
                                        <td><span class="table-strong">Phòng <%= l.getRoomNumber() %></span></td>
                                        <td><%= l.getServiceType() != null ? l.getServiceType() : "Giặt sấy" %></td>
                                        <td><%= l.getQuantity() %></td>
                                        <td class="table-strong"><%= money.format(l.getTotalPrice()) %></td>
                                        <td>
                                            <% if (l.isCompleted()) { %>
                                                <span class="badge badge-success">Đã hoàn thành</span>
                                            <% } else { %>
                                                <span class="badge badge-warning">Chưa hoàn thành</span>
                                            <% } %>
                                        </td>
                                        <td class="notes-cell"><%= (l.getNotes() != null && !l.getNotes().trim().isEmpty()) ? l.getNotes() : "-" %></td>
                                        <td><%= l.getCreatedDate() != null ? dtf.format(l.getCreatedDate()) : "-" %></td>
                                        <td>
                                            <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                                                <a class="btn btn-outline" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/laundry?action=detail&id=<%= l.getId() %>">Chi tiết</a>
                                                <a class="btn btn-primary" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/laundry?action=edit&id=<%= l.getId() %>">Sửa</a>
                                                <% if (!l.isCompleted()) { %>
                                                    <form method="post" action="<%= request.getContextPath() %>/laundry" accept-charset="UTF-8" style="display:inline;" onsubmit="return confirm('Xác nhận hoàn thành đơn giặt ủi này?');">
                                                        <input type="hidden" name="action" value="updateStatus">
                                                        <input type="hidden" name="id" value="<%= l.getId() %>">
                                                        <input type="hidden" name="processingStatus" value="Đã hoàn thành">
                                                        <button type="submit" class="btn btn-success" style="padding: 4px 8px; font-size:12px;">Hoàn thành</button>
                                                    </form>
                                                <% } %>
                                                <form method="post" action="<%= request.getContextPath() %>/laundry" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa đơn giặt ủi này?');">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="<%= l.getId() %>">
                                                    <button type="submit" class="btn btn-danger" style="padding: 4px 8px; font-size:12px;">Xóa</button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } else { %>
                        <div class="empty" style="padding: 40px; text-align: center;">
                            <strong>Chưa có dữ liệu đơn giặt ủi</strong>
                            <p style="color: var(--muted); margin-top: 6px;">Bấm "Thêm đơn giặt mới" để tạo đơn đầu tiên.</p>
                        </div>
                    <% } %>
                </section>
            </div>
        </section>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/app.js"></script>
</body>
</html>

