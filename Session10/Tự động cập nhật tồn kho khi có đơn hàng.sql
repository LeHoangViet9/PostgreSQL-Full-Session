create table products (
	id serial primary key,
	name varchar(100) not null,
	stock int check(stock>0)
);
create table orders(
	id serial primary key,
	product_id int references products(id),
	quantity int check (quantity>0)
);

create or replace function trg_update_stock()
returns trigger as $$
begin
	if tg_op='INSERT' then
	update products
	set stock=stock-new.quantity
	where id=new.product_id;
	return new;

	elsif tg_op='UPDATE' then
	update products
	set stock=stock+old.quantity-new.quantity
	where id=new.product_id;
	return new;

	elsif tg_op='DELETE' then
	update products 
	set stock=stock+old.quantity
	where id=old.product_id;
	return old;
	end if;
	return null;
end;
$$ LANGUAGE plpgsql;

create or replace trigger trg_orders_update_stock
after insert or delete or update on orders 
for each row 
execute function trg_update_stock();

INSERT INTO products(name, stock)
VALUES ('Laptop', 100);

INSERT INTO orders(product_id, quantity)
VALUES (1, 10);

UPDATE orders
SET quantity = 20
WHERE id = 1;
DELETE FROM orders
WHERE id = 1;


select * from products 
select * from orders

