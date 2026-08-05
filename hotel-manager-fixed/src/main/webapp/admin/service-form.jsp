<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Service"%>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    Service service = (Service) request.getAttribute("service");
    boolean isEdit = service != null;
    String activeMenu = "services";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title><%= isEdit ? "Cập nhật dịch vụ" : "Thêm dịch vụ" %> - Nestora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        /* Custom styling to make the service form premium and beautiful */
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
                        <div class="breadcrumb">Vận hành / Dịch vụ / <%= isEdit ? "Chỉnh sửa" : "Thêm mới" %></div>
                        <h1 class="page-title"><%= isEdit ? "Cập nhật dịch vụ" : "Thêm dịch vụ mới" %></h1>
                        <p class="page-desc">Nhập các thông tin chi tiết về dịch vụ và mức giá áp dụng cho khách hàng.</p>
                    </div>
                </div>

                <div class="surface surface-pad form-surface" style="border: 0; box-shadow: none; background: transparent; padding: 0;">
                    <form action="<%= request.getContextPath() %>/services" method="post">
                        <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
                        <% if (isEdit) { %>
                            <input type="hidden" name="id" value="<%= service.getId() %>">
                        <% } %>

                        <div class="form-section-card">
                            <h3 class="form-section-title">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                                Thông tin Dịch vụ Khách sạn
                            </h3>
                            
                            <div class="form-grid">
                                <!-- Tên dịch vụ -->
                                <div class="form-group">
                                    <label class="form-label" for="name">Tên dịch vụ <span class="required-star">*</span></label>
                                    <div class="input-with-icon">
                                        <input class="form-control" id="name" name="name" required placeholder="Ví dụ: Giặt ủi (Laundry), Buffet sáng..." value="<%= isEdit ? service.getName() : "" %>">
                                        <svg class="input-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7" y2="7"/></svg>
                                    </div>
                                </div>

                                <!-- Giá dịch vụ -->
                                <div class="form-group">
                                    <label class="form-label" for="price">Giá dịch vụ (VNĐ) <span class="required-star">*</span></label>
                                    <div class="input-with-icon">
                                        <input class="form-control" type="number" min="0" step="5000" id="price" name="price" required placeholder="Nhập giá dịch vụ" value="<%= isEdit ? (int)service.getPrice() : "" %>">
                                        <svg class="input-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                                    </div>
                                </div>

                                <!-- Đơn vị tính -->
                                <div class="form-group">
                                    <label class="form-label" for="unit">Đơn vị tính <span class="required-star">*</span></label>
                                    <div class="input-with-icon">
                                        <input class="form-control" id="unit" name="unit" required placeholder="Ví dụ: Lượt, Lon, Chai, Dĩa..." value="<%= isEdit && service.getUnit() != null ? service.getUnit() : "Lượt" %>">
                                        <svg class="input-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                                    </div>
                                </div>

                                <!-- Trạng thái -->
                                <div class="form-group">
                                    <label class="form-label" for="status">Trạng thái <span class="required-star">*</span></label>
                                    <div class="input-with-icon">
                                        <select class="form-control" id="status" name="status" required>
                                            <option value="Active" <%= isEdit && "Active".equals(service.getStatus()) ? "selected" : "" %>>Đang hoạt động (Active)</option>
                                            <option value="Inactive" <%= isEdit && "Inactive".equals(service.getStatus()) ? "selected" : "" %>>Tạm ngưng (Inactive)</option>
                                        </select>
                                        <svg class="input-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                    </div>
                                </div>

                                <!-- Mô tả -->
                                <div class="form-group full" style="margin-top: 15px;">
                                    <label class="form-label" for="description">Mô tả dịch vụ</label>
                                    <textarea class="form-control" id="description" name="description" rows="3" placeholder="Mô tả chi tiết nội dung dịch vụ (ví dụ: Giặt sấy lấy nhanh, các món ăn phục vụ sáng...)" style="padding-left: 14px;"><%= isEdit && service.getDescription() != null ? service.getDescription() : "" %></textarea>
                                </div>
                            </div>
                        </div>

                        <div class="form-actions" style="margin-top: 10px;">
                            <a class="btn btn-outline" style="min-height: 44px; padding: 0 24px;" href="<%= request.getContextPath() %>/services?action=list">Quay lại</a>
                            <button class="btn btn-primary" style="min-height: 44px; padding: 0 30px;" type="submit"><%= isEdit ? "Cập nhật dịch vụ" : "Thêm dịch vụ" %></button>
                        </div>
                    </form>
                </div>
            </div>
        </section>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/app.js"></script>
</body>
</html>
