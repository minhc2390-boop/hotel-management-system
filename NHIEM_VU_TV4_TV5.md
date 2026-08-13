# PHÂN CÔNG VÀ HƯỚNG DẪN NHIỆM VỤ DỰ ÁN QUẢN LÝ KHÁCH SẠN (NESTORA HOTEL)

Thư mục dự án này đã được sao chép riêng nhằm phục vụ cho công việc của **Thành viên 4** và **Thành viên 5**.
Toàn bộ phần mã nguồn và chức năng của **Thành viên 1, 2, 3** đã được tích hợp hoàn chỉnh và hoạt động tốt.

---

## I. TỔNG QUAN NỘI DUNG ĐÃ HOÀN THÀNH (THÀNH VIÊN 1, 2, 3)

| Thành viên | Phân hệ / Mô-đun | Các file chính phụ trách | Trạng thái |
| :--- | :--- | :--- | :---: |
| **TV1** | **Xác thực, Bảo mật & Tài khoản**<br>- Đăng ký / Đăng nhập / Đăng xuất<br>- Khôi phục & Đổi mật khẩu qua Email (Mã hóa SHA-256)<br>- Phân quyền người dùng (AuthFilter & Utf8Filter)<br>- Hồ sơ cá nhân (Profile) | 📄 `AuthServlet.java`, `LoginServlet.java`, `RegisterServlet.java`, `ForgotPasswordServlet.java`, `ProfileServlet.java`<br>📄 `UserDAO.java`, `CustomerDAO.java`, `AuthFilter.java`, `Utf8Filter.java`, `AuthUtil.java`<br>📄 `login.jsp`, `register.jsp`, `forgot-password.jsp`, `reset-password.jsp`, `profile.jsp` | ✅ **Hoàn tất** |
| **TV2** | **Quản lý Phòng & Thiết bị**<br>- Danh mục Loại phòng (Deluxe, Suite, Standard...)<br>- Danh sách Phòng vật lý (Thêm/Sửa/Xóa)<br>- Quản lý Trang thiết bị vật tư phòng | 📄 `RoomServlet.java`, `RoomTypeServlet.java`, `EquipmentServlet.java`<br>📄 `RoomDAO.java`, `RoomTypeDAO.java`, `EquipmentDAO.java`<br>📄 `admin/rooms.jsp`, `admin/room-form.jsp`, `admin/room-types.jsp`, `admin/room-type-form.jsp`, `admin/equipments.jsp`, `admin/equipment-form.jsp` | ✅ **Hoàn tất** |
| **TV3** | **Quản lý Dịch vụ Khách sạn**<br>- Quản lý Dịch vụ phát sinh (Giặt ủi, Spa, Đưa đón)<br>- Thực đơn & Vé tiệc Buffet<br>- Đăng ký & Theo dõi dịch vụ phía Khách hàng | 📄 `ServiceServlet.java`, `BuffetServlet.java`, `LaundryServlet.java`<br>📄 `ServiceDAO.java`, `BuffetMenuDAO.java`, `LaundryDAO.java`<br>📄 `admin/services.jsp`, `admin/service-form.jsp`, `admin/buffet-menu.jsp`, `admin/buffet-form.jsp`, `admin/laundry-list.jsp`<br>📄 `buffet.jsp`, `client-laundry-form.jsp` | ✅ **Hoàn tất** |

---

## II. CHI TIẾT NHIỆM VỤ DÀNH CHO THÀNH VIÊN 4

### 👤 **Thành viên 4 — Phân hệ Quản lý Đặt phòng & Nhận/Trả phòng (Booking & Reservation)**

#### 1. Phạm vi công việc:
- Quản lý quy trình tìm kiếm phòng trống theo khoảng thời gian `checkInDate` đến `checkOutDate`.
- Xử lý đặt phòng trực tuyến dành cho khách hàng vãng lai / thành viên (`/booking.jsp`).
- Xử lý Lễ tân tạo đơn đặt phòng tại quầy cho khách hàng (`/admin/booking-form.jsp`).
- Thực hiện quy trình **Check-in (Nhận phòng)**, **Check-out (Trả phòng)** và **Hủy đặt phòng** (có lý do hủy).
- Hiển thị và quản lý **Sơ đồ trạng thái phòng** realtime (`/admin/room-map.jsp`).
- Đặt thêm dịch vụ vào phòng đang lưu trú (`/admin/service-book.jsp`).

#### 2. Các File phụ trách:
- ☕ **Controller**: `src/main/java/com/hotel/controller/BookingServlet.java`
- 🗄️ **DAO**: `src/main/java/com/hotel/dao/BookingDAO.java`
- 📦 **Model**: `src/main/java/com/hotel/model/Booking.java`
- 🌐 **JSP / View**:
  - `src/main/webapp/booking.jsp` (Form đặt phòng Khách hàng)
  - `src/main/webapp/booking-receipt.jsp` (Phiếu xác nhận đặt phòng)
  - `src/main/webapp/my-bookings.jsp` (Lịch sử đặt phòng của Khách hàng)
  - `src/main/webapp/admin/bookings.jsp` (Danh sách đơn đặt phòng Admin/Lễ tân)
  - `src/main/webapp/admin/booking-form.jsp` (Form Lễ tân tạo/sửa đặt phòng)
  - `src/main/webapp/admin/room-map.jsp` (Sơ đồ phòng)
  - `src/main/webapp/admin/service-book.jsp` (Thêm dịch vụ phòng)

