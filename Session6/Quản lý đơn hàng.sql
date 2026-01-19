CREATE TABLE OrderInfo (
    id SERIAL PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total NUMERIC(10,2),
    status VARCHAR(20)
);

INSERT INTO OrderInfo (customer_id, order_date, total, status)
VALUES 
(1, '2023-10-01', 250.50, 'Completed'),
(2, '2023-10-02', 120.00, 'Pending'),
(3, '2023-10-05', 450.75, 'Completed'),
(1, '2023-10-10', 95.20, 'Cancelled'),
(5, '2023-10-12', 310.00, 'Completed');

--Truy vấn các đơn hàng có tổng tiền lớn hơn 500,000
select * from OrderInfo where total >5000000

--Truy vấn các đơn hàng có ngày đặt trong tháng 10 năm 2024
select * from OrderInfo where EXTRACT(MONTH FROM order_date) = 10
AND EXTRACT(YEAR FROM order_date) = 2024

--Liệt kê các đơn hàng có trạng thái khác “Completed”
select * from OrderInfo where status <> 'Completed'

--Lấy 2 đơn hàng mới nhất
select * from OrderInfo order by order_date desc limit 2
