-- Tạo bảng
CREATE TABLE Orders (
    id SERIAL PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount NUMERIC(10,2)
);

-- Thêm 6 dữ liệu mẫu
INSERT INTO Orders (customer_id, order_date, total_amount) VALUES 
(5, '2024-01-20', 1200.00),
(6, '2024-01-21', 850.50),
(7, '2024-01-22', 2100.00),
(5, '2024-01-23', 45.00),
(8, '2024-01-24', 990.00),
(9, '2024-01-25', 150.25);

--Hiển thị tổng doanh thu, số đơn hàng, giá trị trung bình mỗi đơn (dùng SUM, COUNT, AVG) - Đặt bí danh cột lần lượt 
select sum(total_amount) as "total_revenue",
count(total_amount) as "total_orders",
avg(total_amount) as "average_order_value"
from Orders

--Nhóm dữ liệu theo năm đặt hàng, hiển thị doanh thu từng năm (GROUP BY EXTRACT(YEAR FROM order_date))
select extract(year from order_date) as order_year,
sum(total_amount) as total_revenue
from Orders
group by extract(year from order_date)

-- Chỉ hiển thị các năm có doanh thu trên 50 triệu (HAVING)
select Extract(Year from order_date) as year, sum(total_amount) as total_revenue from Orders 
group by Extract(Year from order_date) 
having sum(total_amount)>50000000;

--Hiển thị 5 đơn hàng có giá trị cao nhất (dùng ORDER BY + LIMIT)
select * from Orders order by total_amount desc limit 5