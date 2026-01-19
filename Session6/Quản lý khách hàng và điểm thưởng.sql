CREATE TABLE Customer (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    points INT
);

INSERT INTO Customer (name, email, phone, points)
VALUES 
('Nguyễn Văn An', 'an.nguyen@example.com', '0912345678', 100),
('Trần Thị Bình', 'binh.tran@example.com', '0923456789', 150),
('Lê Hoàng Cường', 'cuong.le@example.com', '0934567890', 200),
('Phạm Minh Đức', 'duc.pham@example.com', '0945678901', 50),
('Vũ Thị Thanh Én', 'en.vu@example.com', '0956789012', 300),
('Ngô Văn Giang', 'giang.ngo@example.com', '0967890123', 120),
('Đỗ Thị Hạnh', NULL, '0978901234', 80);

--Truy vấn danh sách tên khách hàng duy nhất (DISTINCT)
select DISTINCT name from Customer 

--Tìm các khách hàng chưa có email (IS NULL)
select * from Customer where email is null

--Hiển thị 3 khách hàng có điểm thưởng cao nhất, bỏ qua khách hàng cao điểm nhất 
select * from Customer order by points desc limit 3 offset 1

--Sắp xếp danh sách khách hàng theo tên giảm dần
select * from Customer order by name desc
