create table products(
	id serial primary key ,
	name varchar(100) not null,
	price numeric(12,2) check(price>0),
	last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
create or replace function update_last_modifided()
returns trigger as $$
begin
	new.last_modified =current_timestamp;
end ;
$$ language plpgsql

create or replace trigger trg_update_last_modified 
before update on products 
for each row
execute function update_last_modifided()

INSERT INTO products(name, price) VALUES ('Laptop', 1500);

SELECT * FROM products;

UPDATE products SET price = 1600 WHERE id = 1;

SELECT * FROM products;


