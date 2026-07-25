<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Equipment" %>
<%
HttpSession sess = request.getSession(false);
User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
    response.sendRedirect(request.getContextPath() + "/home");
    return;
}
Equipment equipment = (Equipment) request.getAttribute("equipment");
boolean isEdit = equipment != null;
String activeMenu = "equipments";

String currentUnit = isEdit && equipment.getUnit() != null ? equipment.getUnit() : "Cái";
String currentStatus = isEdit && equipment.getStatus() != null ? equipment.getStatus() : "Active";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title><%=isEdit ? "Chỉnh sửa thiết bị" : "Thêm mới thiết bị"%> - Nestora</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
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
                        <div class="breadcrumb">Vận hành / Quản lý thiết bị / <%=isEdit ? "Chỉnh sửa" : "Thêm mới"%></div>
                        <h1 class="page-title"><%=isEdit ? "Chỉnh sửa thiết bị" : "Thêm thiết bị mới"%></h1>
                        <p class="page-desc">Lưu thông tin thiết bị và tình trạng ban đầu.</p>
                    </div>
                </div>

                <section class="surface surface-pad form-surface">
                    <h2 class="form-title">Thông tin thiết bị</h2>
                    <form action="<%=request.getContextPath()%>/equipments" method="post">
                        <input type="hidden" name="action" value="<%=isEdit ? "update" : "insert"%>">
                        <% if (isEdit) { %>
                            <input type="hidden" name="id" value="<%=equipment.getEquipmentId()%>">
                        <% } %>
                        
                        <div class="form-grid">
                            <div class="form-group">
                                <label class="form-label" for="name">Tên thiết bị <span style="color:red">*</span></label>
                                <input class="form-control" id="name" name="name" required placeholder="Nhập tên thiết bị..." value="<%=isEdit ? equipment.getEquipmentName() : ""%>">
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="totalQuantity">Số lượng <span style="color:red">*</span></label>
                                <input class="form-control" type="number" id="totalQuantity" name="totalQuantity" min="0" value="<%=isEdit ? equipment.getTotalQuantity() : 1%>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="unit">Đơn vị tính</label>
                                <select class="form-control" id="unit" name="unit">
                                    <option value="Cái" <%="Cái".equalsIgnoreCase(currentUnit) ? "selected" : ""%>>Cái</option>
                                    <option value="Bộ" <%="Bộ".equalsIgnoreCase(currentUnit) ? "selected" : ""%>>Bộ</option>
                                    <option value="Chiếc" <%="Chiếc".equalsIgnoreCase(currentUnit) ? "selected" : ""%>>Chiếc</option>
                                    <option value="Hộp" <%="Hộp".equalsIgnoreCase(currentUnit) ? "selected" : ""%>>Hộp</option>
                                    <option value="Bình" <%="Bình".equalsIgnoreCase(currentUnit) ? "selected" : ""%>>Bình</option>
                                    <option value="Cặp" <%="Cặp".equalsIgnoreCase(currentUnit) ? "selected" : ""%>>Cặp</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="status">Trạng thái</label>
                                <select class="form-control" id="status" name="status">
                                    <option value="Active" <%="Active".equalsIgnoreCase(currentStatus) || "Hoạt động tốt".equalsIgnoreCase(currentStatus) ? "selected" : ""%>>Hoạt động tốt (Active)</option>
                                    <option value="Maintenance" <%="Maintenance".equalsIgnoreCase(currentStatus) || "Cần kiểm tra".equalsIgnoreCase(currentStatus) ? "selected" : ""%>>Cần kiểm tra (Maintenance)</option>
                                    <option value="OutOfStock" <%="OutOfStock".equalsIgnoreCase(currentStatus) || "Hỏng".equalsIgnoreCase(currentStatus) ? "selected" : ""%>>Hỏng / Hết (OutOfStock)</option>
                                </select>
                            </div>

                            <div class="form-group full">
                                <label class="form-label" for="description">Mô tả</label>
                                <textarea class="form-control" id="description" name="description" placeholder="Thông số, nhãn hiệu, ghi chú bảo trì..."><%=isEdit && equipment.getDescription() != null ? equipment.getDescription() : ""%></textarea>
                            </div>
                        </div>

                        <div class="form-actions">
                            <a class="btn btn-outline" href="<%=request.getContextPath()%>/equipments?action=list">Hủy</a>
                            <button class="btn btn-primary" type="submit"><%=isEdit ? "Lưu thay đổi" : "Lưu thiết bị"%></button>
                        </div>
                    </form>
                </section>
            </div>
        </section>
    </main>
</div>
<script src="<%=request.getContextPath()%>/js/app.js"></script>
</body>
</html>