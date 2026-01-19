CREATE TABLE Course (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100),
    instructor VARCHAR(50),
    price NUMERIC(10,2),
    duration INT -- số giờ học
);
INSERT INTO Course (title, instructor, price, duration)
VALUES 
('Lập trình Java', 'Trần Văn Hùng', 1500000, 45),
('Phát triển Mobile App', 'Lê Thị Mai', 2200000, 50),
('An toàn thông tin', 'Nguyễn Minh Triết', 1850000, 35),
('Tiếng Anh chuyên ngành IT', 'Hoàng Lan', 900000, 25),
('Quản trị cơ sở dữ liệu', 'Phạm Đức Duy', 1350000, 40),
('Kỹ năng mềm cho Dev', 'Đỗ Bảo Ngọc', 700000, 15);

--Cập nhật giá tăng 15% cho các khóa học có thời lượng trên 30 giờ
update Course set price=price*1.5 where duration > 30

--Xóa khóa học có tên chứa từ khóa “Demo”
delete from Course where title ilike '%Demo%'

--Hiển thị các khóa học có tên chứa từ “SQL” (không phân biệt hoa thường)
select * from Course where title ilike '%SQL%'

--Lấy 3 khóa học có giá nằm giữa 500,000 và 2,000,000, sắp xếp theo giá giảm dần
select * from Course where price between 500000 and 2000000 order by price desc limit 3;
