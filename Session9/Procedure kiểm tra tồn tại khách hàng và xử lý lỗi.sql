create table Customers(
	customer_id serial primary key,
	name varchar(100) not null,
	email varchar(100) not null unique
);
create table Orders(
	order_id serial primary key,
	customer_id int not null,
	amount numeric ,
	order_date date
);
INSERT INTO Customers (name, email) VALUES
('Nguyen Van A', 'a@gmail.com'),
('Tran Thi B', 'b@gmail.com'),
('Le Van C', 'c@gmail.com'),
('Pham Thi D', 'd@gmail.com');

INSERT INTO Orders (customer_id, amount, order_date) VALUES
(1, 150000, '2025-01-01'),
(1, 200000, '2025-01-05'),
(2, 300000, '2025-01-03'),
(3, 120000, '2025-01-10'),
(3, 500000, '2025-01-15');

--
--Tạo Procedure add_order(p_customer_id INT, p_amount NUMERIC) để thêm đơn hàng
create or replace procedure add_order(
	p_customer_id int ,
	p_amount numeric
)
LANGUAGE plpgsql
as $$
begin 
	insert into Orders( customer_id, amount ,order_date)
	values (p_customer_id,p_amount,CURRENT_DATE);
end;
$$;

--Kiểm tra nếu customer_id không tồn tại trong bảng Customers, sử dụng RAISE EXCEPTION để báo lỗi
create or replace procedure check_customer(
	p_customer_id int
)
language plpgsql
as $$
begin 
	if not exists (select 1 from Customers where customer_id=p_customer_id) then raise notice 'Customer id is not exists';
	end if;
end ;
$$;

--Nếu khách hàng tồn tại, thêm bản ghi mới vào bảng Orders

create or replace procedure check_customer2(
	p_customer_id int,
	p_amount numeric,
	order_date date
)
language plpgsql
as $$
begin 
	if not exists (select 1 from Customers where customer_id=p_customer_id) then raise notice 'Customer id is not exists';
	end if;
		insert into Orders(customer_id,amount,order_date)
		values (p_customer_id, p_amount,CURRENT_DATE);
	
end ;
$$;