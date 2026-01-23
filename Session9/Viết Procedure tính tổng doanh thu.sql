create table Sales(
	sale_id serial primary key,
	customer_id int not null,
	amount numeric(12,2) not null,
	sale_date date not null
	
);
INSERT INTO Sales (customer_id, amount, sale_date) VALUES
(1, 1000, '2024-01-01'),
(1, 2000, '2024-01-05'),
(1, 1500, '2024-01-10'),

(2, 500,  '2024-01-02'),
(2, 700,  '2024-01-06'),

(3, 3000, '2024-01-03'),
(3, 4000, '2024-01-08'),
(3, 2500, '2024-01-12');

--Tạo Procedure calculate_total_sales(start_date DATE, end_date DATE, OUT total NUMERIC) để tính tổng amount trong khoảng start_date đến end_date
create or replace procedure calculate_total_sales(
	start_date date,
	end_date date,
	out total numeric
)
LANGUAGE plpgsql
as $$
begin
	select COALESCE(sum(amount),0) into total from Sales where sale_date between start_date and end_date;
end;
$$;

--Gọi Procedure với các ngày mẫu và hiển thị kết quả
call calculate_total_sales('2024-01-01', '2024-01-10', NULL)