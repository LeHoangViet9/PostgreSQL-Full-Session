--Viết truy vấn con (Subquery) để tìm sản phẩm có doanh thu cao nhất trong bảng orders
select p.product_name, sum(o.total_price) as total_revenue
from products p join orders o on o.product_id = p.product_id
group by p.product_name
Having sum(o.total_price)=
(
	select max(product_sales)
	from
(select product_id, sum(total_price) 
as product_sales from orders group by product_id ))

--Viết truy vấn hiển thị tổng doanh thu theo từng nhóm category (dùng JOIN + GROUP BY)
select p.category, sum(o.total_price) as total_revenue
from orders o join products p on p.product_id = o.product_id
group by p.category

--Dùng INTERSECT để tìm ra nhóm category có sản phẩm bán chạy nhất (ở câu 1) cũng nằm trong danh sách
--nhóm có tổng doanh thu lớn hơn 3000
select DISTINCT p.category
from products p join orders o on o.product_id = p.product_id
group by p.category
Having sum(o.quantity)=
(select max(total_quantity) from
(select p.category, sum(o.quantity) as total_quantity
from products p join orders o on o.product_id = p.product_id
group by p.category))
