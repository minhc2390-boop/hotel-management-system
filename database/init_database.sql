-- ====================================================================
-- SCRIPT KHỞI TẠO CƠ SỞ DỮ LIỆU ĐỒNG BỘ 100% VỚI JPA HIBERNATE
-- Dự án: NESTORA HOTEL MANAGEMENT SYSTEM
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
IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
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

-- 2. BẢNG CUSTOMERS (Thông tin khách hàng lưu trú)
IF OBJECT_ID(N'dbo.CUSTOMERS', N'U') IS NULL
BEGIN
    CREATE TABLE CUSTOMERS (
        customer_id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NULL,
        customer_name NVARCHAR(100) NOT NULL,
        customer_cccd NVARCHAR(20) NULL UNIQUE,
        customer_phone NVARCHAR(20) NULL,
        customer_email NVARCHAR(150) NULL,
        CONSTRAINT FK_Customers_Users FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE SET NULL
    );
END
ELSE
BEGIN
    IF COL_LENGTH('dbo.CUSTOMERS', 'user_id') IS NULL
    BEGIN
        ALTER TABLE dbo.CUSTOMERS ADD user_id INT NULL;
        ALTER TABLE dbo.CUSTOMERS ADD CONSTRAINT FK_Customers_Users FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE SET NULL;
    END
END
GO

-- 3. BẢNG ROOMTYPES (Loại phòng)
IF OBJECT_ID(N'dbo.RoomTypes', N'U') IS NULL
BEGIN
    CREATE TABLE RoomTypes (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL UNIQUE,
        price_per_day FLOAT NOT NULL,
        capacity INT NOT NULL DEFAULT 2,
        description NVARCHAR(MAX) NULL
    );
END
GO

-- 4. BẢNG ROOMS (Phòng nghỉ)
IF OBJECT_ID(N'dbo.Rooms', N'U') IS NULL
BEGIN
    CREATE TABLE Rooms (
        id INT IDENTITY(1,1) PRIMARY KEY,
        room_number NVARCHAR(50) NOT NULL UNIQUE,
        status NVARCHAR(50) NOT NULL DEFAULT 'Available', -- Available, Booked, Maintenance, Cleaning
        description NVARCHAR(MAX) NULL,
        room_type_id INT NOT NULL,
        CONSTRAINT FK_Rooms_RoomTypes FOREIGN KEY (room_type_id) REFERENCES RoomTypes(id) ON DELETE CASCADE
    );
END
GO

-- 5. BẢNG SERVICES (Dịch vụ khách sạn)
IF OBJECT_ID(N'dbo.Services', N'U') IS NULL
BEGIN
    CREATE TABLE Services (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(150) NOT NULL UNIQUE,
        price FLOAT NOT NULL,
        unit NVARCHAR(50) NULL,
        status NVARCHAR(50) DEFAULT 'Active', -- Active, Inactive
        description NVARCHAR(MAX) NULL
    );
END
GO

-- 6. BẢNG EQUIPMENTS (Trang thiết bị phòng)
IF OBJECT_ID(N'dbo.EQUIPMENTS', N'U') IS NULL
BEGIN
    CREATE TABLE EQUIPMENTS (
        equipment_id INT IDENTITY(1,1) PRIMARY KEY,
        room_id INT NULL,
        equipment_name NVARCHAR(150) NOT NULL,
        total_quantity INT NOT NULL DEFAULT 1,
        unit NVARCHAR(20) DEFAULT N'Cái',
        status NVARCHAR(50) DEFAULT N'Hoạt động tốt', -- Hoạt động tốt, Cần kiểm tra, Bảo trì, Hỏng
        description NVARCHAR(500) NULL,
        CONSTRAINT FK_Equipments_Rooms FOREIGN KEY (room_id) REFERENCES Rooms(id) ON DELETE SET NULL
    );
END
GO

