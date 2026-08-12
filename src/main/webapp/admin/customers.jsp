<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="java.util.List" %>
<% 
  HttpSession sess = request.getSession(false); 
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null; 
  String activeMenu = "customers"; 
  List<User> users = (List<User>) request.getAttribute("users");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Khách hàng & Nguời dùng - Nestora</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
  <style>
    .tab-bar {
      display: flex;
      gap: 24px;
      border-bottom: 2px solid var(--line);
      margin-bottom: 24px;
    }
    .tab-item {
      padding: 12px 4px;
      font-weight: 600;
      color: var(--muted);
      position: relative;
      cursor: pointer;
    }
    .tab-item.active {
      color: var(--brand);
    }
    .tab-item.active::after {
      content: '';
      position: absolute;
      bottom: -2px;
      left: 0;
      right: 0;
      height: 2px;
      background: var(--brand);
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
            <div class="breadcrumb">Vận hành / Người dùng & Khách hàng</div>
            <h1 class="page-title">Danh sách người dùng</h1>
            <p class="page-desc">Quản lý tài khoản khách hàng và nhân viên hệ thống.</p>
          </div>
          <div class="page-actions">
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/users?action=add">＋ Thêm mới người dùng</a>
          </div>
        </div>

        <!-- Tab chuyển đổi -->
        <div class="tab-bar">
          <a href="<%= request.getContextPath() %>/users?action=list" class="tab-item active">Tài khoản hệ thống</a>
          <a href="<%= request.getContextPath() %>/users?action=guests" class="tab-item">Hồ sơ Khách lưu trú</a>
        </div>

        <section class="surface">
          <div class="table-tools">
            <div class="search-box">
              <input type="search" placeholder="Tìm theo tên, email, SĐT...">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/></svg>
            </div>
            <div class="admin-filter-group">
              <select class="admin-filter-select" data-admin-filter aria-label="Lọc theo vai trò">
                <option value="">Tất cả vai trò</option>
                <option value="Admin">Quản trị viên</option>
                <option value="Lễ tân">Lễ tân</option>
                <option value="Hội viên">Hội viên</option>
              </select>
            </div>
            <div class="table-meta"><%= users != null ? users.size() : 0 %> người dùng</div>
          </div>

          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>HỌ VÀ TÊN</th>
                  <th>TÊN ĐĂNG NHẬP</th>
                  <th>EMAIL</th>
                  <th>SỐ ĐIỆN THOẠI</th>
                  <th>VAI TRÒ</th>
                  <th>THAO TÁC</th>
                </tr>
              </thead>
              <tbody>
                <% if (users != null && !users.isEmpty()) { 
                     for (User u : users) { 
                %>
                  <tr>
                    <td class="table-primary">#USR<%= String.format("%03d", u.getId()) %></td>
                    <td class="table-strong"><%= u.getFullName() %></td>
                    <td><%= u.getUsername() %></td>
                    <td><%= u.getEmail() %></td>
                    <td><%= u.getPhone() != null ? u.getPhone() : "-" %></td>
                    <td>
                      <% if ("Admin".equals(u.getRole())) { %>
                        <span class="status danger">Admin</span>
                      <% } else if ("Receptionist".equals(u.getRole())) { %>
                        <span class="status warning">Lễ tân</span>
                      <% } else { %>
                        <span class="status info">Hội viên</span>
                      <% } %>
                    </td>
                    <td>
                      <div class="row-actions">
                        <a class="btn btn-outline btn-icon" title="Sửa" href="<%= request.getContextPath() %>/users?action=edit&id=<%= u.getId() %>">✎</a>
                        <% if (currentUser != null && "Admin".equals(currentUser.getRole()) && u.getId() != currentUser.getId()) { %>
                          <a class="btn btn-danger btn-icon" title="Xóa" onclick="return confirm('Bạn có chắc muốn xóa người dùng này?')" href="<%= request.getContextPath() %>/users?action=delete&id=<%= u.getId() %>">×</a>
                        <% } %>
                      </div>
                    </td>
                  </tr>
                <%   } 
                   } else { 
                %>
                  <tr>
                    <td colspan="7" style="text-align:center; padding:20px;">Chưa có dữ liệu người dùng nào.</td>
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
