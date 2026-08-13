<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Room" %>
<<<<<<< HEAD
<%@ page import="com.hotel.dao.RoomDAO" %>
=======
<%@ page import="com.hotel.model.Booking" %>
<%@ page import="com.hotel.dao.RoomDAO" %>
<%@ page import="com.hotel.dao.BookingDAO" %>
>>>>>>> 06d2f05fb617ae75d9425627b09472113407a437
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = sess != null ? (User)sess.getAttribute("currentUser") : null;
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    String activeMenu = "roomMap";
<<<<<<< HEAD
    RoomDAO roomDAO = new RoomDAO();
    roomDAO.syncRoomStatuses();
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    if (rooms == null) {
        rooms = roomDAO.getAllRooms();
    }
    NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
=======

    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    if (rooms == null) {
        rooms = new RoomDAO().getAllRooms();
    }

    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    if (bookings == null) {
        bookings = new BookingDAO().getAllBookings();
    }

    NumberFormat money = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));

    long availableCount = 0;
    long bookedCount = 0;
    long maintenanceCount = 0;
    if (rooms != null) {
        for (Room r : rooms) {
            if ("Available".equalsIgnoreCase(r.getStatus())) availableCount++;
            else if ("Booked".equalsIgnoreCase(r.getStatus())) bookedCount++;
            else if ("Maintenance".equalsIgnoreCase(r.getStatus())) maintenanceCount++;
        }
    }
    int totalRooms = rooms != null ? rooms.size() : 0;
