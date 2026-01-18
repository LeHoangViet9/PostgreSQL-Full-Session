CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL
);
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    product_id INT,
    quantity INT NOT NULL,
    total_price DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
INSERT INTO products (product_id, product_name, category) VALUES
(1, 'Laptop Dell', 'Electronics'),
(2, 'IPhone 15', 'Electronics'),
(3, 'Bàn học gỗ', 'Furniture'),
(4, 'Ghế xoay', 'Furniture');
INSERT INTO orders (order_id, product_id, quantity, total_price) VALUES
(101, 1, 2, 2200),
(102, 2, 3, 3300),
(103, 3, 5, 2500),
(104, 4, 4, 1600),
(105, 1, 1, 1100);
--1 Viết truy vấn hiển thị tổng doanh thu (SUM(total_price)) và số lượng sản phẩm bán được (SUM(quantity)) cho từng nhóm danh mục (category)
Select p.category, sum(total_price) as total_price, sum(quantity) as total_quantity
from orders o left join products p on p.product_id = o.product_id
group by p.category

--Chỉ hiển thị những nhóm có tổng doanh thu lớn hơn 2000
Select p.category, sum(total_price) as total_price, sum(quantity) as total_quantity
from orders o left join products p on p.product_id = o.product_id
group by p.category
Having sum(total_price) >2000

--Sắp xếp kết quả theo tổng doanh thu giảm dần
Select p.category, sum(total_price) as Total_price, sum(quantity) as total_quantity
from orders o left join products p on p.product_id = o.product_id
group by p.category
Having sum(total_price) >2000
order by Total_price desc