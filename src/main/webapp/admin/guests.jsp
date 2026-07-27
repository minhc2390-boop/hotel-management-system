<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Customer" %>
<%@ page import="java.util.List" %>
<% 
  HttpSession sess = request.getSession(false); 
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null; 
  String activeMenu = "customers"; 
  List<Customer> customers = (List<Customer>) request.getAttribute("customers");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Danh sách Khách lưu trú - Nestora</title>
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
            <div class="breadcrumb">Vận hành / Khách hàng</div>
            <h1 class="page-title">Quản lý Khách hàng</h1>
            <p class="page-desc">Danh sách tất cả khách lưu trú đã thực hiện đặt phòng tại khách sạn.</p>
          </div>
        </div>

        <!-- Tab chuyển đổi -->
        <div class="tab-bar">
          <a href="<%= request.getContextPath() %>/users?action=list" class="tab-item">Tài khoản hệ thống</a>
          <a href="<%= request.getContextPath() %>/users?action=guests" class="tab-item active">Hồ sơ Khách lưu trú</a>
        </div>

        <section class="surface">
          <div class="table-tools">
            <div class="search-box">
              <input type="search" placeholder="Tìm theo tên, email, CCCD, SĐT...">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/></svg>
            </div>
            <div class="table-meta"><%= customers != null ? customers.size() : 0 %> khách hàng</div>
          </div>

          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>MÃ KHÁCH HÀNG</th>
                  <th>HỌ VÀ TÊN</th>
                  <th>CCCD / HỘ CHIẾU</th>
                  <th>SỐ ĐIỆN THOẠI</th>
                  <th>EMAIL</th>
                  <th>THAO TÁC</th>
                </tr>
              </thead>
              <tbody>
                <% if (customers != null && !customers.isEmpty()) { 
                     for (Customer c : customers) { 
                %>
                  <tr>
                    <td class="table-primary">#GST<%= String.format("%04d", c.getCustomerId()) %></td>
                    <td class="table-strong"><%= c.getCustomerName() %></td>
                    <td><%= c.getCustomerCccd() != null ? c.getCustomerCccd() : "-" %></td>
                    <td><%= c.getCustomerPhone() != null ? c.getCustomerPhone() : "-" %></td>
                    <td><%= c.getCustomerEmail() != null ? c.getCustomerEmail() : "-" %></td>
                    <td>
                      <div class="row-actions">
                        <a class="btn btn-primary" style="padding: 6px 12px; font-size: 12px; font-weight:600;" href="<%= request.getContextPath() %>/users?action=guestDetail&id=<%= c.getCustomerId() %>">
                          Xem hồ sơ
                        </a>
                      </div>
                    </td>
                  </tr>
                <%   } 
                   } else { 
                %>
                  <tr>
                    <td colspan="6" style="text-align:center; padding:20px;">Chưa có dữ liệu khách hàng nào.</td>
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
