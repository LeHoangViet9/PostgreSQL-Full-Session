CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100)
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT REFERENCES departments(dept_id),
    salary NUMERIC(10,2),
    hire_date DATE
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INT REFERENCES departments(dept_id)
);

-- Thêm phòng ban
INSERT INTO departments (dept_name) VALUES 
('IT'), ('HR'), ('Marketing'), ('Finance');

-- Thêm nhân viên
INSERT INTO employees (emp_name, dept_id, salary, hire_date) VALUES 
('Nguyen Van An', 1, 1500.00, '2023-01-10'),
('Tran Thi Binh', 1, 2000.00, '2022-05-15'),
('Le Van Cuong', 2, 1200.00, '2023-03-20'),
('Pham Minh Duc', 3, 1800.00, '2021-11-01'),
('Hoang Lan Anh', 4, 2500.00, '2020-08-12');

-- Thêm dự án
INSERT INTO projects (project_name, dept_id) VALUES 
('Cloud Migration', 1),
('Recruitment 2024', 2),
('SEO Optimization', 3),
('System Upgrade', 1);

--Hiển thị danh sách nhân viên gồm: Tên nhân viên, Phòng ban, Lương
--dùng bí danh bảng ngắn (employees as e,departments as d).
select e.emp_name, d.dept_name, d.dept_id, e.salary
from employees e join departments d on d.dept_id = e.dept_id

--Aggregate Functions:
--Tính:
--Tổng quỹ lương toàn công ty
--Mức lương trung bình
--Lương cao nhất, thấp nhất
--Số nhân viên

select sum(e.salary) as "Tổng quỹ lương",
avg(e.salary) as "Mức lương trung bình", 
max(e.salary) as "Mức lương cao nhất", 
min(e.salary) as "Mức lương thấp nhất",
count(e.emp_id) as "Số nhân viên"
from employees e 

--Tính mức lương trung bình của từng phòng ban
--chỉ hiển thị những phòng ban có lương trung bình > 15.000.000

select d.dept_id,d.dept_name, avg(e.salary) as "Mức lương trung bình"
from employees e join departments d on d.dept_id = e.dept_id
group by d.dept_id,d.dept_name
having avg(e.salary)>15000000

--Liệt kê danh sách dự án (project) cùng với phòng ban phụ trách và nhân viên thuộc phòng ban đó

select  p.project_name, e.emp_name, d.dept_name
from employees e join departments d on d.dept_id = e.dept_id
join projects p on p.dept_id = e.dept_id

--Tìm nhân viên có lương cao nhất trong mỗi phòng ban
--Gợi ý: Subquery lồng trong WHERE salary = (SELECT MAX(...))
select emp_id, emp_name from employees where salary =
(select max(salary) from employees)

--UNION: Liệt kê danh sách tất cả các phòng ban có nhân viên hoặc có dự án
--INTERSECT: Liệt kê các phòng ban vừa có nhân viên vừa có dự án

select d.dept_id, d.dept_name from departments d join employees e on d.dept_id=e.dept_id
union
select d.dept_id, d.dept_name from departments d join projects p on d.dept_id = p.dept_id

select d.dept_id, d.dept_name from departments d join employees e on d.dept_id=e.dept_id
intersect
select d.dept_id, d.dept_name from departments d join projects p on d.dept_id = p.dept_id

