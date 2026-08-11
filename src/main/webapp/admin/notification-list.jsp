<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.HotelNotification" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = (sess != null) ? (User) sess.getAttribute("currentUser") : null;
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    String activeMenu = "notifications";
    List<HotelNotification> notifications = (List<HotelNotification>) request.getAttribute("notifications");
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý thông báo - Nestora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .type-badge {
            display: inline-block;
            padding: 3px 10px;
            font-size: 11px;
            font-weight: 700;
            border-radius: 12px;
            text-transform: uppercase;
        }
        .type-info { color: var(--brand); background-color: var(--brand-soft); border: 1px solid var(--line); }
        .type-warning { color: var(--warning); background-color: var(--warning-bg); border: 1px solid var(--line); }
        .type-success { color: var(--success); background-color: var(--success-bg); border: 1px solid var(--line); }
        .type-error { color: var(--danger); background-color: var(--danger-bg); border: 1px solid var(--line); }

        .status-badge {
            display: inline-block;
            padding: 3px 8px;
            font-size: 11px;
            font-weight: 600;
            border-radius: 4px;
        }
        .status-active { color: var(--success); background: var(--success-bg); }
        .status-hidden { color: var(--muted); background: rgba(0,0,0,0.06); }
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
                        <div class="breadcrumb">Hệ thống / Thông báo</div>
                        <h1 class="page-title">Quản lý Thông báo Khách sạn</h1>
                        <p class="page-desc">Tạo và quản lý các thông báo tin tức, cảnh báo cho nhân viên và hệ thống.</p>
                    </div>
                    <div class="page-actions">
                        <a class="btn btn-primary" href="<%= request.getContextPath() %>/admin/notifications?action=add">＋ Thêm thông báo</a>
                    </div>
                </div>

                <% if (request.getParameter("saved") != null) { %>
                    <div class="alert alert-success">
                        ✓ Lưu thông báo thành công!
                    </div>
                <% } %>
                <% if (request.getParameter("deleted") != null) { %>
                    <div class="alert alert-error">
                        ✓ Đã xóa thông báo thành công!
                    </div>
                <% } %>

                <section class="surface">
                    <div class="surface-head">
                        <div>
                            <h2 class="surface-title">Danh sách thông báo</h2>
                            <p class="surface-subtitle">Tổng cộng <%= notifications != null ? notifications.size() : 0 %> thông báo</p>
                        </div>
                    </div>

                    <% if (notifications != null && !notifications.isEmpty()) { %>
                        <div class="table-wrap" data-admin-paginated="10">
                            <table>
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tiêu đề</th>
                                    <th>Loại</th>
                                    <th>Ngày tạo</th>
                                    <th>Người tạo</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% for (HotelNotification n : notifications) { %>
                                    <tr>
                                        <td class="table-primary">#<%= n.getNotificationId() %></td>
                                        <td>
                                            <span class="table-strong"><%= n.getTitle() %></span>
                                            <div style="font-size: 12px; color: var(--muted); max-width: 350px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                                <%= n.getContent() %>
                                            </div>
                                        </td>
                                        <td>
                                            <% if ("INFO".equalsIgnoreCase(n.getType())) { %>
                                                <span class="type-badge type-info">INFO</span>
                                            <% } else if ("WARNING".equalsIgnoreCase(n.getType())) { %>
                                                <span class="type-badge type-warning">WARNING</span>
                                            <% } else if ("SUCCESS".equalsIgnoreCase(n.getType())) { %>
                                                <span class="type-badge type-success">SUCCESS</span>
                                            <% } else { %>
                                                <span class="type-badge type-error">ERROR</span>
                                            <% } %>
                                        </td>
                                        <td><%= n.getCreatedAt() != null ? dtf.format(n.getCreatedAt()) : "-" %></td>
                                        <td>
                                            <%= (n.getCreator() != null && n.getCreator().getFullName() != null) ? n.getCreator().getFullName() : (n.getCreatedBy() != null ? "User #" + n.getCreatedBy() : "Hệ thống") %>
                                        </td>
                                        <td>
                                            <% if (n.getIsActive()) { %>
                                                <span class="status-badge status-active">Hiển thị</span>
                                            <% } else { %>
                                                <span class="status-badge status-hidden">Ẩn</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <div style="display: flex; gap: 6px;">
                                                <a class="btn btn-primary" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/admin/notifications?action=edit&id=<%= n.getNotificationId() %>">Sửa</a>
                                                <form method="post" action="<%= request.getContextPath() %>/admin/notifications" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa thông báo này?');">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="<%= n.getNotificationId() %>">
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
                            <strong>Chưa có thông báo nào</strong>
                            <p style="color: var(--muted); margin-top: 6px;">Bấm "Thêm thông báo" để tạo thông báo mới.</p>
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
