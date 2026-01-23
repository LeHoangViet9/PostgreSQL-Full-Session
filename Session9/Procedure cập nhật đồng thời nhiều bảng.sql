--Tạo Procedure add_order_and_update_customer(p_customer_id INT, p_amount NUMERIC) để:
--Thêm đơn hàng mới vào bảng Orders
--Cập nhật total_spent trong bảng Customers

create table Customers(
	customer_id serial primary key,
	name varchar(100) not null,
	total_spent numeric
);
create table Orders(
	order_id serial primary key,
	customer_id int references Customers(customer_id),
	total_amount numeric
);

INSERT INTO Customers (name, total_spent) VALUES
('Nguyen Van A', 0),
('Tran Thi B', 0),
('Le Van C', 0),
('Pham Thi D', 0);

INSERT INTO Orders (customer_id, total_amount) VALUES
(1, 150000),
(1, 200000),
(2, 300000),
(3, 120000),
(3, 500000);

create or replace procedure  add_order_and_update_customer(
p_customer_id int,
p_amount numeric
)
LANGUAGE plpgsql
as $$
begin
 IF NOT EXISTS (
        SELECT 1 FROM Customers WHERE customer_id = p_customer_id
    ) THEN
        RAISE EXCEPTION 'Customer id % does not exist', p_customer_id;
    END IF;
	insert into Orders(customer_id,total_amount)
	values (p_customer_id,p_amount);

	update Customers set total_spent=total_spent+p_amount where customer_id=p_customer_id;
	
end
$$;

--Sử dụng biến và xử lý điều kiện để đảm bảo khách hàng tồn tại
CREATE OR REPLACE PROCEDURE add_order_and_update_customer(
    p_customer_id INT,
    p_amount NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_customer_count INT;
BEGIN
    -- Đếm số khách hàng có customer_id tương ứng
    SELECT COUNT(*)
    INTO v_customer_count
    FROM Customers
    WHERE customer_id = p_customer_id;

    -- Nếu không tồn tại
    IF not found THEN
        RAISE EXCEPTION 'Customer id % does not exist', p_customer_id;
    END IF;

    -- Thêm đơn hàng
    INSERT INTO Orders(customer_id, total_amount)
    VALUES (p_customer_id, p_amount);

    -- Cập nhật tổng chi tiêu
    UPDATE Customers
    SET total_spent = COALESCE(total_spent, 0) + p_amount
    WHERE customer_id = p_customer_id;

	--Sử dụng EXCEPTION để báo lỗi nếu thêm đơn hàng thất bại
	exception 
	when others then raise exception 'Đơn hàng % thêm thất bại',p_customer_id;
END;
$$;

call add_order_and_update_customer(1,200000);


