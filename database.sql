USE Hotel_manage;
-- GO

-- Xóa bảng cũ nếu tồn tại
IF OBJECT_ID('ROOM_EQUIPMENTS', 'U') IS NOT NULL DROP TABLE ROOM_EQUIPMENTS;
IF OBJECT_ID('BILL_DETAILS', 'U') IS NOT NULL DROP TABLE BILL_DETAILS;
IF OBJECT_ID('BILLS', 'U') IS NOT NULL DROP TABLE BILLS;
IF OBJECT_ID('BOOKINGS', 'U') IS NOT NULL DROP TABLE BOOKINGS;
IF OBJECT_ID('ROOMS', 'U') IS NOT NULL DROP TABLE ROOMS;
IF OBJECT_ID('ROOM_TYPES', 'U') IS NOT NULL DROP TABLE ROOM_TYPES;
IF OBJECT_ID('EQUIPMENTS', 'U') IS NOT NULL DROP TABLE EQUIPMENTS;
IF OBJECT_ID('SERVICES', 'U') IS NOT NULL DROP TABLE SERVICES;
IF OBJECT_ID('CUSTOMERS', 'U') IS NOT NULL DROP TABLE CUSTOMERS;
IF OBJECT_ID('USERS', 'U') IS NOT NULL DROP TABLE USERS;
-- GO

-- 1. USERS
CREATE TABLE USERS (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL DEFAULT 'Receptionist',
    status VARCHAR(20) NOT NULL DEFAULT 'Active'
);
-- GO

-- 2. CUSTOMERS
CREATE TABLE CUSTOMERS (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_name NVARCHAR(100) NOT NULL,
    customer_cccd VARCHAR(20) UNIQUE,
    customer_phone VARCHAR(20),
    customer_email VARCHAR(100)
);
-- GO

-- 3. ROOM_TYPES
CREATE TABLE ROOM_TYPES (
    type_id INT IDENTITY(1,1) PRIMARY KEY,
    type_name NVARCHAR(100) NOT NULL UNIQUE,
    base_price DECIMAL(10, 2) NOT NULL CHECK (base_price >= 0),
    description NVARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'Active'
);
-- GO

-- 4. ROOMS
CREATE TABLE ROOMS (
    room_id INT IDENTITY(1,1) PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL UNIQUE,
    type_id INT NOT NULL,
    floor INT NOT NULL DEFAULT 1,
    status VARCHAR(20) NOT NULL DEFAULT 'Available', -- Available, Booked, Occupied, Maintenance
    FOREIGN KEY (type_id) REFERENCES ROOM_TYPES(type_id) ON DELETE CASCADE
);
-- GO

