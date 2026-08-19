<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %><%@ page import="com.hotel.model.User" %><%@ page import="com.hotel.model.Bill" %><%@ page import="java.util.List" %><%@ page import="java.text.NumberFormat" %><%@ page import="java.text.SimpleDateFormat" %><%@ page import="java.util.Locale" %>
<%
HttpSession sess=request.getSession(false);User currentUser=sess!=null?(User)sess.getAttribute("currentUser"):null;if(currentUser==null||!"Admin".equalsIgnoreCase(currentUser.getRole())){response.sendRedirect(request.getContextPath()+"/home");return;}List<Bill>bills=(List<Bill>)request.getAttribute("bills");NumberFormat money=NumberFormat.getCurrencyInstance(new Locale("vi","VN"));SimpleDateFormat dt=new SimpleDateFormat("dd/MM/yyyy HH:mm");SimpleDateFormat d=new SimpleDateFormat("dd/MM/yyyy");String activeMenu="bills";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Hóa đơn - Nestora</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
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
            <div class="breadcrumb">Tài chính / Hóa đơn</div>
            <h1 class="page-title">Hóa đơn thanh toán</h1>
            <p class="page-desc">Theo dõi hóa đơn, trạng thái thanh toán và thời gian lưu trú.</p>
          </div>
          <div class="page-actions" style="display:flex; gap:10px;">
            <button type="button" class="btn btn-primary" onclick="exportBillsToExcel()">📊 Xuất Excel</button>
            <a class="btn btn-outline" href="<%=request.getContextPath()%>/bookings?action=list&mode=checkout">Trả phòng & thanh toán</a>
          </div>
        </div>

        <%if("1".equals(request.getParameter("cancelled"))){%>
          <div class="alert alert-success">Đã hủy hóa đơn thành công.</div>
        <%}else if("cannotCancelPaid".equals(request.getParameter("error"))||"alreadyPaid".equals(request.getParameter("error"))){%>
          <div class="alert alert-error">Hóa đơn đã được thanh toán, không thể hủy!</div>
        <%}else if("cancelFailed".equals(request.getParameter("error"))){%>
          <div class="alert alert-error">Không thể hủy hóa đơn ở trạng thái hiện tại.</div>
        <%}%>

        <section class="surface">
          <div class="table-tools">
            <div class="search-box">
              <input type="search" placeholder="Tìm theo mã hóa đơn hoặc khách hàng...">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/></svg>
            </div>
            <div class="admin-filter-group">
              <select class="admin-filter-select" data-admin-filter aria-label="Lọc trạng thái hóa đơn">
                <option value="">Tất cả trạng thái</option>
                <option value="Đã thanh toán">Đã thanh toán</option>
                <option value="Chưa thanh toán">Chưa thanh toán</option>
                <option value="Đã hủy">Đã hủy</option>
              </select>
            </div>
            <div class="table-meta"><%=bills!=null?bills.size():0%> hóa đơn</div>
          </div>

          <%if(bills!=null&&!bills.isEmpty()){%>
            <div class="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>MÃ HÓA ĐƠN</th>
                    <th>KHÁCH HÀNG</th>
                    <th>NGÀY TẠO</th>
                    <th>NHẬN PHÒNG</th>
                    <th>TRẢ PHÒNG</th>
                    <th>TỔNG TIỀN</th>
                    <th>TRẠNG THÁI</th>
                    <th>THAO TÁC</th>
                  </tr>
                </thead>
                <tbody>
                  <%for(Bill b:bills){%>
                    <tr>
                      <td class="table-primary">#HD<%=b.getId()%></td>
                      <td>
                        <span class="table-strong"><%=b.getCustomer() != null ? b.getCustomer().getCustomerName() : (b.getUser() != null ? b.getUser().getFullName() : "N/A")%></span><br>
                        <span class="text-muted"><%=b.getCustomer() != null && b.getCustomer().getCustomerEmail() != null ? b.getCustomer().getCustomerEmail() : (b.getUser() != null ? b.getUser().getEmail() : "")%></span>
                      </td>
                      <td><%=dt.format(b.getCreatedAt())%></td>
                      <td><%=d.format(b.getCheckInDate())%></td>
                      <td><%=b.getCheckOutDate()!=null?d.format(b.getCheckOutDate()):"-"%></td>
                      <td class="table-strong"><%=money.format(b.getTotalAmount())%></td>
                      <td>
                        <%if("Paid".equals(b.getStatus())){%>
                          <span class="status success">Đã thanh toán</span>
                        <%}else if("Unpaid".equals(b.getStatus())){%>
                          <span class="status info">Chưa thanh toán</span>
                        <%}else{%>
                          <span class="status danger">Đã hủy</span>
                        <%}%>
                      </td>
                      <td><a class="btn btn-outline" href="<%=request.getContextPath()%>/bills?action=detail&id=<%=b.getId()%>">Xem chi tiết</a></td>
                    </tr>
                  <%}%>
                </tbody>
              </table>
            </div>
            <div class="pagination"><span class="page-number active">1</span></div>
          <%}else{%>
            <div class="empty"><strong>Chưa có hóa đơn</strong>Dữ liệu sẽ hiển thị khi có đặt phòng.</div>
          <%}%>
        </section>
      </div>
    </section>
  </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/xlsx-js-style@1.2.0/dist/xlsx.bundle.js"></script>
