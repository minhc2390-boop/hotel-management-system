<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java"%>
<%@ page import="com.hotel.model.User"%>
<%@ page import="com.hotel.model.Room"%>
<%@ page import="java.util.List"%>
<%
HttpSession sess = request.getSession(false);
User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
String activeMenu = "bookings";

// Lấy danh sách Khách hàng từ Servlet
List<User> userList = (List<User>) request.getAttribute("userList");
if (userList == null) {
    userList = (List<User>) request.getAttribute("users");
}

// Lấy danh sách Phòng trống từ Servlet
List<Room> roomList = (List<Room>) request.getAttribute("rooms");
if (roomList == null) {
    roomList = (List<Room>) request.getAttribute("availableRooms");
}
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Tạo phiếu đặt phòng - Nestora</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
	<div class="admin-layout">
		<%@ include file="/WEB-INF/jspf/admin-sidebar.jspf"%>
		<main class="main-shell">
			<%@ include file="/WEB-INF/jspf/admin-topbar.jspf"%>
			<section class="content">
				<div class="content-inner">
					<div class="page-head">
						<div>
							<div class="breadcrumb">Vận hành / Đặt phòng / Tạo mới</div>
							<h1 class="page-title">Tạo phiếu đặt phòng</h1>
							<p class="page-desc">Tìm kiếm khách hàng cũ, phòng trống và thời gian lưu trú.</p>
						</div>
					</div>
					<section class="surface surface-pad form-surface">
						<h2 class="form-title">Thông tin đặt phòng</h2>
						
						<form action="<%=request.getContextPath()%>/bookings" method="post" onsubmit="return validateBookingForm();">
							<input type="hidden" name="action" value="create">
							
							<!-- Hidden field lưu ID khách hàng thực tế gửi về Servlet -->
							<input type="hidden" name="userId" id="userIdHidden" value="">

							<div class="form-grid">
								
								<!-- 1. Ô NHẬP TÌM KHÁCH HÀNG (DATALIST ĐỀ XUẤT) -->
								<div class="form-group">
									<label class="form-label" for="customerSearch">Tìm / Chọn Khách hàng <span style="color:red">*</span></label>
									<input class="form-control" type="text" id="customerSearch" list="userDatalist" 
										   placeholder="Gõ tên hoặc SĐT để tìm..." autocomplete="off" required oninput="onCustomerSelect()">
									
									<datalist id="userDatalist">
										<% 
										if (userList != null && !userList.isEmpty()) { 
											for (User u : userList) { 
												String phone = (u.getPhone() != null) ? u.getPhone().trim() : "";
												String nameDisplay = (u.getFullName() != null && !u.getFullName().trim().isEmpty()) ? u.getFullName() : u.getUsername();
										%>
												<!-- Format value hiển thị để dễ tìm kiếm -->
												<option data-id="<%=u.getId()%>" data-phone="<%=phone%>" value="<%=nameDisplay%> - SĐT: <%=phone%> [ID: <%=u.getId()%>]">
										<% 
											} 
										} 
										%>
									</datalist>
								</div>

								<!-- 2. Ô SỐ ĐIỆN THOẠI (BỔ SUNG THEO YÊU CẦU SẾP) -->
								<div class="form-group">
									<label class="form-label" for="customerPhone">Số điện thoại <span style="color:red">*</span></label>
									<input class="form-control" type="tel" id="customerPhone" name="phone" placeholder="Số điện thoại liên hệ" required>
								</div>

								<!-- 3. CHỌN PHÒNG TRỐNG -->
								<div class="form-group">
									<label class="form-label" for="roomId">Phòng trống <span style="color:red">*</span></label>
									<select class="form-control" name="roomId" id="roomId" required>
										<option value="">-- Chọn phòng trống --</option>
										<% 
										if (roomList != null && !roomList.isEmpty()) { 
											for (Room r : roomList) { 
												String typeName = (r.getRoomType() != null && r.getRoomType().getName() != null) 
																  ? " - " + r.getRoomType().getName() : "";
										%>
												<option value="<%=r.getId()%>">
													Phòng <%=r.getRoomNumber()%><%=typeName%>
												</option>
										<% 
											} 
										} else { 
										%>
											<option value="" disabled>Hiện không có phòng nào đang trống</option>
										<% } %>
									</select>
								</div>

								<div class="form-group">
									<label class="form-label" for="checkInDate">Ngày nhận phòng <span style="color:red">*</span></label>
									<input class="form-control" type="date" id="checkInDate" name="checkInDate" required>
								</div>

								<div class="form-group">
									<label class="form-label" for="checkOutDate">Ngày trả phòng <span style="color:red">*</span></label>
									<input class="form-control" type="date" id="checkOutDate" name="checkOutDate" required>
								</div>

								<div class="form-group">
									<label class="form-label" for="numGuests">Số người</label>
									<input class="form-control" type="number" id="numGuests" name="numGuests" min="1" value="1">
								</div>

								<div class="form-group">
									<label class="form-label" for="deposit">Tiền đặt cọc (VNĐ)</label>
									<input class="form-control" type="number" id="deposit" name="deposit" placeholder="0" min="0">
								</div>

								<div class="form-group full">
									<label class="form-label" for="note">Ghi chú</label>
									<textarea class="form-control" id="note" name="note" placeholder="Yêu cầu đặc biệt của khách"></textarea>
								</div>
							</div>

							<div class="form-actions">
								<a class="btn btn-outline" href="<%=request.getContextPath()%>/bookings">Hủy</a>
								<button class="btn btn-primary" type="submit">Lưu đặt phòng</button>
							</div>
						</form>
					</section>
				</div>
			</section>
		</main>
	</div>

	<!-- SCRIPT TỰ ĐỘNG KHỚP DỮ LIỆU TÌM KIẾM -->
	<script>
		function onCustomerSelect() {
			var val = document.getElementById("customerSearch").value;
			var options = document.querySelectorAll("#userDatalist option");
			var userIdInput = document.getElementById("userIdHidden");
			var phoneInput = document.getElementById("customerPhone");

			userIdInput.value = ""; // Clear nếu không khớp

			for (var i = 0; i < options.length; i++) {
				if (options[i].value === val) {
					// Nếu chọn đúng item gợi ý
					userIdInput.value = options[i].getAttribute("data-id");
					phoneInput.value = options[i].getAttribute("data-phone");
					break;
				}
			}
		}

		function validateBookingForm() {
			var userId = document.getElementById("userIdHidden").value;
			if (!userId) {
				alert("Vui lòng chọn một khách hàng hợp lệ từ danh sách gợi ý!");
				document.getElementById("customerSearch").focus();
				return false;
			}
			return true;
		}
	</script>
	<script src="<%=request.getContextPath()%>/js/app.js"></script>
</body>
</html>