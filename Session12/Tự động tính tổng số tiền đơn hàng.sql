create table orders(
	order_id serial primary key,
	product_id int references products(product_id),
	quantity int,
	total_amount numeric
);

-- Thêm cột price vào bảng products nếu chưa có
ALTER TABLE products ADD COLUMN price NUMERIC DEFAULT 100;

-- Cập nhật giá mẫu cho sản phẩm
UPDATE products SET price = 500 WHERE product_id = 1;
create or replace function f_calculate()
returns trigger
declare v_price numeric;
as $$
begin
	SELECT price INTO v_price 
    FROM products 
    WHERE product_id = NEW.product_id;

    -- Tính toán tổng tiền
    NEW.total_amount := NEW.quantity * v_price;

    RETURN NEW;
end;
$$ LANGUAGE plpgsql;

create or replace trigger tr_update
before insert on orders
for each row 
execute function f_calculate()