-- 7. BẢNG BOOKINGS (Đặt phòng)
IF OBJECT_ID(N'dbo.BOOKINGS', N'U') IS NULL
BEGIN
    CREATE TABLE BOOKINGS (
        booking_id INT IDENTITY(1,1) PRIMARY KEY,
        customer_id INT NOT NULL,
        room_id INT NOT NULL,
        created_by INT NOT NULL,
        check_in_date DATETIME NOT NULL,
        check_out_date DATETIME NOT NULL,
        status NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, Confirmed, CheckedIn, CheckedOut, Cancelled
        room_price FLOAT NOT NULL,
        note NVARCHAR(MAX) NULL,
        cancellation_reason NVARCHAR(500) NULL,
        CONSTRAINT FK_Bookings_Customers FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
        CONSTRAINT FK_Bookings_Rooms FOREIGN KEY (room_id) REFERENCES Rooms(id),
        CONSTRAINT FK_Bookings_Users FOREIGN KEY (created_by) REFERENCES Users(id)
    );
END
GO

-- 8. BẢNG BILLS (Hóa đơn thanh toán)
IF OBJECT_ID(N'dbo.Bills', N'U') IS NULL
BEGIN
    CREATE TABLE Bills (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        customer_id INT NULL,
        check_in_date DATETIME NOT NULL,
        check_out_date DATETIME NULL,
        total_amount FLOAT DEFAULT 0,
        status NVARCHAR(50) NOT NULL DEFAULT 'Unpaid', -- Unpaid, Paid, Cancelled
        payment_method NVARCHAR(30) NULL, -- Cash, BankTransfer, Card
        created_at DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_Bills_Users FOREIGN KEY (user_id) REFERENCES Users(id),
        CONSTRAINT FK_Bills_Customers FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
    );
END
GO

-- 9. BẢNG BILLDETAILS (Chi tiết hóa đơn - Tiền phòng & Dịch vụ)
IF OBJECT_ID(N'dbo.BillDetails', N'U') IS NULL
BEGIN
    CREATE TABLE BillDetails (
        id INT IDENTITY(1,1) PRIMARY KEY,
        bill_id INT NOT NULL,
        room_id INT NULL,
        service_id INT NULL,
        quantity INT NOT NULL DEFAULT 1,
        price FLOAT NOT NULL DEFAULT 0,
        CONSTRAINT FK_BillDetails_Bills FOREIGN KEY (bill_id) REFERENCES Bills(id) ON DELETE CASCADE,
        CONSTRAINT FK_BillDetails_Rooms FOREIGN KEY (room_id) REFERENCES Rooms(id),
        CONSTRAINT FK_BillDetails_Services FOREIGN KEY (service_id) REFERENCES Services(id)
    );
END
GO

-- 10. BẢNG BUFFETMENUITEMS (Thực đơn Buffet theo ngày & buổi)
IF OBJECT_ID(N'dbo.BuffetMenuItems', N'U') IS NULL
BEGIN
    CREATE TABLE BuffetMenuItems (
        id INT IDENTITY(1,1) PRIMARY KEY,
        menu_date DATE NOT NULL,
        meal_period VARCHAR(20) NOT NULL, -- Breakfast, Lunch, Dinner
        category NVARCHAR(80) NOT NULL,
        dish_name NVARCHAR(160) NOT NULL,
        description NVARCHAR(1000) NULL,
        image_url NVARCHAR(500) NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'Active',
        sort_order INT NOT NULL DEFAULT 0
    );
END
GO

-- 11. BẢNG FEEDBACKS (Đánh giá sau khi trả phòng)
IF OBJECT_ID(N'dbo.Feedbacks', N'U') IS NULL
BEGIN
    CREATE TABLE Feedbacks (
        id INT IDENTITY(1,1) PRIMARY KEY,
        booking_id INT NOT NULL UNIQUE,
        customer_user_id INT NOT NULL,
        rating INT NOT NULL,
        content NVARCHAR(2000) NOT NULL,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_Feedbacks_Bookings FOREIGN KEY (booking_id) REFERENCES BOOKINGS(booking_id),
        CONSTRAINT FK_Feedbacks_Users FOREIGN KEY (customer_user_id) REFERENCES Users(id)
    );
END
GO

-- 12. BẢNG HOTELNOTIFICATION (Thông báo hệ thống nội bộ)
IF OBJECT_ID(N'dbo.HotelNotification', N'U') IS NULL
BEGIN
    CREATE TABLE HotelNotification (
        notification_id INT IDENTITY(1,1) PRIMARY KEY,
        title NVARCHAR(200) NOT NULL,
        content NVARCHAR(MAX) NOT NULL,
        type VARCHAR(30) NOT NULL DEFAULT 'INFO', -- INFO, WARNING, SUCCESS, ERROR
        created_at DATETIME DEFAULT GETDATE(),
        created_by INT NULL,
        is_active BIT DEFAULT 1,
        CONSTRAINT FK_HotelNotification_Users FOREIGN KEY (created_by) REFERENCES Users(id) ON DELETE SET NULL
    );
