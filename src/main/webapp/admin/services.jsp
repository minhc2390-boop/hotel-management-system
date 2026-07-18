<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Service" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User)sess.getAttribute("currentUser") : null;
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    List<Service> services = (List<Service>)request.getAttribute("services");
    NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    boolean isAdmin = "Admin".equals(currentUser.getRole());
    String activeMenu = "services";
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>Dịch vụ - Nestora</title>
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
                <div class="breadcrumb">Vận hành / Dịch vụ</div>
                <h1 class="page-title">Danh sách dịch vụ</h1>
                <p class="page-desc">Quản lý các dịch vụ và mức giá áp dụng cho khách lưu trú.</p>
              </div>
              <div class="page-actions">
                <a class="btn btn-outline" href="<%= request.getContextPath() %>/admin/service-book.jsp">Dịch vụ đã gọi</a>
                <% if (isAdmin) { %>
                <a class="btn btn-primary" href="<%= request.getContextPath() %>/services?action=add">＋ Thêm mới</a>
                <% } %>
              </div>
            </div>
            <section class="surface">
              <div class="table-tools">
                <div class="search-box">
                  <input type="search" placeholder="Tìm theo tên dịch vụ hoặc mô tả..." />
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="11" cy="11" r="7" />
                    <path d="M20 20l-3.5-3.5" />
                  </svg>
                </div>
                <div class="table-meta"><%= services != null ? services.size() : 0 %> dịch vụ</div>
              </div>
              <% if (services != null && !services.isEmpty()) { %>
              <div class="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>MÃ DỊCH VỤ</th>
                      <th>TÊN DỊCH VỤ</th>
                      <th>GIÁ DỊCH VỤ</th>
                      <th>MÔ TẢ</th>
                      <th>TRẠNG THÁI</th>
                      <th>THAO TÁC</th>
                    </tr>
                  </thead>
                  <tbody>
                    <% for (Service s : services) { %>
                    <tr>
                      <td class="table-primary">#DV<%= s.getId() %></td>
                      <td class="table-strong"><%= s.getName() %></td>
                      <td><%= money.format(s.getPrice()) %></td>
                      <td><%= s.getDescription() != null ? s.getDescription() : "-" %></td>
                      <td><span class="status success">Đang hoạt động</span></td>
                      <td>
                        <div class="row-actions">
                          <a
                            class="btn btn-outline btn-icon"
                            href="<%= request.getContextPath() %>/services?action=edit&id=<%= s.getId() %>"
                          >
                            ✎
                          </a>
                          <% if (isAdmin) { %>
                          <a
                            class="btn btn-danger btn-icon"
                            href="<%= request.getContextPath() %>/services?action=delete&id=<%= s.getId() %>"
                            onclick="return confirm('Xóa dịch vụ này?');"
                          >
                            ×
                          </a>
                          <% } %>
                        </div>
                      </td>
                    </tr>
                    <% } %>
                  </tbody>
                </table>
              </div>
              <div class="pagination"><span class="page-number active">1</span></div>
              <% } else { %>
              <div class="empty">
                <strong>Chưa có dịch vụ</strong>
                Hãy thêm dịch vụ đầu tiên.
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
