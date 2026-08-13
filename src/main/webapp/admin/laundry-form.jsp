<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Laundry" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = (sess != null) ? (User) sess.getAttribute("currentUser") : null;
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    String activeMenu = "laundry";
    Boolean isEditObj = (Boolean) request.getAttribute("isEdit");
    boolean isEdit = isEditObj != null && isEditObj;
    Laundry laundry = (Laundry) request.getAttribute("laundry");
    if (laundry == null) laundry = new Laundry();
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Sửa đơn giặt ủi" : "Thêm đơn giặt ủi" %> - Nestora</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
        }
        .form-group {
            margin-bottom: 16px;
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
        .example-box {
            font-size: 12px;
            color: var(--muted);
            margin-top: 6px;
            background: rgba(0, 0, 0, 0.03);
            padding: 8px 12px;
            border-radius: 6px;
            border-left: 3px solid var(--brand);
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
                        <div class="breadcrumb">Dịch vụ / Giặt ủi / <%= isEdit ? "Chỉnh sửa" : "Thêm mới" %></div>
                        <h1 class="page-title"><%= isEdit ? "Chỉnh sửa đơn giặt ủi #" + laundry.getId() : "Thêm đơn giặt ủi mới" %></h1>
                        <p class="page-desc">Nhập thông tin đơn giặt ủi và ghi chú hướng dẫn xử lý quần áo cho khách.</p>
                    </div>
                    <div class="page-actions">
                        <a class="btn btn-outline" href="<%= request.getContextPath() %>/laundry?action=list">← Trở về danh sách</a>
                    </div>
                </div>

                <% if (error != null) { %>
                    <div style="padding: 12px 16px; margin-bottom: 20px; background: #f8d7da; color: #721c24; border-radius: 6px; border: 1px solid #f5c6cb;">
                        ⚠ <%= error %>
                    </div>
                <% } %>

                <section class="surface" style="max-width: 800px;">
                    <div class="surface-head">
                        <h2 class="surface-title">Thông tin chi tiết đơn giặt</h2>
                    </div>
                    <form method="post" action="<%= request.getContextPath() %>/laundry" accept-charset="UTF-8" style="padding: 10px 0;">
                        <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
                        <% if (isEdit) { %>
                            <input type="hidden" name="id" value="<%= laundry.getId() %>">
                        <% } %>

                        <div class="form-grid">
                            <div class="form-group">
                                <label for="customerName">Tên khách hàng <span style="color:red;">*</span></label>
                                <input type="text" id="customerName" name="customerName" required placeholder="Ví dụ: Nguyễn Văn A" value="<%= laundry.getCustomerName() != null ? laundry.getCustomerName() : "" %>">
                            </div>

                            <div class="form-group">
                                <label for="roomNumber">Số phòng <span style="color:red;">*</span></label>
                                <input type="text" id="roomNumber" name="roomNumber" required placeholder="Ví dụ: 101, 202..." value="<%= laundry.getRoomNumber() != null ? laundry.getRoomNumber() : "" %>">
                            </div>
                        </div>

                        <div class="form-grid">
                            <div class="form-group">
                                <label for="serviceType">Loại dịch vụ</label>
                                <select id="serviceType" name="serviceType">
                                    <option value="Giặt sấy thông thường" <%= "Giặt sấy thông thường".equals(laundry.getServiceType()) ? "selected" : "" %>>Giặt sấy thông thường</option>
                                    <option value="Giặt khô (Dry Cleaning)" <%= "Giặt khô (Dry Cleaning)".equals(laundry.getServiceType()) ? "selected" : "" %>>Giặt khô (Dry Cleaning)</option>
                                    <option value="Ủi quần áo" <%= "Ủi quần áo".equals(laundry.getServiceType()) ? "selected" : "" %>>Ủi quần áo</option>
                                    <option value="Giặt hấp cao cấp" <%= "Giặt hấp cao cấp".equals(laundry.getServiceType()) ? "selected" : "" %>>Giặt hấp cao cấp</option>
                                    <option value="Tẩy vết bẩn đặc biệt" <%= "Tẩy vết bẩn đặc biệt".equals(laundry.getServiceType()) ? "selected" : "" %>>Tẩy vết bẩn đặc biệt</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="processingStatus">Trạng thái xử lý <span style="color:red;">*</span></label>
                                <select id="processingStatus" name="processingStatus">
                                    <option value="Chưa hoàn thành" <%= "Chưa hoàn thành".equals(laundry.getProcessingStatus()) ? "selected" : "" %>>Chưa hoàn thành (cần xử lý)</option>
                                    <option value="Đã hoàn thành" <%= "Đã hoàn thành".equals(laundry.getProcessingStatus()) ? "selected" : "" %>>Đã hoàn thành (sẵn sàng giao)</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-grid">
                            <div class="form-group">
                                <label for="quantity">Số lượng (món / kg)</label>
                                <input type="number" id="quantity" name="quantity" min="1" value="<%= laundry.getQuantity() > 0 ? laundry.getQuantity() : 1 %>">
                            </div>

                            <div class="form-group">
                                <label for="totalPrice">Tổng tiền (VNĐ)</label>
                                <input type="number" id="totalPrice" name="totalPrice" step="1000" min="0" value="<%= (long) laundry.getTotalPrice() %>">
                            </div>
                        </div>

                        <!-- Trường Ghi chú (Lưu ý) theo Yêu cầu 1.2 -->
                        <div class="form-group">
                            <label for="notes">Lưu ý</label>
                            <textarea id="notes" name="notes" rows="4" placeholder="Nhập các yêu cầu hoặc ghi chú đặc biệt cho đơn giặt này..."><%= laundry.getNotes() != null ? laundry.getNotes() : "" %></textarea>
                            <div class="example-box">
                                <strong>Gợi ý ví dụ:</strong><br>
                                • Không dùng nước nóng<br>
                                • Giặt riêng<br>
                                • Không sấy<br>
                                • Quần áo dễ phai màu
                            </div>
                        </div>

                        <div style="margin-top: 24px; display: flex; gap: 12px;">
                            <button type="submit" class="btn btn-primary" style="min-width: 140px;">
                                <%= isEdit ? "Cập nhật đơn giặt" : "Tạo đơn giặt" %>
                            </button>
                            <a href="<%= request.getContextPath() %>/laundry?action=list" class="btn btn-outline">Hủy bỏ</a>
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
