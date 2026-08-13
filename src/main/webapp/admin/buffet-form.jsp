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
          <form method="post" action="<%= request.getContextPath() %>/buffet?action=<%= isEdit ? "update" : "insert" %>" enctype="multipart/form-data" id="buffetDishForm">
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
                <textarea class="form-control" id="description" name="description" rows="3" maxlength="1000"
                          placeholder="Thành phần nổi bật hoặc mô tả ngắn về món..."><%= item != null ? buffetFormEscape(item.getDescription()) : "" %></textarea>
              </div>

              <!-- Upload ảnh món ăn: Kéo thả hoặc Nhấn chọn file tự động -->
              <div class="form-group full">
                <label class="form-label">Ảnh món ăn</label>
                <input type="hidden" name="imageUrl" id="imageUrl"
                       value="<%= item != null && item.getImageUrl() != null ? buffetFormEscape(item.getImageUrl()) : "" %>">
                <input type="file" id="dishFileInput" name="imageFile"
                       accept="image/png,image/jpeg,image/webp,image/gif" style="display:none">

                <div class="dish-upload-container">
                  <!-- Trạng thái đang tải lên -->
                  <div class="dish-upload-loader" id="dishUploadLoader">
                    <div class="dish-spinner"></div>
                    <div>Đang tải ảnh món ăn lên máy chủ...</div>
                  </div>

                  <!-- Khu vực Kéo & Thả / Nhấn để chọn ảnh -->
                  <div class="dish-dropzone" id="dishDropzone" tabindex="0" role="button" aria-label="Tải lên ảnh món ăn">
                    <div class="dish-dropzone-icon">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                        <circle cx="8.5" cy="8.5" r="1.5"/>
                        <polyline points="21 15 16 10 5 21"/>
                      </svg>
                    </div>
                    <div class="dish-dropzone-title">
                      Kéo thả ảnh vào đây hoặc <span class="dish-dropzone-btn">chọn file từ máy</span>
                    </div>
                    <p class="dish-dropzone-hint">
                      Hỗ trợ định dạng JPG, PNG, WEBP, GIF (tối đa 10MB). Ảnh sẽ tự động tải lên và lưu vào hệ thống.
                    </p>
                  </div>

                  <!-- Khung Xem trước ảnh khi đã có ảnh -->
                  <div class="dish-preview-card" id="dishPreviewCard" style="display:none">
                    <div class="dish-preview-img-box">
                      <img id="dishPreviewImg" src="" alt="Xem trước món ăn">
                      <div class="dish-preview-overlay">
                        <span class="dish-status-tag active-tag" id="dishPreviewTag">
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                          Ảnh món ăn sẵn sàng
                        </span>
                      </div>
                    </div>
                    <div class="dish-preview-actions">
                      <div class="dish-preview-info">
                        <span class="dish-preview-filename" id="dishFileName">anh_mon_an.png</span>
                        <span class="dish-preview-meta" id="dishFileMeta">Đã lưu trong thư mục ảnh món ăn</span>
                      </div>
                      <div class="dish-preview-btns">
                        <button type="button" class="btn btn-outline" id="btnChangeDishImage" style="font-size:12px;padding:6px 12px;min-height:auto">
                          Thay đổi ảnh
                        </button>
                        <button type="button" class="btn btn-danger" id="btnRemoveDishImage" style="font-size:12px;padding:6px 12px;min-height:auto">
                          Xóa ảnh
                        </button>
                      </div>
                    </div>
                  </div>

                  <!-- Thanh gợi ý ảnh mẫu nhanh nếu không muốn tìm file -->
                  <div class="dish-preset-box">
                    <span class="dish-preset-label">Gợi ý ảnh mẫu:</span>
                    <button type="button" class="dish-preset-btn" data-preset="images/buffet/buffet-breakfast.png">
                      🍳 Buffet sáng
                    </button>
                    <button type="button" class="dish-preset-btn" data-preset="images/buffet/buffet-lunch.png">
                      🍛 Buffet trưa
                    </button>
                    <button type="button" class="dish-preset-btn" data-preset="images/buffet/buffet-dinner.png">
                      🥩 Buffet tối
                    </button>
                  </div>

                  <div id="dishUploadError" class="alert alert-error" style="display:none;margin-top:4px"></div>
                </div>
              </div>
            </div>
            <div style="display:flex;gap:10px;margin-top:20px">
              <a class="btn btn-outline" href="<%= request.getContextPath() %>/buffet?action=list">Hủy</a>
              <button class="btn btn-primary" type="submit" id="btnSubmitDish"><%= isEdit ? "Lưu thay đổi" : "Thêm món" %></button>
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
    const contextPath = '<%= request.getContextPath() %>';
    const imageUrlInput = document.getElementById('imageUrl');
    const fileInput = document.getElementById('dishFileInput');
    const dropzone = document.getElementById('dishDropzone');
    const previewCard = document.getElementById('dishPreviewCard');
    const previewImg = document.getElementById('dishPreviewImg');
    const previewTag = document.getElementById('dishPreviewTag');
    const fileNameSpan = document.getElementById('dishFileName');
    const fileMetaSpan = document.getElementById('dishFileMeta');
    const loader = document.getElementById('dishUploadLoader');
    const errorBox = document.getElementById('dishUploadError');
    const btnChange = document.getElementById('btnChangeDishImage');
    const btnRemove = document.getElementById('btnRemoveDishImage');
    const presetBtns = document.querySelectorAll('.dish-preset-btn');

    function showError(msg) {
      if (errorBox) {
        errorBox.textContent = msg;
        errorBox.style.display = 'block';
      }
    }

    function clearError() {
      if (errorBox) {
        errorBox.textContent = '';
        errorBox.style.display = 'none';
      }
    }

    function resolveSrc(url) {
      if (!url) return '';
      if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('data:')) {
        return url;
      }
      return contextPath + '/' + url.replace(/^\//, '');
    }

    function renderState() {
      const currentUrl = imageUrlInput.value.trim();
      if (currentUrl) {
        previewImg.src = resolveSrc(currentUrl);
        const namePart = currentUrl.split('/').pop() || 'Ảnh món ăn';
        fileNameSpan.textContent = decodeURIComponent(namePart);
        fileMetaSpan.textContent = 'Ảnh đã sẵn sàng lưu cùng món';
        dropzone.style.display = 'none';
        previewCard.style.display = 'block';
      } else {
        previewImg.removeAttribute('src');
        dropzone.style.display = 'flex';
        previewCard.style.display = 'none';
      }
    }

    function uploadFile(file) {
      if (!file) return;

      // Validate file type
      const validTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
      if (!validTypes.includes(file.type) && !file.name.match(/\.(jpg|jpeg|png|webp|gif)$/i)) {
        showError('Chỉ hỗ trợ file ảnh (JPG, PNG, WEBP, GIF).');
        return;
      }

      // Validate size (10MB max)
      if (file.size > 10 * 1024 * 1024) {
        showError('Dung lượng ảnh không được vượt quá 10MB.');
        return;
      }

      clearError();

      // Instant local preview
      const localUrl = URL.createObjectURL(file);
      previewImg.src = localUrl;
      fileNameSpan.textContent = file.name + ' (' + (file.size / 1024).toFixed(1) + ' KB)';
      fileMetaSpan.textContent = 'Đang tự động lưu lên máy chủ...';
      dropzone.style.display = 'none';
      previewCard.style.display = 'block';

      // Show loader
      if (loader) loader.style.display = 'flex';

      // Upload via AJAX
      const formData = new FormData();
      formData.append('imageFile', file);

      fetch(contextPath + '/buffet?action=upload-image', {
        method: 'POST',
        body: formData
      })
      .then(function (res) {
        return res.json();
      })
      .then(function (data) {
        if (loader) loader.style.display = 'none';
        if (data.success && data.imageUrl) {
          imageUrlInput.value = data.imageUrl;
          fileMetaSpan.textContent = 'Đã tải lên và lưu vào hệ thống thành công';
          previewTag.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg> Đã tải lên máy chủ';
        } else {
          showError(data.message || 'Không thể tải ảnh lên máy chủ. Vui lòng thử lại.');
          imageUrlInput.value = '';
          renderState();
        }
      })
      .catch(function (err) {
        if (loader) loader.style.display = 'none';
        // If AJAX upload failed, we still have the file in input for multipart submission fallback
        fileMetaSpan.textContent = 'Ảnh đã chọn (sẽ lưu khi nhấn nút Lưu/Thêm món)';
      });
    }

    // Click dropzone to open file dialog
    dropzone.addEventListener('click', function () {
      fileInput.click();
    });

    dropzone.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        fileInput.click();
      }
    });

    // File input change
    fileInput.addEventListener('change', function () {
      if (fileInput.files && fileInput.files[0]) {
        uploadFile(fileInput.files[0]);
      }
    });

    // Drag & Drop events
    ['dragenter', 'dragover'].forEach(function (eventName) {
      dropzone.addEventListener(eventName, function (e) {
        e.preventDefault();
        e.stopPropagation();
        dropzone.classList.add('is-dragover');
      });
    });

    ['dragleave', 'drop'].forEach(function (eventName) {
      dropzone.addEventListener(eventName, function (e) {
        e.preventDefault();
        e.stopPropagation();
        dropzone.classList.remove('is-dragover');
      });
    });

    dropzone.addEventListener('drop', function (e) {
      const dt = e.dataTransfer;
      if (dt && dt.files && dt.files.length > 0) {
        fileInput.files = dt.files;
        uploadFile(dt.files[0]);
      }
    });

    // Allow dropping directly onto the preview card as well
    ['dragenter', 'dragover'].forEach(function (eventName) {
      previewCard.addEventListener(eventName, function (e) {
        e.preventDefault();
        e.stopPropagation();
        previewCard.style.outline = '2px dashed var(--brand)';
      });
    });

    ['dragleave', 'drop'].forEach(function (eventName) {
      previewCard.addEventListener(eventName, function (e) {
        e.preventDefault();
        e.stopPropagation();
        previewCard.style.outline = 'none';
      });
    });

    previewCard.addEventListener('drop', function (e) {
      const dt = e.dataTransfer;
      if (dt && dt.files && dt.files.length > 0) {
        fileInput.files = dt.files;
        uploadFile(dt.files[0]);
      }
    });

    // Change button
    btnChange.addEventListener('click', function () {
      fileInput.click();
    });

    // Remove button
    btnRemove.addEventListener('click', function () {
      imageUrlInput.value = '';
      fileInput.value = '';
      clearError();
      renderState();
    });

    // Preset buttons
    presetBtns.forEach(function (btn) {
      btn.addEventListener('click', function () {
        const presetPath = btn.getAttribute('data-preset');
        if (presetPath) {
          imageUrlInput.value = presetPath;
          fileInput.value = '';
          clearError();
          renderState();
        }
      });
    });

    // Initial load
    renderState();
  })();
</script>
</body>
</html>
