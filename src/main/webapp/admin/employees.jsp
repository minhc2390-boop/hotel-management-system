<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User)sess.getAttribute("currentUser") : null;
    String activeMenu = "employees";
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>Quản lý nhân viên - Nestora</title>
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
                <div class="breadcrumb">Quản trị / Nhân viên</div>
                <h1 class="page-title">Quản lý nhân viên</h1>
                <p class="page-desc">Danh sách tài khoản quản trị và lễ tân.</p>
              </div>
              <div class="page-actions"><button class="btn btn-primary">＋ Thêm mới</button></div>
            </div>
            <section class="surface">
              <div class="table-tools">
                <div class="search-box">
                  <input type="search" placeholder="Tìm theo họ tên, email hoặc vai trò..." />
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="11" cy="11" r="7" />
                    <path d="M20 20l-3.5-3.5" />
                  </svg>
                </div>
                <div class="table-meta">4 nhân viên</div>
              </div>
              <div class="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>MÃ NHÂN VIÊN</th>
                      <th>HỌ VÀ TÊN</th>
                      <th>EMAIL</th>
                      <th>VAI TRÒ</th>
                      <th>TRẠNG THÁI</th>
                      <th>THAO TÁC</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td class="table-primary">#NV001</td>
                      <td class="table-strong">Ngọc Linh</td>
                      <td>linh@nestora.vn</td>
                      <td>Quản lý</td>
                      <td><span class="status success">Đang hoạt động</span></td>
                      <td>
                        <div class="row-actions">
                          <button class="btn btn-outline btn-icon">✎</button>
                          <button class="btn btn-danger btn-icon">×</button>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td class="table-primary">#NV002</td>
                      <td class="table-strong">Minh Duy</td>
                      <td>duy@nestora.vn</td>
                      <td>Lễ tân</td>
                      <td><span class="status success">Đang hoạt động</span></td>
                      <td>
                        <div class="row-actions">
                          <button class="btn btn-outline btn-icon">✎</button>
                          <button class="btn btn-danger btn-icon">×</button>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td class="table-primary">#NV003</td>
                      <td class="table-strong">Công Nguyễn</td>
                      <td>cong@nestora.vn</td>
                      <td>Lễ tân</td>
                      <td><span class="status warning">Tạm khóa</span></td>
                      <td>
                        <div class="row-actions">
                          <button class="btn btn-outline btn-icon">✎</button>
                          <button class="btn btn-danger btn-icon">×</button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <div class="pagination"><span class="page-number active">1</span></div>
            </section>
          </div>
        </section>
      </main>
    </div>
    <script src="<%= request.getContextPath() %>/js/app.js"></script>
  </body>
</html>
