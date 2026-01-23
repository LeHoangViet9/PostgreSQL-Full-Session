CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    salary NUMERIC(10,2),
    bonus NUMERIC(10,2) DEFAULT 0
);

INSERT INTO employees (name, department, salary) VALUES
('Nguyen Van A', 'HR', 4000),
('Tran Thi B', 'IT', 6000),
('Le Van C', 'Finance', 10500),
('Pham Thi D', 'IT', 8000),
('Do Van E', 'HR', 12000);

create or replace procedure update_employee_status (
	p_emp_id int,
	p_status text
)
LANGUAGE plpgsql
as $$
declare v_status text; v_salary numeric;
begin
select salaru into v_salary from employees where id=p_emp_id;
	if not found
	then raise notice 'Employee not found';
	end if;

	if(v_salary<5000) then v_status ='Junior';
	elsif (v_salary between 5000 and 10000) then v_status ='Mid-level';
	else v_status='Senior';
	end if;

	update employees
	set status=v_status
	where id=p_emp_id;
	
	raise notice 'Employee % updated to status %',p_emp_id,v_status;
end ;
$$;



