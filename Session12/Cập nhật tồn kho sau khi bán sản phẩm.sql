create or replace function f_insert_stock()
returns trigger
as $$
declare current_stock int;
begin
	UPDATE products
    SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;
end;
$$ LANGUAGE plpgsql

create or replace trigger tr_product_log
before insert on products 
for each row 
execute function f_insert_stock()