<script src="<%=request.getContextPath()%>/js/app.js"></script>
<script>
  function exportBillsToExcel() {
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
          setCell(1, c, c === 0 ? 'DANH SÁCH HÓA ĐƠN THANH TOÁN CHI TIẾT' : '', 's', null, {
              font: { name: 'Calibri', sz: 13, bold: true, color: { rgb: 'F8FAFC' } },
              fill: { fgColor: { rgb: '1E293B' } },
              alignment: { horizontal: 'center', vertical: 'center' }
          });
      }
      rowHeights[1] = { hpt: 24 };

      // ROW 2: SPACER
      rowHeights[2] = { hpt: 10 };

      // ROW 3: METADATA
      setCell(3, 0, 'Ngày xuất file:', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
          fill: { fgColor: { rgb: 'F1F5F9' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: thinBorder
      });
      mergeRange(3, 1, 3, 2);
      setCell(3, 1, todayStr, 's', null, {
          font: { name: 'Calibri', sz: 10, color: { rgb: '334155' } },
          fill: { fgColor: { rgb: 'F8FAFC' } },
          alignment: { horizontal: 'left', vertical: 'center' },
          border: thinBorder
      });
      setCell(3, 2, '', 's', null, { border: thinBorder, fill: { fgColor: { rgb: 'F8FAFC' } } });

      setCell(3, 5, 'Người xuất:', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
          fill: { fgColor: { rgb: 'F1F5F9' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: thinBorder
      });
      mergeRange(3, 6, 3, 7);
      setCell(3, 6, '<%= (currentUser != null && currentUser.getFullName() != null) ? currentUser.getFullName() : "Ban Quản Trị" %>', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '1769E0' } },
          fill: { fgColor: { rgb: 'F8FAFC' } },
          alignment: { horizontal: 'left', vertical: 'center' },
          border: thinBorder
      });
      setCell(3, 7, '', 's', null, { border: thinBorder, fill: { fgColor: { rgb: 'F8FAFC' } } });
      rowHeights[3] = { hpt: 22 };

      // ROW 4: SPACER
      rowHeights[4] = { hpt: 10 };

      // ROW 5: HEADERS
      const headers = ['MÃ HĐ', 'TÊN KHÁCH HÀNG', 'EMAIL', 'NGÀY TẠO', 'NGÀY NHẬN', 'NGÀY TRẢ', 'TỔNG TIỀN (VNĐ)', 'TRẠNG THÁI'];
      for (let c = 0; c < headers.length; c++) {
          setCell(5, c, headers[c], 's', null, {
              font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: 'FFFFFF' } },
              fill: { fgColor: { rgb: '1E293B' } },
              alignment: { horizontal: 'center', vertical: 'center', wrapText: true },
              border: headerBorder
          });
      }
      rowHeights[5] = { hpt: 26 };

      // BILLS DATA
      const billData = [
      <% if (bills != null) { 
           for (Bill b : bills) {
             String custName = b.getCustomer() != null ? b.getCustomer().getCustomerName() : (b.getUser() != null ? b.getUser().getFullName() : "N/A");
             String custEmail = b.getCustomer() != null && b.getCustomer().getCustomerEmail() != null ? b.getCustomer().getCustomerEmail() : (b.getUser() != null ? b.getUser().getEmail() : "");
             String createDate = dt.format(b.getCreatedAt());
             String checkIn = d.format(b.getCheckInDate());
             String checkOut = b.getCheckOutDate() != null ? d.format(b.getCheckOutDate()) : "-";
             double amount = b.getTotalAmount();
             String statusText = "Paid".equals(b.getStatus()) ? "Đã thanh toán" : ("Unpaid".equals(b.getStatus()) ? "Chưa thanh toán" : "Đã hủy");
             String statusKey = b.getStatus() != null ? b.getStatus() : "";
      %>
        {
          id: '#HD<%= b.getId() %>',
          name: '<%= custName.replace("'", "\\'") %>',
          email: '<%= custEmail.replace("'", "\\'") %>',
          createDate: '<%= createDate %>',
          checkIn: '<%= checkIn %>',
          checkOut: '<%= checkOut %>',
          amount: <%= amount %>,
          status: '<%= statusText %>',
          statusKey: '<%= statusKey %>'
        },
      <%   }
         } %>
      ];

      let curRow = 6;
      let totalSum = 0;
      let totalPaidSum = 0;

      for (let i = 0; i < billData.length; i++) {
          const item = billData[i];
          const isEven = i % 2 === 0;
          const rowBg = isEven ? 'FFFFFF' : 'F8FAFC';
          totalSum += item.amount;
          if (item.statusKey === 'Paid') totalPaidSum += item.amount;

          let statusFg = '166534';
          let statusBg = 'DCFCE7';
          if (item.statusKey === 'Unpaid') {
              statusFg = 'B45309';
              statusBg = 'FEF3C7';
          } else if (item.statusKey === 'Cancelled') {
              statusFg = '991B1B';
              statusBg = 'FEE2E2';
          }

          setCell(curRow, 0, item.id, 's', null, {
              font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '1769E0' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 1, item.name, 's', null, {
              font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'left', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 2, item.email, 's', null, {
              font: { name: 'Calibri', sz: 10, color: { rgb: '64748B' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'left', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 3, item.createDate, 's', null, {
              font: { name: 'Calibri', sz: 10, color: { rgb: '334155' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 4, item.checkIn, 's', null, {
              font: { name: 'Calibri', sz: 10, color: { rgb: '334155' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 5, item.checkOut, 's', null, {
              font: { name: 'Calibri', sz: 10, color: { rgb: '334155' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 6, item.amount, 'n', numFmt, {
              font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'right', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 7, item.status, 's', null, {
              font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: statusFg } },
              fill: { fgColor: { rgb: statusBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          rowHeights[curRow] = { hpt: 22 };
          curRow++;
      }

      // TOTAL SUMMARY ROW
      mergeRange(curRow, 0, curRow, 5);
      setCell(curRow, 0, 'TỔNG CỘNG GIÁ TRỊ HÓA ĐƠN:', 's', null, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '92400E' } },
          fill: { fgColor: { rgb: 'FEF3C7' } },
          alignment: { horizontal: 'center', vertical: 'center' },
          border: totalBorder
      });
      for (let c = 1; c <= 5; c++) {
          setCell(curRow, c, '', 's', null, { border: totalBorder, fill: { fgColor: { rgb: 'FEF3C7' } } });
      }

      setCell(curRow, 6, totalSum, 'n', numFmt, {
          font: { name: 'Calibri', sz: 12, bold: true, color: { rgb: '92400E' } },
          fill: { fgColor: { rgb: 'FDE68A' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: totalBorder
      });

      setCell(curRow, 7, billData.length + ' Hóa đơn', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
          fill: { fgColor: { rgb: 'FEF3C7' } },
          alignment: { horizontal: 'center', vertical: 'center' },
          border: totalBorder
      });
      rowHeights[curRow] = { hpt: 26 };
      curRow++;

      // PAID TOTAL ROW
      mergeRange(curRow, 0, curRow, 5);
      setCell(curRow, 0, 'Trong đó - Đã thực thu (Đã thanh toán):', 's', null, {
          font: { name: 'Calibri', sz: 10, italic: true, bold: true, color: { rgb: '166534' } },
          fill: { fgColor: { rgb: 'DCFCE7' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: thinBorder
      });
      for (let c = 1; c <= 5; c++) {
          setCell(curRow, c, '', 's', null, { border: thinBorder, fill: { fgColor: { rgb: 'DCFCE7' } } });
      }
      setCell(curRow, 6, totalPaidSum, 'n', numFmt, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '166534' } },
          fill: { fgColor: { rgb: 'DCFCE7' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: thinBorder
      });
      setCell(curRow, 7, '', 's', null, { border: thinBorder, fill: { fgColor: { rgb: 'DCFCE7' } } });
      rowHeights[curRow] = { hpt: 22 };
      curRow++;

      // Set sheet properties
      ws['!ref'] = XLSX.utils.encode_range({ s: { r: 0, c: 0 }, e: { r: curRow - 1, c: 7 } });
      ws['!merges'] = merges;
      ws['!rows'] = rowHeights;
      ws['!cols'] = [
          { wch: 12 }, // MÃ HĐ
          { wch: 26 }, // TÊN KHÁCH HÀNG
          { wch: 28 }, // EMAIL
          { wch: 20 }, // NGÀY TẠO
          { wch: 16 }, // NGÀY NHẬN
          { wch: 16 }, // NGÀY TRẢ
          { wch: 24 }, // TỔNG TIỀN
          { wch: 18 }  // TRẠNG THÁI
      ];

      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, 'Danh Sách Hóa Đơn');
      XLSX.writeFile(wb, 'Danh_Sach_Hoa_Don_Nestora_' + new Date().toISOString().slice(0, 10) + '.xlsx');
  }
</script>
</body>
</html>
