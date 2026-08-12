-- ====================================================================
-- SCRIPT KHỞI TẠO CƠ SỞ DỮ LIỆU THỰC TẾ CHO DỰ ÁN NESTORA HOTEL MANAGER
-- Hệ quản trị: Microsoft SQL Server
-- Database name: Hotel_manage
-- ====================================================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Hotel_manage')
BEGIN
    CREATE DATABASE Hotel_manage;
END
GO

USE Hotel_manage;
GO

-- 1. BẢNG USERS (Tài khoản người dùng & nhân viên)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        id INT IDENTITY(1,1) PRIMARY KEY,
        username NVARCHAR(100) NOT NULL UNIQUE,
        password NVARCHAR(255) NOT NULL,
        full_name NVARCHAR(150) NOT NULL,
        email NVARCHAR(150) NOT NULL UNIQUE,
        phone NVARCHAR(20) NULL,
        role NVARCHAR(50) NOT NULL DEFAULT 'Customer', -- Admin, Receptionist, Manager, Customer
        created_at DATETIME DEFAULT GETDATE()
    );
END
GO

-- 2. BẢNG CUSTOMERS (Khách hàng)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Customers')
BEGIN
    CREATE TABLE Customers (
        customer_id INT IDENTITY(1,1) PRIMARY KEY,
        customer_name NVARCHAR(150) NOT NULL,
        customer_phone NVARCHAR(20) NULL,
        customer_email NVARCHAR(150) NULL,
        customer_cccd NVARCHAR(20) NULL
    );
END
GO

-- 3. BẢNG ROOMTYPES (Loại phòng)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RoomTypes')
BEGIN
    CREATE TABLE RoomTypes (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL UNIQUE,
        price_per_day FLOAT NOT NULL,
        capacity INT NOT NULL,
        description NVARCHAR(MAX) NULL
    );
END
GO

-- 4. BẢNG ROOMS (Phòng nghỉ)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Rooms')
BEGIN
    CREATE TABLE Rooms (
        id INT IDENTITY(1,1) PRIMARY KEY,
        room_number NVARCHAR(50) NOT NULL UNIQUE,
        status NVARCHAR(50) NOT NULL DEFAULT 'Available', -- Available, Booked, Occupied, Maintenance
        description NVARCHAR(MAX) NULL,
        room_type_id INT NOT NULL,
        CONSTRAINT FK_Rooms_RoomTypes FOREIGN KEY (room_type_id) REFERENCES RoomTypes(id) ON DELETE CASCADE
    );
END
GO

-- 5. BẢNG SERVICES (Dịch vụ khách sạn)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Services')
BEGIN
    CREATE TABLE Services (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(150) NOT NULL,
        price FLOAT NOT NULL,
        unit NVARCHAR(50) NULL,
        description NVARCHAR(MAX) NULL
    );
END
GO

-- 6. BẢNG EQUIPMENTS (Trang thiết bị phòng)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Equipments')
BEGIN
    CREATE TABLE Equipments (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(150) NOT NULL,
        room_id INT NOT NULL,
        status NVARCHAR(50) DEFAULT 'Good',
        quantity INT DEFAULT 1,
        description NVARCHAR(MAX) NULL,
        CONSTRAINT FK_Equipments_Rooms FOREIGN KEY (room_id) REFERENCES Rooms(id) ON DELETE CASCADE
    );
END
GO

-- 7. BẢNG BOOKINGS (Đặt phòng)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Bookings')
BEGIN
    CREATE TABLE Bookings (
        booking_id INT IDENTITY(1,1) PRIMARY KEY,
        customer_id INT NOT NULL,
        room_id INT NOT NULL,
        created_by INT NULL,
        check_in_date DATETIME NOT NULL,
        check_out_date DATETIME NOT NULL,
        status NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, Confirmed, CheckedIn, CheckedOut, Cancelled
        room_price FLOAT NOT NULL,
        note NVARCHAR(MAX) NULL,
        CONSTRAINT FK_Bookings_Customers FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
        CONSTRAINT FK_Bookings_Rooms FOREIGN KEY (room_id) REFERENCES Rooms(id),
        CONSTRAINT FK_Bookings_Users FOREIGN KEY (created_by) REFERENCES Users(id)
    );
END
GO

-- 8. BẢNG BILLS (Hóa đơn thanh toán)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Bills')
BEGIN
    CREATE TABLE Bills (
        bill_id INT IDENTITY(1,1) PRIMARY KEY,
        customer_name NVARCHAR(150) NOT NULL,
        room_number NVARCHAR(50) NOT NULL,
        booking_id INT NULL,
        check_in_date DATETIME NULL,
        check_out_date DATETIME NULL,
        room_price FLOAT DEFAULT 0,
        total_amount FLOAT DEFAULT 0,
        discount FLOAT DEFAULT 0,
        created_at DATETIME DEFAULT GETDATE(),
        status NVARCHAR(50) DEFAULT 'Unpaid', -- Paid, Unpaid, Pending
        created_by INT NULL
    );
