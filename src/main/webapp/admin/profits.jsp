<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.dao.BillDAO" %>
<%@ page import="com.hotel.dao.BillDetailDAO" %>
<%@ page import="com.hotel.model.Bill" %>
<%@ page import="com.hotel.model.BillDetail" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
  HttpSession sess = request.getSession(false);
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
  if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
    response.sendRedirect(request.getContextPath() + "/home");
    return;
  }
  String activeMenu = "profits";

  BillDAO billDAO = new BillDAO();
  BillDetailDAO billDetailDAO = new BillDetailDAO();

  List<Bill> allBills = billDAO.getAllBills();
  List<Bill> paidBills = new java.util.ArrayList<>();
  if (allBills != null) {
      for (Bill b : allBills) {
          if ("Paid".equals(b.getStatus())) {
              paidBills.add(b);
          }
      }
  }

  double totalRevenue = 0;
  double roomRevenue = 0;
  double serviceRevenue = 0;

  for (Bill b : paidBills) {
      totalRevenue += b.getTotalAmount();
      List<BillDetail> details = billDetailDAO.getBillDetailsByBillId(b.getId());
      if (details != null) {
          for (BillDetail bd : details) {
              if (bd.getRoom() != null) {
                  roomRevenue += bd.getPrice() * bd.getQuantity();
              } else if (bd.getService() != null) {
                  serviceRevenue += bd.getPrice() * bd.getQuantity();
              }
          }
      }
  }

  long daysCount = 30; // Mặc định 30 ngày
  if (!paidBills.isEmpty()) {
      Timestamp minTime = paidBills.get(paidBills.size() - 1).getCreatedAt();
      Timestamp maxTime = paidBills.get(0).getCreatedAt();
      if (minTime != null && maxTime != null) {
          long diffMs = maxTime.getTime() - minTime.getTime();
          long diffDays = diffMs / (1000 * 60 * 60 * 24) + 1;
          if (diffDays > 0) {
              daysCount = diffDays;
          }
      }
  }
  double averagePerDay = totalRevenue / daysCount;

  NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi","VN"));

  String dateRangeStr = "30 ngày gần đây";
  if (!paidBills.isEmpty()) {
      SimpleDateFormat dateFmt = new SimpleDateFormat("dd/MM/yyyy");
      dateRangeStr = dateFmt.format(paidBills.get(paidBills.size() - 1).getCreatedAt()) + " - " + dateFmt.format(paidBills.get(0).getCreatedAt());
  }

  // Thống kê doanh thu 14 ngày qua
  LocalDate today = LocalDate.now();
  double[] dailyRoom = new double[14];
  double[] dailyService = new double[14];
  String[] dailyLabels = new String[14];
  DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM");

  double maxDayRevenue = 100000; // Để chia tỉ lệ

  for (int i = 0; i < 14; i++) {
      LocalDate date = today.minusDays(13 - i);
      dailyLabels[i] = date.format(formatter);
      
      double dayRoomRev = 0;
      double dayServRev = 0;
      
      for (Bill b : paidBills) {
          LocalDate billDate = b.getCreatedAt().toLocalDateTime().toLocalDate();
          if (billDate.equals(date)) {
              List<BillDetail> details = billDetailDAO.getBillDetailsByBillId(b.getId());
              if (details != null) {
                  for (BillDetail bd : details) {
                      if (bd.getRoom() != null) {
                          dayRoomRev += bd.getPrice() * bd.getQuantity();
                      } else if (bd.getService() != null) {
                          dayServRev += bd.getPrice() * bd.getQuantity();
                      }
                  }
              }
          }
      }
      dailyRoom[i] = dayRoomRev;
      dailyService[i] = dayServRev;
      
      double dayTotal = dayRoomRev + dayServRev;
      if (dayTotal > maxDayRevenue) {
          maxDayRevenue = dayTotal;
      }
  }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Thống kê doanh thu - Nestora</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
  <style>
    .chart-container-box {
      display: flex;
      flex-direction: column;
      gap: 15px;
      padding: 10px 0;
    }
    .chart-labels-row {
      display: grid;
      grid-template-columns: repeat(14, 1fr);
      gap: 10px;
      text-align: center;
      font-size: 10px;
      color: var(--muted);
      font-weight: 500;
      border-top: 1px dashed var(--line);
      padding-top: 10px;
    }
    .chart-labels-row > div {
      text-overflow: ellipsis;
      overflow: hidden;
      white-space: nowrap;
    }
  </style>
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
            <div class="breadcrumb">Tài chính / Doanh thu</div>
            <h1 class="page-title">Thống kê doanh thu</h1>
            <p class="page-desc">Theo dõi doanh thu theo thời gian và nguồn thu.</p>
          </div>
          <div class="page-actions">
            <button class="btn btn-outline"><%= dateRangeStr %></button>
            <button class="btn btn-primary">Xuất Excel</button>
          </div>
        </div>

        <div class="stat-grid">
          <div class="stat-card">
            <div class="stat-label">Tổng doanh thu</div>
            <div class="stat-value"><%= money.format(totalRevenue) %></div>
            <div class="stat-change">Từ hóa đơn đã thanh toán</div>
          </div>
          <div class="stat-card">
            <div class="stat-label">Doanh thu phòng</div>
            <div class="stat-value"><%= money.format(roomRevenue) %></div>
            <div class="stat-change"><%= totalRevenue > 0 ? Math.round(roomRevenue * 100.0 / totalRevenue) : 0 %>% tổng doanh thu</div>
          </div>
          <div class="stat-card">
            <div class="stat-label">Doanh thu dịch vụ</div>
            <div class="stat-value"><%= money.format(serviceRevenue) %></div>
            <div class="stat-change"><%= totalRevenue > 0 ? Math.round(serviceRevenue * 100.0 / totalRevenue) : 0 %>% tổng doanh thu</div>
          </div>
          <div class="stat-card">
            <div class="stat-label">Trung bình / ngày</div>
            <div class="stat-value"><%= money.format(averagePerDay) %></div>
            <div class="stat-change"><%= daysCount %> ngày thống kê</div>
          </div>
        </div>

        <section class="surface">
          <div class="surface-head">
            <div>
              <h2 class="surface-title">Xu hướng doanh thu (14 ngày qua)</h2>
              <p class="surface-subtitle">Doanh thu phòng (xanh đậm) và dịch vụ (xanh nhạt) thực tế theo từng ngày</p>
            </div>
          </div>
          
          <div class="chart-container-box">
            <div class="chart-area" style="height:350px; grid-template-columns:repeat(14,1fr); gap:10px; display:grid;">
              <% for (int i = 0; i < 14; i++) { 
                  int roomHeight = (int) Math.round(dailyRoom[i] * 100.0 / maxDayRevenue);
                  int serviceHeight = (int) Math.round(dailyService[i] * 100.0 / maxDayRevenue);
              %>
                <div class="chart-col" title="Ngày <%= dailyLabels[i] %>: Phòng <%= money.format(dailyRoom[i]) %>, Dịch vụ <%= money.format(dailyService[i]) %>">
                  <div class="chart-bar primary" style="height:<%= roomHeight %>%" aria-label="Doanh thu phòng"></div>
                  <div class="chart-bar" style="height:<%= serviceHeight %>%" aria-label="Doanh thu dịch vụ"></div>
                </div>
              <% } %>
            </div>
            
            <div class="chart-labels-row">
              <% for (int i = 0; i < 14; i++) { %>
                <div><%= dailyLabels[i] %></div>
              <% } %>
            </div>
          </div>
        </section>
      </div>
    </section>
  </main>
</div>
<script src="<%=request.getContextPath()%>/js/app.js"></script>
</body>
</html>