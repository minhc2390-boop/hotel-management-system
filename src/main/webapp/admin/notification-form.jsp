<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.HotelNotification" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = (sess != null) ? (User) sess.getAttribute("currentUser") : null;
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    String activeMenu = "notifications";
    Boolean isEditObj = (Boolean) request.getAttribute("isEdit");
    boolean isEdit = isEditObj != null && isEditObj;
    HotelNotification notification = (HotelNotification) request.getAttribute("notification");
    if (notification == null) notification = new HotelNotification();
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Sửa thông báo" : "Thêm thông báo" %> - Nestora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .form-group {
            margin-bottom: 18px;
        }
        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 6px;
            font-size: 13px;
            color: var(--text);
        }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid var(--line);
            border-radius: 6px;
            background: var(--surface);
            color: var(--text);
            font-family: inherit;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color: var(--brand);
            outline: none;
        }
        .checkbox-group {
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
        }
        .checkbox-group input {
            width: auto;
            cursor: pointer;
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
                        <div class="breadcrumb">Hệ thống / Thông báo / <%= isEdit ? "Chỉnh sửa" : "Thêm mới" %></div>
                        <h1 class="page-title"><%= isEdit ? "Chỉnh sửa thông báo #" + notification.getNotificationId() : "Tạo thông báo mới" %></h1>
                        <p class="page-desc">Soạn thảo nội dung thông báo phát hành trên hệ thống.</p>
                    </div>
                    <div class="page-actions">
                        <a class="btn btn-outline" href="<%= request.getContextPath() %>/admin/notifications?action=list">← Trở về danh sách</a>
                    </div>
                </div>

                <% if (error != null) { %>
                    <div class="alert alert-error">
                        ⚠ <%= error %>
                    </div>
                <% } %>

                <section class="surface" style="max-width: 750px;">
                    <div class="surface-head">
                        <h2 class="surface-title">Nội dung thông báo</h2>
                    </div>
                    <form class="surface-pad" method="post" action="<%= request.getContextPath() %>/admin/notifications">
                        <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
                        <% if (isEdit) { %>
                            <input type="hidden" name="id" value="<%= notification.getNotificationId() %>">
                        <% } %>

                        <div class="form-group">
                            <label for="title">Tiêu đề thông báo <span style="color:red;">*</span></label>
                            <input type="text" id="title" name="title" required placeholder="Nhập tiêu đề ngắn gọn..." value="<%= notification.getTitle() != null ? notification.getTitle() : "" %>">
                        </div>

                        <div class="form-group">
                            <label for="type">Loại thông báo (Type) <span style="color:red;">*</span></label>
                            <select id="type" name="type" required>
                                <option value="INFO" <%= "INFO".equalsIgnoreCase(notification.getType()) ? "selected" : "" %>>INFO (Thông tin chung)</option>
                                <option value="WARNING" <%= "WARNING".equalsIgnoreCase(notification.getType()) ? "selected" : "" %>>WARNING (Cảnh báo)</option>
                                <option value="SUCCESS" <%= "SUCCESS".equalsIgnoreCase(notification.getType()) ? "selected" : "" %>>SUCCESS (Thành công / Tin mừng)</option>
                                <option value="ERROR" <%= "ERROR".equalsIgnoreCase(notification.getType()) ? "selected" : "" %>>ERROR (Sự cố / Lỗi)</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="content">Nội dung thông báo <span style="color:red;">*</span></label>
                            <textarea id="content" name="content" rows="6" required placeholder="Nhập chi tiết nội dung thông báo..."><%= notification.getContent() != null ? notification.getContent() : "" %></textarea>
                        </div>

                        <div class="form-group">
                            <label class="checkbox-group">
                                <input type="checkbox" name="isActive" value="true" <%= (notification.getIsActive() != null && notification.getIsActive()) ? "checked" : "" %>>
                                <span>Kích hoạt hiển thị thông báo này</span>
                            </label>
                        </div>

                        <div style="margin-top: 24px; display: flex; gap: 12px;">
                            <button type="submit" class="btn btn-primary" style="min-width: 140px;">
                                <%= isEdit ? "Cập nhật thông báo" : "Đăng thông báo" %>
                            </button>
                            <a href="<%= request.getContextPath() %>/admin/notifications?action=list" class="btn btn-outline">Hủy bỏ</a>
                        </div>
                    </form>
                </section>
            </div>
        </section>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/app.js"></script>
</body>
</html>
