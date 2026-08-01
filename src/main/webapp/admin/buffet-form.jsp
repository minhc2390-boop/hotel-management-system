<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.BuffetMenuItem" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="java.time.LocalDate" %>
<%!
  private String buffetFormEscape(String value) {
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
  BuffetMenuItem item = (BuffetMenuItem) request.getAttribute("menuItem");
  boolean isEdit = item != null && item.getId() > 0;
  LocalDate defaultDate = item != null && item.getMenuDate() != null
      ? item.getMenuDate() : (LocalDate) request.getAttribute("defaultDate");
  if (defaultDate == null) defaultDate = LocalDate.now();
  String activeMenu = "buffet";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title><%= isEdit ? "Sửa món buffet" : "Thêm món buffet" %> - Nestora</title>
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
            <div class="breadcrumb">Vận hành / Menu Buffet / <%= isEdit ? "Chỉnh sửa" : "Thêm mới" %></div>
            <h1 class="page-title"><%= isEdit ? "Chỉnh sửa món buffet" : "Thêm món buffet" %></h1>
            <p class="page-desc">Thiết lập ngày, buổi phục vụ và thông tin món hiển thị cho khách hàng.</p>
          </div>
        </div>

        <section class="surface surface-pad form-surface">
          <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= buffetFormEscape((String) request.getAttribute("error")) %></div>
          <% } %>
          <form method="post" action="<%= request.getContextPath() %>/buffet?action=<%= isEdit ? "update" : "insert" %>">
            <% if (isEdit) { %><input type="hidden" name="id" value="<%= item.getId() %>"><% } %>
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label" for="menuDate">Ngày áp dụng *</label>
                <input class="form-control" id="menuDate" type="date" name="menuDate"
                       value="<%= defaultDate %>" required>
              </div>
              <div class="form-group">
                <label class="form-label" for="mealPeriod">Buổi phục vụ *</label>
                <select class="form-control" id="mealPeriod" name="mealPeriod" required>
                  <% String meal = item != null ? item.getMealPeriod() : "Breakfast"; %>
                  <option value="Breakfast" <%= "Breakfast".equals(meal) ? "selected" : "" %>>Buffet sáng</option>
                  <option value="Lunch" <%= "Lunch".equals(meal) ? "selected" : "" %>>Buffet trưa</option>
                  <option value="Dinner" <%= "Dinner".equals(meal) ? "selected" : "" %>>Buffet tối</option>
                </select>
              </div>
              <div class="form-group">
                <label class="form-label" for="category">Nhóm món *</label>
                <input class="form-control" id="category" name="category" maxlength="80" required
                       placeholder="Ví dụ: Món chính, Khai vị, Tráng miệng"
                       value="<%= item != null ? buffetFormEscape(item.getCategory()) : "" %>">
              </div>
              <div class="form-group">
                <label class="form-label" for="dishName">Tên món *</label>
                <input class="form-control" id="dishName" name="dishName" maxlength="160" required
                       placeholder="Ví dụ: Phở bò truyền thống"
                       value="<%= item != null ? buffetFormEscape(item.getDishName()) : "" %>">
              </div>
              <div class="form-group">
                <label class="form-label" for="sortOrder">Thứ tự hiển thị</label>
                <input class="form-control" id="sortOrder" type="number" min="0" name="sortOrder"
                       value="<%= item != null ? item.getSortOrder() : 0 %>">
              </div>
              <div class="form-group">
                <label class="form-label" for="status">Trạng thái *</label>
                <% String status = item != null ? item.getStatus() : "Active"; %>
                <select class="form-control" id="status" name="status" required>
                  <option value="Active" <%= "Active".equals(status) ? "selected" : "" %>>Đang hiển thị</option>
                  <option value="Inactive" <%= "Inactive".equals(status) ? "selected" : "" %>>Tạm ẩn</option>
                </select>
              </div>
              <div class="form-group full">
                <label class="form-label" for="description">Mô tả</label>
                <textarea class="form-control" id="description" name="description" rows="4" maxlength="1000"
                          placeholder="Thành phần nổi bật hoặc mô tả ngắn về món..."><%= item != null ? buffetFormEscape(item.getDescription()) : "" %></textarea>
              </div>
              <div class="form-group full">
                <label class="form-label" for="imageUrl">Ảnh món ăn</label>
                <input class="form-control" id="imageUrl" name="imageUrl" maxlength="500"
                       list="buffet-image-suggestions"
                       placeholder="images/buffet/buffet-breakfast.png hoặc URL HTTPS"
                       value="<%= item != null ? buffetFormEscape(item.getImageUrl()) : "" %>">
                <datalist id="buffet-image-suggestions">
                  <option value="images/buffet/buffet-breakfast.png">Ảnh buffet sáng</option>
                  <option value="images/buffet/buffet-lunch.png">Ảnh buffet trưa</option>
                  <option value="images/buffet/buffet-dinner.png">Ảnh buffet tối</option>
                </datalist>
                <small class="form-hint">Chọn ảnh demo có sẵn hoặc nhập URL ảnh bắt đầu bằng https://.</small>
                <div class="buffet-image-preview-wrap">
                  <img id="buffet-image-preview" alt="Xem trước ảnh món ăn">
                  <span id="buffet-image-preview-empty">Chưa chọn ảnh</span>
                </div>
              </div>
            </div>
            <div style="display:flex;gap:10px;margin-top:20px">
              <a class="btn btn-outline" href="<%= request.getContextPath() %>/buffet?action=list">Hủy</a>
              <button class="btn btn-primary" type="submit"><%= isEdit ? "Lưu thay đổi" : "Thêm món" %></button>
            </div>
          </form>
        </section>
      </div>
    </section>
  </main>
</div>
<script src="<%= request.getContextPath() %>/js/app.js"></script>
<script>
  (function () {
    const input = document.getElementById('imageUrl');
    const preview = document.getElementById('buffet-image-preview');
    const empty = document.getElementById('buffet-image-preview-empty');
    const contextPath = '<%= request.getContextPath() %>';

    function updatePreview() {
      const value = input.value.trim();
      if (!value) {
        preview.removeAttribute('src');
        preview.style.display = 'none';
        empty.textContent = 'Chưa chọn ảnh';
        empty.style.display = '';
        return;
      }
      preview.src = value.startsWith('https://')
          ? value
          : contextPath + '/' + value.replace(/^\//, '');
      preview.style.display = 'block';
      empty.style.display = 'none';
    }

    input.addEventListener('input', updatePreview);
    preview.addEventListener('error', function () {
      preview.style.display = 'none';
      empty.textContent = 'Không tải được ảnh từ đường dẫn này';
      empty.style.display = '';
    });
    preview.addEventListener('load', function () {
      empty.textContent = 'Chưa chọn ảnh';
    });
    updatePreview();
  })();
</script>
</body>
</html>
