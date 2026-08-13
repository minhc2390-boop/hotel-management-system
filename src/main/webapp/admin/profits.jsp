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
          if ("Paid".equals(b.getStatus()) && b.getCreatedAt() != null) {
              paidBills.add(b);
          }
      }
  }

  String rangeParam = request.getParameter("range");
  String fromDateParam = request.getParameter("fromDate");
  String toDateParam = request.getParameter("toDate");

  LocalDate endDate = LocalDate.now();
  LocalDate startDate = endDate.minusDays(13); // Mặc định 14 ngày

  if ("7".equals(rangeParam)) {
      startDate = endDate.minusDays(6);
  } else if ("30".equals(rangeParam)) {
      startDate = endDate.minusDays(29);
  } else if ("month".equals(rangeParam)) {
      startDate = endDate.withDayOfMonth(1);
  }

  if (fromDateParam != null && !fromDateParam.trim().isEmpty()) {
      try {
          startDate = LocalDate.parse(fromDateParam.trim());
      } catch (Exception ignored) {}
  }
  if (toDateParam != null && !toDateParam.trim().isEmpty()) {
      try {
          endDate = LocalDate.parse(toDateParam.trim());
      } catch (Exception ignored) {}
  }

  if (endDate.isBefore(startDate)) {
      LocalDate temp = startDate;
      startDate = endDate;
      endDate = temp;
  }

  long totalDays = java.time.temporal.ChronoUnit.DAYS.between(startDate, endDate) + 1;
  if (totalDays <= 0) totalDays = 1;

  double[] dailyRoom = new double[(int) totalDays];
  double[] dailyService = new double[(int) totalDays];
  String[] dailyLabels = new String[(int) totalDays];
  DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM");
  DateTimeFormatter fullFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");

  double totalRevenue = 0;
  double roomRevenue = 0;
  double serviceRevenue = 0;

  for (int i = 0; i < totalDays; i++) {
      LocalDate date = startDate.plusDays(i);
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
      roomRevenue += dayRoomRev;
      serviceRevenue += dayServRev;
  }

  totalRevenue = roomRevenue + serviceRevenue;
  double averagePerDay = totalRevenue / totalDays;

  NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi","VN"));
  String dateRangeStr = startDate.format(fullFmt) + " - " + endDate.format(fullFmt);
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
            <button class="btn btn-outline" onclick="window.print()">🖨️ In Báo cáo PDF</button>
            <button class="btn btn-primary" onclick="exportToExcel()">📊 Xuất Excel</button>
          </div>
        </div>

        <form method="get" action="<%= request.getContextPath() %>/admin/profits.jsp" style="display: flex; gap: 12px; align-items: center; flex-wrap: wrap; margin-bottom: 20px; background: var(--surface); padding: 16px 20px; border-radius: 12px; border: 1px solid var(--line);">
            <div style="display: flex; align-items: center; gap: 8px;">
                <label style="font-weight: 600; font-size: 13px; color: var(--text);">Từ ngày:</label>
                <input type="date" name="fromDate" value="<%= startDate %>" class="form-control" style="width: auto; padding: 6px 12px; height: 38px;">
            </div>
            <div style="display: flex; align-items: center; gap: 8px;">
                <label style="font-weight: 600; font-size: 13px; color: var(--text);">Đến ngày:</label>
                <input type="date" name="toDate" value="<%= endDate %>" class="form-control" style="width: auto; padding: 6px 12px; height: 38px;">
            </div>
            <button type="submit" class="btn btn-primary" style="height: 38px; padding: 0 18px;">🔍 Lọc dữ liệu</button>

            <div style="margin-left: auto; display: flex; gap: 6px;">
                <a href="<%= request.getContextPath() %>/admin/profits.jsp?range=7" class="btn btn-outline" style="height: 34px; padding: 0 12px; font-size: 12px; <%= "7".equals(rangeParam) ? "background: var(--brand); color: #fff;" : "" %>">7 ngày gần nhất</a>
                <a href="<%= request.getContextPath() %>/admin/profits.jsp?range=14" class="btn btn-outline" style="height: 34px; padding: 0 12px; font-size: 12px; <%= "14".equals(rangeParam) || (rangeParam == null && fromDateParam == null) ? "background: var(--brand); color: #fff;" : "" %>">14 ngày gần nhất</a>
                <a href="<%= request.getContextPath() %>/admin/profits.jsp?range=30" class="btn btn-outline" style="height: 34px; padding: 0 12px; font-size: 12px; <%= "30".equals(rangeParam) ? "background: var(--brand); color: #fff;" : "" %>">30 ngày</a>
                <a href="<%= request.getContextPath() %>/admin/profits.jsp?range=month" class="btn btn-outline" style="height: 34px; padding: 0 12px; font-size: 12px; <%= "month".equals(rangeParam) ? "background: var(--brand); color: #fff;" : "" %>">Tháng này</a>
            </div>
        </form>

        <div class="stat-grid">
          <div class="stat-card">
            <div class="stat-label">Tổng doanh thu</div>
            <div class="stat-value"><%= money.format(totalRevenue) %></div>
            <div class="stat-change">Khoảng thời gian: <%= dateRangeStr %></div>
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
            <div class="stat-change"><%= totalDays %> ngày thống kê</div>
          </div>
        </div>

        <section class="surface">
          <div class="surface-head">
            <div>
              <h2 class="surface-title">Xu hướng doanh thu (<%= dateRangeStr %>)</h2>
              <p class="surface-subtitle">Doanh thu phòng (xanh đậm) và dịch vụ (vàng đồng) thực tế theo từng ngày trong kỳ</p>
            </div>
          </div>
          
          <div style="position: relative; height: 350px; width: 100%; padding: 10px 0;">
              <canvas id="revenueChart"></canvas>
          </div>
        </section>

        <section class="surface" style="margin-top: 20px;">
          <div class="surface-head">
            <div>
              <h2 class="surface-title">Bảng chi tiết doanh thu từng ngày</h2>
              <p class="surface-subtitle">Bảng kê doanh thu tiền phòng và dịch vụ phát sinh theo từng ngày trong kỳ chọn</p>
            </div>
          </div>
          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>STT</th>
                  <th>NGÀY THỐNG KÊ</th>
                  <th>DOANH THU PHÒNG</th>
                  <th>DOANH THU DỊCH VỤ</th>
                  <th>TỔNG DOANH THU / NGÀY</th>
                </tr>
              </thead>
              <tbody>
                <% for (int i = 0; i < totalDays; i++) {
                     double dayTotal = dailyRoom[i] + dailyService[i];
                %>
                <tr>
                  <td><%= i + 1 %></td>
                  <td class="table-strong"><%= dailyLabels[i] %></td>
                  <td><%= money.format(dailyRoom[i]) %></td>
                  <td><%= money.format(dailyService[i]) %></td>
                  <td class="table-strong text-primary"><%= money.format(dayTotal) %></td>
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
  const dailyLabels = [<%= String.join(",", java.util.Arrays.stream(dailyLabels).map(s -> "'" + s + "'").toArray(String[]::new)) %>];
  const dailyRoomData = [<%= java.util.Arrays.stream(dailyRoom).mapToObj(String::valueOf).collect(java.util.stream.Collectors.joining(",")) %>];
  const dailyServiceData = [<%= java.util.Arrays.stream(dailyService).mapToObj(String::valueOf).collect(java.util.stream.Collectors.joining(",")) %>];

  function exportToExcel() {
      const fmtMoney = (val) => new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
      const todayStr = new Date().toLocaleDateString('vi-VN');

      const data = [
          ["KHÁCH SẠN NESTORA HOTEL & RESORT"],
          ["BÁO CÁO THỐNG KÊ DOANH THU CHI TIẾT"],
          ["Kỳ báo cáo:", "<%= dateRangeStr %>"],
          ["Ngày xuất file:", todayStr],
          [],
          ["STT", "NGÀY THỐNG KÊ", "DOANH THU PHÒNG (VNĐ)", "DOANH THU DỊCH VỤ (VNĐ)", "TỔNG DOANH THU (VNĐ)"]
      ];

      for (let i = 0; i < dailyLabels.length; i++) {
          const roomRev = dailyRoomData[i];
          const servRev = dailyServiceData[i];
          const totalRev = roomRev + servRev;
          data.push([
              i + 1,
              dailyLabels[i],
              fmtMoney(roomRev),
              fmtMoney(servRev),
              fmtMoney(totalRev)
          ]);
      }

      data.push([]);
      data.push(["", "TỔNG CỘNG DOANH THU KỲ BÁO CÁO:", "", "", fmtMoney(<%= totalRevenue %>)]);
      data.push(["", "Trong đó - Doanh thu Phòng:", "", "", fmtMoney(<%= roomRevenue %>)]);
      data.push(["", "Trong đó - Doanh thu Dịch vụ:", "", "", fmtMoney(<%= serviceRevenue %>)]);
      data.push(["", "Doanh thu Trung bình / Ngày:", "", "", fmtMoney(<%= averagePerDay %>)]);

      const ws = XLSX.utils.aoa_to_sheet(data);

      // Cài đặt độ rộng cột tự động căn chỉnh đẹp mắt
      ws['!cols'] = [
          { wch: 8 },  // STT
          { wch: 20 }, // NGÀY THỐNG KÊ
          { wch: 28 }, // DOANH THU PHÒNG
          { wch: 28 }, // DOANH THU DỊCH VỤ
          { wch: 32 }  // TỔNG DOANH THU
      ];

      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, "Báo Cáo Doanh Thu");
      XLSX.writeFile(wb, "Bao_Cao_Doanh_Thu_Nestora.xlsx");
  }

  (function() {
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
                x: { stacked: true },
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
                        font: { family: 'Outfit, Inter, sans-serif', weight: 'bold' }
                    }
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            let label = context.dataset.label || '';
                            if (label) label += ': ';
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
</script>
</body>
</html>