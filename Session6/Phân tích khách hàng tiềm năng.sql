--Hiển thị tên khách hàng và tổng tiền đã mua, sắp xếp theo tổng tiền giảm dần
select c.name , sum(o.total_amount) as sum_amount
from customer c join orders o on c.id = o.customer_id
group by c.name
order by sum_amount desc

--Tìm khách hàng có tổng chi tiêu cao nhất (dùng Subquery với MAX)
select c.name , sum(o.total_amount) as sum_amount
from customer c join orders o on c.id = o.customer_id 
group by c.name
having sum(o.total_amount) =
(select max(sum_amount) from
(select sum(total_amount) as sum_amount from orders o
group by o.customer_id))

--Liệt kê khách hàng chưa từng mua hàng (LEFT JOIN + IS NULL)
select c.name 
from customer c left join orders o on c.id = o.customer_id
where o.id is null

--Hiển thị khách hàng có tổng chi tiêu > trung bình của toàn bộ khách hàng (dùng Subquery trong HAVING)
select c.name , avg(o.total_amount)
from customer c left join orders o on c.id = o.customer_id
group by c.name
having avg(o.total_amount)>
(select avg(o.total_amount)
from orders o )
