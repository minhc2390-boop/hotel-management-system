<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
	language="java"%><%@ page import="com.hotel.model.User"%>
<%
HttpSession sess = request.getSession(false);
User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
String activeMenu = "bookings";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Đặt phòng - Nestora</title>
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
	<div class="admin-layout"><%@ include
			file="../WEB-INF/jspf/admin-sidebar.jspf"%><main
			class="main-shell"><%@ include
				file="../WEB-INF/jspf/admin-topbar.jspf"%><section
				class="content">
				<div class="content-inner">
					<div class="page-head">
						<div>
							<div class="breadcrumb">Vận hành / Đặt phòng</div>
							<h1 class="page-title">Danh sách đặt phòng</h1>
							<p class="page-desc">Theo dõi lịch đặt và trạng thái nhận
								phòng.</p>
						</div>
						<div class="page-actions">
							<a class="btn btn-primary" href="booking-form.jsp">＋ Tạo mới</a>
						</div>
					</div>
					<section class="surface">
						<div class="table-tools">
							<div class="search-box">
								<input type="search"
									placeholder="Tìm theo mã đặt phòng, khách hàng hoặc số phòng...">
								<svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
									stroke-width="2">
									<circle cx="11" cy="11" r="7" />
									<path d="M20 20l-3.5-3.5" /></svg>
							</div>
							<div class="table-meta">5 đặt phòng</div>
						</div>
						<div class="table-wrap">
							<table>
								<thead>
									<tr>
										<th>MÃ ĐẶT PHÒNG</th>
										<th>KHÁCH HÀNG</th>
										<th>PHÒNG</th>
										<th>NHẬN PHÒNG</th>
										<th>TRẢ PHÒNG</th>
										<th>TRẠNG THÁI</th>
										<th>THAO TÁC</th>
									</tr>
								</thead>
								<tbody>
									<tr>
										<td class="table-primary">#DP001</td>
										<td class="table-strong">Nguyễn Hoàng Anh</td>
										<td>P.102</td>
										<td>17/07/2026</td>
										<td>20/07/2026</td>
										<td><span class="status success">Đã nhận phòng</span></td>
										<td><div class="row-actions">
												<a class="btn btn-outline btn-icon" href="booking-form.jsp">✎</a><a
													class="btn btn-primary" href="payment.jsp">Trả phòng</a>
											</div></td>
									</tr>
									<tr>
										<td class="table-primary">#DP002</td>
										<td class="table-strong">Trần Minh Huy</td>
										<td>P.203</td>
										<td>18/07/2026</td>
										<td>19/07/2026</td>
										<td><span class="status info">Đã xác nhận</span></td>
										<td><div class="row-actions">
												<a class="btn btn-outline btn-icon" href="booking-form.jsp">✎</a>
												<button class="btn btn-primary">Nhận phòng</button>
											</div></td>
									</tr>
									<tr>
										<td class="table-primary">#DP003</td>
										<td class="table-strong">Lê Ngọc Anh</td>
										<td>P.301</td>
										<td>21/07/2026</td>
										<td>24/07/2026</td>
										<td><span class="status warning">Chờ xác nhận</span></td>
										<td><div class="row-actions">
												<a class="btn btn-outline btn-icon" href="booking-form.jsp">✎</a>
												<button class="btn btn-danger btn-icon">×</button>
											</div></td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="pagination">
							<span class="page-number active">1</span><span
								class="page-number">2</span>
						</div>
					</section>
				</div>
			</section>
		</main>
	</div>
	<script src="<%=request.getContextPath()%>/js/app.js"></script>
</body>
</html>