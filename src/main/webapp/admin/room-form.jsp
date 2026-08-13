<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="com.hotel.model.RoomType" %>
<%@ page import="com.hotel.model.Equipment" %>
<%@ page import="com.hotel.dao.RoomDAO" %>
<%@ page import="com.hotel.dao.RoomTypeDAO" %>
<%@ page import="com.hotel.dao.EquipmentDAO" %>
<%@ page import="com.hotel.util.AuthUtil" %>
<%@ page import="com.hotel.util.ParamUtil" %>
<%@ page import="java.util.List" %>
<%!
  private String roomFormEscape(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
  }
%>
<%
  request.setCharacterEncoding("UTF-8");
  response.setCharacterEncoding("UTF-8");

  if (!AuthUtil.isAuthenticated(request)) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
  }

  User currentUser = AuthUtil.getUser(request);
  String role = currentUser != null ? currentUser.getRole() : "";
  if (!"Admin".equalsIgnoreCase(role) && !"Receptionist".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath() + "/home");
    return;
  }

  Room room = (Room) request.getAttribute("room");
  List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
  List<Equipment> roomEquipments = (List<Equipment>) request.getAttribute("roomEquipments");

  // Fallback safety if accessed directly via URL
  if (roomTypes == null || roomTypes.isEmpty()) {
    roomTypes = new RoomTypeDAO().getAllRoomTypes();
  }
  if (room == null) {
    int reqId = ParamUtil.getInt(request, "id", 0);
    if (reqId > 0) {
      room = new RoomDAO().getRoomById(reqId);
    }
  }
  boolean isEdit = room != null && room.getId() > 0;
  if (isEdit && (roomEquipments == null || roomEquipments.isEmpty())) {
    roomEquipments = new EquipmentDAO().getEquipmentsByRoomId(room.getId());
  }

  String activeMenu = "rooms";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title><%= isEdit ? "Chỉnh sửa phòng #" + room.getRoomNumber() : "Thêm phòng mới" %> - Nestora</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
  <style>
    .room-form-card {
      background: #ffffff;
      border-radius: 12px;
      border: 1px solid var(--line);
      box-shadow: 0 4px 16px rgba(28, 52, 84, 0.04);
      padding: 24px;
      margin-bottom: 24px;
    }
    .section-divider {
      margin: 28px 0 20px 0;
      padding-top: 22px;
      border-top: 1px solid var(--line);
    }
    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
      flex-wrap: wrap;
      gap: 12px;
    }
    .section-title {
      font-size: 16px;
      font-weight: 700;
      color: var(--navy);
      display: flex;
      align-items: center;
      gap: 8px;
      margin: 0;
    }
    .equip-table {
      width: 100%;
      border-collapse: separate;
      border-spacing: 0;
      border: 1px solid var(--line);
      border-radius: 10px;
      overflow: hidden;
      background: #ffffff;
    }
    .equip-table th {
      background: #f8fafc;
      color: var(--navy);
      font-size: 12px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      padding: 12px 14px;
      border-bottom: 1px solid var(--line);
      text-align: left;
    }
    .equip-table td {
      padding: 10px 14px;
      border-bottom: 1px solid #f1f5f9;
      vertical-align: middle;
      font-size: 13.5px;
    }
    .equip-table tr:last-child td {
      border-bottom: none;
    }
    .equip-table tr:hover td {
      background: #fbfcfe;
    }
    .equip-row-active td {
      background: #ffffff;
    }
    .equip-check {
      width: 18px;
      height: 18px;
      cursor: pointer;
      accent-color: var(--brand);
      margin: 0 auto;
      display: block;
    }
    .btn-action-del {
      background: #fee2e2;
      color: #dc2626;
      border: none;
      border-radius: 6px;
      width: 32px;
      height: 32px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      font-size: 16px;
      cursor: pointer;
      transition: all 0.2s;
    }
    .btn-action-del:hover {
      background: #ef4444;
      color: #ffffff;
    }
    .quick-box {
      background: #f8fafc;
      border: 1px dashed var(--brand);
      border-radius: 10px;
      padding: 18px;
      margin-top: 18px;
    }
    .quick-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 12px;
      margin-top: 10px;
      align-items: end;
    }
    .status-badge {
      display: inline-flex;
      align-items: center;
      padding: 4px 10px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
    }
    .status-good { background: #dcfce7; color: #15803d; }
    .status-check { background: #fef3c7; color: #b45309; }
    .status-maint { background: #ffedd5; color: #c2410c; }
    .status-broken { background: #fee2e2; color: #dc2626; }
    .status-default { background: #f1f5f9; color: #475569; }
  </style>
</head>
<body>
<div class="admin-layout">
  <%@ include file="../WEB-INF/jspf/admin-sidebar.jspf" %>
  <main class="main-shell">
    <%@ include file="../WEB-INF/jspf/admin-topbar.jspf" %>
    <section class="content">
      <div class="content-inner">
        
        <!-- Header -->
        <div class="page-head">
          <div>
            <div class="breadcrumb">Vận hành / Danh sách phòng / <%= isEdit ? "Chỉnh sửa #" + room.getRoomNumber() : "Thêm mới" %></div>
            <h1 class="page-title"><%= isEdit ? "Cập nhật thông tin phòng #" + room.getRoomNumber() : "Thêm phòng mới & Trang bị thiết bị" %></h1>
            <p class="page-desc">Khai báo thông tin phòng và quản lý danh mục thiết bị cố định được trang bị để tiện kiểm tra hư hao.</p>
          </div>
          <div class="page-actions">
            <a class="btn btn-outline" href="<%= request.getContextPath() %>/rooms?action=list">
              Quay lại danh sách phòng
            </a>
            <% if (isEdit) { %>
              <a class="btn btn-outline" href="<%= request.getContextPath() %>/equipments?action=list&roomId=<%= room.getId() %>">
                Xem thiết bị phòng <%= room.getRoomNumber() %>
              </a>
            <% } %>
          </div>
        </div>

        <!-- Alert messages -->
        <% if (request.getAttribute("error") != null) { %>
          <div class="alert alert-danger" style="margin-bottom: 20px; padding: 14px 18px; border-radius: 8px; background: #fee2e2; color: #991b1b; border: 1px solid #f87171; font-size: 14px; display: flex; align-items: center; gap: 8px;">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <span><strong>Lỗi:</strong> <%= roomFormEscape((String) request.getAttribute("error")) %></span>
          </div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
          <div class="alert alert-success" style="margin-bottom: 20px; padding: 14px 18px; border-radius: 8px; background: #dcfce7; color: #166534; border: 1px solid #4ade80; font-size: 14px; display: flex; align-items: center; gap: 8px;">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            <span><strong>Thành công:</strong> <%= roomFormEscape((String) request.getAttribute("success")) %></span>
          </div>
        <% } %>

        <!-- Main Form Card -->
        <div class="room-form-card">
          <form action="<%= request.getContextPath() %>/rooms" method="post" id="roomForm">
            <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
            <% if (isEdit) { %>
              <input type="hidden" name="id" value="<%= room.getId() %>">
            <% } %>

            <!-- SECTION 1: Thông tin phòng -->
            <div class="section-header">
              <h2 class="section-title">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                1. Thông tin cơ bản phòng khách sạn
              </h2>
            </div>

            <div class="form-grid">
              <div class="form-group">
                <label class="form-label" for="roomNumber">Số phòng / Mã phòng *</label>
                <input class="form-control" id="roomNumber" name="roomNumber" required placeholder="Ví dụ: 101, 202, 305..." value="<%= isEdit ? roomFormEscape(room.getRoomNumber()) : "" %>">
                <small class="form-hint">Mã định danh duy nhất cho mỗi phòng.</small>
              </div>

              <div class="form-group">
                <label class="form-label" for="roomTypeId">Loại phòng *</label>
                <select class="form-control" id="roomTypeId" name="roomTypeId" required>
                  <option value="">-- Chọn loại phòng --</option>
                  <% if (roomTypes != null) {
                    for (RoomType t : roomTypes) {
                      boolean selected = isEdit && t.getId() == room.getRoomTypeId();
                  %>
                    <option value="<%= t.getId() %>" <%= selected ? "selected" : "" %>>
                      <%= roomFormEscape(t.getName()) %> (Sức chứa: <%= t.getCapacity() %> người)
                    </option>
                  <% } } %>
                </select>
                <small class="form-hint">Xác định đơn giá và tiêu chuẩn tiện nghi phòng.</small>
              </div>

              <div class="form-group">
                <label class="form-label" for="status">Trạng thái phòng *</label>
                <select class="form-control" id="status" name="status" required>
                  <option value="Available" <%= isEdit && "Available".equalsIgnoreCase(room.getStatus()) ? "selected" : "" %>>Phòng trống (Available)</option>
                  <option value="Occupied" <%= isEdit && "Occupied".equalsIgnoreCase(room.getStatus()) ? "selected" : "" %>>Đang sử dụng (Occupied)</option>
                  <option value="Cleaning" <%= isEdit && "Cleaning".equalsIgnoreCase(room.getStatus()) ? "selected" : "" %>>Đang dọn dẹp (Cleaning)</option>
                  <option value="Booked" <%= isEdit && "Booked".equalsIgnoreCase(room.getStatus()) ? "selected" : "" %>>Đã đặt (Booked)</option>
                  <option value="Maintenance" <%= isEdit && "Maintenance".equalsIgnoreCase(room.getStatus()) ? "selected" : "" %>>Bảo trì (Maintenance)</option>
                </select>
                <small class="form-hint">Trạng thái vận hành hiện tại của phòng.</small>
              </div>

              <div class="form-group full">
                <label class="form-label" for="description">Mô tả đặc điểm phòng</label>
                <textarea class="form-control" id="description" name="description" rows="2" placeholder="Ví dụ: Tầng 2, view nhìn ra biển, có ban công thoáng mát..."><%= isEdit && room.getDescription() != null ? roomFormEscape(room.getDescription()) : "" %></textarea>
              </div>
            </div>

            <!-- SECTION 2: Quản lý thiết bị của phòng -->
            <div class="section-divider" id="equipments">
              <% if (!isEdit) { %>
                <!-- GIAO DIỆN TẠO PHÒNG MỚI: Checklist thiết bị ban đầu -->
                <div class="section-header">
                  <div>
                    <h2 class="section-title">
                      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                      2. Danh mục thiết bị cố định trang bị cho phòng mới
                    </h2>
                    <p class="form-hint" style="margin-top: 4px; margin-bottom: 0;">Đánh dấu chọn các thiết bị sẽ bàn giao vào phòng này. Hệ thống sẽ tự động tạo và liên kết trực tiếp vào phòng.</p>
                  </div>
                  <div style="display: flex; gap: 8px;">
                    <button type="button" class="btn btn-outline" id="btnToggleAll" style="font-size: 13px; padding: 6px 14px;">
                      Bỏ chọn tất cả
                    </button>
                    <button type="button" class="btn btn-outline" id="btnAddRow" style="font-size: 13px; padding: 6px 14px;">
                      + Thêm thiết bị khác
                    </button>
                  </div>
                </div>

                <div class="table-wrap" style="overflow-x: auto; margin-top: 12px;">
                  <table class="equip-table">
                    <thead>
                      <tr>
                        <th style="width: 50px; text-align: center;">CHỌN</th>
                        <th style="min-width: 200px;">TÊN THIẾT BỊ</th>
                        <th style="width: 90px;">SỐ LƯỢNG</th>
                        <th style="width: 100px;">ĐƠN VỊ</th>
                        <th style="width: 160px;">TÌNH TRẠNG</th>
                        <th style="min-width: 220px;">GHI CHÚ HƯ HAO / VỊ TRÍ</th>
                        <th style="width: 50px; text-align: center;">XÓA</th>
                      </tr>
                    </thead>
                    <tbody id="equipTableBody">
                      <!-- 1. Tivi -->
                      <tr>
                        <td style="text-align: center;">
                          <input type="checkbox" class="equip-check" name="eqEnabled" value="0" checked title="Chọn trang bị thiết bị này">
                        </td>
                        <td><input type="text" class="form-control" name="eqName" value="Tivi Smart 4K 43 inch" placeholder="Tên thiết bị" required></td>
                        <td><input type="number" class="form-control" name="eqQuantity" value="1" min="1"></td>
                        <td>
                          <select class="form-control" name="eqUnit">
                            <option value="Cái" selected>Cái</option>
                            <option value="Bộ">Bộ</option>
                            <option value="Chiếc">Chiếc</option>
                          </select>
                        </td>
                        <td>
                          <select class="form-control" name="eqStatus">
                            <option value="Hoạt động tốt" selected>Hoạt động tốt</option>
                            <option value="Cần kiểm tra">Cần kiểm tra</option>
                            <option value="Bảo trì">Bảo trì</option>
                            <option value="Hỏng">Hỏng</option>
                          </select>
                        </td>
                        <td><input type="text" class="form-control" name="eqDescription" value="Kèm điều khiển và giá treo tường" placeholder="Ghi chú..."></td>
                        <td style="text-align: center;">
                          <button type="button" class="btn-action-del" onclick="this.closest('tr').remove()" title="Xóa dòng này">×</button>
                        </td>
                      </tr>

                      <!-- 2. Máy lạnh -->
                      <tr>
                        <td style="text-align: center;"><input type="checkbox" class="equip-check" name="eqEnabled" value="1" checked></td>
                        <td><input type="text" class="form-control" name="eqName" value="Máy lạnh Inverter Daikin" placeholder="Tên thiết bị" required></td>
                        <td><input type="number" class="form-control" name="eqQuantity" value="1" min="1"></td>
                        <td>
                          <select class="form-control" name="eqUnit">
                            <option value="Bộ" selected>Bộ</option>
                            <option value="Cái">Cái</option>
                          </select>
                        </td>
                        <td>
                          <select class="form-control" name="eqStatus">
                            <option value="Hoạt động tốt" selected>Hoạt động tốt</option>
                            <option value="Cần kiểm tra">Cần kiểm tra</option>
                            <option value="Bảo trì">Bảo trì</option>
                            <option value="Hỏng">Hỏng</option>
                          </select>
                        </td>
                        <td><input type="text" class="form-control" name="eqDescription" value="Điều hòa hai chiều kèm remote" placeholder="Ghi chú..."></td>
                        <td style="text-align: center;"><button type="button" class="btn-action-del" onclick="this.closest('tr').remove()">×</button></td>
                      </tr>

                      <!-- 3. Máy sấy tóc -->
                      <tr>
                        <td style="text-align: center;"><input type="checkbox" class="equip-check" name="eqEnabled" value="2" checked></td>
                        <td><input type="text" class="form-control" name="eqName" value="Máy sấy tóc cao cấp" placeholder="Tên thiết bị" required></td>
                        <td><input type="number" class="form-control" name="eqQuantity" value="1" min="1"></td>
                        <td><select class="form-control" name="eqUnit"><option value="Cái" selected>Cái</option></select></td>
                        <td>
                          <select class="form-control" name="eqStatus">
                            <option value="Hoạt động tốt" selected>Hoạt động tốt</option>
                            <option value="Cần kiểm tra">Cần kiểm tra</option>
                            <option value="Bảo trì">Bảo trì</option>
                            <option value="Hỏng">Hỏng</option>
                          </select>
                        </td>
                        <td><input type="text" class="form-control" name="eqDescription" value="Trang bị trong phòng tắm" placeholder="Ghi chú..."></td>
                        <td style="text-align: center;"><button type="button" class="btn-action-del" onclick="this.closest('tr').remove()">×</button></td>
                      </tr>

                      <!-- 4. Tủ lạnh mini -->
                      <tr>
                        <td style="text-align: center;"><input type="checkbox" class="equip-check" name="eqEnabled" value="3" checked></td>
                        <td><input type="text" class="form-control" name="eqName" value="Tủ lạnh Mini Bar 50L" placeholder="Tên thiết bị" required></td>
                        <td><input type="number" class="form-control" name="eqQuantity" value="1" min="1"></td>
                        <td><select class="form-control" name="eqUnit"><option value="Cái" selected>Cái</option></select></td>
                        <td>
                          <select class="form-control" name="eqStatus">
                            <option value="Hoạt động tốt" selected>Hoạt động tốt</option>
                            <option value="Cần kiểm tra">Cần kiểm tra</option>
                            <option value="Bảo trì">Bảo trì</option>
                            <option value="Hỏng">Hỏng</option>
                          </select>
                        </td>
                        <td><input type="text" class="form-control" name="eqDescription" value="Tủ lạnh mini bảo quản đồ uống" placeholder="Ghi chú..."></td>
                        <td style="text-align: center;"><button type="button" class="btn-action-del" onclick="this.closest('tr').remove()">×</button></td>
                      </tr>

                      <!-- 5. Bình đun -->
                      <tr>
                        <td style="text-align: center;"><input type="checkbox" class="equip-check" name="eqEnabled" value="4" checked></td>
                        <td><input type="text" class="form-control" name="eqName" value="Bình đun siêu tốc 1.8L" placeholder="Tên thiết bị" required></td>
                        <td><input type="number" class="form-control" name="eqQuantity" value="1" min="1"></td>
                        <td><select class="form-control" name="eqUnit"><option value="Cái" selected>Cái</option></select></td>
                        <td>
                          <select class="form-control" name="eqStatus">
                            <option value="Hoạt động tốt" selected>Hoạt động tốt</option>
                            <option value="Cần kiểm tra">Cần kiểm tra</option>
                            <option value="Bảo trì">Bảo trì</option>
                            <option value="Hỏng">Hỏng</option>
                          </select>
                        </td>
                        <td><input type="text" class="form-control" name="eqDescription" value="Kèm khay trà cà phê" placeholder="Ghi chú..."></td>
                        <td style="text-align: center;"><button type="button" class="btn-action-del" onclick="this.closest('tr').remove()">×</button></td>
                      </tr>

                      <!-- 6. Két sắt -->
                      <tr>
                        <td style="text-align: center;"><input type="checkbox" class="equip-check" name="eqEnabled" value="5" checked></td>
                        <td><input type="text" class="form-control" name="eqName" value="Két sắt an toàn điện tử" placeholder="Tên thiết bị" required></td>
                        <td><input type="number" class="form-control" name="eqQuantity" value="1" min="1"></td>
                        <td><select class="form-control" name="eqUnit"><option value="Cái" selected>Cái</option></select></td>
                        <td>
                          <select class="form-control" name="eqStatus">
                            <option value="Hoạt động tốt" selected>Hoạt động tốt</option>
                            <option value="Cần kiểm tra">Cần kiểm tra</option>
                            <option value="Bảo trì">Bảo trì</option>
                            <option value="Hỏng">Hỏng</option>
                          </select>
                        </td>
                        <td><input type="text" class="form-control" name="eqDescription" value="Khóa mã số điện tử an toàn" placeholder="Ghi chú..."></td>
                        <td style="text-align: center;"><button type="button" class="btn-action-del" onclick="this.closest('tr').remove()">×</button></td>
                      </tr>

                      <!-- 7. Bình nóng lạnh -->
                      <tr>
                        <td style="text-align: center;"><input type="checkbox" class="equip-check" name="eqEnabled" value="6" checked></td>
                        <td><input type="text" class="form-control" name="eqName" value="Bình nóng lạnh 30L" placeholder="Tên thiết bị" required></td>
                        <td><input type="number" class="form-control" name="eqQuantity" value="1" min="1"></td>
                        <td>
                          <select class="form-control" name="eqUnit">
                            <option value="Bộ" selected>Bộ</option>
                            <option value="Cái">Cái</option>
                          </select>
                        </td>
                        <td>
                          <select class="form-control" name="eqStatus">
                            <option value="Hoạt động tốt" selected>Hoạt động tốt</option>
                            <option value="Cần kiểm tra">Cần kiểm tra</option>
                            <option value="Bảo trì">Bảo trì</option>
                            <option value="Hỏng">Hỏng</option>
                          </select>
                        </td>
                        <td><input type="text" class="form-control" name="eqDescription" value="Hệ thống nước nóng phòng tắm" placeholder="Ghi chú..."></td>
                        <td style="text-align: center;"><button type="button" class="btn-action-del" onclick="this.closest('tr').remove()">×</button></td>
                      </tr>
                    </tbody>
                  </table>
                </div>

              <% } else { %>
                <!-- GIAO DIỆN CHỈNH SỬA PHÒNG: Xem & kiểm tra thiết bị phòng -->
                <div class="section-header">
                  <div>
                    <h2 class="section-title">
                      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                      2. Danh sách thiết bị cố định phòng <%= room.getRoomNumber() %> (<%= roomEquipments != null ? roomEquipments.size() : 0 %> thiết bị)
                    </h2>
                    <p class="form-hint" style="margin-top: 4px; margin-bottom: 0;">Kiểm tra tình trạng hoạt động và ghi nhận hư hao trang thiết bị phòng.</p>
                  </div>
                  <div>
                    <a class="btn btn-primary" style="font-size: 13px; padding: 7px 16px;" href="<%= request.getContextPath() %>/equipments?action=add&roomId=<%= room.getId() %>">
                      + Thêm thiết bị vào phòng này
                    </a>
                  </div>
                </div>

                <% if (roomEquipments != null && !roomEquipments.isEmpty()) { %>
                  <div class="table-wrap" style="overflow-x: auto; margin-top: 12px;">
                    <table class="equip-table">
                      <thead>
                        <tr>
                          <th style="width: 90px;">MÃ TB</th>
                          <th style="min-width: 180px;">TÊN THIẾT BỊ</th>
                          <th style="width: 90px;">SỐ LƯỢNG</th>
                          <th style="width: 90px;">ĐƠN VỊ</th>
                          <th style="width: 150px;">TÌNH TRẠNG KIỂM TRA</th>
                          <th style="min-width: 220px;">GHI CHÚ HƯ HAO / VỊ TRÍ</th>
                          <th style="width: 140px; text-align: center;">THAO TÁC</th>
                        </tr>
                      </thead>
                      <tbody>
                        <% for (Equipment eq : roomEquipments) {
                            String st = eq.getStatus() != null ? eq.getStatus() : "";
                            String statusBadgeClass = "status-good";
                            if (st.contains("kiểm tra") || "NeedInspection".equalsIgnoreCase(st)) {
                              statusBadgeClass = "status-check";
                            } else if (st.contains("Bảo trì") || "Maintenance".equalsIgnoreCase(st)) {
                              statusBadgeClass = "status-maint";
                            } else if (st.contains("Hỏng") || "Broken".equalsIgnoreCase(st)) {
                              statusBadgeClass = "status-broken";
                            }
                        %>
                          <tr>
                            <td style="font-weight: 700; color: var(--brand);">#TB<%= String.format("%03d", eq.getEquipmentId()) %></td>
                            <td style="font-weight: 600; color: var(--navy);"><%= roomFormEscape(eq.getEquipmentName()) %></td>
                            <td><%= eq.getTotalQuantity() %></td>
                            <td><%= roomFormEscape(eq.getUnit()) %></td>
                            <td><span class="status-badge <%= statusBadgeClass %>"><%= roomFormEscape(st.isEmpty() ? "Hoạt động tốt" : st) %></span></td>
                            <td style="color: var(--text);"><%= eq.getDescription() != null && !eq.getDescription().isEmpty() ? roomFormEscape(eq.getDescription()) : "—" %></td>
                            <td style="text-align: center;">
                              <div style="display: inline-flex; gap: 6px;">
                                <a class="btn btn-outline" style="font-size: 12px; padding: 4px 8px;" href="<%= request.getContextPath() %>/equipments?action=edit&id=<%= eq.getEquipmentId() %>">Sửa / Báo hỏng</a>
                                <a class="btn btn-danger" style="font-size: 12px; padding: 4px 8px;" href="<%= request.getContextPath() %>/equipments?action=delete&id=<%= eq.getEquipmentId() %>&roomId=<%= room.getId() %>" onclick="return confirm('Xóa thiết bị <%= roomFormEscape(eq.getEquipmentName()) %> khỏi phòng này?');">Xóa</a>
                              </div>
                            </td>
                          </tr>
                        <% } %>
                      </tbody>
                    </table>
                  </div>
                <% } else { %>
                  <div class="empty" style="padding: 24px 16px; background: #f8fafc; border-radius: 10px; text-align: center; margin-top: 12px; border: 1px solid var(--line);">
                    <strong style="color: var(--navy); display: block; margin-bottom: 4px;">Phòng này chưa được gán thiết bị nào</strong>
                    <span style="color: var(--muted); font-size: 13px;">Bạn có thể thêm nhanh thiết bị vào phòng này ngay phía dưới.</span>
                  </div>
                <% } %>

                <!-- Thêm nhanh 1 thiết bị vào phòng -->
                <div class="quick-box">
                  <strong style="color: var(--navy); font-size: 14px; display: flex; align-items: center; gap: 6px;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                    Thêm nhanh thiết bị mới vào phòng <%= room.getRoomNumber() %>:
                  </strong>
                  <div class="quick-grid">
                    <div>
                      <label class="form-label" style="font-size: 12px;">Tên thiết bị</label>
                      <input type="text" class="form-control" name="newEqName" placeholder="Ví dụ: Bàn ủi, Loa bluetooth...">
                    </div>
                    <div style="max-width: 100px;">
                      <label class="form-label" style="font-size: 12px;">Số lượng</label>
                      <input type="number" class="form-control" name="newEqQuantity" value="1" min="1">
                    </div>
                    <div style="max-width: 110px;">
                      <label class="form-label" style="font-size: 12px;">Đơn vị</label>
                      <select class="form-control" name="newEqUnit">
                        <option value="Cái">Cái</option>
                        <option value="Bộ">Bộ</option>
                        <option value="Chiếc">Chiếc</option>
                      </select>
                    </div>
                    <div>
                      <label class="form-label" style="font-size: 12px;">Tình trạng ban đầu</label>
                      <select class="form-control" name="newEqStatus">
                        <option value="Hoạt động tốt" selected>Hoạt động tốt</option>
                        <option value="Cần kiểm tra">Cần kiểm tra</option>
                        <option value="Bảo trì">Bảo trì</option>
                        <option value="Hỏng">Hỏng</option>
                      </select>
                    </div>
                    <div>
                      <label class="form-label" style="font-size: 12px;">Ghi chú hư hao / Vị trí</label>
                      <input type="text" class="form-control" name="newEqDescription" placeholder="Vị trí đặt, tình trạng...">
                    </div>
                  </div>
                </div>

              <% } %>
            </div>

            <!-- Form Actions -->
            <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 28px; border-top: 1px solid var(--line); padding-top: 20px;">
              <a class="btn btn-outline" href="<%= request.getContextPath() %>/rooms?action=list">Hủy</a>
              <button class="btn btn-primary" type="submit">
                <%= isEdit ? "Lưu thay đổi phòng" : "Tạo phòng & Lưu thiết bị" %>
              </button>
            </div>
          </form>
        </div>

      </div>
    </section>
  </main>
</div>

<script src="<%= request.getContextPath() %>/js/app.js"></script>
<script>
  (function () {
    const btnToggleAll = document.getElementById('btnToggleAll');
    const btnAddRow = document.getElementById('btnAddRow');
    const tbody = document.getElementById('equipTableBody');

    if (btnToggleAll && tbody) {
      let isAllSelected = true;
      btnToggleAll.addEventListener('click', function () {
        const checkboxes = tbody.querySelectorAll('.equip-check');
        isAllSelected = !isAllSelected;
        checkboxes.forEach(cb => { cb.checked = isAllSelected; });
        btnToggleAll.textContent = isAllSelected ? 'Bỏ chọn tất cả' : 'Chọn tất cả';
      });
    }

    if (btnAddRow && tbody) {
      btnAddRow.addEventListener('click', function () {
        const rowCount = tbody.querySelectorAll('tr').length;
        const tr = document.createElement('tr');
        tr.innerHTML = `
          <td style="text-align: center;">
            <input type="checkbox" class="equip-check" name="eqEnabled" value="${rowCount}" checked>
          </td>
          <td><input type="text" class="form-control" name="eqName" placeholder="Tên thiết bị mới..." required></td>
          <td><input type="number" class="form-control" name="eqQuantity" value="1" min="1"></td>
          <td>
            <select class="form-control" name="eqUnit">
              <option value="Cái" selected>Cái</option>
              <option value="Bộ">Bộ</option>
              <option value="Chiếc">Chiếc</option>
            </select>
          </td>
          <td>
            <select class="form-control" name="eqStatus">
              <option value="Hoạt động tốt" selected>Hoạt động tốt</option>
              <option value="Cần kiểm tra">Cần kiểm tra</option>
              <option value="Bảo trì">Bảo trì</option>
              <option value="Hỏng">Hỏng</option>
            </select>
          </td>
          <td><input type="text" class="form-control" name="eqDescription" placeholder="Ghi chú tình trạng / hư hao..."></td>
          <td style="text-align: center;">
            <button type="button" class="btn-action-del" onclick="this.closest('tr').remove()" title="Xóa dòng này">×</button>
          </td>
        `;
        tbody.appendChild(tr);
      });
    }
  })();
</script>
</body>
</html>
