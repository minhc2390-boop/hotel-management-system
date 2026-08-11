<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.BuffetMenuItem" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%!
  private String buffetAdminEscape(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("<", "&lt;")
        .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
  }
  private String buffetMealName(String value) {
    if ("Breakfast".equals(value)) return "Buffet sáng";
    if ("Lunch".equals(value)) return "Buffet trưa";
    if ("Dinner".equals(value)) return "Buffet tối";
    return value;
  }
%>
<%
  HttpSession sess = request.getSession(false);
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
  if (currentUser == null || (!"Admin".equalsIgnoreCase(currentUser.getRole())
      && !"Receptionist".equalsIgnoreCase(currentUser.getRole()))) {
    response.sendRedirect(request.getContextPath() + "/home");
    return;
  }
  List<BuffetMenuItem> menuItems = (List<BuffetMenuItem>) request.getAttribute("menuItems");
  LocalDate filterDate = (LocalDate) request.getAttribute("filterDate");
  String activeMenu = "buffet";
  DateTimeFormatter displayDate = DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Quản lý Menu Buffet - Nestora</title>
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
            <div class="breadcrumb">Vận hành / Menu Buffet</div>
            <h1 class="page-title">Quản lý Menu Buffet</h1>
            <p class="page-desc">Cập nhật các món được hiển thị cho khách hàng theo từng ngày và buổi phục vụ.</p>
          </div>
          <div class="page-actions">
            <a class="btn btn-outline" target="_blank" href="<%= request.getContextPath() %>/buffet">Xem trang khách hàng</a>
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/buffet?action=add<%= filterDate != null ? "&date=" + filterDate : "" %>">+ Thêm món</a>
          </div>
        </div>

        <% if ("1".equals(request.getParameter("saved"))) { %>
          <div class="alert alert-success">Đã lưu món buffet thành công.</div>
        <% } %>

        <section class="surface">
          <div class="table-tools">
            <form method="get" action="<%= request.getContextPath() %>/buffet" style="display:flex;align-items:flex-end;gap:8px;flex-wrap:wrap">
              <input type="hidden" name="action" value="list">
              <div>
                <label class="form-label" for="filter-date">Lọc theo ngày</label>
                <input class="form-control" id="filter-date" type="date" name="date"
                       value="<%= filterDate != null ? filterDate : "" %>">
              </div>
              <button class="btn btn-primary" type="submit">Lọc</button>
              <a class="btn btn-outline" href="<%= request.getContextPath() %>/buffet?action=list">Tất cả</a>
            </form>
            <div class="table-meta"><%= menuItems != null ? menuItems.size() : 0 %> món</div>
          </div>

          <% if (menuItems != null && !menuItems.isEmpty()) { %>
            <div class="table-wrap" data-admin-paginated="10">
              <table>
                <thead>
                <tr>
                  <th>ẢNH</th>
                  <th>NGÀY</th>
                  <th>BUỔI</th>
                  <th>NHÓM MÓN</th>
                  <th>TÊN MÓN</th>
                  <th>THỨ TỰ</th>
                  <th>TRẠNG THÁI</th>
                  <th>THAO TÁC</th>
                </tr>
                </thead>
                <tbody>
                <% for (BuffetMenuItem item : menuItems) { %>
                  <tr>
                    <td>
                      <% if (item.getImageUrl() != null && !item.getImageUrl().isEmpty()) {
                           String adminRawImage = item.getImageUrl();
                           String adminImageSrc = adminRawImage.startsWith("https://")
                               ? adminRawImage
                               : request.getContextPath() + "/"
                                   + (adminRawImage.startsWith("/") ? adminRawImage.substring(1) : adminRawImage);
                      %>
                        <img class="buffet-admin-thumb" src="<%= buffetAdminEscape(adminImageSrc) %>"
                             alt="<%= buffetAdminEscape(item.getDishName()) %>" loading="lazy">
                      <% } else { %>
                        <span class="buffet-admin-thumb empty-thumb">—</span>
                      <% } %>
                    </td>
                    <td class="table-strong"><%= item.getMenuDate().format(displayDate) %></td>
                    <td><%= buffetMealName(item.getMealPeriod()) %></td>
                    <td><%= buffetAdminEscape(item.getCategory()) %></td>
                    <td>
                      <strong><%= buffetAdminEscape(item.getDishName()) %></strong>
                      <% if (item.getDescription() != null && !item.getDescription().isEmpty()) { %>
                        <div class="text-muted" style="margin-top:4px"><%= buffetAdminEscape(item.getDescription()) %></div>
                      <% } %>
                    </td>
                    <td><%= item.getSortOrder() %></td>
                    <td>
                      <span class="status <%= "Active".equals(item.getStatus()) ? "success" : "warning" %>">
                        <%= "Active".equals(item.getStatus()) ? "Đang hiển thị" : "Đang ẩn" %>
                      </span>
                    </td>
                    <td>
                      <div class="row-actions">
                        <a class="btn btn-outline" href="<%= request.getContextPath() %>/buffet?action=edit&id=<%= item.getId() %>">Sửa</a>
                        <form method="post" action="<%= request.getContextPath() %>/buffet?action=delete"
                              onsubmit="return confirm('Xóa món buffet này?');">
                          <input type="hidden" name="id" value="<%= item.getId() %>">
                          <button class="btn btn-danger" type="submit">Xóa</button>
                        </form>
                      </div>
                    </td>
                  </tr>
                <% } %>
                </tbody>
              </table>
            </div>
          <% } else { %>
            <div class="empty">
              <strong>Chưa có món buffet phù hợp</strong>
              <span>Hãy thêm món mới hoặc chọn một ngày khác.</span>
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
