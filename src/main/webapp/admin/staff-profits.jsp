<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Bill" %>
<%@ page import="com.hotel.model.BillDetail" %>
<%@ page import="com.hotel.dao.UserDAO" %>
<%@ page import="com.hotel.dao.BillDAO" %>
<%@ page import="com.hotel.dao.BillDetailDAO" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.NumberFormat" %>
<%!
  public static class StaffStatItem {
      public User user;
      public int billCount = 0;
      public double roomRevenue = 0;
      public double serviceRevenue = 0;
      public double totalRevenue = 0;
      public List<Bill> bills = new ArrayList<>();
  }
%>
<%
  HttpSession sess = request.getSession(false);
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
  if (currentUser == null || !"Admin".equalsIgnoreCase(currentUser.getRole())) {
    response.sendRedirect(request.getContextPath() + "/home");
    return;
  }
  String activeMenu = "staffProfits";

  UserDAO userDAO = new UserDAO();
  BillDAO billDAO = new BillDAO();
  BillDetailDAO billDetailDAO = new BillDetailDAO();

  List<User> allUsers = userDAO.getAllUsers();
  List<Bill> allBills = billDAO.getAllBills();

  String rangeParam = request.getParameter("range");
  String fromDateParam = request.getParameter("fromDate");
  String toDateParam = request.getParameter("toDate");

  LocalDate endDate = LocalDate.now();
  LocalDate startDate = endDate.minusDays(29); // Mặc định 30 ngày gần nhất
  boolean isAllTime = false;

  if ("today".equals(rangeParam)) {
      startDate = endDate;
  } else if ("7".equals(rangeParam)) {
      startDate = endDate.minusDays(6);
  } else if ("14".equals(rangeParam)) {
      startDate = endDate.minusDays(13);
  } else if ("30".equals(rangeParam)) {
      startDate = endDate.minusDays(29);
  } else if ("month".equals(rangeParam)) {
      startDate = endDate.withDayOfMonth(1);
  } else if ("all".equals(rangeParam)) {
      isAllTime = true;
      startDate = LocalDate.of(2020, 1, 1);
  }

  if (fromDateParam != null && !fromDateParam.trim().isEmpty()) {
      try {
          startDate = LocalDate.parse(fromDateParam.trim());
          isAllTime = false;
      } catch (Exception ignored) {}
  }
  if (toDateParam != null && !toDateParam.trim().isEmpty()) {
      try {
          endDate = LocalDate.parse(toDateParam.trim());
          isAllTime = false;
      } catch (Exception ignored) {}
  }

  if (endDate.isBefore(startDate)) {
      LocalDate temp = startDate;
      startDate = endDate;
      endDate = temp;
  }

  // Thu thập danh sách nhân viên (LOẠI BỎ Quản trị viên / Admin)
  Map<Integer, User> staffMap = new LinkedHashMap<>();
  if (allUsers != null) {
      for (User u : allUsers) {
          if (u != null && u.getRole() != null) {
              String r = u.getRole().trim().toLowerCase();
              if (!"admin".equals(r) && (r.contains("receptionist") || r.contains("staff") || r.contains("employee") || r.contains("nhân viên") || r.contains("lễ tân"))) {
                  staffMap.put(u.getId(), u);
              }
          }
      }
  }

  Map<Integer, StaffStatItem> statsMap = new LinkedHashMap<>();
  for (User u : staffMap.values()) {
      StaffStatItem item = new StaffStatItem();
      item.user = u;
      statsMap.put(u.getId(), item);
  }

  double grandTotalRevenue = 0;
  double grandRoomRevenue = 0;
  double grandServiceRevenue = 0;
  int grandTotalBills = 0;

  if (allBills != null) {
      for (Bill b : allBills) {
          if (b != null && "Paid".equalsIgnoreCase(b.getStatus())) {
              // Bỏ qua hóa đơn do Admin xử lý (Quản trị viên không tính là nhân viên và không xếp hạng doanh thu)
              if (b.getUser() != null && "Admin".equalsIgnoreCase(b.getUser().getRole())) {
                  continue;
              }

              java.time.LocalDate billDate = null;
              if (b.getCheckOutDate() != null) {
                  billDate = b.getCheckOutDate().toLocalDateTime().toLocalDate();
              } else if (b.getCreatedAt() != null) {
                  billDate = b.getCreatedAt().toLocalDateTime().toLocalDate();
              } else if (b.getCheckInDate() != null) {
                  billDate = b.getCheckInDate().toLocalDateTime().toLocalDate();
              }

              // Kiểm tra trong khoảng thời gian
              if (isAllTime || (billDate != null && !billDate.isBefore(startDate) && !billDate.isAfter(endDate))) {
                  double billRoom = 0;
                  double billService = 0;
                  List<BillDetail> details = billDetailDAO.getBillDetailsByBillId(b.getId());
                  if (details != null && !details.isEmpty()) {
                      for (BillDetail bd : details) {
                          if (bd.getRoom() != null) {
                              billRoom += (bd.getPrice() * bd.getQuantity()) * 1.08;
                          } else if (bd.getService() != null) {
                              billService += (bd.getPrice() * bd.getQuantity()) * 1.08;
                          }
                      }
                  } else {
                      billRoom = b.getTotalAmount();
                  }

                  double billTotal = billRoom + billService;
                  if (billTotal <= 0 && b.getTotalAmount() > 0) {
                      billTotal = b.getTotalAmount();
                      billRoom = billTotal;
                  }

                  int staffId = (b.getUser() != null) ? b.getUser().getId() : 0;
                  StaffStatItem staffItem = statsMap.get(staffId);
                  if (staffItem != null) {
                      staffItem.billCount++;
                      staffItem.roomRevenue += billRoom;
                      staffItem.serviceRevenue += billService;
                      staffItem.totalRevenue += billTotal;
                      staffItem.bills.add(b);

                      grandTotalRevenue += billTotal;
                      grandRoomRevenue += billRoom;
                      grandServiceRevenue += billService;
                      grandTotalBills++;
                  }
              }
          }
      }
  }

  // Gom toàn bộ danh sách thống kê nhân viên và sắp xếp giảm dần theo doanh thu
  List<StaffStatItem> statList = new ArrayList<>(statsMap.values());
  statList.sort((a, b) -> Double.compare(b.totalRevenue, a.totalRevenue));

  // Xác định Top Performer
  StaffStatItem topPerformer = !statList.isEmpty() && statList.get(0).totalRevenue > 0 ? statList.get(0) : null;
  int activeStaffCount = 0;
  for (StaffStatItem s : statList) {
      if (s.totalRevenue > 0 || s.billCount > 0) activeStaffCount++;
  }
  double avgRevenuePerStaff = activeStaffCount > 0 ? (grandTotalRevenue / activeStaffCount) : 0;

  NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi","VN"));
  DateTimeFormatter fullFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
  String dateRangeStr = isAllTime ? "Toàn bộ thời gian" : (startDate.format(fullFmt) + " - " + endDate.format(fullFmt));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Thống kê doanh thu nhân viên - Nestora</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
  <style>
    .staff-rank-badge {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 32px;
      height: 32px;
      border-radius: 50%;
      font-weight: 700;
      font-size: 14px;
    }
    .rank-1 { background: #fef3c7; color: #b45309; border: 2px solid #f59e0b; }
    .rank-2 { background: #f1f5f9; color: #475569; border: 2px solid #94a3b8; }
    .rank-3 { background: #ffedd5; color: #c2410c; border: 2px solid #ea580c; }
    .rank-other { background: #f8fafc; color: #64748b; border: 1px solid #cbd5e1; font-size: 12px; }

    .staff-avatar-box {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      background: linear-gradient(135deg, #1769e0, #0f172a);
      color: #ffffff;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 15px;
      box-shadow: 0 2px 6px rgba(23,105,224,0.25);
    }
    .progress-bar-wrap {
      width: 100%;
      height: 8px;
      background: #e2e8f0;
      border-radius: 999px;
      overflow: hidden;
      margin-top: 6px;
    }
    .progress-bar-fill {
      height: 100%;
      background: linear-gradient(90deg, #1769e0, #38bdf8);
      border-radius: 999px;
    }
    .chart-grid {
      display: grid;
      grid-template-columns: 1.5fr 1fr;
      gap: 20px;
      margin-bottom: 24px;
    }
    @media (max-width: 900px) {
      .chart-grid { grid-template-columns: 1fr; }
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
        
        <!-- Header trang -->
        <div class="page-head">
          <div>
            <div class="breadcrumb">Tài chính / Doanh thu nhân viên</div>
            <h1 class="page-title">Thống kê Doanh thu Nhân viên</h1>
            <p class="page-desc">Đánh giá hiệu suất kinh doanh, số lượng đơn xử lý và doanh thu theo từng nhân viên lễ tân/quản lý.</p>
          </div>
          <div class="page-actions">
            <button class="btn btn-outline" onclick="window.print()">🖨️ In Báo cáo PDF</button>
            <button class="btn btn-primary" onclick="exportStaffToExcel()">📊 Xuất Excel</button>
          </div>
        </div>

        <!-- Bộ lọc thời gian -->
        <form method="get" action="<%= request.getContextPath() %>/admin/staff-profits.jsp" style="display: flex; gap: 12px; align-items: center; flex-wrap: wrap; margin-bottom: 20px; background: var(--surface); padding: 16px 20px; border-radius: 12px; border: 1px solid var(--line);">
            <div style="display: flex; align-items: center; gap: 8px;">
                <label style="font-weight: 600; font-size: 13px; color: var(--text);">Từ ngày:</label>
                <input type="date" name="fromDate" value="<%= startDate %>" class="form-control" style="width: auto; padding: 6px 12px; height: 38px;">
            </div>
            <div style="display: flex; align-items: center; gap: 8px;">
                <label style="font-weight: 600; font-size: 13px; color: var(--text);">Đến ngày:</label>
                <input type="date" name="toDate" value="<%= endDate %>" class="form-control" style="width: auto; padding: 6px 12px; height: 38px;">
            </div>
            <button type="submit" class="btn btn-primary" style="height: 38px; padding: 0 18px;">🔍 Lọc dữ liệu</button>

            <div style="margin-left: auto; display: flex; gap: 6px; flex-wrap: wrap;">
                <a href="<%= request.getContextPath() %>/admin/staff-profits.jsp?range=today" class="btn btn-outline" style="height: 34px; padding: 0 12px; font-size: 12px; <%= "today".equals(rangeParam) ? "background: var(--brand); color: #fff;" : "" %>">Hôm nay</a>
                <a href="<%= request.getContextPath() %>/admin/staff-profits.jsp?range=7" class="btn btn-outline" style="height: 34px; padding: 0 12px; font-size: 12px; <%= "7".equals(rangeParam) ? "background: var(--brand); color: #fff;" : "" %>">7 ngày</a>
                <a href="<%= request.getContextPath() %>/admin/staff-profits.jsp?range=30" class="btn btn-outline" style="height: 34px; padding: 0 12px; font-size: 12px; <%= "30".equals(rangeParam) || (rangeParam == null && fromDateParam == null) ? "background: var(--brand); color: #fff;" : "" %>">30 ngày</a>
                <a href="<%= request.getContextPath() %>/admin/staff-profits.jsp?range=month" class="btn btn-outline" style="height: 34px; padding: 0 12px; font-size: 12px; <%= "month".equals(rangeParam) ? "background: var(--brand); color: #fff;" : "" %>">Tháng này</a>
                <a href="<%= request.getContextPath() %>/admin/staff-profits.jsp?range=all" class="btn btn-outline" style="height: 34px; padding: 0 12px; font-size: 12px; <%= "all".equals(rangeParam) ? "background: var(--brand); color: #fff;" : "" %>">Tất cả</a>
            </div>
        </form>

        <!-- Thẻ KPI tổng quan -->
        <div class="stat-grid">
          <div class="stat-card">
            <div class="stat-label">Tổng doanh thu nhân viên</div>
            <div class="stat-value"><%= money.format(grandTotalRevenue) %></div>
            <div class="stat-change">Kỳ: <%= dateRangeStr %> (Đã gồm 8% VAT)</div>
          </div>
          <div class="stat-card">
            <div class="stat-label">🏆 Nhân viên xuất sắc nhất</div>
            <div class="stat-value" style="font-size: 20px; color: #b45309;">
              <%= topPerformer != null ? topPerformer.user.getFullName() : "Chưa có" %>
            </div>
            <div class="stat-change">
              <%= topPerformer != null ? (money.format(topPerformer.totalRevenue) + " (" + topPerformer.billCount + " đơn)") : "0 ₫" %>
            </div>
          </div>
          <div class="stat-card">
            <div class="stat-label">Tổng hóa đơn đã thanh toán</div>
            <div class="stat-value"><%= grandTotalBills %> đơn</div>
            <div class="stat-change"><%= activeStaffCount %> nhân viên có phát sinh doanh thu</div>
          </div>
          <div class="stat-card">
            <div class="stat-label">Trung bình / Nhân viên</div>
            <div class="stat-value"><%= money.format(avgRevenuePerStaff) %></div>
            <div class="stat-change">Tính trên <%= activeStaffCount %> nhân viên hoạt động</div>
          </div>
        </div>

        <!-- Biểu đồ phân tích doanh thu nhân viên -->
        <div class="chart-grid">
          <section class="surface" style="padding: 20px;">
            <div class="surface-head" style="margin-bottom: 14px;">
              <div>
                <h2 class="surface-title">📊 Xếp hạng Doanh thu theo Nhân viên</h2>
                <p class="surface-subtitle">So sánh tổng doanh thu (Phòng + Dịch vụ) giữa các nhân viên</p>
              </div>
            </div>
            <div style="position: relative; height: 280px; width: 100%;">
              <canvas id="staffBarChart"></canvas>
            </div>
          </section>

          <section class="surface" style="padding: 20px;">
            <div class="surface-head" style="margin-bottom: 14px;">
              <div>
                <h2 class="surface-title">🍩 Tỷ trọng Đóng góp (% Doanh thu)</h2>
                <p class="surface-subtitle">Cơ cấu phần trăm doanh thu mang lại của từng nhân viên</p>
              </div>
            </div>
            <div style="position: relative; height: 280px; width: 100%;">
              <canvas id="staffPieChart"></canvas>
            </div>
          </section>
        </div>

        <!-- Bảng xếp hạng chi tiết nhân viên -->
        <section class="surface">
          <div class="surface-head">
            <div>
              <h2 class="surface-title">Bảng Xếp Hạng Hiệu Suất Kinh Doanh</h2>
              <p class="surface-subtitle">Dữ liệu chi tiết doanh số phòng, dịch vụ và tỷ lệ đóng góp của từng nhân viên</p>
            </div>
          </div>

          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th style="width: 70px; text-align: center;">Hạng</th>
                  <th>Nhân viên</th>
                  <th>Chức vụ</th>
                  <th style="text-align: center;">Số đơn hoàn tất</th>
                  <th style="text-align: right;">Doanh thu phòng</th>
                  <th style="text-align: right;">Doanh thu dịch vụ</th>
                  <th style="text-align: right;">Tổng doanh thu</th>
                  <th style="width: 180px;">Tỷ trọng đóng góp</th>
                </tr>
              </thead>
              <tbody>
                <%
                if (!statList.isEmpty()) {
                    int rank = 1;
                    for (StaffStatItem s : statList) {
                        double pct = (grandTotalRevenue > 0) ? (s.totalRevenue * 100.0 / grandTotalRevenue) : 0;
                        String rankClass = (rank == 1) ? "rank-1" : ((rank == 2) ? "rank-2" : ((rank == 3) ? "rank-3" : "rank-other"));
                        String rankIcon = (rank == 1) ? "🥇" : ((rank == 2) ? "🥈" : ((rank == 3) ? "🥉" : String.valueOf(rank)));
                        String initial = s.user.getFullName() != null && !s.user.getFullName().isEmpty() 
                                       ? s.user.getFullName().substring(0, 1).toUpperCase() : "U";
                        String roleName = "Admin".equalsIgnoreCase(s.user.getRole()) ? "Quản trị viên (Admin)" :
                                          ("Receptionist".equalsIgnoreCase(s.user.getRole()) ? "Nhân viên Lễ tân" :
                                          ("Manager".equalsIgnoreCase(s.user.getRole()) ? "Quản lý khách sạn" : s.user.getRole()));
                %>
                <tr>
                  <td style="text-align: center;">
                    <span class="staff-rank-badge <%= rankClass %>"><%= rankIcon %></span>
                  </td>
                  <td>
                    <div style="display: flex; align-items: center; gap: 12px;">
                      <div class="staff-avatar-box"><%= initial %></div>
                      <div>
                        <strong style="color: var(--text); font-size: 14px;"><%= s.user.getFullName() %></strong>
                        <div style="font-size: 12px; color: var(--muted);"><%= s.user.getEmail() != null ? s.user.getEmail() : "" %></div>
                      </div>
                    </div>
                  </td>
                  <td>
                    <span class="status <%= "Admin".equalsIgnoreCase(s.user.getRole()) ? "purple" : "info" %>"><%= roleName %></span>
                  </td>
                  <td style="text-align: center; font-weight: 600;">
                    <%= s.billCount %> đơn
                  </td>
                  <td style="text-align: right; color: var(--muted);">
                    <%= money.format(s.roomRevenue) %>
                  </td>
                  <td style="text-align: right; color: var(--muted);">
                    <%= money.format(s.serviceRevenue) %>
                  </td>
                  <td style="text-align: right;" class="table-strong">
                    <span style="color: var(--brand); font-size: 15px;"><%= money.format(s.totalRevenue) %></span>
                  </td>
                  <td>
                    <div style="display: flex; justify-content: space-between; font-size: 12px; font-weight: 600; color: var(--text);">
                      <span><%= String.format("%.1f", pct) %>%</span>
                      <span style="color: var(--muted);"><%= s.billCount %> GD</span>
                    </div>
                    <div class="progress-bar-wrap">
                      <div class="progress-bar-fill" style="width: <%= Math.min(100, Math.max(2, (int)Math.round(pct))) %>%;"></div>
                    </div>
                  </td>
                </tr>
                <%
                        rank++;
                    }
                } else {
                %>
                <tr>
                  <td colspan="8" class="empty">Không có dữ liệu nhân viên trong khoảng thời gian đã chọn.</td>
                </tr>
                <% } %>
              </tbody>
            </table>
          </div>
        </section>

      </div>
    </section>
  </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdn.jsdelivr.net/npm/xlsx-js-style@1.2.0/dist/xlsx.bundle.js"></script>

<script>
  // Dữ liệu Chart.js
  const staffNames = [
    <% for (int i = 0; i < statList.size(); i++) { %>
      '<%= statList.get(i).user.getFullName().replace("'", "\\'") %>'<%= (i < statList.size() - 1) ? "," : "" %>
    <% } %>
  ];
  const staffTotalRevs = [
    <% for (int i = 0; i < statList.size(); i++) { %>
      <%= statList.get(i).totalRevenue %><%= (i < statList.size() - 1) ? "," : "" %>
    <% } %>
  ];
  const staffRoomRevs = [
    <% for (int i = 0; i < statList.size(); i++) { %>
      <%= statList.get(i).roomRevenue %><%= (i < statList.size() - 1) ? "," : "" %>
    <% } %>
  ];
  const staffServRevs = [
    <% for (int i = 0; i < statList.size(); i++) { %>
      <%= statList.get(i).serviceRevenue %><%= (i < statList.size() - 1) ? "," : "" %>
    <% } %>
  ];

  const chartColors = [
    '#1769e0', '#0ea5e9', '#10b981', '#f59e0b', '#8b5cf6', '#ec4899', '#64748b', '#14b8a6', '#f97316'
  ];

  // 1. Biểu đồ Cột (Stacked Bar Chart)
  const ctxBar = document.getElementById('staffBarChart').getContext('2d');
  new Chart(ctxBar, {
      type: 'bar',
      data: {
          labels: staffNames,
          datasets: [
              {
                  label: 'Doanh thu phòng',
                  data: staffRoomRevs,
                  backgroundColor: '#1769e0',
                  borderRadius: 6
              },
              {
                  label: 'Doanh thu dịch vụ',
                  data: staffServRevs,
                  backgroundColor: '#38bdf8',
                  borderRadius: 6
              }
          ]
      },
      options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
              legend: { position: 'top' },
              tooltip: {
                  callbacks: {
                      label: function(context) {
                          return context.dataset.label + ': ' + new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(context.parsed.y);
                      }
                  }
              }
          },
          scales: {
              x: { stacked: true, grid: { display: false } },
              y: {
                  stacked: true,
                  beginAtZero: true,
                  ticks: {
                      callback: function(v) {
                          return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND', maximumSignificantDigits: 3 }).format(v);
                      }
                  }
              }
          }
      }
  });

  // 2. Biểu đồ Tròn (Doughnut Chart)
  const ctxPie = document.getElementById('staffPieChart').getContext('2d');
  new Chart(ctxPie, {
      type: 'doughnut',
      data: {
          labels: staffNames,
          datasets: [{
              data: staffTotalRevs,
              backgroundColor: chartColors.slice(0, staffNames.length),
              borderWidth: 2,
              borderColor: '#ffffff'
          }]
      },
      options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
              legend: { position: 'right', labels: { boxWidth: 14, font: { size: 11 } } },
              tooltip: {
                  callbacks: {
                      label: function(context) {
                          const val = context.parsed;
                          const total = staffTotalRevs.reduce((a, b) => a + b, 0);
                          const pct = total > 0 ? (val * 100 / total).toFixed(1) : 0;
                          return context.label + ': ' + new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val) + ' (' + pct + '%)';
                      }
                  }
              }
          },
          cutout: '60%'
      }
  });

  // 3. Hàm Xuất Excel Cao Cấp (xlsx-js-style)
  function exportStaffToExcel() {
      const thinBorder = {
          top: { style: 'thin', color: { rgb: 'CBD5E1' } },
          bottom: { style: 'thin', color: { rgb: 'CBD5E1' } },
          left: { style: 'thin', color: { rgb: 'CBD5E1' } },
          right: { style: 'thin', color: { rgb: 'CBD5E1' } }
      };

      const headerBorder = {
          top: { style: 'thin', color: { rgb: '475569' } },
          bottom: { style: 'medium', color: { rgb: '0F172A' } },
          left: { style: 'thin', color: { rgb: '475569' } },
          right: { style: 'thin', color: { rgb: '475569' } }
      };

      const totalBorder = {
          top: { style: 'thin', color: { rgb: 'B45309' } },
          bottom: { style: 'double', color: { rgb: '92400E' } },
          left: { style: 'thin', color: { rgb: 'CBD5E1' } },
          right: { style: 'thin', color: { rgb: 'CBD5E1' } }
      };

      const ws = {};
      const merges = [];
      const rowHeights = [];

      function setCell(r, c, v, t, z, s) {
          const ref = XLSX.utils.encode_cell({ r, c });
          const cell = { v: v, t: t || (typeof v === 'number' ? 'n' : 's') };
          if (z) cell.z = z;
          if (s) cell.s = s;
          ws[ref] = cell;
      }

      function mergeRange(r1, c1, r2, c2) {
          merges.push({ s: { r: r1, c: c1 }, e: { r: r2, c: c2 } });
      }

      const todayStr = new Date().toLocaleDateString('vi-VN');
      const numFmt = '#,##0 "₫"';
      const pctFmt = '0.0%';

      // ROW 0: TITLE
      mergeRange(0, 0, 0, 7);
      for (let c = 0; c <= 7; c++) {
          setCell(0, c, c === 0 ? 'KHÁCH SẠN NESTORA HOTEL & RESORT' : '', 's', null, {
              font: { name: 'Calibri', sz: 16, bold: true, color: { rgb: 'FFFFFF' } },
              fill: { fgColor: { rgb: '0F172A' } },
              alignment: { horizontal: 'center', vertical: 'center' }
          });
      }
      rowHeights[0] = { hpt: 32 };

      // ROW 1: SUBTITLE
      mergeRange(1, 0, 1, 7);
      for (let c = 0; c <= 7; c++) {
          setCell(1, c, c === 0 ? 'BÁO CÁO THỐNG KÊ DOANH THU THEO NHÂN VIÊN' : '', 's', null, {
              font: { name: 'Calibri', sz: 13, bold: true, color: { rgb: 'F8FAFC' } },
              fill: { fgColor: { rgb: '1E293B' } },
              alignment: { horizontal: 'center', vertical: 'center' }
          });
      }
      rowHeights[1] = { hpt: 24 };

      // ROW 2: SPACER
      rowHeights[2] = { hpt: 10 };

      // ROW 3: METADATA
      setCell(3, 0, 'Kỳ báo cáo:', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
          fill: { fgColor: { rgb: 'F1F5F9' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: thinBorder
      });
      mergeRange(3, 1, 3, 2);
      setCell(3, 1, '<%= dateRangeStr %>', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '1769E0' } },
          fill: { fgColor: { rgb: 'F8FAFC' } },
          alignment: { horizontal: 'left', vertical: 'center' },
          border: thinBorder
      });
      setCell(3, 2, '', 's', null, { border: thinBorder, fill: { fgColor: { rgb: 'F8FAFC' } } });

      setCell(3, 5, 'Ngày xuất file:', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
          fill: { fgColor: { rgb: 'F1F5F9' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: thinBorder
      });
      mergeRange(3, 6, 3, 7);
      setCell(3, 6, todayStr, 's', null, {
          font: { name: 'Calibri', sz: 10, color: { rgb: '334155' } },
          fill: { fgColor: { rgb: 'F8FAFC' } },
          alignment: { horizontal: 'left', vertical: 'center' },
          border: thinBorder
      });
      setCell(3, 7, '', 's', null, { border: thinBorder, fill: { fgColor: { rgb: 'F8FAFC' } } });
      rowHeights[3] = { hpt: 22 };

      // ROW 4: SPACER
      rowHeights[4] = { hpt: 10 };

      // ROW 5: HEADERS
      const headers = ['XẾP HẠNG', 'HỌ VÀ TÊN NHÂN VIÊN', 'CHỨC VỤ / VAI TRÒ', 'SỐ ĐƠN HOÀN TẤT', 'DOANH THU PHÒNG', 'DOANH THU DỊCH VỤ', 'TỔNG DOANH THU (VNĐ)', 'TỶ TRỌNG (%)'];
      for (let c = 0; c < headers.length; c++) {
          setCell(5, c, headers[c], 's', null, {
              font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: 'FFFFFF' } },
              fill: { fgColor: { rgb: '1E293B' } },
              alignment: { horizontal: 'center', vertical: 'center', wrapText: true },
              border: headerBorder
          });
      }
      rowHeights[5] = { hpt: 26 };

      // DATA ROWS
      const exportList = [
        <% for (int i = 0; i < statList.size(); i++) {
             StaffStatItem s = statList.get(i);
             double pct = (grandTotalRevenue > 0) ? (s.totalRevenue / grandTotalRevenue) : 0;
             String rName = "Admin".equalsIgnoreCase(s.user.getRole()) ? "Quản trị viên" :
                            ("Receptionist".equalsIgnoreCase(s.user.getRole()) ? "Nhân viên Lễ tân" :
                            ("Manager".equalsIgnoreCase(s.user.getRole()) ? "Quản lý" : s.user.getRole()));
        %>
          {
            rank: <%= (i + 1) %>,
            name: '<%= s.user.getFullName().replace("'", "\\'") %>',
            role: '<%= rName %>',
            bills: <%= s.billCount %>,
            roomRev: <%= s.roomRevenue %>,
            servRev: <%= s.serviceRevenue %>,
            totalRev: <%= s.totalRevenue %>,
            pct: <%= pct %>
          }<%= (i < statList.size() - 1) ? "," : "" %>
        <% } %>
      ];

      let curRow = 6;
      for (let i = 0; i < exportList.length; i++) {
          const item = exportList[i];
          const isEven = i % 2 === 0;
          const rowBg = isEven ? 'FFFFFF' : 'F8FAFC';

          setCell(curRow, 0, item.rank === 1 ? '🥇 Hạng 1' : (item.rank === 2 ? '🥈 Hạng 2' : (item.rank === 3 ? '🥉 Hạng 3' : 'Hạng ' + item.rank)), 's', null, {
              font: { name: 'Calibri', sz: 10, bold: item.rank <= 3, color: { rgb: item.rank === 1 ? 'B45309' : '0F172A' } },
              fill: { fgColor: { rgb: item.rank === 1 ? 'FEF3C7' : rowBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 1, item.name, 's', null, {
              font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'left', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 2, item.role, 's', null, {
              font: { name: 'Calibri', sz: 10, color: { rgb: '475569' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 3, item.bills, 'n', '#,##0 " đơn"', {
              font: { name: 'Calibri', sz: 10, color: { rgb: '0F172A' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 4, item.roomRev, 'n', numFmt, {
              font: { name: 'Calibri', sz: 10, color: { rgb: '334155' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'right', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 5, item.servRev, 'n', numFmt, {
              font: { name: 'Calibri', sz: 10, color: { rgb: '334155' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'right', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 6, item.totalRev, 'n', numFmt, {
              font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '1769E0' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'right', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 7, item.pct, 'n', pctFmt, {
              font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'right', vertical: 'center' },
              border: thinBorder
          });

          rowHeights[curRow] = { hpt: 22 };
          curRow++;
      }

      // TOTAL SUMMARY ROW
      mergeRange(curRow, 0, curRow, 2);
      setCell(curRow, 0, 'TỔNG CỘNG DOANH THU TOÀN BỘ NHÂN VIÊN:', 's', null, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '92400E' } },
          fill: { fgColor: { rgb: 'FEF3C7' } },
          alignment: { horizontal: 'center', vertical: 'center' },
          border: totalBorder
      });
      setCell(curRow, 1, '', 's', null, { border: totalBorder, fill: { fgColor: { rgb: 'FEF3C7' } } });
      setCell(curRow, 2, '', 's', null, { border: totalBorder, fill: { fgColor: { rgb: 'FEF3C7' } } });

      setCell(curRow, 3, <%= grandTotalBills %>, 'n', '#,##0 " đơn"', {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '92400E' } },
          fill: { fgColor: { rgb: 'FEF3C7' } },
          alignment: { horizontal: 'center', vertical: 'center' },
          border: totalBorder
      });

      setCell(curRow, 4, <%= grandRoomRevenue %>, 'n', numFmt, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '92400E' } },
          fill: { fgColor: { rgb: 'FEF3C7' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: totalBorder
      });

      setCell(curRow, 5, <%= grandServiceRevenue %>, 'n', numFmt, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '92400E' } },
          fill: { fgColor: { rgb: 'FEF3C7' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: totalBorder
      });

      setCell(curRow, 6, <%= grandTotalRevenue %>, 'n', numFmt, {
          font: { name: 'Calibri', sz: 12, bold: true, color: { rgb: '92400E' } },
          fill: { fgColor: { rgb: 'FDE68A' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: totalBorder
      });

      setCell(curRow, 7, 1.0, 'n', pctFmt, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '92400E' } },
          fill: { fgColor: { rgb: 'FEF3C7' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: totalBorder
      });
      rowHeights[curRow] = { hpt: 26 };
      curRow++;

      // SIGNATURE BLOCK
      curRow += 2;
      mergeRange(curRow, 0, curRow, 2);
      setCell(curRow, 0, 'NGƯỜI LẬP BÁO CÁO', 's', null, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '0F172A' } },
          alignment: { horizontal: 'center' }
      });
      mergeRange(curRow, 5, curRow, 7);
      setCell(curRow, 5, 'GIÁM ĐỐC ĐIỀU HÀNH / KẾ TOÁN TRƯỞNG', 's', null, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '0F172A' } },
          alignment: { horizontal: 'center' }
      });
      curRow++;

      mergeRange(curRow, 0, curRow, 2);
      setCell(curRow, 0, '(Ký và ghi rõ họ tên)', 's', null, {
          font: { name: 'Calibri', sz: 10, italic: true, color: { rgb: '64748B' } },
          alignment: { horizontal: 'center' }
      });
      mergeRange(curRow, 5, curRow, 7);
      setCell(curRow, 5, '(Ký, đóng dấu và ghi rõ họ tên)', 's', null, {
          font: { name: 'Calibri', sz: 10, italic: true, color: { rgb: '64748B' } },
          alignment: { horizontal: 'center' }
      });

      // Set sheet properties
      ws['!ref'] = XLSX.utils.encode_range({ s: { r: 0, c: 0 }, e: { r: curRow + 4, c: 7 } });
      ws['!merges'] = merges;
      ws['!rows'] = rowHeights;
      ws['!cols'] = [
          { wch: 14 }, // XẾP HẠNG
          { wch: 28 }, // TÊN NHÂN VIÊN
          { wch: 22 }, // CHỨC VỤ
          { wch: 18 }, // SỐ ĐƠN
          { wch: 20 }, // DT PHÒNG
          { wch: 20 }, // DT DỊCH VỤ
          { wch: 24 }, // TỔNG DT
          { wch: 16 }  // TỶ TRỌNG
      ];

      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, 'Doanh Thu Nhân Viên');
      XLSX.writeFile(wb, 'Bao_Cao_Doanh_Thu_Nhan_Vien_' + new Date().toISOString().slice(0, 10) + '.xlsx');
  }
</script>
</body>
</html>
