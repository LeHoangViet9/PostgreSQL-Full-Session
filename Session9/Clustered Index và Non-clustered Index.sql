--Tạo Clustered Index trên cột category_id
create or replace index idx_products_category_id on Products(category);
cluster products using idx_products_category_id;
--Tạo Non-clustered Index trên cột price
create or replace index idx_products_price on Products(price);
--Thực hiện truy vấn SELECT * FROM Products WHERE category_id = X ORDER BY price; và giải thích cách Index hỗ trợ tối ưu
explain ANALYZE SELECT * FROM Products WHERE category_id = 1 ORDER BY price; 
--seq scan is very slow
-- 
CREATE INDEX idx_products_category_price
ON products(category_id, price);
