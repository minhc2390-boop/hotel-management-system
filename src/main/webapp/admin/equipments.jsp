<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Equipment" %>
<%@ page import="com.hotel.dao.EquipmentDAO" %>
<%@ page import="java.util.List" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User)sess.getAttribute("currentUser") : null;
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    String activeMenu = "equipments";
    List<Equipment> equipments = (List<Equipment>) request.getAttribute("equipments");
    if (equipments == null) {
        EquipmentDAO equipmentDAO = new EquipmentDAO();
        equipments = equipmentDAO.getAllEquipments();
    }
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>Quản lý thiết bị - Nestora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css" />
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
              <div class="page-actions"><a class="btn btn-primary" href="<%= request.getContextPath() %>/equipments?action=add">＋ Thêm mới</a></div>
            </div>
            <section class="surface">
              <div class="table-tools">
                <div class="search-box">
                  <input type="search" placeholder="Tìm theo tên hoặc mã thiết bị..." />
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="11" cy="11" r="7" />
                    <path d="M20 20l-3.5-3.5" />
                  </svg>
                </div>
                <div class="table-meta"><%= equipments != null ? equipments.size() : 0 %> thiết bị</div>
              </div>
              <div class="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>MÃ THIẾT BỊ</th>
                      <th>TÊN THIẾT BỊ</th>
                      <th>SỐ LƯỢNG</th>
                      <th>ĐƠN VỊ</th>
                      <th>TRẠNG THÁI</th>
                      <th>THAO TÁC</th>
                    </tr>
                  </thead>
                  <tbody>
                    <% if (equipments != null && !equipments.isEmpty()) {
                         for (Equipment eq : equipments) {
                    %>
                      <tr>
                        <td class="table-primary">#TB<%= String.format("%03d", eq.getEquipmentId()) %></td>
                        <td class="table-strong"><%= eq.getEquipmentName() %></td>
                        <td><%= eq.getTotalQuantity() %></td>
                        <td><%= eq.getUnit() != null ? eq.getUnit() : "Cái" %></td>
                        <td>
                          <% if ("Hoạt động tốt".equalsIgnoreCase(eq.getStatus()) || "Good".equalsIgnoreCase(eq.getStatus())) { %>
                            <span class="status success">Hoạt động tốt</span>
                          <% } else if ("Cần kiểm tra".equalsIgnoreCase(eq.getStatus()) || "Maintenance".equalsIgnoreCase(eq.getStatus())) { %>
                            <span class="status warning">Cần kiểm tra</span>
                          <% } else { %>
                            <span class="status danger"><%= eq.getStatus() != null ? eq.getStatus() : "N/A" %></span>
                          <% } %>
                        </td>
                        <td>
                          <div class="row-actions">
                            <a class="btn btn-outline btn-icon" title="Sửa" href="<%= request.getContextPath() %>/equipments?action=edit&id=<%= eq.getEquipmentId() %>">✎</a>
                            <a class="btn btn-danger btn-icon" title="Xóa" onclick="return confirm('Bạn có chắc muốn xóa thiết bị này?')" href="<%= request.getContextPath() %>/equipments?action=delete&id=<%= eq.getEquipmentId() %>">×</a>
                          </div>
                        </td>
                      </tr>
                    <%   }
                       } else {
                    %>
                      <tr>
                        <td colspan="6" style="text-align:center; padding:20px;">Chưa có thiết bị nào.</td>
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