END
GO

-- 13. BẢNG LAUNDRY (Đơn dịch vụ giặt ủi)
IF OBJECT_ID(N'dbo.Laundry', N'U') IS NULL
BEGIN
    CREATE TABLE Laundry (
        id INT IDENTITY(1,1) PRIMARY KEY,
        customer_name NVARCHAR(150) NOT NULL,
        room_number VARCHAR(20) NOT NULL,
        service_type NVARCHAR(100) DEFAULT N'Giặt sấy thông thường',
        quantity INT DEFAULT 1,
        total_price FLOAT DEFAULT 0,
        processing_status VARCHAR(100) NOT NULL DEFAULT 'Chưa hoàn thành', -- Chưa hoàn thành, Đã hoàn thành
        notes NVARCHAR(500) NULL,
        created_date DATETIME DEFAULT GETDATE()
    );
END
GO

-- 14. BẢNG SYSTEM_SETTINGS (Cấu hình hệ thống & VietQR)
IF OBJECT_ID(N'dbo.system_settings', N'U') IS NULL
BEGIN
    CREATE TABLE system_settings (
        setting_key NVARCHAR(100) PRIMARY KEY,
        setting_value NVARCHAR(500) NULL
    );
END
GO

-- ====================================================================
-- CHÈN DỮ LIỆU SEED DATA ĐẦY ĐỦ VÀ CHUẨN XÁC
-- ====================================================================

-- 1. Seed Cấu hình Hệ thống (System Settings)
IF NOT EXISTS (SELECT 1 FROM system_settings WHERE setting_key = 'hotel_name')
BEGIN
    INSERT INTO system_settings (setting_key, setting_value) VALUES
    ('hotel_name', N'Khách sạn Nestora'),
    ('hotel_address', N'123 Đường Trần Phú, Phường Lộc Thọ, Nha Trang, Khánh Hòa'),
    ('hotel_phone', N'0258 3888 999'),
    ('hotel_email', N'contact@nestora.com'),
    ('hotel_bank_id', N'MB'),
    ('hotel_bank_account', N'1903567890123'),
    ('hotel_bank_name', N'CONG TY NESTORA HOTEL'),
    ('nestora_theme', N'light');
END
GO

