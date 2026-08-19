<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.dao.SystemSettingDAO" %>
<% 
  HttpSession sess=request.getSession(false); 
  User currentUser=sess!=null?(User)sess.getAttribute("currentUser"):null; 
  String activeMenu="checkout"; 
  SystemSettingDAO sysDAO = new SystemSettingDAO();
  String bankId = sysDAO.getBankId();
  String bankAccount = sysDAO.getBankAccount();
  String bankName = sysDAO.getBankName();
%>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Trả phòng & thanh toán - Nestora</title><link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
<style>
  #transfer-qr-container {
    display: none;
    margin-top: 18px;
    border: 1px dashed var(--brand);
    border-radius: 10px;
    padding: 18px;
    text-align: center;
    background: var(--brand-soft);
    animation: qrFadeIn 0.35s ease;
  }
  @keyframes qrFadeIn {
    from { opacity: 0; transform: translateY(8px); }
    to { opacity: 1; transform: translateY(0); }
  }
  .qr-wrapper {
    background: #fff;
    padding: 10px;
    border-radius: 8px;
    display: inline-block;
    box-shadow: 0 4px 12px rgba(23,105,224,0.08);
    margin-bottom: 12px;
  }
  .qr-bank-details {
    font-size: 12px;
    color: var(--navy);
    line-height: 1.5;
  }
  .qr-bank-details strong {
    color: var(--brand-dark);
  }
</style>
</head><body><div class="admin-layout"><%@ include file="../WEB-INF/jspf/admin-sidebar.jspf" %><main class="main-shell"><%@ include file="../WEB-INF/jspf/admin-topbar.jspf" %><section class="content"><div class="content-inner">
<div class="page-head"><div><div class="breadcrumb">Vận hành / Trả phòng</div><h1 class="page-title">Trả phòng</h1><p class="page-desc">Kiểm tra dịch vụ phát sinh và xác nhận thanh toán.</p></div></div><div class="checkout-grid"><section class="surface surface-pad"><h2 class="form-title">Phòng & khách lưu trú</h2><div class="checkout-room"><div class="checkout-line"><span>Phòng</span><strong>102 - Deluxe Twin</strong></div><div class="checkout-line"><span>Khách hàng</span><strong>Nguyễn Hoàng Anh</strong></div><div class="checkout-line"><span>Nhận phòng</span><strong>17/07/2026 · 14:00</strong></div><div class="checkout-line"><span>Trả phòng</span><strong>20/07/2026 · 12:00</strong></div></div><h2 class="form-title" style="margin-top:20px">Dịch vụ sử dụng</h2><div class="table-wrap"><table><thead><tr><th>DỊCH VỤ</th><th>SL</th><th>ĐƠN GIÁ</th><th>THÀNH TIỀN</th></tr></thead><tbody><tr><td>Buffet sáng</td><td>2</td><td>150.000 đ</td><td>300.000 đ</td></tr><tr><td>Giặt ủi</td><td>1</td><td>120.000 đ</td><td>120.000 đ</td></tr></tbody></table></div></section><aside class="surface surface-pad"><h2 class="form-title">Tổng thanh toán</h2><div class="checkout-line"><span>Tiền phòng (3 đêm)</span><strong>3.600.000 đ</strong></div><div class="checkout-line"><span>Dịch vụ</span><strong>420.000 đ</strong></div><div class="checkout-line"><span>Phụ thu</span><strong>0 đ</strong></div><div class="checkout-line"><span>Giảm giá</span><strong class="text-success">-120.000 đ</strong></div><div class="checkout-line"><span>Tổng cộng</span><strong class="checkout-total">3.900.000 đ</strong></div>
<div class="form-group" style="margin-top:18px"><label class="form-label">Phương thức thanh toán</label>
<select class="form-control" id="payment-method-select" onchange="handlePaymentMethodChange()">
<option value="cash">Tiền mặt</option>
<option value="transfer">Chuyển khoản</option>
<option value="card">Thẻ ngân hàng</option>
</select></div>
<div id="transfer-qr-container">
  <span class="form-label" style="color: var(--brand); font-weight: 700; margin-bottom: 10px; display: block;">MÃ QR THANH TOÁN (VIETQR)</span>
  <div class="qr-wrapper">
    <img id="vietqr-image" src="" alt="VietQR Payment Code" style="width: 180px; height: 180px; display: block; margin: 0 auto;" />
  </div>
  <div class="qr-bank-details">
    Ngân hàng: <strong><%= bankId %> Bank</strong><br>
    Số TK: <strong><%= bankAccount %></strong><br>
    Chủ TK: <strong><%= bankName %></strong>
  </div>
</div>
<div class="form-actions" style="margin-top:20px"><a class="btn btn-outline" href="bookings.jsp">Hủy</a><button class="btn btn-primary" type="button" onclick="confirmPayment()">Xác nhận thanh toán</button></div></aside></div>
</div></section></main></div>
<script>
  function handlePaymentMethodChange() {
      var select = document.getElementById('payment-method-select');
      var qrContainer = document.getElementById('transfer-qr-container');
      
      if (select.value === 'transfer') {
          // Get dynamic total amount from checkout page
          var totalText = document.querySelector('.checkout-total').innerText;
          var amount = totalText.replace(/[^0-9]/g, '');
          if (!amount) amount = '3900000'; // fallback
          
          var bankId = '<%= bankId %>';
          var accountNo = '<%= bankAccount %>';
          var accountName = '<%= bankName.replace("'", "\\'") %>';
          var template = 'qr_only'; 
          
          // Generate content with Room information
          var roomNo = '102';
          var addInfo = encodeURIComponent('Nestora P' + roomNo + ' Thanh toan');
          
          var qrUrl = 'https://img.vietqr.io/image/' + bankId + '-' + accountNo + '-' + template + '.png?amount=' + amount + '&addInfo=' + addInfo + '&accountName=' + encodeURIComponent(accountName);
          
          document.getElementById('vietqr-image').src = qrUrl;
          qrContainer.style.display = 'block';
      } else {
          qrContainer.style.display = 'none';
      }
  }
  
  function confirmPayment() {
      alert("Xác nhận thanh toán thành công! Trạng thái hóa đơn đã được cập nhật.");
      window.location.href = "<%= request.getContextPath() %>/bills?action=list";
  }
</script>
</body></html>