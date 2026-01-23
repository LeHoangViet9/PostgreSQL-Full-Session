--Tạo một B-Tree Index trên cột customer_id
create or replace index idx_orders_customer_id on orders(customer_id);
--Thực hiện truy vấn SELECT * FROM Orders WHERE customer_id = X; trước và sau khi tạo Index, so sánh thời gian thực hiện
explain ANALYZE
SELECT * FROM Orders WHERE customer_id = 1;
-- Seq Scan on orders thời gian phụ thuộc vào số lượng record
--Khi tạo truy vấn : index scan using idx_orders_customer_id on Orders
-- tìm đc trực tiếp không phải quét bảng nên nhanh hơn