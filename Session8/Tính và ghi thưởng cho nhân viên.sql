create or replace procedure calculate_bonus(
	p_emp_id int,
	p_percent numeric,
	out p_bonus numeric
)
LANGUAGE plpgsql
as $$
declare v_salary numeric;
begin 
	select salary into v_salary from employees where id=p_emp_id;
	--Nếu nhân viên không tồn tại → ném lỗi "Employee not found"
	if not found then raise notice 'Employee not found';
	end if;
	--Nếu p_percent <= 0 → không tính, p_bonus = 0
	if (p_percent <=0) then p_bonus=0;
	else  
	--Tính thưởng = salary * p_percent / 100 và lưu vào cột bonus trong bảng employees
	p_bonus=v_salary*p_percent/100;
	end if;
	update employees  
	set bonus=p_bonus
	where id=p_emp_id;

	raise notice 'Tiền thưởng của % phần trăm là :%',p_percent,p_bonus;
end;
$$;

