-- Tạo bảng OldCustomers (Khách hàng cũ)
CREATE TABLE OldCustomers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50)
);

-- Tạo bảng NewCustomers (Khách hàng mới)
CREATE TABLE NewCustomers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50)
);

-- Thêm dữ liệu vào bảng OldCustomers
INSERT INTO OldCustomers (name, city) VALUES 
('Nguyễn Văn An', 'Hà Nội'),
('Trần Thị Bình', 'Đà Nẵng'),
('Lê Văn Cường', 'TP. Hồ Chí Minh');

-- Thêm dữ liệu vào bảng NewCustomers
INSERT INTO NewCustomers (name, city) VALUES 
('Phạm Minh Đức', 'Cần Thơ'),
('Hoàng Lan Anh', 'Hải Phòng'),
('Đặng Quốc Bảo', 'Huế');

-- Lấy danh sách tất cả khách hàng (cũ + mới) không trùng lặp (UNION)
select * from oldcustomers
union 
select * from newcustomers

--Tìm khách hàng vừa thuộc bảng OldCustomers vừa thuộc bảng NewCustomers (INTERSECT)
select * from oldcustomers
INTERSECT 
select * from newcustomers

--Tính số lượng khách hàng ở từng thành phố (dùng GROUP BY city)
SELECT city, COUNT(*) AS tong_so_khach
FROM (
    SELECT city FROM OldCustomers
    UNION ALL
    SELECT city FROM NewCustomers
) AS all_customers
GROUP BY city
ORDER BY tong_so_khach DESC;

--Tìm thành phố có nhiều khách hàng nhất (dùng Subquery và MAX)
SELECT city, COUNT(*) AS so_luong
FROM NewCustomers
GROUP BY city
HAVING COUNT(*) = (
    -- Subquery: Tìm số lượng khách hàng lớn nhất tại một thành phố bất kỳ
    SELECT MAX(city_count)
    FROM (
        SELECT COUNT(*) AS city_count
        FROM NewCustomers
        GROUP BY city
    ) AS sub
);