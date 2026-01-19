create table Product(
 id serial primary key ,
 name varchar(100),
 category varchar(50),
 price numeric(10,2),
 stock int
);
insert into Product (name,category,price,stock) values
('Laptop Dell Inspiron', 'Electronics', 1800.00, 15),
('iPhone 15 Pro', 'Electronics', 2500.00, 20),
('Samsung Galaxy S24', 'Electronics', 2200.00, 18),
('Bàn học gỗ', 'Furniture', 750.00, 10),
('Ghế xoay văn phòng', 'Furniture', 1200.00, 8),
('Tai nghe Bluetooth Sony', 'Accessories', 350.00, 30),
('Chuột Logitech MX Master', 'Accessories', 420.00, 25),
('Bàn phím cơ Keychron', 'Accessories', 650.00, 12),
('Máy in Canon LBP', 'Office', 2100.00, 6),
('Màn hình LG 27 inch', 'Electronics', 1900.00, 9);

--Hiển thị danh sách toàn bộ sản phẩm
select * from Product;

--Hiển thị 3 sản phẩm có giá cao nhất
select * from product order by price desc limit 3;

--Hiển thị các sản phẩm thuộc danh mục “Điện tử” có giá nhỏ hơn 10,000,000

select * from product where price <10000000

--Sắp xếp sản phẩm theo số lượng tồn kho tăng dần
select * from product order by stock asc