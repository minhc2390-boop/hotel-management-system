<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Customer" %>
<%@ page import="com.hotel.model.Bill" %>
<%@ page import="com.hotel.model.BillDetail" %>
<%@ page import="com.hotel.model.Service" %>
<%@ page import="com.hotel.model.Laundry" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%
HttpSession sess = request.getSession(false);
User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
Bill bill = (Bill) request.getAttribute("bill");
List<BillDetail> details = (List<BillDetail>) request.getAttribute("details");
List<Service> services = (List<Service>) request.getAttribute("services");
<<<<<<< HEAD
String reqBankId = (String) request.getAttribute("bankId");
String reqBankAccount = (String) request.getAttribute("bankAccount");
String reqBankName = (String) request.getAttribute("bankName");
if (reqBankId == null || reqBankId.isEmpty()) reqBankId = "MB";
if (reqBankAccount == null || reqBankAccount.isEmpty()) reqBankAccount = "1903567890123";
if (reqBankName == null || reqBankName.isEmpty()) reqBankName = "CONG TY NESTORA HOTEL";
=======
List<Laundry> laundryList = (List<Laundry>) request.getAttribute("laundryList");
String bankId = (String) request.getAttribute("bankId");
String bankAccount = (String) request.getAttribute("bankAccount");
String bankName = (String) request.getAttribute("bankName");

if (bankId == null || bankId.trim().isEmpty()) bankId = "MB";
if (bankAccount == null || bankAccount.trim().isEmpty()) bankAccount = "1903567890123";
if (bankName == null || bankName.trim().isEmpty()) bankName = "CONG TY NESTORA HOTEL";

>>>>>>> 06d2f05fb617ae75d9425627b09472113407a437
if (currentUser == null || bill == null) {
	response.sendRedirect(request.getContextPath() + "/login");
	return;
}
boolean admin = "Admin".equals(currentUser.getRole()) || "Receptionist".equals(currentUser.getRole());
NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
SimpleDateFormat dt = new SimpleDateFormat("dd/MM/yyyy HH:mm"), d = new SimpleDateFormat("dd/MM/yyyy");

