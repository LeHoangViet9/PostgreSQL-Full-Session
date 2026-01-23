CREATE TABLE order_detail (
    id SERIAL PRIMARY KEY,
    order_id INT,
    product_name VARCHAR(100),
    quantity INT,
    unit_price NUMERIC
);
INSERT INTO order_detail (order_id, product_name, quantity, unit_price)
VALUES 
    (101, 'Chuột không dây', 2, 450000),
    (102, 'Lót chuột cỡ lớn', 1, 150000),
    (103, 'Tai nghe Gaming', 1, 950000);

create or replace procedure calculate_order_total(
order_id_input int,
out total numeric
)
LANGUAGE plpgsql
as $$
begin 
	select sum(quantity*unit_price) into total
	from order_detail where order_id=order_id_input;
	
	raise notice 'Tổng giá trị là: %',total;
end $$

--Viết câu lệnh tính tổng tiền theo order_id
SELECT SUM(quantity * unit_price) 
INTO total 
FROM order_detail 
WHERE order_id = order_id_input;
--Gọi Procedure để kiểm tra hoạt động với một order_id cụ thể
do $$
declare v_total numeric;
begin
call calculate_order_total(101,v_total);
raise notice 'Kết quả là : %',v_total;
end $$;