#### 3. Yêu cầu kỹ thuật & Nghiệp vụ cốt lõi:
- **Kiểm tra Overbooking**: Bắt buộc dùng `bookingDAO.isRoomAvailable(roomId, checkInDate, checkOutDate)` trước khi cho phép đặt.
- **Trạng thái đơn đặt phòng**: `Pending` (Khách tự đặt), `Confirmed` (Xác nhận/Admin đặt), `CheckedIn` (Đang ở), `CheckedOut` (Đã trả phòng), `Cancelled` (Đã hủy).
- Bắt buộc kiểm tra phân quyền để khách hàng chỉ xem/hủy đơn đặt phòng của chính họ.

---

## III. CHI TIẾT NHIỆM VỤ DÀNH CHO THÀNH VIÊN 5

### 👤 **Thành viên 5 — Phân hệ Hóa đơn, Thanh toán, Phản hồi & Báo cáo Doanh thu (Billing, Payment & Analytics)**

#### 1. Phạm vi công việc:
- Quản lý quy trình tính tổng tiền phòng (Số ngày ở × Giá phòng/đêm) + Tiền dịch vụ phát sinh (Giặt ủi, Buffet, Spa...).
- Tự động sinh hóa đơn khi Check-out và quản lý danh sách hóa đơn (`/admin/bills.jsp`, `/my-bills.jsp`).
- Xử lý xác nhận **Thanh toán Hóa đơn** (Tiền mặt, Chuyển khoản QR code, Thẻ ngân hàng) (`/admin/payment.jsp`, `/bill-details.jsp`).
- Xây dựng **Báo cáo Thống kê Doanh thu & Lợi nhuận** theo ngày/tháng/năm (`/admin/profits.jsp`, `/admin/dashboard.jsp`).
- Quản lý **Đánh giá / Phản hồi (Feedback)** của khách hàng (`/feedback-form.jsp`, `/admin/feedbacks.jsp`).
- Quản lý **Thông báo hệ thống** & Cài đặt thông số hệ thống (`NotificationServlet`, `SettingServlet`, `/admin/settings.jsp`).

#### 2. Các File phụ trách:
- ☕ **Controller**: 
  - `src/main/java/com/hotel/controller/BillServlet.java`
  - `src/main/java/com/hotel/controller/FeedbackServlet.java`
  - `src/main/java/com/hotel/controller/NotificationServlet.java`
  - `src/main/java/com/hotel/controller/SettingServlet.java`
- 🗄️ **DAO**:
  - `src/main/java/com/hotel/dao/BillDAO.java`
  - `src/main/java/com/hotel/dao/BillDetailDAO.java`
  - `src/main/java/com/hotel/dao/FeedbackDAO.java`
  - `src/main/java/com/hotel/dao/NotificationDAO.java`
  - `src/main/java/com/hotel/dao/SystemSettingDAO.java`
- 📦 **Model**: `Bill.java`, `BillDetail.java`, `Feedback.java`, `HotelNotification.java`, `SystemSetting.java`
- 🌐 **JSP / View**:
  - `src/main/webapp/my-bills.jsp` (Hóa đơn của tôi)
  - `src/main/webapp/bill-details.jsp` (Chi tiết hóa đơn & QR Thanh toán)
  - `src/main/webapp/feedback-form.jsp` (Gửi phản hồi)
  - `src/main/webapp/admin/bills.jsp` (Quản lý hóa đơn Admin)
  - `src/main/webapp/admin/payment.jsp` (Xác nhận thanh toán)
  - `src/main/webapp/admin/profits.jsp` (Báo cáo doanh thu & lợi nhuận)
  - `src/main/webapp/admin/dashboard.jsp` (Bảng điều khiển thống kê tổng quan)
  - `src/main/webapp/admin/feedbacks.jsp` (Quản lý đánh giá)
  - `src/main/webapp/admin/notification-list.jsp`, `notification-form.jsp` (Quản lý thông báo)
  - `src/main/webapp/admin/settings.jsp` (Cấu hình tài khoản ngân hàng QR, hệ thống)

#### 3. Yêu cầu kỹ thuật & Nghiệp vụ cốt lõi:
- **Độ chính xác tài chính**: Tổng hóa đơn = (Số đêm × Giá phòng) + ∑(Tiền dịch vụ). Không được làm tròn sai lệch số tiền.
- **Tích hợp VietQR**: Hiển thị mã VietQR động dựa trên Ngân hàng, STK và Số tiền hóa đơn lấy từ `SystemSettingDAO`.
- **Cập nhật trạng thái phòng**: Khi đánh dấu Hóa đơn `Paid` (Đã thanh toán) hoặc `Cancelled` (Đã hủy), tự động giải phóng phòng về trạng thái `Available` (Trống).

---

## IV. CẤU TRÚC CƠ SỞ DỮ LIỆU & HƯỚNG DẪN CHẠY DỰ ÁN

1. **Cơ sở dữ liệu (SQL)**:
   - Thư mục `database/` chứa 3 file SQL:
     - `init_database.sql`: Khởi tạo bảng và dữ liệu mẫu ban đầu.
     - `alter_table_laundry_notification.sql`: Cập nhật cấu trúc bảng Dịch vụ giặt ủi và Thông báo.
     - `demo_buffet_menu.sql`: Dữ liệu thực đơn buffet mẫu.
2. **Cấu hình kết nối Database**:
   - Chỉnh sửa thông tin tài khoản SQL Server / MySQL trong `src/main/java/com/hotel/dao/DBContext.java` hoặc `src/main/resources/META-INF/persistence.xml`.
