<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Bill" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%
  HttpSession sess = request.getSession(false);
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
  if (currentUser == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
  }
  List<Bill> bills = (List<Bill>) request.getAttribute("bills");
  NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
  SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm");
  SimpleDateFormat date = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Hóa đơn của bạn - Nestora</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body class="client-body">
<%@ include file="WEB-INF/jspf/client-header.jspf" %>

<main class="client-main">
  <div class="client-page-head">
    <div>
      <p class="client-eyebrow">Tài khoản của bạn</p>
      <h1 class="client-page-title">Hóa đơn lưu trú</h1>
      <p class="client-page-desc">Theo dõi lịch sử lưu trú, dịch vụ phát sinh và trạng thái thanh toán.</p>
    </div>
  </div>

  <section class="client-surface">
    <% if (bills != null && !bills.isEmpty()) { %>
      <div class="table-wrap">
        <table>
          <thead>
          <tr>
            <th>MÃ HÓA ĐƠN</th>
            <th>NGÀY LẬP</th>
            <th>NHẬN PHÒNG</th>
            <th>TRẢ PHÒNG</th>
            <th>TỔNG TIỀN</th>
            <th>TRẠNG THÁI</th>
            <th>THAO TÁC</th>
          </tr>
          </thead>
          <tbody>
          <% for (Bill bill : bills) { %>
            <tr>
              <td class="table-primary">#HD<%= bill.getId() %></td>
              <td><%= dateTime.format(bill.getCreatedAt()) %></td>
              <td><%= date.format(bill.getCheckInDate()) %></td>
              <td><%= bill.getCheckOutDate() != null ? date.format(bill.getCheckOutDate()) : "-" %></td>
              <td class="table-strong"><%= money.format(bill.getTotalAmount()) %></td>
              <td>
                <% if ("Paid".equals(bill.getStatus())) { %>
                  <span class="status success">Đã thanh toán</span>
                <% } else if ("Unpaid".equals(bill.getStatus())) { %>
                  <span class="status info">Chưa thanh toán</span>
                <% } else { %>
                  <span class="status danger">Đã hủy</span>
                <% } %>
              </td>
              <td>
                <a class="btn btn-outline" href="<%= request.getContextPath() %>/bills?action=detail&id=<%= bill.getId() %>">Chi tiết</a>
              </td>
            </tr>
          <% } %>
          </tbody>
        </table>
      </div>
    <% } else { %>
      <div class="client-empty">
        <strong>Bạn chưa có hóa đơn nào</strong>
        <span>Hóa đơn sẽ xuất hiện sau khi khách sạn thực hiện thủ tục trả phòng.</span><br>
        <a class="btn btn-primary" style="margin-top:16px" href="<%= request.getContextPath() %>/home">Khám phá phòng</a>
      </div>
    <% } %>
  </section>
</main>

<%@ include file="WEB-INF/jspf/client-footer.jspf" %>
</body>
</html>
