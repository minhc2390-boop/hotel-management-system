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
  if (currentUser == null || !"Admin".equalsIgnoreCase(currentUser.getRole())) {
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
          if (b != null && "Paid".equalsIgnoreCase(b.getStatus())) {
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
          java.time.LocalDate billDate = null;
          if (b.getCheckOutDate() != null) {
              billDate = b.getCheckOutDate().toLocalDateTime().toLocalDate();
          } else if (b.getCreatedAt() != null) {
              billDate = b.getCreatedAt().toLocalDateTime().toLocalDate();
          } else if (b.getCheckInDate() != null) {
              billDate = b.getCheckInDate().toLocalDateTime().toLocalDate();
          }

          if (billDate != null && billDate.equals(date)) {
              List<BillDetail> details = billDetailDAO.getBillDetailsByBillId(b.getId());
              if (details != null && !details.isEmpty()) {
                  for (BillDetail bd : details) {
                      if (bd.getRoom() != null) {
                          dayRoomRev += (bd.getPrice() * bd.getQuantity()) * 1.08;
                      } else if (bd.getService() != null) {
                          dayServRev += (bd.getPrice() * bd.getQuantity()) * 1.08;
                      }
                  }
              } else {
                  dayRoomRev += b.getTotalAmount();
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
<script src="https://cdn.jsdelivr.net/npm/xlsx-js-style@1.2.0/dist/xlsx.bundle.js"></script>
<script src="<%=request.getContextPath()%>/js/app.js"></script>
<script>
  const dailyLabels = [<%= String.join(",", java.util.Arrays.stream(dailyLabels).map(s -> "'" + s + "'").toArray(String[]::new)) %>];
  const dailyRoomData = [<%= java.util.Arrays.stream(dailyRoom).mapToObj(String::valueOf).collect(java.util.stream.Collectors.joining(",")) %>];
  const dailyServiceData = [<%= java.util.Arrays.stream(dailyService).mapToObj(String::valueOf).collect(java.util.stream.Collectors.joining(",")) %>];

  function exportToExcel() {
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

      // --- ROW 0: TITLE BANNER ---
      mergeRange(0, 0, 0, 4);
      for (let c = 0; c <= 4; c++) {
          setCell(0, c, c === 0 ? 'KHÁCH SẠN NESTORA HOTEL & RESORT' : '', 's', null, {
              font: { name: 'Calibri', sz: 16, bold: true, color: { rgb: 'FFFFFF' } },
              fill: { fgColor: { rgb: '0F172A' } },
              alignment: { horizontal: 'center', vertical: 'center' }
          });
      }
      rowHeights[0] = { hpt: 32 };

      // --- ROW 1: SUBTITLE ---
      mergeRange(1, 0, 1, 4);
      for (let c = 0; c <= 4; c++) {
          setCell(1, c, c === 0 ? 'BÁO CÁO THỐNG KÊ DOANH THU CHI TIẾT' : '', 's', null, {
              font: { name: 'Calibri', sz: 13, bold: true, color: { rgb: 'F8FAFC' } },
              fill: { fgColor: { rgb: '1E293B' } },
              alignment: { horizontal: 'center', vertical: 'center' }
          });
      }
      rowHeights[1] = { hpt: 24 };

      // --- ROW 2: MOTTO ---
      mergeRange(2, 0, 2, 4);
      for (let c = 0; c <= 4; c++) {
          setCell(2, c, c === 0 ? 'Hệ thống Quản trị Khách sạn Thông minh Nestora Hotel Manager' : '', 's', null, {
              font: { name: 'Calibri', sz: 10, italic: true, color: { rgb: '94A3B8' } },
              fill: { fgColor: { rgb: '1E293B' } },
              alignment: { horizontal: 'center', vertical: 'center' }
          });
      }
      rowHeights[2] = { hpt: 20 };

      // --- ROW 3: SPACER ---
      rowHeights[3] = { hpt: 10 };

      // --- ROW 4: META ROW 1 ---
      setCell(4, 0, 'Kỳ báo cáo:', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
          fill: { fgColor: { rgb: 'F1F5F9' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: thinBorder
      });
      mergeRange(4, 1, 4, 2);
      setCell(4, 1, '<%= dateRangeStr %>', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '1769E0' } },
          fill: { fgColor: { rgb: 'F8FAFC' } },
          alignment: { horizontal: 'left', vertical: 'center' },
          border: thinBorder
      });
      setCell(4, 2, '', 's', null, { border: thinBorder, fill: { fgColor: { rgb: 'F8FAFC' } } });
      setCell(4, 3, 'Ngày xuất file:', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
          fill: { fgColor: { rgb: 'F1F5F9' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: thinBorder
      });
      setCell(4, 4, todayStr, 's', null, {
          font: { name: 'Calibri', sz: 10, color: { rgb: '334155' } },
          fill: { fgColor: { rgb: 'F8FAFC' } },
          alignment: { horizontal: 'center', vertical: 'center' },
          border: thinBorder
      });
      rowHeights[4] = { hpt: 22 };

      // --- ROW 5: META ROW 2 ---
      setCell(5, 0, 'Người xuất:', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
          fill: { fgColor: { rgb: 'F1F5F9' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: thinBorder
      });
      mergeRange(5, 1, 5, 2);
      setCell(5, 1, '<%= (currentUser != null && currentUser.getFullName() != null) ? currentUser.getFullName() : "Ban Quản Trị" %>', 's', null, {
          font: { name: 'Calibri', sz: 10, color: { rgb: '334155' } },
          fill: { fgColor: { rgb: 'F8FAFC' } },
          alignment: { horizontal: 'left', vertical: 'center' },
          border: thinBorder
      });
      setCell(5, 2, '', 's', null, { border: thinBorder, fill: { fgColor: { rgb: 'F8FAFC' } } });
      setCell(5, 3, 'Đơn vị tiền tệ:', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
          fill: { fgColor: { rgb: 'F1F5F9' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: thinBorder
      });
      setCell(5, 4, 'VNĐ (Việt Nam Đồng)', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '166534' } },
          fill: { fgColor: { rgb: 'DCFCE7' } },
          alignment: { horizontal: 'center', vertical: 'center' },
          border: thinBorder
      });
      rowHeights[5] = { hpt: 22 };

      // --- ROW 6: SPACER ---
      rowHeights[6] = { hpt: 12 };

      // --- ROW 7: KPI SUMMARY CARDS ---
      mergeRange(7, 0, 7, 1);
      setCell(7, 0, 'TỔNG DOANH THU: ' + new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(<%= totalRevenue %>), 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: 'FDE68A' } },
          fill: { fgColor: { rgb: '0F172A' } },
          alignment: { horizontal: 'center', vertical: 'center' },
          border: thinBorder
      });
      setCell(7, 1, '', 's', null, { border: thinBorder, fill: { fgColor: { rgb: '0F172A' } } });
      setCell(7, 2, 'Tiền phòng: ' + new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(<%= roomRevenue %>), 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: 'FFFFFF' } },
          fill: { fgColor: { rgb: '1E3A8A' } },
          alignment: { horizontal: 'center', vertical: 'center' },
          border: thinBorder
      });
      setCell(7, 3, 'Tiền dịch vụ: ' + new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(<%= serviceRevenue %>), 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: 'FFFFFF' } },
          fill: { fgColor: { rgb: '92400E' } },
          alignment: { horizontal: 'center', vertical: 'center' },
          border: thinBorder
      });
      setCell(7, 4, 'TB/Ngày: ' + new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(<%= averagePerDay %>), 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: 'FFFFFF' } },
          fill: { fgColor: { rgb: '065F46' } },
          alignment: { horizontal: 'center', vertical: 'center' },
          border: thinBorder
      });
      rowHeights[7] = { hpt: 26 };

      // --- ROW 8: SPACER ---
      rowHeights[8] = { hpt: 12 };

      // --- ROW 9: TABLE HEADER ---
      const headers = ['STT', 'NGÀY THỐNG KÊ', 'DOANH THU PHÒNG (VNĐ)', 'DOANH THU DỊCH VỤ (VNĐ)', 'TỔNG DOANH THU (VNĐ)'];
      for (let c = 0; c < headers.length; c++) {
          setCell(9, c, headers[c], 's', null, {
              font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: 'FFFFFF' } },
              fill: { fgColor: { rgb: '1E293B' } },
              alignment: { horizontal: 'center', vertical: 'center', wrapText: true },
              border: headerBorder
          });
      }
      rowHeights[9] = { hpt: 28 };

      // --- DATA ROWS ---
      let curRow = 10;
      for (let i = 0; i < dailyLabels.length; i++) {
          const roomRev = dailyRoomData[i];
          const servRev = dailyServiceData[i];
          const totalRev = roomRev + servRev;
          const isEven = i % 2 === 0;
          const rowBg = isEven ? 'FFFFFF' : 'F8FAFC';

          setCell(curRow, 0, i + 1, 'n', null, {
              font: { name: 'Calibri', sz: 10, color: { rgb: '64748B' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 1, dailyLabels[i], 's', null, {
              font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '1E293B' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 2, roomRev, 'n', numFmt, {
              font: { name: 'Calibri', sz: 10, color: { rgb: '0F172A' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'right', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 3, servRev, 'n', numFmt, {
              font: { name: 'Calibri', sz: 10, color: { rgb: '0F172A' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'right', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 4, totalRev, 'n', numFmt, {
              font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '1769E0' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'right', vertical: 'center' },
              border: thinBorder
          });

          rowHeights[curRow] = { hpt: 22 };
          curRow++;
      }

      // --- ROW: TOTAL SUMMARY (TỔNG CỘNG) ---
      mergeRange(curRow, 0, curRow, 1);
      setCell(curRow, 0, 'TỔNG CỘNG DOANH THU KỲ BÁO CÁO:', 's', null, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '92400E' } },
          fill: { fgColor: { rgb: 'FEF3C7' } },
          alignment: { horizontal: 'center', vertical: 'center' },
          border: totalBorder
      });
      setCell(curRow, 1, '', 's', null, { border: totalBorder, fill: { fgColor: { rgb: 'FEF3C7' } } });

      setCell(curRow, 2, <%= roomRevenue %>, 'n', numFmt, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '0F172A' } },
          fill: { fgColor: { rgb: 'FEF3C7' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: totalBorder
      });

      setCell(curRow, 3, <%= serviceRevenue %>, 'n', numFmt, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '0F172A' } },
          fill: { fgColor: { rgb: 'FEF3C7' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: totalBorder
      });

      setCell(curRow, 4, <%= totalRevenue %>, 'n', numFmt, {
          font: { name: 'Calibri', sz: 12, bold: true, color: { rgb: '92400E' } },
          fill: { fgColor: { rgb: 'FDE68A' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: totalBorder
      });
      rowHeights[curRow] = { hpt: 26 };
      curRow++;

      // --- ROW: AVERAGE PER DAY ---
      mergeRange(curRow, 0, curRow, 3);
      setCell(curRow, 0, 'Doanh thu trung bình mỗi ngày:', 's', null, {
          font: { name: 'Calibri', sz: 10, italic: true, bold: true, color: { rgb: '475569' } },
          fill: { fgColor: { rgb: 'F1F5F9' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: thinBorder
      });
      for (let c = 1; c <= 3; c++) {
          setCell(curRow, c, '', 's', null, { border: thinBorder, fill: { fgColor: { rgb: 'F1F5F9' } } });
      }
      setCell(curRow, 4, <%= averagePerDay %>, 'n', numFmt, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '166534' } },
          fill: { fgColor: { rgb: 'DCFCE7' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: thinBorder
      });
      rowHeights[curRow] = { hpt: 22 };
      curRow++;

      // --- ROW: SPACER ---
      curRow++;
      rowHeights[curRow - 1] = { hpt: 18 };

      // --- SIGNATURE SECTION ---
      setCell(curRow, 1, 'NGƯỜI LẬP BÁO CÁO', 's', null, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '0F172A' } },
          alignment: { horizontal: 'center', vertical: 'center' }
      });
      setCell(curRow, 4, 'KẾ TOÁN TRƯỞNG / BAN GIÁM ĐỐC', 's', null, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '0F172A' } },
          alignment: { horizontal: 'center', vertical: 'center' }
      });
      rowHeights[curRow] = { hpt: 20 };
      curRow++;

      setCell(curRow, 1, '(Ký, ghi rõ họ tên)', 's', null, {
          font: { name: 'Calibri', sz: 9, italic: true, color: { rgb: '64748B' } },
          alignment: { horizontal: 'center', vertical: 'center' }
      });
      setCell(curRow, 4, '(Ký, đóng dấu)', 's', null, {
          font: { name: 'Calibri', sz: 9, italic: true, color: { rgb: '64748B' } },
          alignment: { horizontal: 'center', vertical: 'center' }
      });
      rowHeights[curRow] = { hpt: 18 };
      curRow += 3; // Space for signature

      setCell(curRow, 1, '<%= (currentUser != null && currentUser.getFullName() != null) ? currentUser.getFullName() : "Ban Quản Trị" %>', 's', null, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '0F172A' } },
          alignment: { horizontal: 'center', vertical: 'center' }
      });
      setCell(curRow, 4, 'Đại diện Ban Quản Trị Nestora', 's', null, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '0F172A' } },
          alignment: { horizontal: 'center', vertical: 'center' }
      });
      rowHeights[curRow] = { hpt: 22 };

      // Set sheet properties
      ws['!ref'] = XLSX.utils.encode_range({ s: { r: 0, c: 0 }, e: { r: curRow, c: 4 } });
      ws['!merges'] = merges;
      ws['!rows'] = rowHeights;
      ws['!cols'] = [
          { wch: 8 },  // STT
          { wch: 24 }, // NGÀY THỐNG KÊ
          { wch: 28 }, // DOANH THU PHÒNG
          { wch: 28 }, // DOANH THU DỊCH VỤ
          { wch: 34 }  // TỔNG DOANH THU
      ];

      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, 'Báo Cáo Doanh Thu');
      XLSX.writeFile(wb, 'Bao_Cao_Doanh_Thu_Nestora_' + new Date().toISOString().slice(0, 10) + '.xlsx');
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