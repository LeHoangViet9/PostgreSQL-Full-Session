create table orders (
	id serial primary key,
	product_id int REFERENCES products(id),
	quantity int check (quantity>0),
	order_status varchar(20)
);

create or replace function trg_update_orders()
returns trigger as $$
DECLARE
    current_stock INT;
    diff INT;
begin
	if tg_op='INSERT' then 
	select stock into current_stock from products 
	where id=new.product_id
	for update;
	if new.quantity>current_stock then 
	raise exception 'Không đủ tồn kho. Hiện có %, yêu cầu %',
                current_stock, NEW.quantity;
	end if;
	
	update products 
	set stock=stock-new.quantity
	where id=new.product_id;
	return new;

	elsif tg_op='UPDATE' then 
	diff := new.quantity -old.quantity;
	select stock into current_stock
	from products where id=new.product_id
	for update;

	if diff >0 and diff> current_stock then 
	RAISE EXCEPTION 'Không đủ tồn kho để cập nhật đơn hàng';
	end if;
	
	update products 
	set stock=stock +old.quantity-new.quantity
	where id=new.product_id;
	return new;

	elsif tg_op='DELETE' then 
	update products 
	set stock=stock + old.quantity
	where id=old.product_id;
	return old;
	end if;
	return null;
end;
$$ LANGUAGE plpgsql

CREATE TRIGGER trg_orders_manage_stock
BEFORE INSERT OR UPDATE OR DELETE
ON orders
FOR EACH ROW
EXECUTE FUNCTION trg_update_orders()

INSERT INTO products(name, stock)
VALUES ('Laptop', 50);

INSERT INTO orders(product_id, quantity, order_status)
VALUES (1, 10, 'CONFIRMED');

UPDATE orders
SET quantity = 20
WHERE id = 1;

UPDATE orders
SET quantity = 100
WHERE id = 1;

DELETE FROM orders WHERE id = 1;
