<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Equipment" %>
<%@ page import="java.util.List" %>
<%
HttpSession sess = request.getSession(false);
User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
    response.sendRedirect(request.getContextPath() + "/home");
    return;
}
List<Equipment> equipments = (List<Equipment>) request.getAttribute("equipments");
String keyword = (String) request.getAttribute("keyword");
if (keyword == null) keyword = "";
boolean isAdmin = "Admin".equals(currentUser.getRole());
String activeMenu = "equipments";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Quản lý thiết bị - Nestora</title>
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
                        <div class="breadcrumb">Vận hành / Quản lý thiết bị</div>
                        <h1 class="page-title">Quản lý thiết bị</h1>
                        <p class="page-desc">Theo dõi thiết bị, số lượng và tình trạng sử dụng.</p>
                    </div>
                    <div class="page-actions">
                        <a class="btn btn-primary" href="<%=request.getContextPath()%>/equipments?action=add">＋ Thêm mới</a>
                    </div>
                </div>

                <section class="surface">
                    <form action="<%=request.getContextPath()%>/equipments" method="get" class="table-tools">
                        <input type="hidden" name="action" value="list">
                        <div class="search-box">
                            <input type="search" name="keyword" value="<%=keyword%>" placeholder="Tìm theo tên, đơn vị, trạng thái..." onchange="this.form.submit()">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="11" cy="11" r="7"/>
                                <path d="M20 20l-3.5-3.5"/>
                            </svg>
                        </div>
                        <div class="table-meta"><%=equipments != null ? equipments.size() : 0%> thiết bị</div>
                    </form>

                    <% if (equipments != null && !equipments.isEmpty()) { %>
                        <div class="table-wrap">
                            <table>
                                <thead>
                                <tr>
                                    <th>MÃ THIẾT BỊ</th>
                                    <th>TÊN THIẾT BỊ</th>
                                    <th>SỐ LƯỢNG</th>
                                    <th>ĐƠN VỊ</th>
                                    <th>TRẠNG THÁI</th>
                                    <th>MÔ TẢ</th>
                                    <th>THAO TÁC</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% for (Equipment e : equipments) {
                                    String st = e.getStatus();
                                    String badgeClass = "status";
                                    String stDisplay = st != null ? st : "Hoạt động tốt";
                                    if (st != null) {
                                        if (st.contains("Active") || st.toLowerCase().contains("tốt") || st.toLowerCase().contains("hoạt động")) {
                                            badgeClass = "status success";
                                            stDisplay = "Hoạt động tốt";
                                        } else if (st.contains("Maintenance") || st.toLowerCase().contains("kiểm tra") || st.toLowerCase().contains("bảo trì")) {
                                            badgeClass = "status warning";
                                            stDisplay = "Cần kiểm tra";
                                        } else if (st.contains("OutOfStock") || st.toLowerCase().contains("hỏng") || st.toLowerCase().contains("ngưng")) {
                                            badgeClass = "status danger";
                                            stDisplay = "Hỏng";
                                        }
                                    }
                                %>
                                <tr>
                                    <td class="table-primary">#TB<%= String.format("%03d", e.getEquipmentId()) %></td>
                                    <td class="table-strong"><%= e.getEquipmentName() %></td>
                                    <td><%= e.getTotalQuantity() %></td>
                                    <td><%= e.getUnit() != null ? e.getUnit() : "Cái" %></td>
                                    <td><span class="<%= badgeClass %>"><%= stDisplay %></span></td>
                                    <td><%= e.getDescription() != null && !e.getDescription().trim().isEmpty() ? e.getDescription() : "-" %></td>
                                    <td>
                                        <div class="row-actions">
                                            <a class="btn btn-outline btn-icon" href="<%=request.getContextPath()%>/equipments?action=edit&id=<%=e.getEquipmentId()%>" title="Chỉnh sửa">✎</a>
                                            <a class="btn btn-danger btn-icon" href="<%=request.getContextPath()%>/equipments?action=delete&id=<%=e.getEquipmentId()%>" onclick="return confirm('Bạn có chắc muốn xóa thiết bị này?')" title="Xóa">×</a>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                                </tbody>
                            </table>
                        </div>
                        <div class="pagination">
                            <span class="page-number active">1</span>
                        </div>
                    <% } else { %>
                        <div class="empty">
                            <strong>Chưa có thiết bị nào</strong>
                            <p>Hãy thêm thiết bị mới vào hệ thống.</p>
                        </div>
                    <% } %>
                </section>
            </div>
        </section>
    </main>
</div>
<script src="<%=request.getContextPath()%>/js/app.js"></script>
</body>
</html>