-- Tạo bảng lưu thông tin sản phẩm
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    stock INT
);

-- Tạo bảng lưu thông tin đơn hàng (có liên kết với bảng sản phẩm)
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    quantity INT
);

create or replace function f_product_log()
returns trigger
as $$
declare current_stock int;
begin
	select stock into current_stock
	from products 
	where product_id=new.product_id;
	if current_stoct<new.quantity then
	raise exception 'Đơn hàng vượt quá tồn kho';
	end if ;
end;
$$ LANGUAGE plpgsql

create or replace trigger tr_product_log
before insert on products 
for each row 
execute function f_product_log()

INSERT INTO products (name, stock) VALUES ('iPhone 15', 5);

INSERT INTO sales (product_id, quantity) VALUES (1, 10);