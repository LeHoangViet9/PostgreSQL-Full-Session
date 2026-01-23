--Tạo View CustomerSales tổng hợp tổng amount theo từng customer_id
create or replace view CustomerSales as
	select customer_id, sum(amount) as totalAmount
	from sales
	group by customer_id

--Viết truy vấn SELECT * FROM CustomerSales WHERE total_amount > 1000; để xem khách hàng mua nhiều
 SELECT * FROM CustomerSales WHERE total_amount > 1000; 
--Thử cập nhật một bản ghi qua View và quan sát kết quả
update CustomerSales set totalAmount=14062008 where customer_id=1;