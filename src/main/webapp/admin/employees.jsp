<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="java.util.List" %>
<% 
  HttpSession sess = request.getSession(false); 
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null; 
  if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
      response.sendRedirect(request.getContextPath() + "/home");
      return;
  }
  String activeMenu = "employees"; 
  List<User> employees = (List<User>) request.getAttribute("employees");
  if (employees == null) {
      com.hotel.dao.UserDAO userDAO = new com.hotel.dao.UserDAO();
      List<User> allUsers = userDAO.getAllUsers();
      employees = new java.util.ArrayList<>();
      if (allUsers != null) {
          for (User u : allUsers) {
              if (u != null && ("Admin".equalsIgnoreCase(u.getRole()) || "Receptionist".equalsIgnoreCase(u.getRole()))) {
                  employees.add(u);
              }
          }
      }
  }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Quản lý nhân viên - Nestora</title>
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
            <div class="breadcrumb">Quản trị / Nhân viên</div>
            <h1 class="page-title">Quản lý nhân viên</h1>
            <p class="page-desc">Danh sách tài khoản quản trị và lễ tân (phân bổ quyền).</p>
          </div>
          <div class="page-actions">
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/users?action=add">＋ Thêm mới nhân viên</a>
          </div>
        </div>
        
        <section class="surface">
          <div class="table-tools">
            <div class="search-box">
              <input type="search" placeholder="Tìm theo họ tên, email hoặc vai trò...">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/>
              </svg>
            </div>
            <div class="table-meta"><%= employees != null ? employees.size() : 0 %> nhân viên</div>
          </div>
          
          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>MÃ NHÂN VIÊN</th>
                  <th>HỌ VÀ TÊN</th>
                  <th>TÊN ĐĂNG NHẬP</th>
                  <th>EMAIL</th>
                  <th>SỐ ĐIỆN THOẠI</th>
                  <th>VAI TRÒ</th>
                  <th>THAO TÁC</th>
                </tr>
              </thead>
              <tbody>
                <% if (employees != null && !employees.isEmpty()) { 
                     for (User u : employees) { 
                %>
                  <tr>
                    <td class="table-primary">#NV<%= String.format("%03d", u.getId()) %></td>
                    <td class="table-strong"><%= u.getFullName() %></td>
                    <td><%= u.getUsername() %></td>
                    <td><%= u.getEmail() %></td>
                    <td><%= u.getPhone() != null && !u.getPhone().isEmpty() ? u.getPhone() : "-" %></td>
                    <td>
                      <% if ("Admin".equals(u.getRole())) { %>
                        <span class="status danger">Quản lý (Admin)</span>
                      <% } else if ("Receptionist".equals(u.getRole())) { %>
                        <span class="status warning">Lễ tân (Receptionist)</span>
                      <% } else { %>
                        <span class="status info">Khách hàng (Customer)</span>
                      <% } %>
                    </td>
                    <td>
                      <div class="row-actions">
                        <a class="btn btn-outline btn-icon" title="Sửa vai trò / thông tin" href="<%= request.getContextPath() %>/users?action=edit&id=<%= u.getId() %>">✎</a>
                        <% if (currentUser != null && u.getId() != currentUser.getId()) { %>
                          <a class="btn btn-danger btn-icon" title="Xóa" onclick="return confirm('Bạn có chắc muốn xóa nhân viên này?')" href="<%= request.getContextPath() %>/users?action=delete&id=<%= u.getId() %>">×</a>
                        <% } %>
                      </div>
                    </td>
                  </tr>
                <%   } 
                   } else { 
                %>
                  <tr>
                    <td colspan="7" style="text-align:center; padding:20px;">Không có dữ liệu nhân viên.</td>
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