<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.RoomType" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<% 
  HttpSession sess = request.getSession(false); 
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null; 
  String activeMenu = "roomTypes"; 
  List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
  NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi","VN"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Loại phòng - Nestora</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
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
            <div class="breadcrumb">Vận hành / Loại phòng</div>
            <h1 class="page-title">Danh mục loại phòng</h1>
            <p class="page-desc">Quản lý các loại phòng, đơn giá theo ngày và sức chứa.</p>
          </div>
          <div class="page-actions">
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/roomtypes?action=add">＋ Thêm loại phòng</a>
          </div>
        </div>

        <section class="surface">
          <div class="table-tools">
            <div class="search-box">
              <input type="search" placeholder="Tìm theo tên loại phòng...">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/></svg>
            </div>
            <div class="admin-filter-group">
              <select class="admin-filter-select" data-admin-filter aria-label="Lọc theo sức chứa">
                <option value="">Tất cả sức chứa</option>
                <option value="1 khách">1 khách</option>
                <option value="2 khách">2 khách</option>
                <option value="3 khách">3 khách</option>
                <option value="4 khách">4 khách</option>
              </select>
            </div>
            <div class="table-meta"><%= roomTypes != null ? roomTypes.size() : 0 %> loại phòng</div>
          </div>

          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>TÊN LOẠI PHÒNG</th>
                  <th>ĐƠN GIÁ / NGÀY</th>
                  <th>SỨC CHỨA</th>
                  <th>MÔ TẢ</th>
                  <th>THAO TÁC</th>
                </tr>
              </thead>
              <tbody>
                <% if (roomTypes != null && !roomTypes.isEmpty()) { 
                     for (RoomType rt : roomTypes) { 
                %>
                  <tr>
                    <td class="table-primary">#RT<%= rt.getId() %></td>
                    <td class="table-strong"><%= rt.getName() %></td>
                    <td><strong class="text-success"><%= money.format(rt.getPricePerDay()) %></strong></td>
                    <td><%= rt.getCapacity() %> khách</td>
                    <td><%= rt.getDescription() != null ? rt.getDescription() : "-" %></td>
                    <td>
                      <div class="row-actions">
                        <a class="btn btn-outline btn-icon" title="Sửa" href="<%= request.getContextPath() %>/roomtypes?action=edit&id=<%= rt.getId() %>">✎</a>
                        <% if (currentUser != null && "Admin".equals(currentUser.getRole())) { %>
                          <a class="btn btn-danger btn-icon" title="Xóa" onclick="return confirm('Bạn có chắc muốn xóa loại phòng này?')" href="<%= request.getContextPath() %>/roomtypes?action=delete&id=<%= rt.getId() %>">×</a>
                        <% } %>
                      </div>
                    </td>
                  </tr>
                <%   } 
                   } else { 
                %>
                  <tr>
                    <td colspan="6" style="text-align:center; padding:20px;">Chưa có dữ liệu loại phòng nào.</td>
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
