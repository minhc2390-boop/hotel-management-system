<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="com.hotel.model.RoomType" %>
<%@ page import="java.util.List" %>
<%
    HttpSession sess = request.getSession(false);
    User currentUser = (sess != null) ? (User) sess.getAttribute("currentUser") : null;
    
    if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }

    Room room = (Room) request.getAttribute("room"); // Null if Add, Not Null if Edit
    List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
    boolean isEdit = (room != null);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Sửa thông tin phòng" : "Thêm phòng mới" %> - Luxury Hotel</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

    <header>
        <div class="navbar">
            <div class="logo">🏨 LUXURY<span>HOTEL</span> <span style="font-size: 0.9rem; font-weight: normal; background-color: var(--accent); padding: 0.15rem 0.5rem; border-radius: var(--radius-sm); margin-left: 0.5rem;">ADMIN PANEL</span></div>
            <ul class="nav-links">
                <li><a href="<%= request.getContextPath() %>/home">Bảng điều khiển</a></li>
                <li><a href="<%= request.getContextPath() %>/rooms?action=list" class="active">Quản lý phòng</a></li>
                <li><a href="<%= request.getContextPath() %>/services?action=list">Quản lý dịch vụ</a></li>
                <li><a href="<%= request.getContextPath() %>/bills?action=list">Quản lý hóa đơn</a></li>
                <li class="user-info">
                    <span>Xin chào, <strong><%= currentUser.getFullName() %></strong></span>
                </li>
                <li><a href="<%= request.getContextPath() %>/logout" class="btn-logout">Đăng xuất</a></li>
            </ul>
        </div>
    </header>

    <div class="container" style="max-width: 600px;">
        <h2 class="section-title"><%= isEdit ? "Cập nhật thông tin phòng" : "Thêm phòng khách sạn mới" %></h2>

        <div class="panel">
            <form action="<%= request.getContextPath() %>/rooms" method="POST">
                <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
                <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= room.getId() %>">
                <% } %>

                <div class="form-group">
                    <label class="form-label" for="roomNumber">Số phòng</label>
                    <input type="text" id="roomNumber" name="roomNumber" class="form-control" required
                           placeholder="Ví dụ: 101, 202, 305..."
                           value="<%= isEdit ? room.getRoomNumber() : "" %>">
                </div>

                <div class="form-group">
                    <label class="form-label" for="roomTypeId">Loại phòng</label>
                    <select id="roomTypeId" name="roomTypeId" class="form-control" required>
                        <option value="">-- Chọn loại phòng --</option>
                        <% 
                            if (roomTypes != null) {
                                for (RoomType type : roomTypes) {
                                    boolean selected = isEdit && (type.getId() == room.getRoomTypeId());
                        %>
                                    <option value="<%= type.getId() %>" <%= selected ? "selected" : "" %>>
                                        <%= type.getName() %> (Sức chứa: <%= type.getCapacity() %> người)
                                    </option>
                        <% 
                                }
                            } 
                        %>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="status">Trạng thái phòng</label>
                    <select id="status" name="status" class="form-control" required>
                        <option value="Available" <%= isEdit && "Available".equals(room.getStatus()) ? "selected" : "" %>>Sẵn sàng đón khách (Available)</option>
                        <option value="Booked" <%= isEdit && "Booked".equals(room.getStatus()) ? "selected" : "" %>>Đang được thuê (Booked)</option>
                        <option value="Maintenance" <%= isEdit && "Maintenance".equals(room.getStatus()) ? "selected" : "" %>>Đang bảo trì / dọn dẹp (Maintenance)</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="description">Mô tả phòng</label>
                    <textarea id="description" name="description" class="form-control" rows="4" 
                              placeholder="Thông tin thêm về phòng, vị trí, tiện nghi..."><%= isEdit && room.getDescription() != null ? room.getDescription() : "" %></textarea>
                </div>

                <div style="display: flex; gap: 1rem; justify-content: flex-end; margin-top: 2rem;">
                    <a href="<%= request.getContextPath() %>/rooms?action=list" class="btn btn-secondary">Hủy bỏ</a>
                    <button type="submit" class="btn btn-primary">
                        <%= isEdit ? "Lưu thay đổi" : "Tạo phòng mới" %>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <footer>
        <p>&copy; 2026 Luxury Hotel. Phát triển bởi Antigravity Pair Programmer.</p>
    </footer>

</body>
</html>
