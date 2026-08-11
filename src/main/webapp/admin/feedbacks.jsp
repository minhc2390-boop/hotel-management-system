<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.Feedback" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%!
  private String feedbackAdminEscape(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("<", "&lt;")
        .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
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
  List<Feedback> feedbacks = (List<Feedback>) request.getAttribute("feedbacks");
  String activeMenu = "feedbacks";
  SimpleDateFormat dateTime = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Đánh giá & Góp ý - Nestora</title>
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
            <div class="breadcrumb">Vận hành / Đánh giá & Góp ý</div>
            <h1 class="page-title">Đánh giá từ khách hàng</h1>
            <p class="page-desc">Theo dõi phản hồi được gửi sau khi khách đã hoàn tất trả phòng.</p>
          </div>
        </div>

        <section class="surface">
          <div class="table-tools">
            <div class="table-meta"><%= feedbacks != null ? feedbacks.size() : 0 %> đánh giá</div>
          </div>
          <% if (feedbacks != null && !feedbacks.isEmpty()) { %>
          <div class="table-wrap" data-admin-paginated="10">
              <table>
                <thead>
                <tr>
                  <th>KHÁCH HÀNG</th>
                  <th>PHÒNG</th>
                  <th>MỨC ĐÁNH GIÁ</th>
                  <th>NỘI DUNG</th>
                  <th>NGÀY GỬI</th>
                </tr>
                </thead>
                <tbody>
                <% for (Feedback feedback : feedbacks) { %>
                  <tr>
                    <td>
                      <strong><%= feedbackAdminEscape(feedback.getCustomerUser().getFullName()) %></strong>
                      <div class="text-muted"><%= feedbackAdminEscape(feedback.getCustomerUser().getEmail()) %></div>
                    </td>
                    <td>
                      <span class="table-primary">P.<%= feedbackAdminEscape(feedback.getBooking().getRoom().getRoomNumber()) %></span>
                      <div class="text-muted">#DP<%= feedback.getBooking().getBookingId() %></div>
                    </td>
                    <td><span class="feedback-stars"><% for (int star = 1; star <= 5; star++) { %><%= star <= feedback.getRating() ? "★" : "☆" %><% } %></span></td>
                    <td style="min-width:280px;white-space:normal"><%= feedbackAdminEscape(feedback.getContent()) %></td>
                    <td><%= dateTime.format(feedback.getCreatedAt()) %></td>
                  </tr>
                <% } %>
                </tbody>
              </table>
            </div>
          <% } else { %>
            <div class="empty">
              <strong>Chưa có đánh giá nào</strong>
              <span>Đánh giá sẽ xuất hiện sau khi khách đã trả phòng và gửi góp ý.</span>
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
