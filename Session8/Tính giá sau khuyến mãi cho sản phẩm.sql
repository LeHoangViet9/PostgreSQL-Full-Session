CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price NUMERIC,
    discount_percent INT
);

INSERT INTO products (name, price, discount_percent)
VALUES 
    ('iPhone 15 Pro', 28000000, 5),
    ('Bàn phím cơ AKKO', 1500000, 15),
    ('Chuột Logitech G502', 1200000, 20);


--Viết Procedure calculate_discount(p_id INT, OUT p_final_price NUMERIC) để:
--Lấy price và discount_percent của sản phẩm
--Tính giá sau giảm:
 --p_final_price = price - (price * discount_percent / 100)
--Nếu phần trăm giảm giá > 50, thì giới hạn chỉ còn 50%

create or replace procedure calculate_discount(
p_id int ,
out p_final_price numeric
)
LANGUAGE plpgsql
as $$
declare v_price numeric; v_discount int;
begin
	select price,discount_percent into v_price,v_discount from products where id=p_id ;
	if(v_discount >50) then v_discount =50;
	end if;
	p_final_price= v_price - (v_price * v_discount / 100);
	raise notice 'Giá sau khi giảm % phần trăm là %',v_discount,p_final_price;
end;
$$;

UPDATE products
SET price = price - (price * (CASE 
                                WHEN discount_percent > 50 THEN 50 
                                ELSE discount_percent 
                              END) / 100);

do $$
declare p_final_price numeric;
begin
	call calculate_discount(2,p_final_price);
end $$;

