<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Booking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
    
    String mode = (String) request.getAttribute("mode");
    if (mode == null) {
        mode = "";
    }
    
    String activeMenu = "bookings";
    if ("checkin".equals(mode)) {
        activeMenu = "checkin";
    } else if ("checkout".equals(mode)) {
        activeMenu = "checkout";
    }
    
    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    boolean bulkModeAvailable = true;
    
    User currentUserCheck = (User) session.getAttribute("currentUser");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Đặt phòng - Nestora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .badge-status {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
        }
        .badge-Pending { background: #fef3c7; color: #d97706; }
        .badge-Confirmed { background: #d1fae5; color: #059669; }
        .badge-CheckedIn { background: #dbeafe; color: #2563eb; }
        .badge-CheckedOut { background: #f3f4f6; color: #4b5563; }
        .badge-Cancelled { background: #fee2e2; color: #dc2626; }
        .table-actions {
            display: flex;
            gap: 8px;
            align-items: center;
        }
        .bulk-selector-cell { display: none; width: 58px; text-align: center; }
        .bulk-mode-active .bulk-selector-cell { display: table-cell; }
        .bulk-action-bar {
            display: none;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            padding: 14px 18px;
            border-bottom: 1px solid var(--line);
            background: var(--brand-soft);
        }
        .bulk-mode-active .bulk-action-bar { display: flex; }
        .bulk-selection-summary { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
        .bulk-selection-summary strong { color: var(--brand); }
        .bulk-selection-actions { display: flex; gap: 8px; flex-wrap: wrap; }
        .booking-select {
            width: 18px;
            height: 18px;
            accent-color: var(--brand);
            cursor: pointer;
        }
        tr.selection-disabled td { background: var(--canvas); }
        tr.selection-disabled td:not(.bulk-selector-cell) { opacity: .42; }
        tr.selection-disabled .booking-select { cursor: not-allowed; }
        tr.selection-selected td { background: var(--brand-soft); }
        @media (max-width: 720px) {
            .bulk-action-bar { align-items: stretch; flex-direction: column; }
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
                        <div class="breadcrumb">Vận hành / <%= "checkin".equals(mode) ? "Nhận phòng" : ("checkout".equals(mode) ? "Trả phòng" : "Đặt phòng") %></div>
                        <h1 class="page-title">
                            <%= "checkin".equals(mode) ? "Danh sách chờ nhận phòng" : ("checkout".equals(mode) ? "Danh sách chờ trả phòng" : "Danh sách đặt phòng") %>
                        </h1>
                        <p class="page-desc">
                            <%= "checkin".equals(mode) ? "Xem danh sách và thực hiện thủ tục nhận phòng cho khách hàng." : ("checkout".equals(mode) ? "Thực hiện thủ tục trả phòng và thanh toán hóa đơn." : "Theo dõi lịch đặt và quản lý trạng thái nhận/trả phòng.") %>
                        </p>
                    </div>
                    <div class="page-actions" style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <button class="btn btn-outline" type="button" onclick="exportBookingsToExcel()">📊 Xuất Excel</button>
                        <% if (bulkModeAvailable) { %>
                            <button class="btn btn-outline" id="enable-bulk-mode" type="button">☑ Chọn nhiều phòng</button>
                        <% } %>
                        <a class="btn btn-primary" href="<%= request.getContextPath() %>/bookings?action=add">＋ Tạo mới đặt phòng</a>
                    </div>
                </div>

                <% if (request.getParameter("processed") != null) { %>
                    <div class="alert alert-success">Đã xử lý thành công cho <%= request.getParameter("processed") %> phòng.</div>
                <% } else if ("1".equals(request.getParameter("cancelled"))) { %>
                    <div class="alert alert-success">Đã hủy đặt phòng và lưu lý do hủy.</div>
                <% } else if ("cancelReasonRequired".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-error">Vui lòng dùng nút Hủy và nhập lý do hủy đặt phòng.</div>
                <% } else if ("noSelection".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-error">Vui lòng chọn ít nhất một phòng.</div>
                <% } else if ("invalidCancelReason".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-error">Lý do hủy phải có từ 3 đến 500 ký tự.</div>
                <% } else if ("cancelFailed".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-error">Không thể hủy đặt phòng ở trạng thái hiện tại.</div>
                <% } else if ("cannotCancelPaid".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-error">Đơn đặt phòng đã được nhận/trả phòng hoặc thanh toán, không thể hủy.</div>
                <% } else if ("permissionDenied".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-error">Bạn không có quyền xem hoặc thao tác trên đơn đặt phòng của nhân viên khác.</div>
                <% } else if ("bulkFailed".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-error">Không thể xử lý. Các phòng phải cùng một khách hàng và có trạng thái phù hợp.</div>
                <% } %>

                <form id="bulk-booking-form" method="post" action="<%= request.getContextPath() %>/bookings">
                <input type="hidden" name="action" value="<%= "checkout".equals(mode) ? "bulkCheckout" : "bulkCheckin" %>">
                <section class="surface" id="bulk-booking-surface">
                    <% if (bulkModeAvailable) { %>
                    <div class="bulk-action-bar" id="bulk-action-bar">
                        <div class="bulk-selection-summary">
                            <span>Đã chọn: <strong id="bulk-selected-count">0 phòng</strong></span>
                            <span>Khách hàng: <strong id="bulk-selected-customer">Chưa chọn</strong></span>
                            <span>Tổng tiền phòng: <strong id="bulk-selected-total">—</strong></span>
                        </div>
                        <div class="bulk-selection-actions">
                            <button class="btn btn-outline" id="select-same-customer" type="button" disabled>Chọn tất cả của khách này</button>
                            <button class="btn btn-outline" id="cancel-bulk-mode" type="button">Hủy chọn nhiều</button>
                            <button class="btn btn-primary" id="submit-bulk-action" type="submit" disabled>
                                Chọn phòng để xử lý
                            </button>
                        </div>
                    </div>
                    <% } %>
                    <div class="table-tools">
                        <div class="search-box">
                            <input type="search" placeholder="Tìm kiếm...">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="11" cy="11" r="7"/>
                                <path d="M20 20l-3.5-3.5"/>
                            </svg>
                        </div>
                        <div class="admin-filter-group">
                            <select class="admin-filter-select" data-admin-filter aria-label="Lọc trạng thái đặt phòng">
                                <option value="">Tất cả trạng thái</option>
                                <option value="Chờ xác nhận">Chờ xác nhận</option>
                                <option value="Đã xác nhận">Đã xác nhận</option>
                                <option value="Đã nhận phòng">Đã nhận phòng</option>
                                <option value="Đã trả phòng">Đã trả phòng</option>
                                <option value="Đã hủy">Đã hủy</option>
                            </select>
                        </div>
                        <div class="table-meta"><%= bookings != null ? bookings.size() : 0 %> đặt phòng</div>
                    </div>
                    
                    <div class="table-wrap">
                        <table>
                            <thead>
                            <tr>
                                <% if (bulkModeAvailable) { %><th class="bulk-selector-cell">CHỌN</th><% } %>
                                <th>MÃ ĐẶT PHÒNG</th>
                                <th>KHÁCH HÀNG</th>
                                <th>PHÒNG</th>
                                <th>GIÁ ĐẶT</th>
                                <th>NGƯỜI TẠO</th>
                                <th>NHẬN PHÒNG</th>
                                <th>TRẢ PHÒNG</th>
                                <th>TRẠNG THÁI</th>
                                <th>THAO TÁC</th>
                            </tr>
                            </thead>
                            <tbody>
                            <%
                                if (bookings != null && !bookings.isEmpty()) {
                                    for (Booking b : bookings) {
                                        String statusText = "Chờ xác nhận";
                                        if ("Confirmed".equals(b.getStatus())) statusText = "Đã xác nhận";
                                        else if ("CheckedIn".equals(b.getStatus())) statusText = "Đang ở";
                                        else if ("CheckedOut".equals(b.getStatus())) statusText = "Đã trả phòng";
                                        else if ("Cancelled".equals(b.getStatus())) statusText = "Đã hủy";
                                        
                                        long stayMs = b.getCheckOutDate().getTime() - b.getCheckInDate().getTime();
                                        long stayDays = stayMs / (1000L * 60 * 60 * 24);
                                        if (stayDays <= 0) stayDays = 1;
                                        double bookingTotal = stayDays * b.getRoomPrice();
                                        
                                        boolean canBulkCheckIn = "Pending".equals(b.getStatus()) || "Confirmed".equals(b.getStatus());
                                        boolean canBulkCheckOut = "CheckedIn".equals(b.getStatus());
                                        boolean canBulkProcess = canBulkCheckIn || canBulkCheckOut;
                                        String bulkOperation = canBulkCheckOut ? "checkout" : (canBulkCheckIn ? "checkin" : "");
                                        
                                        int cId = (b.getCustomer() != null) ? b.getCustomer().getCustomerId() : 0;
                                        String cName = (b.getCustomer() != null) ? b.getCustomer().getCustomerName() : "N/A";
                                        String cPhone = (b.getCustomer() != null && b.getCustomer().getCustomerPhone() != null) ? b.getCustomer().getCustomerPhone() : "";
                                        String rNum = (b.getRoom() != null) ? b.getRoom().getRoomNumber() : "N/A";
                                        String rType = (b.getRoom() != null && b.getRoom().getRoomType() != null) ? b.getRoom().getRoomType().getName() : "";
                                        String creatorName = (b.getCreatedBy() != null && b.getCreatedBy().getFullName() != null) ? b.getCreatedBy().getFullName() : "Khách online";
                            %>
                            <tr data-customer-id="<%= cId %>">
                                <% if (bulkModeAvailable) { %>
                                <td class="bulk-selector-cell">
                                    <input class="booking-select" type="checkbox" name="bookingIds"
                                           value="<%= b.getBookingId() %>"
                                           data-customer-id="<%= cId %>"
                                           data-amount="<%= bookingTotal %>"
                                           data-operation="<%= bulkOperation %>"
                                           data-eligible="<%= canBulkProcess %>"
                                           <%= canBulkProcess ? "" : "disabled" %>
                                           aria-label="Chọn phòng <%= rNum %>">
                                </td>
                                <% } %>
                                <td class="table-primary">#DP<%= b.getBookingId() %></td>
                                <td>
                                    <div class="table-strong customer-name"><%= cName %></div>
                                    <div style="font-size:11px; color:var(--muted);"><%= cPhone %></div>
                                </td>
                                <td>
                                    <div class="table-strong">P.<%= rNum %></div>
                                    <div style="font-size:11px; color:var(--muted);"><%= rType %></div>
                                </td>
                                <td class="table-strong text-primary"><%= money.format(b.getRoomPrice()) %></td>
                                <td>
                                    <span style="font-size:12px; font-weight:600; color:var(--navy); display:inline-flex; align-items:center; gap:4px;">
                                        👤 <%= creatorName %>
                                    </span>
                                </td>
                                <td><%= sdf.format(b.getCheckInDate()) %></td>
                                <td><%= sdf.format(b.getCheckOutDate()) %></td>
                                <td>
                                    <span class="badge-status badge-<%= b.getStatus() %>"><%= statusText %></span>
                                </td>
                                <td>
                                    <div class="table-actions">
                                        <a class="btn btn-outline" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/bookings?action=receipt&id=<%= b.getBookingId() %>">📄 Phiếu</a>
                                        
                                        <% if ("Pending".equals(b.getStatus()) || "Confirmed".equals(b.getStatus())) { %>
                                             <a class="btn btn-primary" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/bookings?action=checkin&id=<%= b.getBookingId() %>">Nhận phòng</a>
                                        <% } else if ("CheckedIn".equals(b.getStatus())) { %>
                                            <a class="btn btn-success" style="padding: 4px 8px; font-size:12px;" href="<%= request.getContextPath() %>/bookings?action=checkout&id=<%= b.getBookingId() %>">Trả phòng</a>
                                        <% } %>

                                        <% if ("Pending".equals(b.getStatus()) || "Confirmed".equals(b.getStatus())) { %>
                                            <button class="btn btn-danger" type="button" style="padding: 4px 8px; font-size:12px;"
                                                    data-cancel-booking data-booking-id="<%= b.getBookingId() %>"
                                                    data-cancel-url="<%= request.getContextPath() %>/bookings">Hủy</button>
                                        <% } %>

                                        <a class="btn btn-outline btn-icon" href="<%= request.getContextPath() %>/bookings?action=edit&id=<%= b.getBookingId() %>">✎</a>
                                        <a class="btn btn-outline btn-icon" href="<%= request.getContextPath() %>/bookings?action=delete&id=<%= b.getBookingId() %>" onclick="return confirm('Xóa lịch sử đặt phòng này?')">×</a>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="<%= bulkModeAvailable ? 10 : 9 %>" style="text-align: center; color: var(--muted); padding: 20px;">Không có dữ liệu đặt phòng nào.</td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </section>
                </form>
            </div>
        </section>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/app.js"></script>
<% if (bulkModeAvailable) { %>
<script>
    (function () {
        const surface = document.getElementById('bulk-booking-surface');
        const enableButton = document.getElementById('enable-bulk-mode');
        const cancelButton = document.getElementById('cancel-bulk-mode');
        const submitButton = document.getElementById('submit-bulk-action');
        const selectSameButton = document.getElementById('select-same-customer');
        const form = document.getElementById('bulk-booking-form');
        const actionInput = form ? form.querySelector('input[name="action"]') : null;
        const checkboxes = Array.from(document.querySelectorAll('.booking-select'));
        const countLabel = document.getElementById('bulk-selected-count');
        const customerLabel = document.getElementById('bulk-selected-customer');
        const totalLabel = document.getElementById('bulk-selected-total');

        function resetSelection() {
            checkboxes.forEach(function (checkbox) {
                checkbox.checked = false;
                checkbox.disabled = false;
                var row = checkbox.closest('tr');
                if (row) row.classList.remove('selection-disabled', 'selection-selected');
            });
            refreshSelection();
        }

        function refreshSelection() {
            const selected = checkboxes.filter(function (checkbox) { return checkbox.checked; });
            const lockedCustomerId = selected.length ? selected[0].dataset.customerId : null;
            const lockedOperation = selected.length ? selected[0].dataset.operation : null;
            let total = 0;

            checkboxes.forEach(function (checkbox) {
                const unavailable = checkbox.dataset.eligible !== 'true';
                const incompatible = lockedCustomerId && (
                    checkbox.dataset.customerId !== lockedCustomerId
                    || checkbox.dataset.operation !== lockedOperation
                );
                checkbox.disabled = unavailable || Boolean(incompatible);
                const row = checkbox.closest('tr');
                if (row) {
                    row.classList.toggle('selection-disabled', unavailable || Boolean(incompatible));
                    row.classList.toggle('selection-selected', checkbox.checked);
                }
                if (checkbox.checked) total += Number(checkbox.dataset.amount || 0);
            });

            if (countLabel) countLabel.textContent = selected.length + ' phòng';
            if (customerLabel) {
                customerLabel.textContent = selected.length
                    ? selected[0].closest('tr').querySelector('.customer-name').textContent.trim()
                    : 'Chưa chọn';
            }
            if (totalLabel) {
                if (lockedOperation === 'checkout') {
                    totalLabel.textContent = new Intl.NumberFormat('vi-VN', {
                        style: 'currency', currency: 'VND', maximumFractionDigits: 0
                    }).format(total);
                } else {
                    totalLabel.textContent = '—';
                }
            }
            if (actionInput) {
                actionInput.value = lockedOperation === 'checkout' ? 'bulkCheckout' : 'bulkCheckin';
            }
            if (submitButton) {
                submitButton.textContent = lockedOperation === 'checkout'
                    ? 'Trả phòng & tạo hóa đơn'
                    : (lockedOperation === 'checkin' ? 'Xác nhận nhận phòng' : 'Chọn phòng để xử lý');
                submitButton.classList.toggle('btn-success', lockedOperation === 'checkout');
                submitButton.classList.toggle('btn-primary', lockedOperation !== 'checkout');
                submitButton.disabled = selected.length === 0;
            }
            if (selectSameButton) selectSameButton.disabled = selected.length === 0;
        }

        if (enableButton) {
            enableButton.addEventListener('click', function () {
                if (surface) surface.classList.add('bulk-mode-active');
                enableButton.disabled = true;
                refreshSelection();
            });
        }
        if (cancelButton) {
            cancelButton.addEventListener('click', function () {
                resetSelection();
                if (surface) surface.classList.remove('bulk-mode-active');
                if (enableButton) enableButton.disabled = false;
            });
        }
        if (selectSameButton) {
            selectSameButton.addEventListener('click', function () {
                const firstSelected = checkboxes.find(function (checkbox) { return checkbox.checked; });
                if (!firstSelected) return;
                checkboxes.forEach(function (checkbox) {
                    if (checkbox.dataset.customerId === firstSelected.dataset.customerId
                            && checkbox.dataset.operation === firstSelected.dataset.operation
                            && checkbox.dataset.eligible === 'true') {
                        checkbox.checked = true;
                    }
                });
                refreshSelection();
            });
        }
        checkboxes.forEach(function (checkbox) {
            checkbox.addEventListener('change', refreshSelection);
        });
        if (form) {
            form.addEventListener('submit', function (event) {
                const selectedCount = checkboxes.filter(function (checkbox) { return checkbox.checked; }).length;
                if (!selectedCount) {
                    event.preventDefault();
                    return;
                }
                const isCheckout = actionInput && actionInput.value === 'bulkCheckout';
                const message = isCheckout
                    ? 'Xác nhận trả ' + selectedCount + ' phòng và tạo một hóa đơn tổng?'
                    : 'Xác nhận nhận ' + selectedCount + ' phòng cho khách hàng này?';
                if (!window.confirm(message)) event.preventDefault();
            });
        }
    })();
</script>
<% } %>

<script src="https://cdn.jsdelivr.net/npm/xlsx-js-style@1.2.0/dist/xlsx.bundle.js"></script>
<script>
  function exportBookingsToExcel() {
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
      mergeRange(0, 0, 0, 8);
      for (let c = 0; c <= 8; c++) {
          setCell(0, c, c === 0 ? 'KHÁCH SẠN NESTORA HOTEL & RESORT' : '', 's', null, {
              font: { name: 'Calibri', sz: 16, bold: true, color: { rgb: 'FFFFFF' } },
              fill: { fgColor: { rgb: '0F172A' } },
              alignment: { horizontal: 'center', vertical: 'center' }
          });
      }
      rowHeights[0] = { hpt: 32 };

      // ROW 1: SUBTITLE
      mergeRange(1, 0, 1, 8);
      for (let c = 0; c <= 8; c++) {
          setCell(1, c, c === 0 ? 'DANH SÁCH ĐƠN ĐẶT PHÒNG KHÁCH SẠN' : '', 's', null, {
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

      setCell(3, 6, 'Người xuất:', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
          fill: { fgColor: { rgb: 'F1F5F9' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: thinBorder
      });
      mergeRange(3, 7, 3, 8);
      setCell(3, 7, '<%= (currentUser != null && currentUser.getFullName() != null) ? currentUser.getFullName() : "Ban Quản Trị" %>', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '1769E0' } },
          fill: { fgColor: { rgb: 'F8FAFC' } },
          alignment: { horizontal: 'left', vertical: 'center' },
          border: thinBorder
      });
      setCell(3, 8, '', 's', null, { border: thinBorder, fill: { fgColor: { rgb: 'F8FAFC' } } });
      rowHeights[3] = { hpt: 22 };

      // ROW 4: SPACER
      rowHeights[4] = { hpt: 10 };

      // ROW 5: HEADERS
      const headers = ['MÃ ĐẶT', 'KHÁCH HÀNG', 'SĐT', 'PHÒNG', 'LOẠI PHÒNG', 'NGÀY NHẬN', 'NGÀY TRẢ', 'TỔNG TIỀN (VNĐ)', 'TRẠNG THÁI'];
      for (let c = 0; c < headers.length; c++) {
          setCell(5, c, headers[c], 's', null, {
              font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: 'FFFFFF' } },
              fill: { fgColor: { rgb: '1E293B' } },
              alignment: { horizontal: 'center', vertical: 'center', wrapText: true },
              border: headerBorder
          });
      }
      rowHeights[5] = { hpt: 26 };

      const bookingList = [
      <% if (bookings != null) {
           for (Booking b : bookings) {
             String cName = (b.getCustomer() != null && b.getCustomer().getCustomerName() != null) ? b.getCustomer().getCustomerName() : (b.getCreatedBy() != null ? b.getCreatedBy().getFullName() : "N/A");
             String cPhone = (b.getCustomer() != null && b.getCustomer().getCustomerPhone() != null) ? b.getCustomer().getCustomerPhone() : (b.getCreatedBy() != null ? b.getCreatedBy().getPhone() : "");
             String rNum = b.getRoom() != null ? b.getRoom().getRoomNumber() : "-";
             String rType = (b.getRoom() != null && b.getRoom().getRoomType() != null) ? b.getRoom().getRoomType().getName() : "-";
             String inDate = b.getCheckInDate() != null ? sdf.format(b.getCheckInDate()) : "-";
             String outDate = b.getCheckOutDate() != null ? sdf.format(b.getCheckOutDate()) : "-";
             long diffDays = (b.getCheckOutDate() != null && b.getCheckInDate() != null) ? ((b.getCheckOutDate().getTime() - b.getCheckInDate().getTime()) / (1000 * 60 * 60 * 24)) : 1;
             if (diffDays <= 0) diffDays = 1;
             double total = diffDays * b.getRoomPrice() * 1.08;
             String st = b.getStatus() != null ? b.getStatus() : "";
             String stVi = "Pending".equalsIgnoreCase(st) ? "Chờ xử lý" : ("Confirmed".equalsIgnoreCase(st) ? "Đã xác nhận" : ("CheckedIn".equalsIgnoreCase(st) ? "Đang ở" : ("CheckedOut".equalsIgnoreCase(st) ? "Đã trả phòng" : "Đã hủy")));
      %>
        {
          id: '#BK<%= b.getBookingId() %>',
          name: '<%= cName.replace("'", "\\'") %>',
          phone: '<%= cPhone.replace("'", "\\'") %>',
          room: '<%= rNum.replace("'", "\\'") %>',
          roomType: '<%= rType.replace("'", "\\'") %>',
          inDate: '<%= inDate %>',
          outDate: '<%= outDate %>',
          total: <%= total %>,
          status: '<%= stVi %>',
          statusKey: '<%= st %>'
        },
      <%   }
         } %>
      ];

      let curRow = 6;
      let totalMoney = 0;

      for (let i = 0; i < bookingList.length; i++) {
          const item = bookingList[i];
          const isEven = i % 2 === 0;
          const rowBg = isEven ? 'FFFFFF' : 'F8FAFC';
          if (item.statusKey !== 'Cancelled') totalMoney += item.total;

          let statusFg = '166534';
          let statusBg = 'DCFCE7';
          if (item.statusKey === 'Pending') {
              statusFg = 'B45309';
              statusBg = 'FEF3C7';
          } else if (item.statusKey === 'CheckedIn') {
              statusFg = '1D4ED8';
              statusBg = 'DBEAFE';
          } else if (item.statusKey === 'Cancelled') {
              statusFg = '991B1B';
              statusBg = 'FEE2E2';
          } else if (item.statusKey === 'CheckedOut') {
              statusFg = '374151';
              statusBg = 'F3F4F6';
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

          setCell(curRow, 2, item.phone, 's', null, {
              font: { name: 'Calibri', sz: 10, color: { rgb: '64748B' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 3, item.room, 's', null, {
              font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 4, item.roomType, 's', null, {
              font: { name: 'Calibri', sz: 10, color: { rgb: '334155' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'left', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 5, item.inDate, 's', null, {
              font: { name: 'Calibri', sz: 10, color: { rgb: '334155' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 6, item.outDate, 's', null, {
              font: { name: 'Calibri', sz: 10, color: { rgb: '334155' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 7, item.total, 'n', numFmt, {
              font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
              fill: { fgColor: { rgb: rowBg } },
              alignment: { horizontal: 'right', vertical: 'center' },
              border: thinBorder
          });

          setCell(curRow, 8, item.status, 's', null, {
              font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: statusFg } },
              fill: { fgColor: { rgb: statusBg } },
              alignment: { horizontal: 'center', vertical: 'center' },
              border: thinBorder
          });

          rowHeights[curRow] = { hpt: 22 };
          curRow++;
      }

      // TOTAL SUMMARY ROW
      mergeRange(curRow, 0, curRow, 6);
      setCell(curRow, 0, 'TỔNG CỘNG GIÁ TRỊ ĐẶT PHÒNG (KHÔNG TÍNH ĐƠN HỦY):', 's', null, {
          font: { name: 'Calibri', sz: 11, bold: true, color: { rgb: '92400E' } },
          fill: { fgColor: { rgb: 'FEF3C7' } },
          alignment: { horizontal: 'center', vertical: 'center' },
          border: totalBorder
      });
      for (let c = 1; c <= 6; c++) {
          setCell(curRow, c, '', 's', null, { border: totalBorder, fill: { fgColor: { rgb: 'FEF3C7' } } });
      }

      setCell(curRow, 7, totalMoney, 'n', numFmt, {
          font: { name: 'Calibri', sz: 12, bold: true, color: { rgb: '92400E' } },
          fill: { fgColor: { rgb: 'FDE68A' } },
          alignment: { horizontal: 'right', vertical: 'center' },
          border: totalBorder
      });

      setCell(curRow, 8, bookingList.length + ' Đơn', 's', null, {
          font: { name: 'Calibri', sz: 10, bold: true, color: { rgb: '0F172A' } },
          fill: { fgColor: { rgb: 'FEF3C7' } },
          alignment: { horizontal: 'center', vertical: 'center' },
          border: totalBorder
      });
      rowHeights[curRow] = { hpt: 26 };

      // Set sheet properties
      ws['!ref'] = XLSX.utils.encode_range({ s: { r: 0, c: 0 }, e: { r: curRow, c: 8 } });
      ws['!merges'] = merges;
      ws['!rows'] = rowHeights;
      ws['!cols'] = [
          { wch: 12 }, // MÃ ĐẶT
          { wch: 26 }, // KHÁCH HÀNG
          { wch: 16 }, // SĐT
          { wch: 12 }, // PHÒNG
          { wch: 22 }, // LOẠI PHÒNG
          { wch: 16 }, // NGÀY NHẬN
          { wch: 16 }, // NGÀY TRẢ
          { wch: 24 }, // TỔNG TIỀN
          { wch: 18 }  // TRẠNG THÁI
      ];

      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, 'Danh Sách Đặt Phòng');
      XLSX.writeFile(wb, 'Danh_Sach_Dat_Phong_Nestora_' + new Date().toISOString().slice(0, 10) + '.xlsx');
  }
</script>
</body>
</html>
