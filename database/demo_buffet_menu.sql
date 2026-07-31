USE [Hotel_manage];
GO

SET NOCOUNT ON;

-- Tạo bảng khi chạy file SQL độc lập, không cần chờ Hibernate khởi động.
IF OBJECT_ID(N'dbo.BuffetMenuItems', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.BuffetMenuItems
    (
        id           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        menu_date    DATE              NOT NULL,
        meal_period  VARCHAR(20)       NOT NULL,
        category     NVARCHAR(80)      NOT NULL,
        dish_name    NVARCHAR(160)     NOT NULL,
        description  NVARCHAR(1000)    NULL,
        image_url    NVARCHAR(500)     NULL,
        status       VARCHAR(20)       NOT NULL CONSTRAINT DF_BuffetMenuItems_Status DEFAULT ('Active'),
        sort_order   INT               NOT NULL CONSTRAINT DF_BuffetMenuItems_SortOrder DEFAULT (0)
    );
END;
GO

-- Bổ sung cột ảnh cho database đã có bảng buffet từ phiên bản trước.
IF COL_LENGTH(N'dbo.BuffetMenuItems', N'image_url') IS NULL
BEGIN
    ALTER TABLE dbo.BuffetMenuItems ADD image_url NVARCHAR(500) NULL;
END;
GO

DECLARE @Today DATE = CAST(GETDATE() AS DATE);

-- Tạo thực đơn từ 2 ngày trước đến 7 ngày tiếp theo để luôn có dữ liệu demo quanh ngày hiện tại.
;WITH DayOffsets AS
(
    SELECT day_offset
    FROM (VALUES (-2), (-1), (0), (1), (2), (3), (4), (5), (6), (7)) AS d(day_offset)
),
MenuTemplate AS
(
    SELECT *
    FROM (VALUES
        ('Breakfast', N'Món nước',      N'Phở bò truyền thống',
         N'Nước dùng hầm xương, thịt bò mềm, bánh phở và rau thơm tươi.',
         N'images/buffet/buffet-breakfast.png', 10),
        ('Breakfast', N'Món nóng',      N'Bánh mì ốp la',
         N'Bánh mì giòn dùng cùng trứng ốp la, xúc xích và rau củ.',
         N'images/buffet/buffet-breakfast.png', 20),
        ('Breakfast', N'Món Việt',      N'Xôi gà lá sen',
         N'Xôi nếp dẻo, gà xé, hành phi và nước sốt đặc biệt của bếp trưởng.',
         N'images/buffet/buffet-breakfast.png', 30),
        ('Breakfast', N'Tráng miệng',   N'Sữa chua và trái cây nhiệt đới',
         N'Sữa chua tự nhiên dùng cùng thanh long, dưa hấu và dứa tươi.',
         N'images/buffet/buffet-breakfast.png', 40),

        ('Lunch',     N'Khai vị',       N'Gỏi cuốn tôm thịt',
         N'Tôm, thịt, bún và rau sống cuốn bánh tráng, dùng với sốt đậu phộng.',
         N'images/buffet/buffet-lunch.png', 10),
        ('Lunch',     N'Món chính',     N'Gà nướng sả',
         N'Đùi gà ướp sả và gia vị Việt, nướng vàng thơm, ăn cùng rau củ.',
         N'images/buffet/buffet-lunch.png', 20),
        ('Lunch',     N'Món chính',     N'Cơm chiên hải sản',
         N'Cơm chiên tơi với tôm, mực, trứng, rau củ và hành lá.',
         N'images/buffet/buffet-lunch.png', 30),
        ('Lunch',     N'Món chay',      N'Rau củ xào nấm',
         N'Bông cải, cà rốt, đậu Hà Lan và nấm theo mùa xào thanh vị.',
         N'images/buffet/buffet-lunch.png', 40),

        ('Dinner',    N'Quầy nướng',    N'Bò nướng sốt tiêu đen',
         N'Thăn bò nướng mềm, dùng với sốt tiêu đen và rau củ bỏ lò.',
         N'images/buffet/buffet-dinner.png', 10),
        ('Dinner',    N'Hải sản',       N'Tôm sú nướng bơ tỏi',
         N'Tôm sú nướng vừa chín tới với bơ, tỏi và thảo mộc.',
         N'images/buffet/buffet-dinner.png', 20),
        ('Dinner',    N'Hải sản',       N'Cá hồi áp chảo sốt chanh',
         N'Cá hồi áp chảo da giòn, sốt kem chanh nhẹ và rau củ.',
         N'images/buffet/buffet-dinner.png', 30),
        ('Dinner',    N'Tráng miệng',   N'Crème caramel và bánh ngọt',
         N'Crème caramel mềm mịn cùng bánh mousse và quả mọng tươi.',
         N'images/buffet/buffet-dinner.png', 40)
    ) AS m(meal_period, category, dish_name, description, image_url, sort_order)
)
INSERT INTO dbo.BuffetMenuItems
    (menu_date, meal_period, category, dish_name, description, image_url, status, sort_order)
SELECT
    DATEADD(DAY, d.day_offset, @Today),
    m.meal_period,
    m.category,
    m.dish_name,
    m.description,
    m.image_url,
    'Active',
    m.sort_order
FROM DayOffsets d
CROSS JOIN MenuTemplate m
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.BuffetMenuItems existing
    WHERE existing.menu_date = DATEADD(DAY, d.day_offset, @Today)
      AND existing.meal_period = m.meal_period
      AND existing.dish_name = m.dish_name
);

SELECT
    menu_date,
    meal_period,
    COUNT(*) AS total_dishes
FROM dbo.BuffetMenuItems
WHERE menu_date BETWEEN DATEADD(DAY, -2, @Today) AND DATEADD(DAY, 7, @Today)
GROUP BY menu_date, meal_period
ORDER BY menu_date,
         CASE meal_period WHEN 'Breakfast' THEN 1 WHEN 'Lunch' THEN 2 ELSE 3 END;
GO