>>>>>>> 06d2f05fb617ae75d9425627b09472113407a437
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>Sơ đồ phòng - Nestora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css" />
    <style>
      .room-map-filters {
        display: flex;
        gap: 8px;
        margin-bottom: 20px;
        flex-wrap: wrap;
      }
      .filter-tab {
        padding: 8px 16px;
        border-radius: 6px;
        border: 1px solid var(--line, #cbd5e1);
        background: var(--surface, #ffffff);
        color: var(--text, #334155);
        font-weight: 600;
        font-size: 13px;
        cursor: pointer;
        transition: all 0.2s ease;
      }
      .filter-tab.active {
        background: var(--brand, #1769e0);
        color: #ffffff;
        border-color: var(--brand, #1769e0);
      }
      .room-tile-link {
        text-decoration: none;
        color: inherit;
        display: block;
        transition: transform 0.18s ease, box-shadow 0.18s ease;
      }
      .room-tile-link:hover {
        transform: translateY(-4px);
      }
      .room-tile {
        position: relative;
        border: 1px solid var(--line, #e2e8f0);
        border-radius: 10px;
        padding: 16px;
        background: var(--surface, #ffffff);
        transition: all 0.2s ease;
        display: flex;
        flex-direction: column;
        gap: 8px;
      }
      .tile-available {
        border-left: 5px solid #16a36a;
      }
      .tile-available:hover {
        border-color: #16a36a;
        box-shadow: 0 8px 20px rgba(22, 163, 106, 0.15);
      }
      .tile-booked {
        border-left: 5px solid #1769e0;
        background: #f8fafc;
      }
      .tile-booked:hover {
        border-color: #1769e0;
        box-shadow: 0 8px 20px rgba(23, 105, 224, 0.15);
      }
      .tile-maintenance {
        border-left: 5px solid #f59e0b;
        background: #fffbeb;
      }
      .tile-maintenance:hover {
        border-color: #f59e0b;
        box-shadow: 0 8px 20px rgba(245, 158, 11, 0.15);
      }
      .room-tile-head {
        display: flex;
        align-items: center;
        justify-content: space-between;
      }
      .room-badge {
        font-size: 11px;
        font-weight: 700;
        padding: 3px 8px;
        border-radius: 4px;
        text-transform: uppercase;
      }
      .badge-Available { background: #d1fae5; color: #059669; }
      .badge-Booked { background: #dbeafe; color: #2563eb; }
      .badge-Maintenance { background: #fef3c7; color: #d97706; }
      
      .room-btn-action {
        margin-top: 6px;
        padding: 6px 12px;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 700;
        text-align: center;
        transition: background 0.2s ease;
      }
      .btn-action-available {
        background: #16a36a;
        color: #ffffff;
      }
      .room-tile-link:hover .btn-action-available {
        background: #15803d;
      }
      .btn-action-booked {
        background: #e2e8f0;
        color: #1e293b;
      }
      .btn-action-maintenance {
        background: #fef3c7;
        color: #d97706;
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
                <div class="breadcrumb">Vận hành / Sơ đồ phòng</div>
                <h1 class="page-title">Sơ đồ phòng</h1>
<<<<<<< HEAD
                <p class="page-desc">Theo dõi trạng thái phòng theo từng tầng và cập nhật dọn dẹp, bảo trì.</p>
=======
                <p class="page-desc">Nhấn vào phòng còn trống để tiến hành đặt phòng trực tiếp.</p>
>>>>>>> 06d2f05fb617ae75d9425627b09472113407a437
              </div>
              <div class="page-actions">
                <a class="btn btn-primary" href="<%= request.getContextPath() %>/rooms?action=add">＋ Thêm phòng</a>
              </div>
            </div>
<<<<<<< HEAD
            <section class="surface surface-pad">
              <div class="surface-head" style="padding: 0 0 16px">
                <div>
                  <h2 class="surface-title">Danh sách phòng thực tế</h2>
                  <p class="surface-subtitle"><%= rooms != null ? rooms.size() : 0 %> phòng đang quản lý trên hệ thống</p>
                </div>
              </div>
              <div class="room-map-grid">
                <% if (rooms != null && !rooms.isEmpty()) {
                    for (Room r : rooms) {
                        String dotColor = "#16a36a"; // Available
                        String statusLabel = "Trống";
                        if ("Occupied".equalsIgnoreCase(r.getStatus())) {
                            dotColor = "#1769e0";
                            statusLabel = "Đang sử dụng";
                        } else if ("Cleaning".equalsIgnoreCase(r.getStatus())) {
                            dotColor = "#f59e0b";
                            statusLabel = "Dọn dẹp";
                        } else if ("Maintenance".equalsIgnoreCase(r.getStatus())) {
                            dotColor = "#ff4163";
                            statusLabel = "Bảo trì";
                        } else if ("Booked".equalsIgnoreCase(r.getStatus())) {
                            dotColor = "#8b5cf6";
                            statusLabel = "Đã đặt";
                        }
                %>
                  <a href="<%= request.getContextPath() %>/rooms?action=edit&id=<%= r.getId() %>" class="room-tile" style="text-decoration: none; color: inherit;">
                    <span class="room-dot" style="background: <%= dotColor %>"></span>
                    <div class="room-no">Phòng <%= r.getRoomNumber() %></div>
                    <div class="room-type"><%= r.getRoomType() != null ? r.getRoomType().getName() : "-" %></div>
                    <div class="room-person" style="font-weight: 700; color: <%= dotColor %>"><%= statusLabel %></div>
                    <div class="room-price"><%= r.getRoomType() != null ? money.format(r.getRoomType().getPricePerDay()) : "-" %></div>
                  </a>
                <% } } else { %>
                  <div class="empty">Chưa có phòng nào trong hệ thống</div>
=======

            <div class="room-map-filters" id="room-filters">
              <button class="filter-tab active" data-filter="all">Tất cả (<%= totalRooms %>)</button>
              <button class="filter-tab" data-filter="Available">🟢 Phòng trống (<%= availableCount %>)</button>
              <button class="filter-tab" data-filter="Booked">🔵 Đang ở (<%= bookedCount %>)</button>
              <button class="filter-tab" data-filter="Maintenance">🟡 Bảo trì (<%= maintenanceCount %>)</button>
            </div>

            <section class="surface surface-pad">
              <div class="surface-head" style="padding: 0 0 16px">
                <div>
                  <h2 class="surface-title">Danh sách phòng hiện tại</h2>
                  <p class="surface-subtitle">Hiển thị <%= totalRooms %> phòng trong hệ thống</p>
                </div>
              </div>

              <div class="room-map-grid" id="room-grid">
                <%
                  if (rooms != null && !rooms.isEmpty()) {
                    for (Room r : rooms) {
                      String status = r.getStatus() != null ? r.getStatus() : "Available";
                      boolean isAvailable = "Available".equalsIgnoreCase(status);
                      boolean isBooked = "Booked".equalsIgnoreCase(status);
                      boolean isMaintenance = "Maintenance".equalsIgnoreCase(status);

                      String dotColor = "#16a36a";
                      String statusBadgeText = "Phòng trống";
                      String personText = "Trống";
                      String linkUrl = request.getContextPath() + "/bookings?action=add&roomId=" + r.getId();
                      String titleText = "Bấm vào để chọn đặt phòng " + r.getRoomNumber();
                      String actionBtnText = "＋ Đặt phòng này";
                      String actionBtnClass = "btn-action-available";

                      if (isBooked) {
                        dotColor = "#1769e0";
                        statusBadgeText = "Đang ở";
                        personText = "Đang ở";
                        titleText = "Phòng đang có khách ở";
                        actionBtnText = "📄 Xem phiếu đặt";
                        actionBtnClass = "btn-action-booked";
                        linkUrl = request.getContextPath() + "/bookings?action=list";

                        if (bookings != null) {
                          for (Booking b : bookings) {
                            if (b.getRoom() != null && b.getRoom().getId() == r.getId()
                                && !"Cancelled".equalsIgnoreCase(b.getStatus())
                                && !"CheckedOut".equalsIgnoreCase(b.getStatus())) {
                              if (b.getCustomer() != null && b.getCustomer().getCustomerName() != null) {
                                personText = b.getCustomer().getCustomerName();
                              }
                              linkUrl = request.getContextPath() + "/bookings?action=receipt&id=" + b.getBookingId();
                              titleText = "Xem chi tiết phiếu đặt phòng của " + personText;
                              break;
                            }
                          }
                        }
                      } else if (isMaintenance) {
                        dotColor = "#f59e0b";
                        statusBadgeText = "Bảo trì";
                        personText = "Cần dọn / Bảo trì";
                        linkUrl = request.getContextPath() + "/rooms?action=edit&id=" + r.getId();
                        titleText = "Chỉnh sửa thông tin phòng " + r.getRoomNumber();
                        actionBtnText = "✎ Cập nhật phòng";
                        actionBtnClass = "btn-action-maintenance";
                      }
                %>
                <a class="room-tile-link" href="<%= linkUrl %>" data-status="<%= status %>" title="<%= titleText %>">
                  <div class="room-tile <%= isAvailable ? "tile-available" : (isBooked ? "tile-booked" : "tile-maintenance") %>">
                    <div class="room-tile-head">
                      <span class="room-dot" style="background: <%= dotColor %>;"></span>
                      <span class="room-badge badge-<%= status %>"><%= statusBadgeText %></span>
                    </div>
                    <div class="room-no">Phòng <%= r.getRoomNumber() %></div>
                    <div class="room-type"><%= r.getRoomType() != null ? r.getRoomType().getName() : "Phòng" %></div>
                    <div class="room-person"><%= personText %></div>
                    <div class="room-price"><%= r.getRoomType() != null ? money.format(r.getRoomType().getPricePerDay()) : "" %></div>
                    <div class="room-btn-action <%= actionBtnClass %>"><%= actionBtnText %></div>
                  </div>
                </a>
                <%
                    }
                  } else {
                %>
                  <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: var(--muted);">Chưa có thông tin phòng nào.</div>
>>>>>>> 06d2f05fb617ae75d9425627b09472113407a437
                <% } %>
              </div>
            </section>
          </div>
        </section>
          </div>
        </section>
      </main>
    </div>
    <script src="<%= request.getContextPath() %>/js/app.js"></script>
    <script>
      (function() {
        const filterTabs = document.querySelectorAll('#room-filters .filter-tab');
        const roomLinks = document.querySelectorAll('#room-grid .room-tile-link');

        filterTabs.forEach(function(tab) {
          tab.addEventListener('click', function() {
            filterTabs.forEach(function(t) { t.classList.remove('active'); });
            tab.classList.add('active');

            const filter = tab.dataset.filter;
            roomLinks.forEach(function(link) {
              if (filter === 'all' || link.dataset.status.toLowerCase() === filter.toLowerCase()) {
                link.style.display = 'block';
              } else {
                link.style.display = 'none';
              }
            });
          });
        });
      })();
    </script>
  </body>
</html>
