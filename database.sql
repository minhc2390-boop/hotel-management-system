-- Create Database
-- CREATE DATABASE HotelManage;
-- GO
USE Hotel_manage;
GO

-- 1. Table: Users (For Authentication & Authorization: Admin, Receptionist, Customer)
CREATE TABLE Users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL DEFAULT 'Customer', -- Admin, Receptionist, Customer
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 2. Table: RoomTypes (Room categories like Single, Double, Deluxe, Suite)
CREATE TABLE RoomTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(50) NOT NULL UNIQUE,
    price_per_day DECIMAL(10, 2) NOT NULL,
    capacity INT NOT NULL, -- Number of guests allowed
    description NVARCHAR(500)
);
GO

-- 3. Table: Rooms (Physical rooms in the hotel)
CREATE TABLE Rooms (
    id INT IDENTITY(1,1) PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type_id INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Available', -- Available, Booked, Maintenance
    description NVARCHAR(500),
    FOREIGN KEY (room_type_id) REFERENCES RoomTypes(id) ON DELETE CASCADE
);
GO

-- 4. Table: Services (Extra hotel services like Laundry, Pool, Spa, Food)
CREATE TABLE Services (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10, 2) NOT NULL,
    description NVARCHAR(500)
);
GO

-- 5. Table: Bills (Invoices / Bookings)
CREATE TABLE Bills (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL, -- Customer who booked/purchased
    check_in_date DATETIME NOT NULL,
    check_out_date DATETIME,
    total_amount DECIMAL(10, 2) DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'Unpaid', -- Unpaid, Paid, Cancelled
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);
GO

-- 6. Table: BillDetails (Itemized list of Rooms booked and Services used in a Bill)
CREATE TABLE BillDetails (
    id INT IDENTITY(1,1) PRIMARY KEY,
    bill_id INT NOT NULL,
    room_id INT, -- If this row is a room charge
    service_id INT, -- If this row is a service charge
    quantity INT DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL, -- Price at the time of purchase
    FOREIGN KEY (bill_id) REFERENCES Bills(id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES Rooms(id) ON DELETE SET NULL,
    FOREIGN KEY (service_id) REFERENCES Services(id) ON DELETE SET NULL
);
GO

-- Insert Initial Sample Data for testing
-- Admin: admin/admin123, Receptionist: receptionist/rep123, Customer: customer/cus123
INSERT INTO Users (username, password, full_name, email, phone, role) VALUES
('admin', 'admin123', N'Quản trị viên', 'admin@hotel.com', '0987654321', 'Admin'),
('receptionist', 'rep123', N'Lễ tân A', 'receptionist@hotel.com', '0912345678', 'Receptionist'),
('customer', 'cus123', N'Nguyễn Văn A', 'customer@gmail.com', '0901234567', 'Customer');

INSERT INTO RoomTypes (name, price_per_day, capacity, description) VALUES
(N'Standard Single', 300000, 1, N'Phòng đơn tiêu chuẩn, giường 1m2, đầy đủ tiện nghi cơ bản.'),
(N'Deluxe Double', 600000, 2, N'Phòng đôi cao cấp, giường 1m8, view hướng thành phố, bồn tắm.'),
(N'Presidential Suite', 2000000, 4, N'Phòng hoàng gia sang trọng bậc nhất, 2 phòng ngủ, view biển, mini bar.');

INSERT INTO Rooms (room_number, room_type_id, status, description) VALUES
('101', 1, 'Available', N'Tầng 1, phòng đơn thoáng mát'),
('102', 1, 'Available', N'Tầng 1, phòng đơn yên tĩnh'),
('201', 2, 'Available', N'Tầng 2, phòng đôi Deluxe rộng rãi'),
('202', 2, 'Available', N'Tầng 2, phòng đôi Deluxe hướng phố'),
('301', 3, 'Available', N'Tầng 3, phòng Suite VIP');

INSERT INTO Services (name, price, description) VALUES
(N'Giặt ủi (Laundry)', 50000, N'Dịch vụ giặt sấy quần áo lấy nhanh trong ngày'),
(N'Buffet sáng (Breakfast)', 100000, N'Buffet sáng từ 6h00 đến 9h30 hàng ngày'),
(N'Thuê xe máy (Motorbike Rental)', 150000, N'Thuê xe máy tự lái (xăng tự túc), tính theo ngày');
