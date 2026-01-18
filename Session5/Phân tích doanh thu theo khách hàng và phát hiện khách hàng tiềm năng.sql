CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL
);
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_price DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
INSERT INTO customers (customer_id, customer_name, city) VALUES
(1, 'Nguyễn Văn A', 'Hà Nội'),
(2, 'Trần Thị B', 'Đà Nẵng'),
(3, 'Lê Văn C', 'Hồ Chí Minh'),
(4, 'Phạm Thị D', 'Hà Nội');
INSERT INTO orders (order_id, customer_id, order_date, total_price) VALUES
(101, 1, '2024-12-20', 3000),
(102, 2, '2025-01-05', 1500),
(103, 1, '2025-02-10', 2500),
(104, 3, '2025-02-15', 4000),
(105, 4, '2025-03-01', 800);
INSERT INTO order_items (item_id, order_id, product_id, quantity, price) VALUES
(1, 101, 1, 2, 1500),
(2, 102, 2, 1, 1500),
(3, 103, 3, 5, 500),
(4, 104, 2, 4, 1000);

--Viết truy vấn hiển thị tổng doanh thu và
--tổng số đơn hàng của mỗi khách hàng:
select o.order_id, sum(o.total_price) as total_revenue, sum(ot.quantity) as total_quantity
from order_items ot join orders o on ot.order_id = o.order_id
group by o.order_id

--Chỉ hiển thị khách hàng có tổng doanh thu > 2000
select o.order_id, sum(o.total_price) as total_revenue, sum(ot.quantity) as total_quantity
from order_items ot join orders o on ot.order_id = o.order_id
group by o.order_id
having sum(o.total_price)>2000

--Dùng ALIAS: total_revenue và order_count
select sum(o.total_price) as total_revenue, sum(ot.quantity) as order_count
from order_items ot join orders o on ot.order_id = o.order_id
group by o.order_id
having sum(o.total_price)>2000

-- Viết truy vấn con (Subquery) để tìm doanh thu trung bình của tất cả khách hàng
select c.customer_name , sum(o.total_price) as total_revenue
from customers c join orders o on c.customer_id=o.customer_id
group by c.customer_name
Having sum(o.total_price)>
(select avg(customer_revenue)
from
(select o.customer_id, sum(o.total_price) as customer_revenue from orders o 
group by o.customer_id))

--Dùng HAVING + GROUP BY để lọc ra thành phố có tổng doanh thu cao nhất
select c.city , sum(o.total_price) as total_revenue
from customers c join orders o on c.customer_id=o.customer_id
group by c.city
Having sum(o.total_price)>
(select avg(customer_revenue)
from
(select o.customer_id, sum(o.total_price) as customer_revenue from orders o 
group by o.customer_id))

--Hãy dùng INNER JOIN giữa customers, orders, order_items để hiển thị chi tiết:
--Tên khách hàng, tên thành phố, tổng sản phẩm đã mua, tổng chi tiêu
select c.customer_name,c.city, sum(ot.quantity)as order_count, sum(ot.quantity*ot.price) from customers c join orders o on o.customer_id = c.customer_id
join order_items ot on ot.order_id = o.order_id
group by c.customer_name,c.city