CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    credit_limit NUMERIC(12,2) CHECK (credit_limit >= 0)
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    order_amount NUMERIC(12,2) CHECK (order_amount > 0)
);


create or replace function check_credit_limit()
returns trigger as $$
declare 
	total_order_amount NUMERIC(12,2);
begin
	select coalesce(Sum(o.order_amount),0)
	into total_order_amount 
	from orders o
	where o.customer_id=new.customer_id;
	if(total_order_amount+new.order_amount)>(
	select credit_limit from customers where id=new.customer_id
	)
	then raise exception 'Tài khoản không đủ để thanh toán';
	end if;
	return new;
end ;
$$ language plpgsql;

create or replace trigger trg_check_credit  
before insert on orders 
for each row
execute function check_credit_limit()

select * from customers
select * from orders
INSERT INTO customers(name, credit_limit)
VALUES ('Le Hoang Viet', 5000);
-- đơn hợp lệ
INSERT INTO orders(customer_id, order_amount)
VALUES (1, 2000);

-- đơn hợp lệ
INSERT INTO orders(customer_id, order_amount)
VALUES (1, 2500);

-- đơn này sẽ FAIL
INSERT INTO orders(customer_id, order_amount)
VALUES (1, 1000);

