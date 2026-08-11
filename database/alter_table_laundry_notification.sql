-- =========================================================
-- FILE SQL ALTER & INITIALIZATION FOR HOTEL MANAGEMENT SYSTEM
-- Cập nhật module Laundry & Hệ thống HotelNotification
-- =========================================================

USE [Hotel_manage];
GO

SET NOCOUNT ON;
GO

-- 1. CẬP NHẬT / TẠO BẢNG LAUNDRY (DỊCH VỤ GIẶT ỦI)
IF OBJECT_ID(N'dbo.Laundry', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Laundry (
        id INT IDENTITY(1,1) PRIMARY KEY,
        customer_name NVARCHAR(150) NOT NULL,
        room_number VARCHAR(20) NOT NULL,
        service_type NVARCHAR(100) DEFAULT N'Giặt sấy thông thường',
        quantity INT DEFAULT 1,
        total_price FLOAT DEFAULT 0,
        processing_status VARCHAR(20) NOT NULL CONSTRAINT DF_Laundry_ProcessingStatus DEFAULT 'Pending',
        booking_id INT NULL,
        bill_id INT NULL,
        bill_detail_id INT NULL,
        notes NVARCHAR(500) NULL,
        created_date DATETIME DEFAULT GETDATE()
    );
END
ELSE
BEGIN
    IF COL_LENGTH(N'dbo.Laundry', N'processing_status') IS NULL
    BEGIN
        ALTER TABLE Laundry
        ADD processing_status VARCHAR(20) NOT NULL CONSTRAINT DF_Laundry_ProcessingStatus DEFAULT 'Chưa hoàn tất';
    END;

    IF COL_LENGTH(N'dbo.Laundry', N'notes') IS NULL
    BEGIN
        ALTER TABLE Laundry
        ADD notes NVARCHAR(500) NULL;
    END;

    IF COL_LENGTH(N'dbo.Laundry', N'booking_id') IS NULL
        ALTER TABLE dbo.Laundry ADD booking_id INT NULL;

    IF COL_LENGTH(N'dbo.Laundry', N'bill_id') IS NULL
        ALTER TABLE dbo.Laundry ADD bill_id INT NULL;

    IF COL_LENGTH(N'dbo.Laundry', N'bill_detail_id') IS NULL
        ALTER TABLE dbo.Laundry ADD bill_detail_id INT NULL;
END;
GO

-- Chuẩn hóa trạng thái backend để transaction tính phí dùng một giá trị duy nhất.
UPDATE dbo.Laundry
SET processing_status = CASE
    WHEN UPPER(processing_status) IN ('COMPLETED', 'DONE')
         OR processing_status LIKE N'%Đã%'
         OR processing_status LIKE N'%hoàn thành%'
         OR processing_status LIKE N'%hoàn tất%'
        THEN 'Completed'
    ELSE 'Pending'
END;
GO

-- 2. TẠO BẢNG HOTELNOTIFICATION (HỆ THỐNG THÔNG BÁO)
IF OBJECT_ID(N'dbo.HotelNotification', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.HotelNotification (
        notification_id INT IDENTITY(1,1) PRIMARY KEY,
        title NVARCHAR(200) NOT NULL,
        content NVARCHAR(MAX) NOT NULL,
        type VARCHAR(30) NOT NULL, -- INFO, WARNING, SUCCESS, ERROR
        created_at DATETIME DEFAULT GETDATE(),
        created_by INT NULL,
        is_active BIT DEFAULT 1,
        CONSTRAINT FK_HotelNotification_Users FOREIGN KEY (created_by) REFERENCES dbo.Users(id) ON DELETE SET NULL
    );
END;
GO

-- 3. CHÈN DỮ LIỆU DEMO CHO LAUNDRY & HOTELNOTIFICATION (NẾU CHƯA CÓ)
IF NOT EXISTS (SELECT 1 FROM dbo.Laundry)
BEGIN
    INSERT INTO dbo.Laundry (customer_name, room_number, service_type, quantity, total_price, processing_status, notes, created_date)
    VALUES 
    (N'Nguyễn Văn An', '101', N'Giặt sấy thông thường', 3, 135000, 'Pending', N'Không dùng nước nóng\nGiặt riêng', GETDATE()),
    (N'Trần Thị Bích', '205', N'Giặt khô (Dry Cleaning)', 1, 120000, 'Completed', N'Quần áo dễ phai màu', GETDATE());
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.HotelNotification)
BEGIN
    INSERT INTO dbo.HotelNotification (title, content, type, created_at, created_by, is_active)
    VALUES 
    (N'Chào mừng đến với Nestora Hotel', N'Hệ thống quản lý khách sạn đã cập nhật tính năng thông báo mới và theo dõi dịch vụ giặt ủi!', 'SUCCESS', GETDATE(), NULL, 1),
    (N'Bảo trì hệ thống thang máy', N'Thang máy số 2 sẽ được kiểm tra kỹ thuật định kỳ vào lúc 14:00 hôm nay.', 'WARNING', GETDATE(), NULL, 1),
    (N'Quy định bàn giao ca lễ tân', N'Yêu cầu tất cả lễ tân bàn giao sổ thu chi và tiền mặt trước khi kết thúc ca làm.', 'INFO', GETDATE(), NULL, 1);
END;
GO
