<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>403 - Không có quyền truy cập | Nestora</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body class="client-body">
<%@ include file="../WEB-INF/jspf/client-header.jspf" %>
<main class="client-main">
  <div class="error-center" style="min-height:55vh">
    <div>
      <div class="error-icon warning">
        <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.8">
          <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="M12 8v4M12 16h.01"/>
        </svg>
      </div>
      <div class="error-code">403</div>
      <h1 class="error-title">Bạn không có quyền truy cập</h1>
      <p class="error-text">Tài khoản hiện tại không được cấp quyền để xem nội dung này.</p>
      <a class="btn btn-primary" href="<%= request.getContextPath() %>/home">Quay về trang chủ</a>
    </div>
  </div>
</main>
<%@ include file="../WEB-INF/jspf/client-footer.jspf" %>
</body>
</html>
