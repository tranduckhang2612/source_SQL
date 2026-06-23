-- Bài 1
-- Tuổi của nhân viên phải lớn hơn 18
CREATE TRIGGER trg_NHANVIEN_Tuoi_LonHon18
ON NHANVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra nếu có nhân viên mới hoặc vừa cập nhật có tuổi <= 18
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE DATEDIFF(YEAR, NgaySinh, GETDATE()) <= 18
    )
    BEGIN
        RAISERROR (N'Lỗi: Tuổi của nhân viên phải lớn hơn 18.', 16, 1);
        ROLLBACK TRANSACTION;
    END 
END;

-- Testcase 
-- Cập nhật tuổi của nhân viên đã có (123456789) thành dưới 18 tuổi để kích hoạt lỗi
UPDATE NHANVIEN SET NgaySinh = GETDATE() WHERE SoCCCD = '123456789';

-- Bài 2
-- Người quản lý phải lớn tuổi hơn nhân viên dưới quyền
CREATE TRIGGER trg_NHANVIEN_QuanLyLonTuoiHon
ON NHANVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN NHANVIEN ql ON i.SoCCCD_NguoiQL = ql.SoCCCD
        WHERE i.NgaySinh <= ql.NgaySinh -- Ngày sinh lớn hơn nghĩa là ít tuổi hơn
    )
    BEGIN
        RAISERROR (N'Lỗi: Người quản lý phải lớn tuổi hơn nhân viên dưới quyền.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

-- Testcase
-- Cập nhật nhân viên 456789123 có ngày sinh nhỏ hơn (già hơn) người quản lý 987654321 (sinh năm 1988)
UPDATE NHANVIEN SET NgaySinh = '1980-01-01' WHERE SoCCCD = '456789123';

-- Bài 3:
-- Lương nhân viên không được lớn hơn lương người quản lý
CREATE TRIGGER trg_NHANVIEN_LuongNhoHonQuanLy
ON NHANVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN NHANVIEN ql ON i.SoCCCD_NguoiQL = ql.SoCCCD
        WHERE i.Luong > ql.Luong
    )
    BEGIN
        RAISERROR (N'Lỗi: Lương nhân viên không được vượt quá lương người quản lý.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

-- Testcase
-- Cập nhật lương của nhân viên 456789123 (hiện tại 35000) lớn hơn người quản lý 987654321 (lương 40000)
UPDATE NHANVIEN SET Luong = 45000.00 WHERE SoCCCD = '456789123';

-- Bài 4:
-- Trưởng phòng của một phòng ban phải là nhân viên của phòng ban đó
CREATE TRIGGER trg_PHONGBAN_TruongPhongThuocPhong
ON PHONGBAN
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN NHANVIEN nv ON i.SoCCCD_TruongPhong = nv.SoCCCD
        WHERE nv.MaPhong <> i.MaPhong
    )
    BEGIN
        RAISERROR (N'Lỗi: Trưởng phòng phải là nhân viên thuộc phòng ban đó.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

-- Testcase 
-- Gán nhân viên 789123456 (đang thuộc phòng 3) làm trưởng phòng của phòng 4
UPDATE PHONGBAN SET SoCCCD_TruongPhong = '789123456' WHERE MaPhong = 4;

-- Bài 5:
-- Địa điểm của dự án phải trùng với một trong các địa điểm của phòng ban phụ trách dự án đó
CREATE TRIGGER trg_DUAN_DiaDiemHopLe
ON DUAN
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE NOT EXISTS (
            SELECT 1 FROM DIADIEM_PHONG dd 
            WHERE dd.MaPhong = i.MaPhong AND dd.DiaDiem = i.DiaDiemDuAn
        )
    )
    BEGIN
        RAISERROR (N'Lỗi: Địa điểm dự án phải trùng với địa điểm của phòng ban quản lý.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

-- Testcase 
-- Cập nhật địa điểm của dự án 10 thành địa điểm không thuộc phòng ban 2 quản lý
UPDATE DUAN SET DiaDiemDuAn = 'Vung Tau' WHERE SoDuAn = 10;

-- Bài 6: 
-- Ngày vào làm của nhân viên phải lớn hơn ngày sinh
CREATE TRIGGER trg_NHANVIEN_NgayLamLonHonNgaySinh
ON NHANVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE NgayVaoLam <= NgaySinh
    )
    BEGIN
        RAISERROR (N'Lỗi: Ngày vào làm phải lớn hơn ngày sinh.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

-- Testcase: 
-- Cập nhật ngày vào làm của nhân viên 123456789 trước ngày sinh của họ (1985-01-15)
UPDATE NHANVIEN SET NgayVaoLam = '1980-01-01' WHERE SoCCCD = '123456789';

-- Bài 7: 
-- Người quản lý phải được thuê trước nhân viên cấp dưới ít nhất 1 năm 
CREATE TRIGGER trg_NHANVIEN_QuanLyVaoLamTruoc1Nam
ON NHANVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN NHANVIEN ql ON i.SoCCCD_NguoiQL = ql.SoCCCD
        WHERE DATEDIFF(YEAR, ql.NgayVaoLam, i.NgayVaoLam) < 1
    )
    BEGIN
        RAISERROR (N'Lỗi: Người quản lý phải vào làm trước nhân viên cấp dưới ít nhất 1 năm.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

-- Testcase
-- Cập nhật ngày vào làm của 456789123 thành 2015-06-01, trong khi quản lý 987654321 vào làm 2015-03-12 (nhỏ hơn 1 năm)
UPDATE NHANVIEN SET NgayVaoLam = '2015-06-01' WHERE SoCCCD = '456789123';

-- Bài 8:
-- Thuộc tính PHONGBAN.SoLuongNhanVien là thuộc tính suy diễn từ NHANVIEN.MaPhong.
CREATE TRIGGER trg_NHANVIEN_CapNhatSoLuongNV
ON NHANVIEN
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
    IF TRIGGER_NESTLEVEL() > 1 RETURN;

    UPDATE PHONGBAN
    SET SoLuongNhanVien = (SELECT COUNT(*) FROM NHANVIEN nv WHERE nv.MaPhong = PHONGBAN.MaPhong)
    WHERE MaPhong IN (
        SELECT MaPhong FROM inserted
        UNION
        SELECT MaPhong FROM deleted
    );
END;

-- Testcase
-- Thử đổi phòng ban của nhân viên đã có sẵn (123456789) để kích hoạt trigger
UPDATE NHANVIEN SET MaPhong = 2 WHERE SoCCCD = '123456789';

SELECT MaPhong, SoLuongNhanVien 
FROM PHONGBAN;


-- Bài 9:
-- Một nhân viên làm việc tối đa ở 4 dự án.
CREATE TRIGGER trg_THAMGIA_ToiDa4DuAn
ON THAM_GIA
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT SoCCCD_NV FROM THAM_GIA
        WHERE SoCCCD_NV IN (SELECT SoCCCD_NV FROM inserted)
        GROUP BY SoCCCD_NV
        HAVING COUNT(SoDuAn) > 4
    )
    BEGIN
        RAISERROR (N'Lỗi: Một nhân viên làm việc tối đa ở 4 dự án.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

-- Testcase
-- Nhân viên 123456789 đã tham gia 1 dự án (40) trong insertTable. 
-- Thêm vào 4 dự án nữa để kích hoạt lỗi làm quá 4 dự án.
INSERT INTO THAM_GIA(SoCCCD_NV, SoDuAn, SoGio) VALUES ('123456789', 10, 5);
INSERT INTO THAM_GIA(SoCCCD_NV, SoDuAn, SoGio) VALUES ('123456789', 20, 5);
INSERT INTO THAM_GIA(SoCCCD_NV, SoDuAn, SoGio) VALUES ('123456789', 30, 5);
INSERT INTO THAM_GIA(SoCCCD_NV, SoDuAn, SoGio) VALUES ('123456789', 50, 5);


-- Bài 10:
-- Một nhân viên làm việc ít nhất 30h/tuần và tối đa 50h/tuần trên tất cả các dự án của mình.
CREATE TRIGGER trg_THAMGIA_TongGioLam
ON THAM_GIA
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT SoCCCD_NV FROM THAM_GIA
        WHERE SoCCCD_NV IN (SELECT SoCCCD_NV FROM inserted)
        GROUP BY SoCCCD_NV
        HAVING SUM(SoGio) < 30 OR SUM(SoGio) > 50
    )
    BEGIN
        RAISERROR (N'Lỗi: Tổng số giờ làm việc của nhân viên trên tất cả dự án phải từ 30 đến 50 giờ.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

-- Testcase
-- Nhân viên 123456789 đã có 15.5h. Thêm 40h nữa -> Tổng > 50h, kích hoạt lỗi.
INSERT INTO THAM_GIA(SoCCCD_NV, SoDuAn, SoGio) VALUES ('123456789', 10, 40);


-- Bài 11:
-- Trong số các nhân viên làm việc cho một dự án, tối đa 2 người có thể làm việc dưới 10 giờ.
CREATE TRIGGER trg_THAMGIA_ToiDa2NVDuoi10Gio
ON THAM_GIA
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT SoDuAn FROM THAM_GIA
        WHERE SoDuAn IN (SELECT SoDuAn FROM inserted) AND SoGio < 10
        GROUP BY SoDuAn
        HAVING COUNT(SoCCCD_NV) > 2
    )
    BEGIN
        RAISERROR (N'Lỗi: Tối đa 2 nhân viên có thể làm việc dưới 10 giờ trong một dự án.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

-- Testcase
-- Thêm 3 nhân viên có sẵn làm việc dưới 10h cho cùng 1 dự án (20)
INSERT INTO THAM_GIA(SoCCCD_NV, SoDuAn, SoGio) VALUES ('123456789', 20, 5);
INSERT INTO THAM_GIA(SoCCCD_NV, SoDuAn, SoGio) VALUES ('987654321', 20, 5);
INSERT INTO THAM_GIA(SoCCCD_NV, SoDuAn, SoGio) VALUES ('456789123', 20, 5);


-- Bài 12:
-- Chỉ trưởng phòng mới được làm việc dưới 5 giờ cho một dự án.
CREATE TRIGGER trg_THAMGIA_NVDuoi5GioLaTruongPhong
ON THAM_GIA
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE i.SoGio < 5 AND NOT EXISTS (
            SELECT 1 FROM PHONGBAN pb WHERE pb.SoCCCD_TruongPhong = i.SoCCCD_NV
        )
    )
    BEGIN
        RAISERROR (N'Lỗi: Chỉ trưởng phòng mới được làm việc dưới 5 giờ cho một dự án.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

-- Testcase
-- Nhân viên 456789123 không phải trưởng phòng, chèn thời gian < 5h để kích hoạt lỗi
INSERT INTO THAM_GIA(SoCCCD_NV, SoDuAn, SoGio) VALUES ('456789123', 20, 4);


-- Bài 13:
-- Nhân viên không phải là người giám sát (không quản lý ai) phải làm việc ít nhất 10 giờ trên mỗi dự án.
CREATE TRIGGER trg_THAMGIA_NVKhongQuanLyLamTren10Gio
ON THAM_GIA
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE i.SoGio < 10 AND NOT EXISTS (
            SELECT 1 FROM NHANVIEN nv WHERE nv.SoCCCD_NguoiQL = i.SoCCCD_NV
        )
    )
    BEGIN
        RAISERROR (N'Lỗi: Nhân viên không phải người quản lý phải làm việc ít nhất 10 giờ trên mỗi dự án.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

-- Testcase
-- Nhân viên 456789123 không quản lý ai, làm việc < 10h để kích hoạt lỗi
INSERT INTO THAM_GIA(SoCCCD_NV, SoDuAn, SoGio) VALUES ('456789123', 20, 9);


-- Bài 14:
-- Trưởng phòng của một phòng ban phải làm việc ít nhất 5 giờ trên tất cả các dự án do phòng ban đó kiểm soát.
CREATE TRIGGER trg_THAMGIA_TruongPhongDuAnPhong
ON THAM_GIA
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN DUAN da ON i.SoDuAn = da.SoDuAn
        JOIN PHONGBAN pb ON da.MaPhong = pb.MaPhong AND i.SoCCCD_NV = pb.SoCCCD_TruongPhong
        WHERE i.SoGio < 5
    )
    BEGIN
        RAISERROR (N'Lỗi: Trưởng phòng phải làm việc ít nhất 5 giờ trên các dự án do phòng mình kiểm soát.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

-- Tự động gán trưởng phòng vào dự án khi tạo mới để đảm bảo có tham gia
CREATE TRIGGER trg_DUAN_ThemTruongPhongVaoDuAn
ON DUAN
AFTER INSERT
AS
BEGIN
    INSERT INTO THAM_GIA (SoCCCD_NV, SoDuAn, SoGio)
    SELECT pb.SoCCCD_TruongPhong, i.SoDuAn, 5.0
    FROM inserted i
    JOIN PHONGBAN pb ON i.MaPhong = pb.MaPhong
    WHERE pb.SoCCCD_TruongPhong IS NOT NULL;
END;

-- Testcase
-- Trưởng phòng 987654321 (phòng 2) làm việc < 5h cho dự án do phòng mình kiểm soát (Dự án 20)
INSERT INTO THAM_GIA(SoCCCD_NV, SoDuAn, SoGio) VALUES ('987654321', 20, 4);


-- Bài 15:
-- Thuộc tính NHANVIEN.SoCCCD_NguoiQL là thuộc tính suy diễn.
-- Trưởng phòng phòng ban 1 giám sát trưởng phòng các phòng khác.
-- Trưởng phòng giám sát nhân viên trong phòng. Trưởng phòng 1 có SoCCCD_NguoiQL = NULL.
CREATE TRIGGER trg_NHANVIEN_CapNhatNguoiQL
ON NHANVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    IF TRIGGER_NESTLEVEL() > 1 RETURN;

    IF UPDATE(MaPhong) OR UPDATE(SoCCCD)
    BEGIN
        -- 1. Nhân viên bình thường -> NguoiQL = TruongPhong của phòng ban họ
        UPDATE nv
        SET SoCCCD_NguoiQL = pb.SoCCCD_TruongPhong
        FROM NHANVIEN nv
        JOIN inserted i ON nv.SoCCCD = i.SoCCCD
        JOIN PHONGBAN pb ON nv.MaPhong = pb.MaPhong
        WHERE nv.SoCCCD <> ISNULL(pb.SoCCCD_TruongPhong, '');

        -- 2. Trưởng phòng các phòng khác -> NguoiQL = TruongPhong của phòng ban 1
        UPDATE nv
        SET SoCCCD_NguoiQL = (SELECT SoCCCD_TruongPhong FROM PHONGBAN WHERE MaPhong = 1)
        FROM NHANVIEN nv
        JOIN inserted i ON nv.SoCCCD = i.SoCCCD
        JOIN PHONGBAN pb ON nv.MaPhong = pb.MaPhong
        WHERE nv.SoCCCD = pb.SoCCCD_TruongPhong AND nv.MaPhong <> 1;

        -- 3. Trưởng phòng ban 1 -> NguoiQL = NULL
        UPDATE nv
        SET SoCCCD_NguoiQL = NULL
        FROM NHANVIEN nv
        JOIN inserted i ON nv.SoCCCD = i.SoCCCD
        JOIN PHONGBAN pb ON nv.MaPhong = pb.MaPhong
        WHERE nv.SoCCCD = pb.SoCCCD_TruongPhong AND nv.MaPhong = 1;
    END
END;

-- Testcase
-- Chuyển nhân viên 456789123 sang phòng 3 để cập nhật người quản lý mới tự động
UPDATE NHANVIEN SET MaPhong = 3 WHERE SoCCCD = '456789123';


-- Bài 16:
-- Mối quan hệ giám sát được xác định bởi Employee.SoCCCD_NguoiQL không được có tính chu kỳ.
-- (Giả sử thuộc tính này KHÔNG phải là thuộc tính suy diễn như bài 15).
CREATE TRIGGER trg_NHANVIEN_KhongVoVongLapQuanLy
ON NHANVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    IF UPDATE(SoCCCD_NguoiQL)
    BEGIN
        ;WITH CTE AS (
            SELECT SoCCCD, SoCCCD_NguoiQL, SoCCCD AS RootCCCD, 1 AS Level
            FROM inserted
            WHERE SoCCCD_NguoiQL IS NOT NULL
            
            UNION ALL
            
            SELECT c.SoCCCD, nv.SoCCCD_NguoiQL, c.RootCCCD, c.Level + 1
            FROM CTE c
            JOIN NHANVIEN nv ON c.SoCCCD_NguoiQL = nv.SoCCCD
            WHERE nv.SoCCCD_NguoiQL IS NOT NULL AND c.Level < 100
        )
        IF EXISTS (SELECT 1 FROM CTE WHERE SoCCCD_NguoiQL = RootCCCD)
        BEGIN
            RAISERROR (N'Lỗi: Mối quan hệ quản lý không được tạo thành vòng lặp.', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
END;

-- Testcase
-- Nhân viên 987654321 đang được quản lý bởi 123456789 (theo insertTable).
-- Cập nhật để 123456789 bị quản lý bởi 987654321 (tạo vòng lặp) để kích hoạt lỗi.
UPDATE NHANVIEN 
SET SoCCCD_NguoiQL = '987654321'
WHERE SoCCCD = '123456789';