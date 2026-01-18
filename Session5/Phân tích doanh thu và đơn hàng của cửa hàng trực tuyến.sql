--Hiển thị danh sách tất cả các đơn hàng với các cột:
--Tên khách (customer_name)
--Ngày đặt hàng (order_date)
--Tổng tiền (total_amount)

select c.customer_name, o.order_date,o.total_amount
from customers c join orders o on c.customer_id = o.customer_id

--Aggregate Functions:
--Tính các thông tin tổng hợp:
--Tổng doanh thu (SUM(total_amount))
--Trung bình giá trị đơn hàng (AVG(total_amount))
--Đơn hàng lớn nhất (MAX(total_amount))
--Đơn hàng nhỏ nhất (MIN(total_amount))
--Số lượng đơn hàng (COUNT(order_id))

select sum(o.total_amount) as total_amount,avg(o.total_amount) as avg_amount,
max(o.total_amount) as max_amount,min(o.total_amount) as min_amount,
count(o.order_id) as count_order
from orders o

--GROUP BY / HAVING:
--Tính tổng doanh thu theo từng thành phố
--chỉ hiển thị những thành phố có tổng doanh thu lớn hơn 10.000

select c.city, sum(o.total_amount) as total_amount
from customers c join orders o on o.customer_id = c.customer_id
group by c.city
having sum(o.total_amount)>10000

--Liệt kê tất cả các sản phẩm đã bán, kèm:
--Tên khách hàng
--Ngày đặt hàng
--Số lượng và giá
--(JOIN 3 bảng customers, orders, order_items)

select c.customer_name, o.order_date, ot.quantity, ot.price
from customers c join orders o on o.customer_id = c.customer_id
join order_items ot on ot.order_id = o.order_id

--Tìm tên khách hàng có tổng doanh thu cao nhất.
--Gợi ý: Dùng SUM(total_amount) trong subquery để tìm MAX
select c.customer_name,sum(o.total_amount) as totalAmount  from customers c join orders o on o.customer_id = c.customer_id
group by c.customer_name
having sum(o.total_amount)=
(select max(totalAmount) from
(select sum(total_amount) as totalAmount from orders
group by customer_id))

--Dùng UNION để hiển thị danh sách tất cả thành phố có khách hàng hoặc có đơn hàng

select city from customers 
union
select c.city from orders o join customers c on c.customer_id = o.customer_id
--Dùng INTERSECT để hiển thị các thành phố vừa có khách hàng vừa có đơn hàng
select city from customers 
intersect
select c.city from orders o join customers c on c.customer_id = o.customer_id
