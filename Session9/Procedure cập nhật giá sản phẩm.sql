create table Products(
	product_id serial primary key,
	name varchar(100) not null,
	price numeric(12,2) not null,
	category_id int not null
);
INSERT INTO Products (name, price, category_id) VALUES
('Laptop Dell', 1500.00, 1),
('Laptop HP', 1400.00, 1),
('Laptop Asus', 1300.00, 1),

('iPhone 14', 1200.00, 2),
('Samsung Galaxy S23', 1100.00, 2),

('Tai nghe Sony', 200.00, 3),
('Chuột Logitech', 80.00, 3),
('Bàn phím Keychron', 150.00, 3);

--Tạo Procedure update_product_price(p_category_id INT, p_increase_percent NUMERIC) để tăng giá tất cả sản phẩm trong một category_id theo phần trăm
create or replace procedure update_product_price(
	p_category_id int,
	p_increase_percent numeric
)
LANGUAGE plpgsql
as $$
begin 
	update Products set price=price*(1+p_increase_percent/100) where category_id=p_category_id;
end ;
$$;

--Sử dụng biến để tính giá mới cho từng sản phẩm trong vòng lặp
create or replace procedure update_product_price_loop(
	p_category_id int,
	p_increase_percent numeric
)
LANGUAGE plpgsql
as $$
declare v_product record; v_new_price numeric;
begin 
	if p_increase_percent<= 0 then raise notice 'Increase percent must be >0';
	end if;

	for v_product in 
		select product_id,price
		from Products
		where category_id=p_category_id
	loop 
		v_new_price := v_product.price *(1+p_increase_percent/100);

		update Products
		set price=v_new_price
		where product_id=v_product.product_id;
	end loop;
end ;
$$;

CALL update_product_price_loop(1, 20);

SELECT product_id, name, price
FROM Products
WHERE category_id = 1;
