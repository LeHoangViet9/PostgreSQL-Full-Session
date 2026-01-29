CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    position VARCHAR(50)
);

-- Bảng log nhân viên
CREATE TABLE employee_log (
    log_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(50),
    action_time TIMESTAMP
);

create or replace function f_employee_log()
returns trigger
as $$
begin
	insert into employee_log(emp_name,action_time) values
	(new.name,CURRENT_TIMESTAMP);
end;
$$ LANGUAGE plpgsql;

create or replace trigger tr_employee_log
after update on employees
for each row
execute function f_employee_log()