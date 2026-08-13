<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.HotelNotification" %>
<%@ page import="com.hotel.dao.NotificationDAO" %>
<%@ page import="com.hotel.util.AuthUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%!
    private String escapeHtml(String val) {
        if (val == null) return "";
        return val.replace("&", "&amp;").replace("<", "&lt;")
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
    if (!"Admin".equalsIgnoreCase(role) && !"Receptionist".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }

    String activeMenu = "notifications";
    List<HotelNotification> notifications = (List<HotelNotification>) request.getAttribute("notifications");
    if (notifications == null) {
        notifications = new NotificationDAO().getAllNotifications();
    }

    String keyword = (String) request.getAttribute("keyword");
    if (keyword == null) keyword = "";
    String typeFilter = (String) request.getAttribute("type");
    if (typeFilter == null) typeFilter = "ALL";
    String statusFilter = (String) request.getAttribute("status");
    if (statusFilter == null) statusFilter = "ALL";

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    // Compute stats
    int totalCount = notifications != null ? notifications.size() : 0;
    int activeCount = 0;
    int warningCount = 0;
    int hiddenCount = 0;
    if (notifications != null) {
        for (HotelNotification n : notifications) {
            boolean act = n.getIsActive() != null && n.getIsActive();
            if (act) activeCount++; else hiddenCount++;
            if ("WARNING".equalsIgnoreCase(n.getType()) || "ERROR".equalsIgnoreCase(n.getType())) {
                warningCount++;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Thông báo Khách sạn - Nestora</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 20px;
        }
        .stat-card {
            background: #ffffff;
            border-radius: 12px;
            border: 1px solid var(--line);
            padding: 18px 20px;
            display: flex;
            align-items: center;
            gap: 16px;
            box-shadow: 0 2px 8px rgba(28, 52, 84, 0.04);
        }
        .stat-icon {
            width: 46px;
            height: 46px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
        }
        .stat-icon.blue { background: #eaf2ff; color: #1769e0; }
        .stat-icon.green { background: #e8f8f1; color: #16a36a; }
        .stat-icon.orange { background: #fff5dc; color: #f59e0b; }
        .stat-icon.gray { background: #f1f5f9; color: #64748b; }
        .stat-info h3 {
            margin: 0;
            font-size: 22px;
            font-weight: 700;
            color: var(--navy);
        }
        .stat-info p {
            margin: 2px 0 0 0;
            font-size: 13px;
            color: var(--muted);
        }

        .filter-panel {
            background: #ffffff;
            border-radius: 12px;
            border: 1px solid var(--line);
            padding: 16px 20px;
            margin-bottom: 20px;
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            align-items: center;
            justify-content: space-between;
        }
        .filter-fields {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            align-items: center;
            flex: 1;
        }

        .badge-type {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 10px;
            font-size: 11.5px;
            font-weight: 700;
            border-radius: 20px;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        .badge-info { background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; }
        .badge-warning { background: #fef3c7; color: #b45309; border: 1px solid #fde68a; }
        .badge-success { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
        .badge-error { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }

        .toggle-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.15s ease;
            cursor: pointer;
            border: none;
        }
        .toggle-active {
            background: #dcfce7;
            color: #15803d;
        }
        .toggle-active:hover {
            background: #bbf7d0;
        }
        .toggle-hidden {
            background: #f1f5f9;
            color: #64748b;
        }
        .toggle-hidden:hover {
            background: #e2e8f0;
        }

        /* Modal preview */
        .notif-modal-backdrop {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(15, 23, 42, 0.5);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            padding: 16px;
        }
        .notif-modal-box {
            background: #ffffff;
            border-radius: 14px;
            max-width: 580px;
            width: 100%;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            animation: modalFadeIn 0.2s ease;
        }
        @keyframes modalFadeIn {
            from { opacity: 0; transform: scale(0.96); }
            to { opacity: 1; transform: scale(1); }
        }
        .notif-modal-head {
            padding: 18px 24px;
            border-bottom: 1px solid var(--line);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .notif-modal-body {
            padding: 24px;
            max-height: 60vh;
            overflow-y: auto;
            line-height: 1.65;
            color: var(--text);
            font-size: 14.5px;
            white-space: pre-wrap;
        }
        .notif-modal-foot {
            padding: 14px 24px;
            border-top: 1px solid var(--line);
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            background: #f8fafc;
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
                        <div class="breadcrumb">Vận hành / Thông báo hệ thống</div>
                        <h1 class="page-title">Quản lý Thông báo Khách sạn</h1>
                        <p class="page-desc">Tạo, cập nhật và quản lý toàn bộ các thông báo, bảng tin nội bộ gửi tới nhân viên và khách sạn.</p>
                    </div>
                    <div class="page-actions">
                        <a class="btn btn-primary" href="<%= request.getContextPath() %>/admin/notifications?action=add">
                            ＋ Soạn thông báo mới
                        </a>
                    </div>
                </div>

                <!-- Toast Alerts -->
                <% if (request.getParameter("saved") != null) { %>
                    <div class="alert alert-success" style="margin-bottom: 18px; padding: 12px 16px; border-radius: 8px; background: #dcfce7; color: #15803d; border: 1px solid #86efac; font-size: 14px; display: flex; align-items: center; gap: 8px;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                        <strong>Thành công:</strong> Đã lưu nội dung thông báo thành công vào hệ thống!
                    </div>
                <% } %>
                <% if (request.getParameter("deleted") != null) { %>
                    <div class="alert alert-success" style="margin-bottom: 18px; padding: 12px 16px; border-radius: 8px; background: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; font-size: 14px; display: flex; align-items: center; gap: 8px;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                        <strong>Thành công:</strong> Đã xóa thông báo khỏi hệ thống.
                    </div>
                <% } %>
                <% if (request.getParameter("toggled") != null) { %>
                    <div class="alert alert-success" style="margin-bottom: 18px; padding: 12px 16px; border-radius: 8px; background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; font-size: 14px; display: flex; align-items: center; gap: 8px;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18.36 6.64a9 9 0 1 1-12.73 0"/><line x1="12" y1="2" x2="12" y2="12"/></svg>
                        <strong>Thành công:</strong> Đã cập nhật trạng thái hiển thị của thông báo.
                    </div>
                <% } %>

                <!-- Stats Overview -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon blue">📢</div>
                        <div class="stat-info">
                            <h3><%= totalCount %></h3>
                            <p>Tổng số thông báo</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon green">🟢</div>
                        <div class="stat-info">
                            <h3><%= activeCount %></h3>
                            <p>Đang phát hành</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon orange">⚠️</div>
                        <div class="stat-info">
                            <h3><%= warningCount %></h3>
                            <p>Cảnh báo & Khẩn</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon gray">⚪</div>
                        <div class="stat-info">
                            <h3><%= hiddenCount %></h3>
                            <p>Đã tạm ẩn</p>
                        </div>
                    </div>
                </div>

                <!-- Search & Filters -->
                <div class="filter-panel">
                    <form action="<%= request.getContextPath() %>/admin/notifications" method="get" class="filter-fields">
                        <input type="hidden" name="action" value="list">
                        
                        <div style="min-width: 220px; flex: 2;">
                            <input type="text" class="form-control" name="keyword" placeholder="🔍 Tìm theo tiêu đề, nội dung..." value="<%= escapeHtml(keyword) %>">
                        </div>

                        <div style="min-width: 150px; flex: 1;">
                            <select class="form-control" name="type">
                                <option value="ALL" <%= "ALL".equalsIgnoreCase(typeFilter) ? "selected" : "" %>>-- Tất cả loại --</option>
                                <option value="INFO" <%= "INFO".equalsIgnoreCase(typeFilter) ? "selected" : "" %>>ℹ️ INFO (Tin tức)</option>
                                <option value="WARNING" <%= "WARNING".equalsIgnoreCase(typeFilter) ? "selected" : "" %>>⚠️ WARNING (Cảnh báo)</option>
                                <option value="SUCCESS" <%= "SUCCESS".equalsIgnoreCase(typeFilter) ? "selected" : "" %>>✅ SUCCESS (Tin mừng)</option>
                                <option value="ERROR" <%= "ERROR".equalsIgnoreCase(typeFilter) ? "selected" : "" %>>🚨 ERROR (Khẩn cấp)</option>
                            </select>
                        </div>

                        <div style="min-width: 140px; flex: 1;">
                            <select class="form-control" name="status">
                                <option value="ALL" <%= "ALL".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>-- Tất cả trạng thái --</option>
                                <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>🟢 Đang hiển thị</option>
                                <option value="HIDDEN" <%= "HIDDEN".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>⚪ Đang ẩn</option>
                            </select>
                        </div>

                        <div style="display: flex; gap: 8px;">
                            <button type="submit" class="btn btn-primary" style="padding: 9px 16px;">Lọc</button>
                            <a href="<%= request.getContextPath() %>/admin/notifications?action=list" class="btn btn-outline" style="padding: 9px 14px;">Đặt lại</a>
                        </div>
                    </form>
                </div>

                <!-- Notifications Table -->
                <section class="surface">
                    <div class="surface-head" style="padding: 16px 20px; border-bottom: 1px solid var(--line); display: flex; justify-content: space-between; align-items: center;">
                        <div>
                            <h2 class="surface-title" style="font-size: 15px; margin: 0; font-weight: 700;">Danh sách bản tin & thông báo</h2>
                            <p class="surface-subtitle" style="margin: 2px 0 0 0; font-size: 13px;">Hiển thị <%= totalCount %> thông báo phù hợp</p>
                        </div>
                    </div>

                    <% if (notifications != null && !notifications.isEmpty()) { %>
                        <div class="table-wrap">
                            <table>
                                <thead>
                                <tr>
                                    <th style="width: 75px;">MÃ TB</th>
                                    <th style="min-width: 240px;">TIÊU ĐỀ & NỘI DUNG</th>
                                    <th style="width: 130px;">PHÂN LOẠI</th>
                                    <th style="width: 145px;">THỜI GIAN ĐĂNG</th>
                                    <th style="width: 140px;">NGƯỜI TẠO</th>
                                    <th style="width: 125px; text-align: center;">TRẠNG THÁI</th>
                                    <th style="width: 160px; text-align: center;">THAO TÁC</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% for (HotelNotification n : notifications) {
                                    String badgeClass = "badge-info";
                                    String icon = "ℹ️";
                                    if ("WARNING".equalsIgnoreCase(n.getType())) {
                                        badgeClass = "badge-warning";
                                        icon = "⚠️";
                                    } else if ("SUCCESS".equalsIgnoreCase(n.getType())) {
                                        badgeClass = "badge-success";
                                        icon = "✅";
                                    } else if ("ERROR".equalsIgnoreCase(n.getType())) {
                                        badgeClass = "badge-error";
                                        icon = "🚨";
                                    }
                                    boolean isActive = n.getIsActive() != null && n.getIsActive();
                                %>
                                    <tr>
                                        <td class="table-primary" style="font-weight: 700;">#TB<%= String.format("%03d", n.getNotificationId()) %></td>
                                        <td>
                                            <div style="font-weight: 600; color: var(--navy); margin-bottom: 3px; font-size: 14px;">
                                                <%= escapeHtml(n.getTitle()) %>
                                            </div>
                                            <div style="font-size: 12.5px; color: var(--muted); max-width: 380px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                                <%= escapeHtml(n.getContent()) %>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge-type <%= badgeClass %>">
                                                <%= icon %> <%= escapeHtml(n.getType()) %>
                                            </span>
                                        </td>
                                        <td style="font-size: 13px; color: var(--text);">
                                            <%= n.getCreatedAt() != null ? dtf.format(n.getCreatedAt()) : "—" %>
                                        </td>
                                        <td style="font-size: 13px;">
                                            <span style="display: flex; align-items: center; gap: 6px;">
                                                <span style="display: inline-block; width: 22px; height: 22px; border-radius: 50%; background: #e2e8f0; text-align: center; line-height: 22px; font-size: 11px;">👤</span>
                                                <%= (n.getCreator() != null && n.getCreator().getFullName() != null) ? escapeHtml(n.getCreator().getFullName()) : "Quản trị viên" %>
                                            </span>
                                        </td>
                                        <td style="text-align: center;">
                                            <a class="toggle-btn <%= isActive ? "toggle-active" : "toggle-hidden" %>" 
                                               href="<%= request.getContextPath() %>/admin/notifications?action=toggle&id=<%= n.getNotificationId() %>" 
                                               title="Bấm để <%= isActive ? "Ẩn thông báo" : "Hiển thị thông báo" %>">
                                                <%= isActive ? "🟢 Đang hiện" : "⚪ Đã ẩn" %>
                                            </a>
                                        </td>
                                        <td style="text-align: center;">
                                            <div style="display: inline-flex; gap: 6px;">
                                                <button type="button" class="btn btn-outline" style="padding: 4px 8px; font-size: 12px;" 
                                                        onclick="openViewModal('<%= escapeHtml(n.getTitle()) %>', '<%= escapeHtml(n.getType()) %>', '<%= escapeHtml(n.getContent()) %>', '<%= n.getCreatedAt() != null ? dtf.format(n.getCreatedAt()) : "" %>')">
                                                    🔍 Xem
                                                </button>
                                                <a class="btn btn-primary" style="padding: 4px 8px; font-size: 12px;" href="<%= request.getContextPath() %>/admin/notifications?action=edit&id=<%= n.getNotificationId() %>">
                                                    Sửa
                                                </a>
                                                <a class="btn btn-danger" style="padding: 4px 8px; font-size: 12px;" href="<%= request.getContextPath() %>/admin/notifications?action=delete&id=<%= n.getNotificationId() %>" onclick="return confirm('Bạn có chắc chắn muốn xóa thông báo #TB<%= n.getNotificationId() %>: <%= escapeHtml(n.getTitle()) %>?');">
                                                    Xóa
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } else { %>
                        <div class="empty" style="padding: 48px 20px; text-align: center;">
                            <div style="font-size: 36px; margin-bottom: 8px;">📭</div>
                            <strong style="color: var(--navy); font-size: 15px;">Không tìm thấy thông báo nào</strong>
                            <p style="color: var(--muted); margin: 4px 0 16px 0; font-size: 13px;">Chưa có thông báo nào hoặc không có kết quả phù hợp với bộ lọc.</p>
                            <a class="btn btn-primary" href="<%= request.getContextPath() %>/admin/notifications?action=add">＋ Soạn thông báo mới</a>
                        </div>
                    <% } %>
                </section>

            </div>
        </section>
    </main>
</div>

<!-- Modal Xem Chi Tiết Thông Báo -->
<div class="notif-modal-backdrop" id="notifViewModal">
    <div class="notif-modal-box">
        <div class="notif-modal-head">
            <div>
                <span class="badge-type badge-info" id="modalTypeBadge">INFO</span>
                <h3 style="margin: 6px 0 0 0; font-size: 16px; color: var(--navy);" id="modalTitle">Tiêu đề</h3>
            </div>
            <button type="button" style="background:none; border:none; font-size:22px; cursor:pointer; color:var(--muted);" onclick="closeViewModal()">×</button>
        </div>
        <div class="notif-modal-body" id="modalContent">
            Nội dung thông báo...
        </div>
        <div class="notif-modal-foot">
            <span style="font-size: 12px; color: var(--muted); align-self: center;" id="modalTime"></span>
            <button type="button" class="btn btn-outline" onclick="closeViewModal()">Đóng</button>
        </div>
    </div>
</div>

<script src="<%= request.getContextPath() %>/js/app.js"></script>
<script>
    function openViewModal(title, type, content, time) {
        document.getElementById('modalTitle').textContent = title;
        document.getElementById('modalContent').textContent = content;
        document.getElementById('modalTime').textContent = time ? 'Đăng lúc: ' + time : '';
        
        const badge = document.getElementById('modalTypeBadge');
        badge.textContent = type;
        badge.className = 'badge-type ' + (
            type === 'WARNING' ? 'badge-warning' :
            type === 'SUCCESS' ? 'badge-success' :
            type === 'ERROR' ? 'badge-error' : 'badge-info'
        );

        document.getElementById('notifViewModal').style.display = 'flex';
    }

    function closeViewModal() {
        document.getElementById('notifViewModal').style.display = 'none';
    }

    document.getElementById('notifViewModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeViewModal();
        }
    });
</script>
</body>
</html>
