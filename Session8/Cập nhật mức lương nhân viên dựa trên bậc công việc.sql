CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100),
    job_level INT,
    salary NUMERIC
);

INSERT INTO employees (emp_name, job_level, salary)
VALUES 
    ('Nguyễn Văn A', 1, 15000000),
    ('Trần Thị B', 2, 25000000),
    ('Lê Văn C', 3, 40000000);

create or replace procedure adjust_salary(
	p_emp_id int,
	out p_new_salary numeric
)
LANGUAGE plpgsql
as $$
begin
	update employees
	set salary =case 
				when job_level=1 then salary *1.05
				when job_level=2 then salary *1.1
				when job_level=3 then salary *1.15
				else salary
	end
	where emp_id=p_emp_id
	returning salary into p_new_salary;

	raise notice 'Nhân viên ID % đã được cập nhập lương mới %',p_emp_id,p_new_salary;
end; $$;

do $$
declare p_new_salary numeric;
begin
call adjust_salary(3,p_new_salary);
raise notice 'Lương mới là : %',p_new_salary;
end $$;