String roomNumber = "";
if (details != null) {
    for (BillDetail bd : details) {
        if (bd.getRoomId() != null && bd.getRoom() != null) {
            roomNumber = bd.getRoom().getRoomNumber();
            break;
        }
    }
}
if (roomNumber.isEmpty()) {
    roomNumber = "HD" + bill.getId();
}
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Chi tiết hóa đơn - Nestora</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
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
</head>
<body class="client-body">
	<%@ include file="WEB-INF/jspf/client-header.jspf" %>
	<main class="client-main">
		<div class="page-head">
			<div>
				<div class="breadcrumb">Hóa đơn / #<%=bill.getId()%></div>
				<h1 class="page-title">Chi tiết hóa đơn #<%=bill.getId()%></h1>
				<p class="page-desc">Thông tin phòng, dịch vụ đi kèm &amp; dịch vụ giặt ủi.</p>
			</div>
		</div>
		<div class="checkout-grid">
			<div>
				<section class="surface">
					<div class="surface-head">
						<div>
							<h2 class="surface-title">Hạng mục thanh toán</h2>
						</div>
					</div>
					<div class="table-wrap">
						<table>
							<thead>
								<tr>
									<th>HẠNG MỤC</th>
									<th>ĐƠN GIÁ</th>
									<th>SỐ LƯỢNG</th>
									<th>THÀNH TIỀN</th>
								</tr>
							</thead>
							<tbody>
								<%
								if (details != null) {
									for (BillDetail bd : details) {
										double total = bd.getPrice() * bd.getQuantity();
								%><tr>
									<td class="table-strong">
										<% if (bd.getRoomId() != null) { %>
											Phòng <%= bd.getRoom() != null ? bd.getRoom().getRoomNumber() : bd.getRoomId() %> (Tiền phòng)
										<% } else if (bd.getServiceId() != null) { %>
											Dịch vụ: <%= bd.getService() != null ? bd.getService().getName() : bd.getServiceId() %>
										<% } else { %>
											Hạng mục khác
										<% } %>
									</td>
									<td><%=money.format(bd.getPrice())%></td>
									<td><%=bd.getQuantity()%></td>
									<td class="table-strong"><%=money.format(total)%></td>
								</tr>
								<%
									}
								}
								if (laundryList != null && !laundryList.isEmpty()) {
									for (Laundry l : laundryList) {
								%>
								<tr>
									<td class="table-strong">
										Giặt ủi: <%= l.getServiceType() %> (<%= l.getProcessingStatus() %>)
									</td>
									<td><%= money.format(l.getTotalPrice() / Math.max(1, l.getQuantity())) %></td>
									<td><%= l.getQuantity() %></td>
									<td class="table-strong"><%= money.format(l.getTotalPrice()) %></td>
								</tr>
								<%
									}
								}
								%>
							</tbody>
						</table>
					</div>
					<div class="surface-pad text-right">
						<span class="checkout-total">Tổng tiền: <%=money.format(bill.getTotalAmount())%></span>
					</div>
				</section>
				<%
				if ("Unpaid".equals(bill.getStatus())) {
				%><section class="surface surface-pad" style="margin-top: 16px">
					<h2 class="form-title">Gọi thêm dịch vụ</h2>
					<form action="<%=request.getContextPath()%>/bills" method="post">
						<input type="hidden" name="action" value="addService">
						<input type="hidden" name="billId" value="<%=bill.getId()%>">
						<div class="form-grid">
							<div class="form-group">
								<label class="form-label" for="serviceId">Dịch vụ</label>
								<select class="form-control" id="serviceId" name="serviceId" required>
									<option value="">Chọn dịch vụ</option>
									<%
									if (services != null) {
										for (Service s : services) {
									%><option value="<%=s.getId()%>"><%=s.getName()%> · <%=money.format(s.getPrice())%></option>
									<%
										}
									}
									%>
								</select>
							</div>
							<div class="form-group">
								<label class="form-label" for="quantity">Số lượng</label>
								<input class="form-control" type="number" min="1" value="1" id="quantity" name="quantity" required>
							</div>
						</div>
						<div class="form-actions">
							<button class="btn btn-primary" type="submit">Thêm dịch vụ</button>
						</div>
					</form>
				</section>
				<%
				}
				%>
			</div>
			<aside class="surface surface-pad">
				<h2 class="form-title">Thông tin chung</h2>
				<div class="checkout-line">
					<span>Trạng thái</span>
					<strong>
						<% if ("Paid".equals(bill.getStatus())) { %>
							<span class="status success">Đã thanh toán</span>
						<% } else if ("Unpaid".equals(bill.getStatus())) { %>
							<span class="status info">Chưa thanh toán</span>
						<% } else { %>
							<span class="status danger">Đã hủy</span>
						<% } %>
					</strong>
				</div>
				<div class="checkout-line">
					<span>Ngày tạo</span><strong><%=bill.getCreatedAt() != null ? dt.format(bill.getCreatedAt()) : ""%></strong>
				</div>
				<div class="checkout-line">
					<span>Nhận phòng</span><strong><%=bill.getCheckInDate() != null ? d.format(bill.getCheckInDate()) : ""%></strong>
				</div>
				<div class="checkout-line">
					<span>Trả phòng</span><strong><%=bill.getCheckOutDate() != null ? d.format(bill.getCheckOutDate()) : ""%></strong>
				</div>
				<h2 class="form-title" style="margin-top: 22px">Khách hàng</h2>
				<div class="checkout-line">
					<span>Họ tên</span><strong><%=bill.getCustomer() != null ? bill.getCustomer().getCustomerName() : (bill.getUser() != null ? bill.getUser().getFullName() : "N/A")%></strong>
				</div>
				<div class="checkout-line">
					<span>Email</span><strong><%=bill.getCustomer() != null && bill.getCustomer().getCustomerEmail() != null ? bill.getCustomer().getCustomerEmail() : (bill.getUser() != null && bill.getUser().getEmail() != null ? bill.getUser().getEmail() : "N/A")%></strong>
				</div>
				<div class="checkout-line">
					<span>Điện thoại</span><strong><%=bill.getCustomer() != null && bill.getCustomer().getCustomerPhone() != null ? bill.getCustomer().getCustomerPhone() : (bill.getUser() != null && bill.getUser().getPhone() != null ? bill.getUser().getPhone() : "Chưa có")%></strong>
				</div>
				<%
				if ("Unpaid".equals(bill.getStatus())) {
				%>
				<div class="form-group" style="margin-top:18px">
					<label class="form-label" style="font-weight: 600; margin-bottom: 6px; display: block;">Phương thức thanh toán</label>
					<select class="form-control" id="payment-method-select" onchange="handlePaymentMethodChange()">
						<option value="cash">Tiền mặt</option>
						<option value="transfer">Chuyển khoản (VietQR)</option>
						<option value="card">Thẻ ngân hàng</option>
					</select>
				</div>
				<div id="transfer-qr-container">
					<span class="form-label" style="color: var(--brand); font-weight: 700; margin-bottom: 10px; display: block;">MÃ QR THANH TOÁN (VIETQR)</span>
					<div class="qr-wrapper">
						<img id="vietqr-image" src="" alt="VietQR Payment Code" style="width: 180px; height: 180px; display: block; margin: 0 auto;" />
					</div>
					<div class="qr-bank-details">
						Ngân hàng: <strong id="display-bank-id"><%= bankId %></strong><br>
						Số TK: <strong id="display-account-no"><%= bankAccount %></strong><br>
						Chủ TK: <strong id="display-account-name"><%= bankName %></strong>
					</div>
				</div>
				<%
				}
				%>
				<div style="display: grid; gap: 8px; margin-top: 18px">
					<%
					if ("Unpaid".equals(bill.getStatus()) && admin) {
					%><a class="btn btn-success" href="<%=request.getContextPath()%>/bills?action=pay&id=<%=bill.getId()%>">Xác nhận thanh toán</a>
					<%
					}
					%>
					<%
					if ("Unpaid".equals(bill.getStatus())) {
					%><a class="btn btn-danger" href="<%=request.getContextPath()%>/bills?action=cancel&id=<%=bill.getId()%>" onclick="return confirm('Hủy đơn này?')">Hủy đơn</a>
					<%
					}
					%><a class="btn btn-outline" href="<%=request.getContextPath()%>/<%=admin ? "bills?action=list" : "bills?action=mybills"%>">Quay lại</a>
				</div>
			</aside>
		</div>
	</main>
	<%@ include file="WEB-INF/jspf/client-footer.jspf" %>
	<script>
	  function handlePaymentMethodChange() {
	      var select = document.getElementById('payment-method-select');
	      var qrContainer = document.getElementById('transfer-qr-container');
	      if (!select || !qrContainer) return;
	      
	      if (select.value === 'transfer') {
	          var amount = '<%= (long)bill.getTotalAmount() %>';
<<<<<<< HEAD
	          var bankId = '<%= reqBankId %>';
	          var accountNo = '<%= reqBankAccount %>';
	          var accountName = '<%= reqBankName %>';
=======
	          var bankId = '<%= bankId %>';
	          var accountNo = '<%= bankAccount %>';
	          var accountName = '<%= bankName %>';
>>>>>>> 06d2f05fb617ae75d9425627b09472113407a437
	          
	          document.getElementById('display-bank-id').innerText = bankId;
	          document.getElementById('display-account-no').innerText = accountNo;
	          document.getElementById('display-account-name').innerText = accountName;
	          
	          var template = 'qr_only'; 
	          var roomNo = '<%= roomNumber %>';
	          var addInfo = encodeURIComponent('Hotel P' + roomNo + ' HD' + '<%= bill.getId() %>');
	          
	          var qrUrl = 'https://img.vietqr.io/image/' + bankId + '-' + accountNo + '-' + template + '.png?amount=' + amount + '&addInfo=' + addInfo + '&accountName=' + encodeURIComponent(accountName);
	          
	          document.getElementById('vietqr-image').src = qrUrl;
	          qrContainer.style.display = 'block';
	      } else {
	          qrContainer.style.display = 'none';
	      }
	  }
	</script>
</body>
</html>