-- 5. BOOKINGS
CREATE TABLE BOOKINGS (
    booking_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    room_id INT NOT NULL,
    created_by INT NOT NULL,
    check_in_date DATETIME NOT NULL,
    check_out_date DATETIME NOT NULL,
    room_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00, -- Lưu giá phòng tại thời điểm đặt
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    CONSTRAINT CHK_Booking_Dates CHECK (check_out_date > check_in_date),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES ROOMS(room_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES USERS(user_id)
);
-- GO

-- 6. BILLS
CREATE TABLE BILLS (
    bill_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    created_by INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    total_amount DECIMAL(10, 2) DEFAULT 0.00 CHECK (total_amount >= 0),
    payment_method VARCHAR(30) DEFAULT 'Cash',
    status VARCHAR(20) NOT NULL DEFAULT 'Unpaid',
    FOREIGN KEY (booking_id) REFERENCES BOOKINGS(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES USERS(user_id)
);
-- GO

-- 7. SERVICES
CREATE TABLE SERVICES (
    service_id INT IDENTITY(1,1) PRIMARY KEY,
    service_name NVARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    description NVARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'Active'
);
-- GO

-- 8. BILL_DETAILS
CREATE TABLE BILL_DETAILS (
    detail_id INT IDENTITY(1,1) PRIMARY KEY,
    bill_id INT NOT NULL,
    service_id INT NOT NULL,
    quantity INT DEFAULT 1 CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    FOREIGN KEY (bill_id) REFERENCES BILLS(bill_id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES SERVICES(service_id) ON DELETE CASCADE
);
-- GO

-- 9. EQUIPMENTS
CREATE TABLE EQUIPMENTS (
    equipment_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_name NVARCHAR(100) NOT NULL UNIQUE,
    total_quantity INT NOT NULL DEFAULT 0 CHECK (total_quantity >= 0),
    unit NVARCHAR(20) DEFAULT N'Cái',
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    description NVARCHAR(500)
);
-- GO

-- 10. ROOM_EQUIPMENTS
CREATE TABLE ROOM_EQUIPMENTS (
    room_id INT NOT NULL,
    equipment_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    condition_status NVARCHAR(50) DEFAULT N'Tốt',
    note NVARCHAR(255),
    PRIMARY KEY (room_id, equipment_id),
    FOREIGN KEY (room_id) REFERENCES ROOMS(room_id) ON DELETE CASCADE,
    FOREIGN KEY (equipment_id) REFERENCES EQUIPMENTS(equipment_id) ON DELETE CASCADE
);
-- GO

-- =========================================================
-- DỮ LIỆU MẪU BAN ĐẦU
-- =========================================================

INSERT INTO USERS (username, password, full_name, email, role, status) VALUES
('admin', 'admin123', N'Quản trị viên', 'admin@hotel.com', 'Admin', 'Active'),
('receptionist', 'rep123', N'Lễ tân Nguyễn Văn A', 'receptionist@hotel.com', 'Receptionist', 'Active');

INSERT INTO CUSTOMERS (customer_name, customer_cccd, customer_phone, customer_email) VALUES
(N'Nguyễn Hoàng Anh', '079201003421', '0901234567', 'anh.nguyen@gmail.com'),
(N'Trần Minh Huy', '079202004321', '0912345678', 'huy.tran@gmail.com'),
(N'Lê Ngọc Anh', '079203005432', '0933456789', 'anh.le@gmail.com');

INSERT INTO ROOM_TYPES (type_name, base_price, description, status) VALUES
(N'Standard Single', 300000, N'Phòng đơn tiêu chuẩn, giường 1m2, đầy đủ tiện nghi cơ bản.', 'Active'),
(N'Deluxe Double', 600000, N'Phòng đôi cao cấp, giường 1m8, view hướng thành phố, bồn tắm.', 'Active'),
(N'Presidential Suite', 2000000, N'Phòng hoàng gia sang trọng bậc nhất, 2 phòng ngủ, view biển.', 'Active');

INSERT INTO ROOMS (room_number, type_id, floor, status) VALUES
('101', 1, 1, 'Available'),
('102', 1, 1, 'Available'),
('201', 2, 2, 'Occupied'),
('202', 2, 2, 'Available'),
('301', 3, 3, 'Maintenance');

INSERT INTO SERVICES (service_name, price, description, status) VALUES
(N'Giặt ủi (Laundry)', 50000, N'Dịch vụ giặt sấy quần áo lấy nhanh trong ngày', 'Active'),
(N'Buffet sáng (Breakfast)', 100000, N'Buffet sáng từ 6h00 đến 9h30 hàng ngày', 'Active'),
(N'Thuê xe máy (Motorbike Rental)', 150000, N'Thuê xe máy tự lái (xăng tự túc), tính theo ngày', 'Active');

INSERT INTO EQUIPMENTS (equipment_name, total_quantity, unit, status, description) VALUES
(N'Điều hòa Inverter 12000 BTU', 20, N'Cái', 'Active', N'Điều hòa Daikin hai chiều'),
(N'Tivi Smart 55 inch', 15, N'Cái', 'Active', N'Tivi Samsung 4K'),
(N'Tủ lạnh Mini Bar 50L', 20, N'Cái', 'Active', N'Tủ lạnh Electrolux nhỏ gọn'),
(N'Máy sấy tóc 1800W', 25, N'Cái', 'Active', N'Máy sấy tóc Panasonic');

INSERT INTO ROOM_EQUIPMENTS (room_id, equipment_id, quantity, condition_status, note) VALUES
(1, 1, 1, N'Tốt', N'Mới bảo dưỡng tháng trước'),
(1, 4, 1, N'Tốt', N'Hoạt động bình thường'),
(3, 1, 1, N'Tốt', N'Hoạt động tốt'),
(3, 2, 1, N'Tốt', N'Tivi phòng 201'),
(3, 3, 1, N'Tốt', N'Mini bar phòng 201');

-- Đặt phòng 2 đêm x 600,000 = 1,200,000
INSERT INTO BOOKINGS (customer_id, room_id, created_by, check_in_date, check_out_date, room_price, status) VALUES
(1, 3, 2, '2026-07-20 14:00:00', '2026-07-22 12:00:00', 600000, 'CheckedIn');

-- Tiền phòng (1.200.000) + Tiền dịch vụ (350.000) = 1.550.000
INSERT INTO BILLS (booking_id, created_by, created_at, total_amount, payment_method, status) VALUES
(1, 2, '2026-07-20 14:00:00', 1550000, 'Cash', 'Unpaid');

INSERT INTO BILL_DETAILS (bill_id, service_id, quantity, unit_price) VALUES
(1, 2, 2, 100000), -- 200,000
(1, 1, 3, 50000);  -- 150,000
-- GO