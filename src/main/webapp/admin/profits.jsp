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
    @media print {
      .sidebar, .topbar, .page-actions, .breadcrumb, .btn {
        display: none !important;
      }
      .main-shell, .content, .content-inner {
        margin: 0 !important;
        padding: 0 !important;
        width: 100% !important;
      }
      .surface, .stat-card {
        box-shadow: none !important;
        border: 1px solid #cbd5e1 !important;
        break-inside: avoid;
      }
      body {
        background: #ffffff !important;
        color: #000000 !important;
      }
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
          <div class="page-actions" style="display: flex; gap: 10px; align-items: center;">
            <button class="btn btn-outline" type="button"><%= dateRangeStr %></button>
            <button class="btn btn-primary" type="button" onclick="exportProfitExcel()">
              <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 4px; vertical-align: middle;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>Xuất Excel
            </button>
            <button class="btn btn-outline" type="button" onclick="printProfitPDF()" style="border-color: var(--brand); color: var(--brand);">
              <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 4px; vertical-align: middle;"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>In Báo cáo PDF
            </button>
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
          
          <div style="position: relative; height: 350px; width: 100%; padding: 10px 0;">
              <canvas id="revenueChart"></canvas>
          </div>
        </section>

        <!-- Bảng thống kê doanh thu chi tiết -->
        <section class="surface" style="margin-top: 20px;">
          <div class="surface-head">
            <div>
              <h2 class="surface-title">Bảng chi tiết doanh thu 14 ngày qua</h2>
              <p class="surface-subtitle">Số liệu phân tích chi tiết cho báo cáo xuất Excel / PDF</p>
            </div>
          </div>
          <div class="table-wrap">
            <table id="profitReportTable">
              <thead>
                <tr>
                  <th>NGÀY</th>
                  <th>DOANH THU PHÒNG</th>
                  <th>DOANH THU DỊCH VỤ</th>
                  <th>TỔNG DOANH THU NGÀY</th>
                </tr>
              </thead>
              <tbody>
                <% for (int i = 0; i < 14; i++) { 
                     double dayTotal = dailyRoom[i] + dailyService[i];
                %>
                  <tr>
                    <td class="table-primary"><%= dailyLabels[i] %></td>
                    <td><%= money.format(dailyRoom[i]) %></td>
                    <td><%= money.format(dailyService[i]) %></td>
                    <td class="table-strong"><%= money.format(dayTotal) %></td>
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
<script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>
<script src="<%=request.getContextPath()%>/js/app.js"></script>
<script>
  (function() {
    const dailyLabels = [<%= String.join(",", java.util.Arrays.stream(dailyLabels).map(s -> "'" + s + "'").toArray(String[]::new)) %>];
    const dailyRoomData = [<%= java.util.Arrays.stream(dailyRoom).mapToObj(String::valueOf).collect(java.util.stream.Collectors.joining(",")) %>];
    const dailyServiceData = [<%= java.util.Arrays.stream(dailyService).mapToObj(String::valueOf).collect(java.util.stream.Collectors.joining(",")) %>];
    
    const ctx = document.getElementById('revenueChart').getContext('2d');
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: dailyLabels,
            datasets: [
                {
                    label: 'Doanh thu phòng',
                    data: dailyRoomData,
                    backgroundColor: '#0f172a',
                    borderColor: '#0f172a',
                    borderWidth: 1,
                    borderRadius: 4
                },
                {
                    label: 'Doanh thu dịch vụ',
                    data: dailyServiceData,
                    backgroundColor: '#c5a880',
                    borderColor: '#c5a880',
                    borderWidth: 1,
                    borderRadius: 4
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: {
                    stacked: true
                },
                y: {
                    stacked: true,
                    beginAtZero: true,
                    ticks: {
                        callback: function(value) {
                            return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND', maximumSignificantDigits: 3 }).format(value);
                        }
                    }
                }
            },
            plugins: {
                legend: {
                    position: 'top',
                    labels: {
                        font: {
                            family: 'Outfit, Inter, sans-serif',
                            weight: 'bold'
                        }
                    }
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            let label = context.dataset.label || '';
                            if (label) {
                                label += ': ';
                            }
                            if (context.parsed.y !== null) {
                                label += new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(context.parsed.y);
                            }
                            return label;
                        }
                    }
                }
            }
        }
    });
  })();

  function exportProfitExcel() {
    if (typeof XLSX === 'undefined') {
        alert('Thư viện xuất Excel đang được tải, vui lòng thử lại sau giây lát.');
        return;
    }
    const table = document.getElementById('profitReportTable');
    if (table) {
        const wb = XLSX.utils.table_to_book(table, { sheet: "Bao_Cao_Doanh_Thu" });
        XLSX.writeFile(wb, "Bao_Cao_Doanh_Thu_Nestora.xlsx");
    }
  }

  function printProfitPDF() {
    window.print();
  }
</script>
</body>
</html>