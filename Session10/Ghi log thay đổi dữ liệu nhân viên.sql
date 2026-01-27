create table employees(
	id serial primary key,
	name varchar(100) not null,
	position varchar(50) not null,
	salary numeric(12,2) check (salary>=0)
);
create table employees_log(
	id serial primary key,
	employee_id int,
	operation varchar(20),
	old_data jsonb,
	new_data jsonb,
	change_time timestamp default CURRENT_TIMESTAMP
);

create or replace function log_employees()
returns trigger
as $$
begin
	if tg_op ='INSERT' then 
	Insert into employees_log(employee_id,operation,old_data,new_data)
	values (new.id,'INSERT',null,to_jsonb(new));
	return new;
	elsif tg_op='UPDATE' then 
	Insert into employees_log(employee_id,operation,old_data,new_data)
	values (old.id,'UPDATE',to_jsonb(old),to_jsonb(new));
	return new;
	elsif tg_op='DELETE' then
	Insert into employees_log(employee_id,operation,old_data,new_data)
	values (old.id,'DELETE',to_jsonb(old),null);
	return old;
	end if;
	return null;
end ;
$$ language plpgsql ;

create or replace trigger trg_employees_logs
after insert or delete or update on employees 
for each row 
execute function log_employees();


INSERT INTO employees(name, position, salary)
VALUES ('Nguyen Van A', 'Developer', 1500);

UPDATE employees
SET salary = 2000
WHERE id = 2;

DELETE FROM employees
WHERE id = 1;

select * from employees
select * from employees_log