END
GO

-- 9. BẢNG BILLDETAILS (Chi tiết hóa đơn dịch vụ)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BillDetails')
BEGIN
    CREATE TABLE BillDetails (
        bill_detail_id INT IDENTITY(1,1) PRIMARY KEY,
        bill_id INT NOT NULL,
        service_name NVARCHAR(150) NOT NULL,
        price FLOAT NOT NULL,
        quantity INT NOT NULL,
        total_price FLOAT NOT NULL,
        CONSTRAINT FK_BillDetails_Bills FOREIGN KEY (bill_id) REFERENCES Bills(bill_id) ON DELETE CASCADE
    );
END
GO

-- 10. BẢNG BUFFETMENUITEMS (Thực đơn Buffet)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BuffetMenuItems')
BEGIN
    CREATE TABLE BuffetMenuItems (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(150) NOT NULL,
        category NVARCHAR(100) NOT NULL,
        price FLOAT NOT NULL,
        status NVARCHAR(50) DEFAULT 'Available',
        description NVARCHAR(MAX) NULL,
        image_url NVARCHAR(255) NULL
    );
END
GO

-- 11. BẢNG FEEDBACKS (Đánh giá khách hàng)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Feedbacks')
BEGIN
    CREATE TABLE Feedbacks (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NULL,
        booking_id INT NULL,
        rating INT NOT NULL,
        comment NVARCHAR(MAX) NULL,
        created_at DATETIME DEFAULT GETDATE(),
        admin_reply NVARCHAR(MAX) NULL,
        replied_at DATETIME NULL
    );
END
GO

-- 12. BẢNG HOTELNOTIFICATIONS (Thông báo hệ thống)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'HotelNotifications')
BEGIN
    CREATE TABLE HotelNotifications (
        id INT IDENTITY(1,1) PRIMARY KEY,
        title NVARCHAR(200) NOT NULL,
        content NVARCHAR(MAX) NOT NULL,
        type NVARCHAR(50) DEFAULT 'INFO',
        target_role NVARCHAR(50) DEFAULT 'ALL',
        created_by NVARCHAR(100) NULL,
        created_at DATETIME DEFAULT GETDATE(),
        is_read BIT DEFAULT 0
    );
END
GO

-- 13. BẢNG LAUNDRYORDERS (Đơn giặt ủi)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LaundryOrders')
BEGIN
    CREATE TABLE LaundryOrders (
        id INT IDENTITY(1,1) PRIMARY KEY,
        booking_id INT NULL,
        room_number NVARCHAR(50) NOT NULL,
        customer_name NVARCHAR(150) NOT NULL,
        laundry_items_json NVARCHAR(MAX) NULL,
        total_price FLOAT DEFAULT 0,
        status NVARCHAR(50) DEFAULT 'Pending',
        notes NVARCHAR(MAX) NULL,
        created_at DATETIME DEFAULT GETDATE(),
        completed_at DATETIME NULL,
        received_by NVARCHAR(100) NULL
    );
END
GO

-- ====================================================================
-- CHÈN DỮ LIỆU MẪU THỰC TẾ (SEED DATA)
-- ====================================================================

-- 1. Thêm Người dùng & Nhân viên mặc định
IF NOT EXISTS (SELECT * FROM Users WHERE username = 'admin')
BEGIN
    INSERT INTO Users (username, password, full_name, email, phone, role)
    VALUES 
    (N'admin', N'admin123', N'Nguyễn Văn Admin', N'admin@nestora.com', N'0901234567', N'Admin'),
    (N'receptionist1', N'123456', N'Trần Thị Lễ Tân', N'letan@nestora.com', N'0912345678', N'Receptionist'),
    (N'manager1', N'123456', N'Lê Hoàng Quản Lý', N'quanly@nestora.com', N'0923456789', N'Manager'),
    (N'khachhang1', N'123456', N'Phạm Minh Tuấn', N'tuan.pm@gmail.com', N'0987654321', N'Customer');
END
GO

-- 2. Thêm Loại phòng mẫu
IF NOT EXISTS (SELECT * FROM RoomTypes WHERE name = 'Standard')
BEGIN
    INSERT INTO RoomTypes (name, price_per_day, capacity, description)
    VALUES 
    (N'Standard', 450000, 2, N'Phòng tiêu chuẩn ấm cúng, trang bị đầy đủ tiện nghi cơ bản, thích hợp cho 2 người.'),
    (N'Deluxe City View', 850000, 2, N'Phòng cao cấp với hướng nhìn ra toàn cảnh thành phố, ban công thoáng mát và bồn tắm ngâm.'),
    (N'Executive Suite VIP', 1500000, 4, N'Căn hộ Suite sang trọng bậc nhất với phòng khách riêng biệt, minibar miễn phí và dịch vụ đưa đón.');
