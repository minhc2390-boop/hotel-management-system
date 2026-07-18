<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Service" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User)sess.getAttribute("currentUser") : null;
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    Service service = (Service)request.getAttribute("service");
    boolean isEdit = service != null;
    String activeMenu = "services";
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title><%= isEdit ? "Cập nhật dịch vụ" : "Thêm dịch vụ" %> - Nestora</title>
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
                <div class="breadcrumb">Vận hành / Dịch vụ / <%= isEdit ? "Chỉnh sửa" : "Thêm mới" %></div>
                <h1 class="page-title"><%= isEdit ? "Cập nhật dịch vụ" : "Thêm dịch vụ mới" %></h1>
                <p class="page-desc">Nhập tên dịch vụ, giá và mô tả.</p>
              </div>
            </div>
            <section class="surface surface-pad form-surface">
              <h2 class="form-title">Thông tin dịch vụ</h2>
              <form action="<%= request.getContextPath() %>/services" method="post">
                <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>" />
                <% if (isEdit) { %>
                <input type="hidden" name="id" value="<%= service.getId() %>" />
                <% } %>
                <div class="form-grid">
                  <div class="form-group">
                    <label class="form-label" for="name">Tên dịch vụ</label>
                    <input
                      class="form-control"
                      id="name"
                      name="name"
                      required
                      placeholder="Ví dụ: Giặt ủi"
                      value="<%= isEdit ? service.getName() : "" %>"
                    />
                  </div>
                  <div class="form-group">
                    <label class="form-label" for="price">Giá dịch vụ (VNĐ)</label>
                    <input
                      class="form-control"
                      type="number"
                      min="0"
                      step="5000"
                      id="price"
                      name="price"
                      required
                      value="<%= isEdit ? (int)service.getPrice() : "" %>"
                    />
                  </div>
                  <div class="form-group full">
                    <label class="form-label" for="description">Mô tả</label>
                    <textarea class="form-control" id="description" name="description"><%= isEdit && service.getDescription() != null ? service.getDescription() : "" %></textarea>
                  </div>
                </div>
                <div class="form-actions">
                  <a class="btn btn-outline" href="<%= request.getContextPath() %>/services?action=list">Hủy</a>
                  <button class="btn btn-primary" type="submit"><%= isEdit ? "Lưu thay đổi" : "Tạo dịch vụ" %></button>
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
