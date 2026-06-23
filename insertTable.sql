USE grouping_uth;
GO

INSERT INTO PHONGBAN (TenPhong, MaPhong, SoCCCD_TruongPhong, NgayNhanChuc, SoLuongNhanVien) VALUES
('Giam Doc',     1, NULL, '2010-01-01', 1),
('Nghiencuu',    2, NULL, '2015-03-12', 2),
('KeToan',       3, NULL, '2012-10-01', 1),
('Nhan Su',      4, NULL, '2018-05-01', 1),
('Kinh Doanh',   5, NULL, '2020-09-15', 0);

INSERT INTO NHANVIEN (TenLot, ChuCaiDauGiua, Ten, SoCCCD, NgaySinh, DiaChi, GioiTinh, Luong, SoCCCD_NguoiQL, MaPhong, NgayVaoLam) VALUES
('Nguyen', 'T', 'Anh',   '123456789', '1985-01-15', '123 Le Loi, Q1', 'M', 50000.00, NULL, 1, '2010-01-01'),
('Tran',   'V', 'Binh',  '987654321', '1988-05-20', '456 Nguyen Hue, Q3', 'M', 40000.00, '123456789', 2, '2015-03-12'),
('Pham',   'P', 'Dung',  '789123456', '1990-11-30', '321 Cach Mang T8, TB', 'M', 38000.00, '123456789', 3, '2012-10-01'),
('Le',     'M', 'Chi',   '456789123', '1992-09-05', '789 Dien Bien Phu, BT', 'F', 35000.00, '987654321', 2, '2018-07-22'),
('Hoang',  'T', 'Huong', '321654987', '1995-04-18', '654 Vo Van Kiet, Q5', 'F', 32000.00, '123456789', 4, '2018-05-01');


UPDATE PHONGBAN SET SoCCCD_TruongPhong = '123456789' WHERE MaPhong = 1;
UPDATE PHONGBAN SET SoCCCD_TruongPhong = '987654321' WHERE MaPhong = 2;
UPDATE PHONGBAN SET SoCCCD_TruongPhong = '789123456' WHERE MaPhong = 3;
UPDATE PHONGBAN SET SoCCCD_TruongPhong = '321654987' WHERE MaPhong = 4;
-- MaPhong 5 tam thoi chua co truong phong thuc te, de NULL.

INSERT INTO DUAN (TenDuAn, SoDuAn, DiaDiemDuAn, MaPhong) VALUES
('ProjectA', 10, 'TP HCM', 2),
('ProjectB', 20, 'Ha Noi', 2),
('ProjectC', 30, 'Da Nang', 3),
('ProjectD', 40, 'TP HCM', 1),
('ProjectE', 50, 'Can Tho', 4);

INSERT INTO DIADIEM_PHONG (MaPhong, DiaDiem) VALUES
(1, 'Tang 10 Toa A'),
(2, 'Phong Lab 1'),
(3, 'Tang 5 Toa B'),
(4, 'Tang 2 Toa A'),
(5, 'Phong 102 Toa C');

INSERT INTO NGUOI_PHU_THUOC (SoCCCD_NV, TenNguoiPhuThuoc, GioiTinh, NgaySinh, QuanHe) VALUES
('123456789', 'Nguyen Minh A', 'M', '2012-03-25', 'Con trai'),
('123456789', 'Le Thi B',      'F', '1987-08-14', 'Vo'),
('987654321', 'Tran Thanh C',  'F', '2016-11-02', 'Con gai'),
('789123456', 'Pham Hoang D',  'M', '2019-05-19', 'Con trai'),
('321654987', 'Hoang Van E',   'M', '2021-01-10', 'Con trai');

INSERT INTO THAM_GIA (SoCCCD_NV, SoDuAn, SoGio) VALUES
('123456789', 40, 15.5),
('987654321', 10, 32.0),
('456789123', 10, 40.0),
('789123456', 30, 20.0),
('321654987', 50, 35.0);