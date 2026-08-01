<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.BuffetMenuItem" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Map" %>
<%!
  private String buffetEscape(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("<", "&lt;")
        .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
  }
%>
<%
  LocalDate selectedDate = (LocalDate) request.getAttribute("selectedDate");
  if (selectedDate == null) selectedDate = LocalDate.now();
  List<BuffetMenuItem> menuItems = (List<BuffetMenuItem>) request.getAttribute("menuItems");
  if (menuItems == null) menuItems = new ArrayList<>();

  Map<String, List<BuffetMenuItem>> meals = new HashMap<>();
  meals.put("Breakfast", new ArrayList<>());
  meals.put("Lunch", new ArrayList<>());
  meals.put("Dinner", new ArrayList<>());
  for (BuffetMenuItem item : menuItems) {
    meals.computeIfAbsent(item.getMealPeriod(), key -> new ArrayList<>()).add(item);
  }

  Locale viLocale = Locale.forLanguageTag("vi-VN");
  DateTimeFormatter fullDateFormat = DateTimeFormatter.ofPattern("EEEE, dd/MM/yyyy", viLocale);
  DateTimeFormatter dayNameFormat = DateTimeFormatter.ofPattern("EEE", viLocale);
  DateTimeFormatter shortDateFormat = DateTimeFormatter.ofPattern("dd/MM");
  LocalDate stripStart = selectedDate.minusDays(3);
  String[] mealKeys = {"Breakfast", "Lunch", "Dinner"};
  String[] mealNames = {"Buffet sáng", "Buffet trưa", "Buffet tối"};
  String[] mealTimes = {"06:30 – 10:00", "11:30 – 14:00", "18:00 – 21:30"};
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Menu Buffet theo ngày - Nestora Hotel & Resort</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body class="client-body">
<%@ include file="WEB-INF/jspf/client-header.jspf" %>

<main class="client-main">
  <div class="client-page-head">
    <div>
      <p class="client-eyebrow">Ẩm thực tại Nestora</p>
      <h1 class="client-page-title">Menu Buffet theo ngày</h1>
      <p class="client-page-desc">
        Khám phá thực đơn được phục vụ trong
        <strong><%= selectedDate.format(fullDateFormat) %></strong>.
        Thực đơn có thể thay đổi theo nguồn nguyên liệu trong ngày.
      </p>
    </div>
    <form action="<%= request.getContextPath() %>/buffet" method="get" class="buffet-date-form">
      <label class="form-label" for="buffet-date">Chọn ngày khác</label>
      <div style="display:flex;gap:8px">
        <input class="form-control" id="buffet-date" type="date" name="date"
               value="<%= selectedDate %>">
        <button class="btn btn-primary" type="submit">Xem menu</button>
      </div>
    </form>
  </div>

  <nav class="buffet-date-strip" aria-label="Chọn ngày xem buffet">
    <% for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
         LocalDate date = stripStart.plusDays(dayOffset);
         boolean active = date.equals(selectedDate);
    %>
      <a class="buffet-date-link <%= active ? "active" : "" %>"
         <%= active ? "aria-current=\"date\"" : "" %>
         href="<%= request.getContextPath() %>/buffet?date=<%= date %>">
        <span><%= date.equals(LocalDate.now()) ? "Hôm nay" : date.format(dayNameFormat) %></span>
        <strong><%= date.format(shortDateFormat) %></strong>
      </a>
    <% } %>
  </nav>

  <section class="buffet-meal-grid">
    <% for (int mealIndex = 0; mealIndex < mealKeys.length; mealIndex++) {
         List<BuffetMenuItem> mealItems = meals.get(mealKeys[mealIndex]);
    %>
      <article class="client-surface buffet-meal-card">
        <div class="buffet-meal-head">
          <h2><%= mealNames[mealIndex] %></h2>
          <p>Phục vụ từ <%= mealTimes[mealIndex] %></p>
        </div>
        <% if (mealItems != null && !mealItems.isEmpty()) { %>
          <div class="buffet-dish-list">
            <% for (BuffetMenuItem item : mealItems) { %>
              <div class="buffet-dish <%= item.getImageUrl() != null && !item.getImageUrl().isEmpty() ? "has-image" : "" %>">
                <% if (item.getImageUrl() != null && !item.getImageUrl().isEmpty()) {
                     String rawImageUrl = item.getImageUrl();
                     String resolvedImageUrl = rawImageUrl.startsWith("https://")
                         ? rawImageUrl
                         : request.getContextPath() + "/"
                             + (rawImageUrl.startsWith("/") ? rawImageUrl.substring(1) : rawImageUrl);
                %>
                  <img class="buffet-dish-image" src="<%= buffetEscape(resolvedImageUrl) %>"
                       alt="<%= buffetEscape(item.getDishName()) %>" loading="lazy">
                <% } %>
                <div class="buffet-dish-content">
                  <span class="buffet-dish-category"><%= buffetEscape(item.getCategory()) %></span>
                  <h3><%= buffetEscape(item.getDishName()) %></h3>
                  <% if (item.getDescription() != null && !item.getDescription().isEmpty()) { %>
                    <p><%= buffetEscape(item.getDescription()) %></p>
                  <% } %>
                </div>
              </div>
            <% } %>
          </div>
        <% } else { %>
          <div class="client-empty" style="padding:36px 20px">
            <strong>Chưa cập nhật món</strong>
            <span>Nhà hàng sẽ bổ sung thực đơn cho buổi này sớm nhất.</span>
          </div>
        <% } %>
      </article>
    <% } %>
  </section>
</main>

<%@ include file="WEB-INF/jspf/client-footer.jspf" %>
</body>
</html>
