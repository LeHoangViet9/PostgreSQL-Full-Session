CREATE TABLE inventory (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    quantity INT
);

INSERT INTO inventory (product_name, quantity)
VALUES 
    ('Laptop Dell XPS', 15),
    ('Chuột Logitech G502', 50),
    ('Bàn phím cơ Akko', 25),
    ('Màn hình LG 27 inch', 10);

create or replace procedure check_stock(
p_id int ,
p_qty int
)
LANGUAGE plpgsql
as $$
begin
	
	if 	exists (select * from inventory where product_id=p_id and quantity<p_qty)
	then
		raise notice 'Không đủ hàng trong kho';
	else 
		raise notice 'Sản phẩm ID % đủ hàng để bán',p_id;
	end if;
end $$


--Một sản phẩm có đủ hàng
--Một sản phẩm không đủ hàng
call check_stock(1,20);
call check_stock(2,5);