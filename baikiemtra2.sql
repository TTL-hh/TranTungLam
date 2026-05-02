-- =============================================
-- DATABASE
-- =============================================
CREATE DATABASE QuanLyPhongNet_K235480106039;
GO

USE QuanLyPhongNet_K235480106039;
GO

-- =============================================
-- TABLES
-- =============================================

-- Bảng Khách Hàng
CREATE TABLE [KhachHang] (
    [KhachHangId] INT PRIMARY KEY IDENTITY,
    [TenKhach] NVARCHAR(100) NOT NULL,
    [SoDienThoai] VARCHAR(15),
    [SoDu] MONEY CHECK ([SoDu] >= 0)
);

-- Bảng Máy Tính
CREATE TABLE [MayTinh] (
    [MayId] INT PRIMARY KEY IDENTITY,
    [TenMay] NVARCHAR(50),
    [TrangThai] NVARCHAR(20) 
        CHECK ([TrangThai] IN (N'Rảnh', N'Đang dùng'))
);

-- Bảng Hóa Đơn
CREATE TABLE [HoaDon] (
    [HoaDonId] INT PRIMARY KEY IDENTITY,
    [KhachHangId] INT,
    [MayId] INT,
    [ThoiGianBatDau] DATETIME,
    [ThoiGianKetThuc] DATETIME,
    [TongTien] MONEY,
    FOREIGN KEY ([KhachHangId]) REFERENCES [KhachHang]([KhachHangId]),
    FOREIGN KEY ([MayId]) REFERENCES [MayTinh]([MayId])
);

-- =============================================
-- SAMPLE DATA
-- =============================================

INSERT INTO KhachHang (TenKhach, SoDienThoai, SoDu)
VALUES 
(N'Nguyen Van A', '0123456789', 50000),
(N'Tran Thi B', '0987654321', 30000);

INSERT INTO MayTinh (TenMay, TrangThai)
VALUES 
(N'May 1', N'Rảnh'),
(N'May 2', N'Rảnh');

-- =============================================
-- BUILT-IN FUNCTION DEMO
-- =============================================
SELECT GETDATE() AS CurrentTime;
SELECT LEN(N'PhongNet') AS DoDai;
SELECT ABS(-100) AS GiaTriTuyetDoi;

-- =============================================
-- SCALAR FUNCTION
-- =============================================
GO
CREATE FUNCTION fn_TinhTien(@SoGio FLOAT)
RETURNS MONEY
AS
BEGIN
    RETURN @SoGio * 5000;
END;
GO

SELECT dbo.fn_TinhTien(3) AS Tien3Gio;

-- =============================================
-- INLINE TABLE FUNCTION
-- =============================================
GO
CREATE FUNCTION fn_MayDangDung()
RETURNS TABLE
AS
RETURN (
    SELECT * FROM MayTinh
    WHERE TrangThai = N'Đang dùng'
);
GO

SELECT * FROM fn_MayDangDung();

-- =============================================
-- MULTI-STATEMENT FUNCTION
-- =============================================
GO
CREATE FUNCTION fn_HoaDonLonHon(@Tien MONEY)
RETURNS @Result TABLE (
    HoaDonId INT,
    TongTien MONEY
)
AS
BEGIN
    INSERT INTO @Result
    SELECT HoaDonId, TongTien
    FROM HoaDon
    WHERE TongTien > @Tien;

    RETURN;
END;
GO

SELECT * FROM fn_HoaDonLonHon(10000);

-- =============================================
-- STORED PROCEDURES
-- =============================================

-- SP Insert có điều kiện
GO
CREATE PROCEDURE sp_ThemKhach
    @Ten NVARCHAR(100),
    @SoDu MONEY
AS
BEGIN
    IF @SoDu < 0
        PRINT N'Số dư không hợp lệ';
    ELSE
        INSERT INTO KhachHang(TenKhach, SoDu)
        VALUES(@Ten, @SoDu);
END;
GO

EXEC sp_ThemKhach N'Le Van C', 20000;

-- SP OUTPUT
GO
CREATE PROCEDURE sp_TongTienKhach
    @KhachId INT,
    @Tong MONEY OUTPUT
AS
BEGIN
    SELECT @Tong = SUM(TongTien)
    FROM HoaDon
    WHERE KhachHangId = @KhachId;
END;
GO

DECLARE @Tong MONEY;
EXEC sp_TongTienKhach 1, @Tong OUTPUT;
SELECT @Tong AS TongTienKhach;

-- SP JOIN
GO
CREATE PROCEDURE sp_DanhSachHoaDon
AS
BEGIN
    SELECT KH.TenKhach, MT.TenMay, HD.TongTien
    FROM HoaDon HD
    JOIN KhachHang KH ON HD.KhachHangId = KH.KhachHangId
    JOIN MayTinh MT ON HD.MayId = MT.MayId;
END;
GO

EXEC sp_DanhSachHoaDon;

-- =============================================
-- TRIGGER
-- =============================================
GO
CREATE TRIGGER trg_KhiThemHoaDon
ON HoaDon
AFTER INSERT
AS
BEGIN
    UPDATE MayTinh
    SET TrangThai = N'Đang dùng'
    WHERE MayId IN (SELECT MayId FROM inserted);
END;
GO

-- Test trigger
INSERT INTO HoaDon (KhachHangId, MayId, ThoiGianBatDau, TongTien)
VALUES (1, 1, GETDATE(), 15000);

SELECT * FROM MayTinh;

-- =============================================
-- CURSOR
-- =============================================
DECLARE @Id INT;

DECLARE cur CURSOR FOR
SELECT HoaDonId FROM HoaDon;

OPEN cur;

FETCH NEXT FROM cur INTO @Id;

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE HoaDon
    SET TongTien = 10000
    WHERE HoaDonId = @Id;

    FETCH NEXT FROM cur INTO @Id;
END;

CLOSE cur;
DEALLOCATE cur;

-- =============================================
-- NON-CURSOR (OPTIMIZED)
-- =============================================
UPDATE HoaDon
SET TongTien = 20000;

-- =============================================
-- END FILE
-- =============================================