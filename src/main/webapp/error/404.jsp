<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>404 - Không tìm thấy trang | Nestora</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body class="client-body">
<%@ include file="../WEB-INF/jspf/client-header.jspf" %>
<main class="client-main">
  <div class="error-center" style="min-height:55vh">
    <div>
      <div class="error-icon">
        <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.8">
          <circle cx="12" cy="12" r="9"/><path d="M9.5 9a2.7 2.7 0 1 1 4.5 2c-1.1.8-2 1.2-2 3M12 18h.01"/>
        </svg>
      </div>
      <div class="error-code">404</div>
      <h1 class="error-title">Không tìm thấy trang</h1>
      <p class="error-text">Đường dẫn bạn truy cập không tồn tại hoặc đã được thay đổi.</p>
      <a class="btn btn-primary" href="<%= request.getContextPath() %>/home">Quay về trang chủ</a>
    </div>
  </div>
</main>
<%@ include file="../WEB-INF/jspf/client-footer.jspf" %>
</body>
</html>