-- 2. Seed Người dùng & Nhân viên mặc định (Mật khẩu 'admin123' / '123456' hash SHA-256)
-- Mật khẩu SHA-256:
-- admin123: 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9
-- 123456:   8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
IF NOT EXISTS (SELECT 1 FROM Users WHERE username = 'admin')
BEGIN
    INSERT INTO Users (username, password, full_name, email, phone, role)
    VALUES 
    (N'admin', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'Nguyễn Văn Admin', N'admin@nestora.com', N'0901234567', N'Admin'),
    (N'receptionist1', N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Trần Thị Lễ Tân', N'letan@nestora.com', N'0912345678', N'Receptionist'),
    (N'manager1', N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Lê Hoàng Quản Lý', N'quanly@nestora.com', N'0923456789', N'Manager'),
    (N'khachhang1', N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Phạm Minh Tuấn', N'tuan.pm@gmail.com', N'0987654321', N'Customer');
END
GO

-- 3. Seed Loại phòng (RoomTypes)
IF NOT EXISTS (SELECT 1 FROM RoomTypes WHERE name = 'Standard')
BEGIN
    INSERT INTO RoomTypes (name, price_per_day, capacity, description)
    VALUES 
    (N'Standard', 450000, 2, N'Phòng tiêu chuẩn ấm cúng, trang bị đầy đủ tiện nghi cơ bản, thích hợp cho 2 người.'),
    (N'Deluxe City View', 850000, 2, N'Phòng cao cấp với hướng nhìn ra toàn cảnh thành phố, ban công thoáng mát và bồn tắm ngâm.'),
    (N'Executive Suite VIP', 1500000, 4, N'Căn hộ Suite sang trọng bậc nhất với phòng khách riêng biệt, minibar miễn phí và dịch vụ đưa đón.');
END
GO

-- 4. Seed Phòng nghỉ (Rooms)
IF NOT EXISTS (SELECT 1 FROM Rooms WHERE room_number = '101')
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
    (N'301', N'Available', N'Phòng Executive Suite VIP tầng 3, có phòng khách riêng biệt.', @suiteId),
    (N'302', N'Available', N'Phòng Executive Suite gia đình tầng 3, 2 giường King size sang trọng.', @suiteId);
END
GO

-- 5. Seed Dịch vụ (Services)
IF NOT EXISTS (SELECT 1 FROM Services WHERE name LIKE N'%Buffet%')
BEGIN
    INSERT INTO Services (name, price, unit, status, description)
    VALUES 
    (N'Ăn sáng Buffet Thượng hạng', 150000, N'Người', N'Active', N'Thưởng thức buffet sáng phong phú với hơn 40 món Âu-Á thượng hạng.'),
    (N'Dịch vụ Giặt ủi cao cấp', 50000, N'Bộ', N'Active', N'Giặt sấy lấy ngay trong ngày, bảo vệ sợi vải và là ủi phẳng phiêu.'),
    (N'Thuê xe máy tự chọn', 120000, N'Ngày', N'Active', N'Xe tay ga và xe số đời mới, bao gồm đầy đủ nón bảo hiểm và bảo hiểm.'),
    (N'Đưa đón sân bay cao cấp', 300000, N'Lượt', N'Active', N'Xe 7 chỗ sang trọng đưa đón tận sảnh sân bay 24/7.');
END
GO

-- 6. Seed Trang thiết bị phòng (Equipments)
IF NOT EXISTS (SELECT 1 FROM EQUIPMENTS)
BEGIN
    DECLARE @r101 INT = (SELECT id FROM Rooms WHERE room_number = '101');
    DECLARE @r201 INT = (SELECT id FROM Rooms WHERE room_number = '201');
    DECLARE @r301 INT = (SELECT id FROM Rooms WHERE room_number = '301');

    IF @r101 IS NOT NULL
    BEGIN
        INSERT INTO EQUIPMENTS (room_id, equipment_name, total_quantity, unit, status, description) VALUES
        (@r101, N'Smart TV Sony 43 inch', 1, N'Cái', N'Hoạt động tốt', N'Hỗ trợ Netflix & YouTube 4K'),
        (@r101, N'Điều hòa Daikin Inverter 1.5 HP', 1, N'Bộ', N'Hoạt động tốt', N'Máy 2 chiều kèm remote'),
        (@r101, N'Tủ lạnh mini 50L', 1, N'Cái', N'Hoạt động tốt', N'Làm lạnh nhanh, êm ái');
    END

    IF @r201 IS NOT NULL
    BEGIN
        INSERT INTO EQUIPMENTS (room_id, equipment_name, total_quantity, unit, status, description) VALUES
        (@r201, N'Smart TV LG 55 inch 4K', 1, N'Cái', N'Hoạt động tốt', N'Màn hình viền mỏng cao cấp'),
        (@r201, N'Máy sấy tóc Philips 1800W', 1, N'Cái', N'Hoạt động tốt', N'Trang bị phòng tắm'),
        (@r201, N'Bình đun siêu tốc 1.8L', 1, N'Cái', N'Hoạt động tốt', N'Inox 304 an toàn');
    END

    IF @r301 IS NOT NULL
    BEGIN
        INSERT INTO EQUIPMENTS (room_id, equipment_name, total_quantity, unit, status, description) VALUES
        (@r301, N'Smart TV Samsung 65 inch OLED', 1, N'Cái', N'Hoạt động tốt', N'Phòng khách VIP'),
        (@r301, N'Két sắt điện tử an toàn', 1, N'Cái', N'Hoạt động tốt', N'Mã khóa bảo mật'),
        (@r301, N'Bồn tắm ngâm Massage Jacuzzi', 1, N'Bộ', N'Hoạt động tốt', N'Hệ thống sục khí thư giãn');
    END
END
GO

-- 7. Seed Khách hàng lưu trú (CUSTOMERS)
IF NOT EXISTS (SELECT 1 FROM CUSTOMERS WHERE customer_name = N'Nguyễn Thị Hoa')
BEGIN
    INSERT INTO CUSTOMERS (customer_name, customer_phone, customer_email, customer_cccd)
    VALUES 
    (N'Nguyễn Thị Hoa', N'0912334455', N'hoa.nguyen@gmail.com', N'001198001234'),
    (N'Hoàng Văn Nam', N'0988776655', N'nam.hoang@yahoo.com', N'001195005678');
END
GO

-- 8. Seed Thực đơn Buffet mẫu (BuffetMenuItems)
IF NOT EXISTS (SELECT 1 FROM BuffetMenuItems)
BEGIN
    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    INSERT INTO BuffetMenuItems (menu_date, meal_period, category, dish_name, description, image_url, status, sort_order) VALUES
    (@Today, 'Breakfast', N'Món nước', N'Phở bò truyền thống Hà Nội', N'Nước dùng hầm xương 12h, thịt bò mềm và rau thơm tươi.', N'assets/pho_bo.jpg', 'Active', 10),
    (@Today, 'Breakfast', N'Món nóng', N'Bánh mì ốp la xúc xích Đức', N'Bánh mì giòn kèm trứng ốp la, xúc xích và bơ tươi.', N'assets/banh_mi.jpg', 'Active', 20),
    (@Today, 'Breakfast', N'Đồ uống', N'Cà phê muối xứ Huế', N'Cà phê đậm đà hòa quyện lớp kem béo ngậy.', N'assets/ca_phe_muoi.jpg', 'Active', 30),
    (@Today, 'Lunch', N'Khai vị', N'Gỏi cuốn tôm thịt ngũ sắc', N'Tôm tươi, thịt luộc, rau sống cuốn bánh tráng chấm sốt đậu.', N'assets/goi_cuon.jpg', 'Active', 10),
    (@Today, 'Lunch', N'Món chính', N'Gà nướng thảo mộc sả ớt', N'Đùi gà ướp gia vị đậm đà, nướng vàng da giòn.', N'assets/ga_nuong.jpg', 'Active', 20),
    (@Today, 'Dinner', N'Quầy nướng', N'Bò Úc nướng sốt tiêu đen', N'Thăn bò nướng mềm mọng sốt tiêu đen hảo hạng.', N'assets/bo_nuong.jpg', 'Active', 10),
    (@Today, 'Dinner', N'Hải sản', N'Tôm sú nướng bơ tỏi Nha Trang', N'Tôm sú tươi sống nướng bơ tỏi thơm lừng.', N'assets/tom_nuong.jpg', 'Active', 20);
END
GO

-- 9. Seed Thông báo nội bộ (HotelNotification)
IF NOT EXISTS (SELECT 1 FROM HotelNotification)
BEGIN
    INSERT INTO HotelNotification (title, content, type, created_at, created_by, is_active) VALUES
    (N'Chào mừng đến với hệ thống Nestora Hotel', N'Hệ thống quản lý khách sạn đã sẵn sàng phục vụ vận hành chuyên nghiệp.', 'SUCCESS', GETDATE(), 1, 1),
    (N'Bảo trì định kỳ thang máy sảnh chính', N'Thang máy số 2 sẽ được kiểm tra kỹ thuật vào 14:00 hôm nay.', 'WARNING', GETDATE(), 1, 1),
    (N'Quy định bàn giao ca lễ tân', N'Yêu cầu tất cả lễ tân bàn giao sổ quỹ và trạng thái phòng trước khi kết thúc ca.', 'INFO', GETDATE(), 1, 1);
END
GO

-- 10. Seed Đơn giặt ủi mẫu (Laundry)
IF NOT EXISTS (SELECT 1 FROM Laundry)
BEGIN
    INSERT INTO Laundry (customer_name, room_number, service_type, quantity, total_price, processing_status, notes, created_date) VALUES
    (N'Nguyễn Văn An', '101', N'Giặt sấy thông thường', 3, 45000, 'Chưa hoàn thành', N'Không dùng nước nóng, giặt riêng', GETDATE()),
    (N'Trần Thị Bích', '201', N'Giặt khô (Dry Cleaning)', 1, 120000, N'Đã hoàn thành', N'Quần áo lụa cao cấp', GETDATE());
END
GO

PRINT N'========================================================================';
PRINT N'ĐÃ KHỞI TẠO VÀ ĐỒNG BỘ 100% CƠ SỞ DỮ LIỆU CHO NESTORA HOTEL MANAGEMENT!';
PRINT N'========================================================================';
GO
