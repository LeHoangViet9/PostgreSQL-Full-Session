create table customers(
	id serial primary key,
name varchar(100) not null,
email varchar(100) not null unique,
phone varchar(15) not null unique,
address varchar(100) not null
);
create table customers_log(
id serial primary key,
customer_id int ,
operation varchar(15),
old_data jsonb,
new_data jsonb,
changed_by text,
change_time timestamp default CURRENT_TIMESTAMP
);

create or replace function trg_customer_log()
returns trigger as $$
begin
     if tg_op='INSERT' then
	 insert into customers_log(customer_id,operation,old_data,new_data,changed_by)
	 values(new.id,'INSERT',null,to_jsonb(new),CURRENT_user);
	 return new;

	 elsif tg_op='UPDATE' then
	 insert into customers_log(customer_id,operation,old_data,new_data,changed_by)
	 values(new.id,'UPDATE',to_jsonb(old),to_jsonb(new),CURRENT_user);
	 return new;

	 elsif tg_op='DELETE' then
	 insert into customers_log(customer_id,operation,old_data,new_data,changed_by)
	 values(old.id,'DELETE',to_jsonb(old),null,CURRENT_user);
	 return old;
	 end if;
	 return null;
end ;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_customers
AFTER INSERT OR UPDATE OR DELETE
ON customers
FOR EACH ROW
EXECUTE FUNCTION trg_customer_log();


INSERT INTO customers(name, email, phone, address)
VALUES ('Nguyen Van A', 'a@gmail.com', '0123456789', 'Ha Noi');

UPDATE customers
SET phone = '0987654321'
WHERE id = 1;


DELETE FROM customers
WHERE id = 1;


select * from customers
select * from customers_log
