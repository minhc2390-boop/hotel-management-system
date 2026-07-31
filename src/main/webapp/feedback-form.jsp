<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.Booking" %>
<%@ page import="com.hotel.model.Feedback" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%!
  private String feedbackEscape(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("<", "&lt;")
        .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
  }
%>
<%
  HttpSession feedbackSession = request.getSession(false);
  User currentUser = feedbackSession != null
      ? (User) feedbackSession.getAttribute("currentUser") : null;
  Booking booking = (Booking) request.getAttribute("booking");
  Feedback feedback = (Feedback) request.getAttribute("feedback");
  if (currentUser == null || booking == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
  }
  boolean readOnly = feedback != null;
  int selectedRating = readOnly ? feedback.getRating()
      : request.getAttribute("rating") != null ? (Integer) request.getAttribute("rating") : 0;
  String feedbackContent = readOnly ? feedback.getContent()
      : request.getAttribute("content") != null ? (String) request.getAttribute("content") : "";
  SimpleDateFormat feedbackDate = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title><%= readOnly ? "Đánh giá của bạn" : "Đánh giá kỳ lưu trú" %> - Nestora</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body class="client-body">
<%@ include file="WEB-INF/jspf/client-header.jspf" %>

<main class="client-main">
  <div class="client-page-head">
    <div>
      <p class="client-eyebrow">Trải nghiệm của bạn</p>
      <h1 class="client-page-title"><%= readOnly ? "Đánh giá đã gửi" : "Đánh giá & Góp ý" %></h1>
      <p class="client-page-desc">
        <%= readOnly
            ? "Cảm ơn bạn đã chia sẻ trải nghiệm tại Nestora."
            : "Góp ý của bạn giúp chúng tôi cải thiện chất lượng phục vụ trong những kỳ nghỉ tiếp theo." %>
      </p>
    </div>
  </div>

  <div class="feedback-layout">
    <section class="client-surface feedback-panel">
      <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-error"><%= feedbackEscape((String) request.getAttribute("error")) %></div>
      <% } %>

      <% if (readOnly) { %>
        <div class="form-group">
          <label class="form-label">Mức độ hài lòng</label>
          <div class="feedback-stars" style="font-size:34px">
            <% for (int star = 1; star <= 5; star++) { %><%= star <= selectedRating ? "★" : "☆" %><% } %>
          </div>
        </div>
        <div class="form-group">
          <label class="form-label">Nội dung góp ý</label>
          <div class="client-surface" style="padding:18px;box-shadow:none;white-space:pre-wrap"><%= feedbackEscape(feedbackContent) %></div>
        </div>
        <a class="btn btn-primary" href="<%= request.getContextPath() %>/bookings?action=mybookings">Quay lại phòng đã đặt</a>
      <% } else { %>
        <form method="post" action="<%= request.getContextPath() %>/feedbacks?action=insert">
          <input type="hidden" name="bookingId" value="<%= booking.getBookingId() %>">
          <div class="form-group">
            <label class="form-label">Bạn hài lòng với kỳ lưu trú này ở mức nào? *</label>
            <div class="rating-picker" role="radiogroup" aria-label="Mức đánh giá từ 1 đến 5 sao">
              <% for (int star = 5; star >= 1; star--) { %>
                <input id="rating-<%= star %>" type="radio" name="rating" value="<%= star %>"
                       <%= selectedRating == star ? "checked" : "" %> required>
                <label for="rating-<%= star %>" title="<%= star %> sao">★</label>
              <% } %>
            </div>
          </div>
          <div class="form-group">
            <label class="form-label" for="feedback-content">Đánh giá & góp ý *</label>
            <textarea class="form-control" id="feedback-content" name="content" rows="7"
                      minlength="10" maxlength="2000" required
                      placeholder="Hãy chia sẻ điều bạn hài lòng hoặc những điểm Nestora có thể cải thiện..."><%= feedbackEscape(feedbackContent) %></textarea>
            <div style="margin-top:6px;color:var(--muted);font-size:11px">Từ 10 đến 2000 ký tự.</div>
          </div>
          <div style="display:flex;gap:10px;flex-wrap:wrap">
            <button class="btn btn-primary" type="submit">Gửi đánh giá</button>
            <a class="btn btn-outline" href="<%= request.getContextPath() %>/bookings?action=mybookings">Để sau</a>
          </div>
        </form>
      <% } %>
    </section>

    <aside class="client-surface feedback-panel">
      <p class="client-eyebrow">Thông tin kỳ lưu trú</p>
      <div class="feedback-booking-summary">
        <div class="feedback-summary-row"><span>Mã phiếu</span><strong>#DP<%= booking.getBookingId() %></strong></div>
        <div class="feedback-summary-row"><span>Phòng</span><strong><%= feedbackEscape(booking.getRoom().getRoomNumber()) %></strong></div>
        <div class="feedback-summary-row"><span>Loại phòng</span><strong><%= feedbackEscape(booking.getRoom().getRoomType().getName()) %></strong></div>
        <div class="feedback-summary-row"><span>Nhận phòng</span><strong><%= feedbackDate.format(booking.getCheckInDate()) %></strong></div>
        <div class="feedback-summary-row"><span>Trả phòng</span><strong><%= feedbackDate.format(booking.getCheckOutDate()) %></strong></div>
        <div class="feedback-summary-row"><span>Trạng thái</span><strong>Đã trả phòng</strong></div>
      </div>
    </aside>
  </div>
</main>

<%@ include file="WEB-INF/jspf/client-footer.jspf" %>
</body>
</html>
