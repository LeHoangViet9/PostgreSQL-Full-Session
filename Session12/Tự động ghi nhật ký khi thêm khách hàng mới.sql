CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(50)
);

CREATE TABLE customer_log (
    log_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(50),
    action_time TIMESTAMP
);

create or replace function f_customer_lop()
returns trigger 
as $$
begin
	insert into customer_log(customer_name,action_time) values
	(new.name,CURRENT_TIMESTAMP);
	return new;
end ;
$$ LANGUAGE plpgsql

CREATE or replace TRIGGER trg_after_customer_insert
AFTER INSERT ON customers
FOR EACH ROW
EXECUTE FUNCTION f_customer_lop()

-- Thêm 3 bản ghi mới
INSERT INTO customers (name, email) 
VALUES 
('Phan Van D', 'd@gmail.com'),
('Hoang Thi E', 'e@gmail.com'),
('Ngo Van F', 'f@gmail.com');

select * from customers

select * from customer_log