END
GO

-- 3. Thêm Phòng nghỉ mẫu
IF NOT EXISTS (SELECT * FROM Rooms WHERE room_number = '101')
BEGIN
    DECLARE @stdId INT = (SELECT id FROM RoomTypes WHERE name = N'Standard');
    DECLARE @delId INT = (SELECT id FROM RoomTypes WHERE name = N'Deluxe City View');
    DECLARE @suiteId INT = (SELECT id FROM RoomTypes WHERE name = N'Executive Suite VIP');

    INSERT INTO Rooms (room_number, status, description, room_type_id)
    VALUES 
    (N'101', N'Available', N'Phòng Standard tầng 1, giường đôi Queen size êm ái.', @stdId),
    (N'102', N'Available', N'Phòng Standard tầng 1, cửa sổ nhìn ra vườn cây xanh mát.', @stdId),
    (N'201', N'Available', N'Phòng Deluxe tầng 2, ban công rộng thoáng nhìn ra phố chính.', @delId),
    (N'202', N'Available', N'Phòng Deluxe tầng 2, trang bị hệ thống Smart TV 55 inch.', @delId),
    (N'301', N'Available', N'Phòng Executive Suite VIP tầng 3, có phòng khách riêng.', @suiteId),
    (N'302', N'Available', N'Phòng Executive Suite gia đình tầng 3, 2 giường King size.', @suiteId);
END
GO

-- 4. Thêm Dịch vụ mẫu
IF NOT EXISTS (SELECT * FROM Services WHERE name LIKE N'%Buffet%')
BEGIN
    INSERT INTO Services (name, price, unit, description)
    VALUES 
    (N'Ăn sáng Buffet Thượng hạng', 150000, N'Người', N'Thưởng thức buffet sáng phong phú với hơn 40 món Âu-Á thượng hạng.'),
    (N'Dịch vụ Giặt ủi cao cấp', 50000, N'Bộ', N'Giặt sấy lấy ngay trong ngày, bảo vệ sợi vải và là ủi phẳng phiêu.'),
    (N'Thuê xe máy tự chọn', 120000, N'Ngày', N'Xe tay ga và xe số đời mới, bao gồm đầy đủ nón bảo hiểm và bảo hiểm.'),
    (N'Đưa đón sân bay cao cấp', 300000, N'Lượt', N'Xe 7 chỗ sang trọng đưa đón tận sảnh sân bay 24/7.');
END
GO

-- 5. Thêm Thực đơn Buffet mẫu
IF NOT EXISTS (SELECT * FROM BuffetMenuItems WHERE name LIKE N'%Phở%')
BEGIN
    INSERT INTO BuffetMenuItems (name, category, price, status, description, image_url)
    VALUES 
    (N'Phở Bò Tái Nạm Hà Nội', N'Món Chính', 85000, N'Available', N'Nước dùng ninh từ xương ống 12 tiếng thơm lừng quế hồi.', N'assets/pho_bo.jpg'),
    (N'Bánh Mỳ Bít Tết Sốt Tiêu Đen', N'Món Chính', 110000, N'Available', N'Thịt bò Mỹ mềm mọng kèm sốt tiêu đen kèm bánh mỳ giòn rụm.', N'assets/bit_tet.jpg'),
    (N'Cà Phê Muối Xứ Huế', N'Đồ Uống', 45000, N'Available', N'Cà phê phin đậm đà hòa quyện cùng lớp kem muối béo ngậy.', N'assets/ca_phe_muoi.jpg'),
    (N'Nước Ép Dưa Hấu Tươi', N'Đồ Uống', 40000, N'Available', N'Nước ép nguyên chất 100% không đường hóa học.', N'assets/nuoc_ep.jpg');
END
GO

-- 6. Thêm Khách hàng mẫu
IF NOT EXISTS (SELECT * FROM Customers WHERE customer_name = N'Nguyễn Thị Hoa')
BEGIN
    INSERT INTO Customers (customer_name, customer_phone, customer_email, customer_cccd)
    VALUES 
    (N'Nguyễn Thị Hoa', N'0912334455', N'hoa.nguyen@gmail.com', N'001198001234'),
    (N'Hoàng Văn Nam', N'0988776655', N'nam.hoang@yahoo.com', N'001195005678');
END
GO

PRINT N'=====================================================';
PRINT N'ĐÃ KHỞI TẠO THÀNH CÔNG DATABASE Hotel_manage VỚI DỮ LIỆU THỰC TẾ!';
PRINT N'=====================================================';
GO
