<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.HotelNotification" %>
<%@ page import="com.hotel.dao.NotificationDAO" %>
<%@ page import="com.hotel.util.AuthUtil" %>
<%@ page import="com.hotel.util.ParamUtil" %>
<%!
    private String escapeHtml(String val) {
        if (val == null) return "";
        String fixed = com.hotel.util.EncodingUtil.fixEncoding(val);
        return fixed.replace("&", "&amp;").replace("<", "&lt;")
                  .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    if (!AuthUtil.isAuthenticated(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    User currentUser = AuthUtil.getUser(request);
    String role = currentUser != null ? currentUser.getRole() : "";
    if (!"Admin".equalsIgnoreCase(role) && !"Manager".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }

    String activeMenu = "notifications";
    Boolean isEditObj = (Boolean) request.getAttribute("isEdit");
    boolean isEdit = isEditObj != null && isEditObj;
    HotelNotification notification = (HotelNotification) request.getAttribute("notification");

    // Fallback if accessed directly with id parameter
    if (notification == null) {
        int reqId = ParamUtil.getInt(request, "id", 0);
        if (reqId > 0) {
            notification = new NotificationDAO().getById(reqId);
            isEdit = (notification != null);
        }
    }
    if (notification == null) {
        notification = new HotelNotification();
    }

    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Chỉnh sửa thông báo #" + notification.getNotificationId() : "Soạn thông báo mới" %> - Nestora</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .form-surface-card {
            background: #ffffff;
            border-radius: 14px;
            border: 1px solid var(--line);
            padding: 28px;
            box-shadow: 0 4px 16px rgba(28, 52, 84, 0.04);
            max-width: 800px;
        }
        .type-options {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
            gap: 12px;
            margin-top: 8px;
        }
        .type-option-card {
            border: 1.5px solid var(--line);
            border-radius: 10px;
            padding: 12px 14px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: all 0.2s ease;
            background: #f8fafc;
        }
        .type-option-card:hover {
            border-color: var(--brand);
            background: #ffffff;
        }
        .type-option-card input[type="radio"] {
            margin: 0;
            accent-color: var(--brand);
        }
        .type-option-card.selected {
            border-color: var(--brand);
            background: #f0f7ff;
            box-shadow: 0 0 0 1px var(--brand);
        }
        .type-option-icon {
            font-size: 20px;
        }
        .type-option-label {
            font-size: 13.5px;
            font-weight: 600;
            color: var(--navy);
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

                <!-- Header -->
                <div class="page-head">
                    <div>
                        <div class="breadcrumb">Vận hành / Thông báo / <%= isEdit ? "Chỉnh sửa #" + notification.getNotificationId() : "Soạn mới" %></div>
                        <h1 class="page-title"><%= isEdit ? "Chỉnh sửa thông báo #" + notification.getNotificationId() : "Soạn thảo thông báo mới" %></h1>
                        <p class="page-desc">Phát hành bản tin hoặc cảnh báo nội bộ đến nhân viên lễ tân, quản lý và vận hành khách sạn.</p>
                    </div>
                    <div class="page-actions">
                        <a class="btn btn-outline" href="<%= request.getContextPath() %>/admin/notifications?action=list">
                            ← Quay lại danh sách
                        </a>
                    </div>
                </div>

                <!-- Error Alert -->
                <% if (error != null) { %>
                    <div class="alert alert-danger" style="margin-bottom: 20px; padding: 14px 18px; border-radius: 8px; background: #fee2e2; color: #991b1b; border: 1px solid #f87171; font-size: 14px; display: flex; align-items: center; gap: 8px; max-width: 800px;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        <span><strong>Lỗi:</strong> <%= escapeHtml(error) %></span>
                    </div>
                <% } %>

                <!-- Form Card -->
                <div class="form-surface-card">
                    <form method="post" action="<%= request.getContextPath() %>/admin/notifications" id="notifForm">
                        <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
                        <% if (isEdit) { %>
                            <input type="hidden" name="id" value="<%= notification.getNotificationId() %>">
                        <% } %>

                        <!-- Tiêu đề -->
                        <div class="form-group" style="margin-bottom: 20px;">
                            <label class="form-label" for="title" style="font-weight: 700; font-size: 14px; margin-bottom: 8px; display: block;">
                                Tiêu đề thông báo <span style="color: red;">*</span>
                            </label>
                            <input type="text" class="form-control" id="title" name="title" required 
                                   placeholder="Ví dụ: Lịch bảo trì hệ thống điều hòa khu VIP, Quy định trực ca mới..." 
                                   value="<%= escapeHtml(notification.getTitle()) %>" 
                                   maxlength="200" style="font-size: 14.5px; padding: 11px 14px;">
                            <small class="form-hint" style="margin-top: 4px; display: block;">Tối đa 200 ký tự. Ngắn gọn, súc tích.</small>
                        </div>

                        <!-- Loại thông báo -->
                        <div class="form-group" style="margin-bottom: 22px;">
                            <label class="form-label" style="font-weight: 700; font-size: 14px; margin-bottom: 6px; display: block;">
                                Phân loại thông báo <span style="color: red;">*</span>
                            </label>
                            <% String curType = notification.getType() != null ? notification.getType() : "INFO"; %>
                            <div class="type-options">
                                <label class="type-option-card <%= "INFO".equalsIgnoreCase(curType) ? "selected" : "" %>">
                                    <input type="radio" name="type" value="INFO" <%= "INFO".equalsIgnoreCase(curType) ? "checked" : "" %> onchange="updateSelectedType(this)">
                                    <span class="type-option-icon">ℹ️</span>
                                    <div>
                                        <div class="type-option-label">INFO</div>
                                        <small style="color: var(--muted); font-size: 11px;">Thông tin / Tin tức</small>
                                    </div>
                                </label>

                                <label class="type-option-card <%= "WARNING".equalsIgnoreCase(curType) ? "selected" : "" %>">
                                    <input type="radio" name="type" value="WARNING" <%= "WARNING".equalsIgnoreCase(curType) ? "checked" : "" %> onchange="updateSelectedType(this)">
                                    <span class="type-option-icon">⚠️</span>
                                    <div>
                                        <div class="type-option-label">WARNING</div>
                                        <small style="color: var(--muted); font-size: 11px;">Cảnh báo / Lưu ý</small>
                                    </div>
                                </label>

                                <label class="type-option-card <%= "SUCCESS".equalsIgnoreCase(curType) ? "selected" : "" %>">
                                    <input type="radio" name="type" value="SUCCESS" <%= "SUCCESS".equalsIgnoreCase(curType) ? "checked" : "" %> onchange="updateSelectedType(this)">
                                    <span class="type-option-icon">✅</span>
                                    <div>
                                        <div class="type-option-label">SUCCESS</div>
                                        <small style="color: var(--muted); font-size: 11px;">Tin mừng / Khen thưởng</small>
                                    </div>
                                </label>

                                <label class="type-option-card <%= "ERROR".equalsIgnoreCase(curType) ? "selected" : "" %>">
                                    <input type="radio" name="type" value="ERROR" <%= "ERROR".equalsIgnoreCase(curType) ? "checked" : "" %> onchange="updateSelectedType(this)">
                                    <span class="type-option-icon">🚨</span>
                                    <div>
                                        <div class="type-option-label">ERROR</div>
                                        <small style="color: var(--muted); font-size: 11px;">Sự cố / Khẩn cấp</small>
                                    </div>
                                </label>
                            </div>
                        </div>

                        <!-- Nội dung chi tiết -->
                        <div class="form-group" style="margin-bottom: 22px;">
                            <label class="form-label" for="content" style="font-weight: 700; font-size: 14px; margin-bottom: 8px; display: block;">
                                Chi tiết nội dung thông báo <span style="color: red;">*</span>
                            </label>
                            <textarea class="form-control" id="content" name="content" rows="6" required 
                                      placeholder="Soạn thảo đầy đủ nội dung thông báo, thời gian áp dụng, hướng dẫn thực hiện..." 
                                      style="font-size: 14px; padding: 12px 14px; line-height: 1.6;"><%= escapeHtml(notification.getContent()) %></textarea>
                        </div>

                        <!-- Kích hoạt hiển thị -->
                        <div class="form-group" style="margin-bottom: 26px; padding: 14px 16px; background: #f8fafc; border: 1px solid var(--line); border-radius: 8px;">
                            <label style="display: flex; align-items: center; gap: 10px; cursor: pointer; margin: 0;">
                                <input type="checkbox" name="isActive" value="true" <%= (notification.getIsActive() != null && notification.getIsActive()) ? "checked" : "" %> style="width: 18px; height: 18px; accent-color: var(--brand); cursor: pointer;">
                                <div>
                                    <strong style="color: var(--navy); font-size: 14px; display: block;">Kích hoạt phát hành thông báo</strong>
                                    <span style="color: var(--muted); font-size: 12.5px;">Bật lựa chọn này để hiển thị thông báo ngay lập tức trên thanh thông báo chuông và danh sách.</span>
                                </div>
                            </label>
                        </div>

                        <!-- Action Buttons -->
                        <div style="display: flex; justify-content: flex-end; gap: 12px; border-top: 1px solid var(--line); padding-top: 20px;">
                            <a href="<%= request.getContextPath() %>/admin/notifications?action=list" class="btn btn-outline" style="min-width: 100px;">
                                Hủy bỏ
                            </a>
                            <button type="submit" class="btn btn-primary" style="min-width: 160px;">
                                <%= isEdit ? "💾 Cập nhật thông báo" : "📢 Đăng thông báo ngay" %>
                            </button>
                        </div>
                    </form>
                </div>

            </div>
        </section>
    </main>
</div>

<script src="<%= request.getContextPath() %>/js/app.js"></script>
<script>
    function updateSelectedType(radio) {
        document.querySelectorAll('.type-option-card').forEach(card => card.classList.remove('selected'));
        if (radio.checked) {
            radio.closest('.type-option-card').classList.add('selected');
        }
    }
</script>
</body>
</html>
