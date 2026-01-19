-- Tạo bảng Product
CREATE TABLE Product (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price NUMERIC(10,2)
);

-- Tạo bảng OrderDetail
CREATE TABLE OrderDetail (
    id SERIAL PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT
);

INSERT INTO Product (name, category, price) VALUES 
('Laptop Dell XPS', 'Điện tử', 25000000.00),
('iPhone 15 Pro', 'Điện thoại', 30000000.00),
('Chuột Logitech', 'Phụ kiện', 500000.00);

INSERT INTO OrderDetail (order_id, product_id, quantity) VALUES 
(1, 1, 1), 
(1, 3, 2), 
(2, 2, 1); 



--Tính tổng doanh thu từng sản phẩm, hiển thị product_name, total_sales (SUM(price * quantity))
select p.name, sum(p.price*od.quantity) as total_sales
from product p join orderdetail od on od.product_id=p.id
group by p.name

--Tính doanh thu trung bình theo từng loại sản phẩm (GROUP BY category)
select p.category, avg(p.price*od.quantity) as avg_total_sales
from product p join orderdetail od on od.product_id=p.id
group by p.category;

--Chỉ hiển thị các loại sản phẩm có doanh thu trung bình > 20 triệu (HAVING)
select p.category, avg(p.price*od.quantity) as avg_total_sales
from product p join orderdetail od on od.product_id=p.id
group by p.category
having  avg(p.price*od.quantity)>20000000

--Hiển thị tên sản phẩm có doanh thu cao hơn doanh thu trung bình toàn bộ sản phẩm (dùng Subquery)
select p.name, sum(p.price*od.quantity) as total_revenue
from product p join orderdetail od on od.product_id=p.id 
group by p.name
having sum(p.price*od.quantity)>
(select avg(product_revenue) 
from (
select sum(p.price*od.quantity) as product_revenue
from product p join orderdetail od on od.product_id=p.id 
group by p.id
) )

--Liệt kê toàn bộ sản phẩm và số lượng bán được (nếu có) – kể cả sản phẩm chưa có đơn hàng (LEFT JOIN)
select p.name,sum(od.quantity) as number_discount
from product p left join orderdetail od on od.product_id=p.id 
group by p.name

