Create table Employee(
id serial primary key ,
full_name varchar(100),
department varchar(50),
salary numeric(10,2),
hire_date date
);
insert into Employee (full_name, department, salary, hire_date)
values 
('Nguyen Van An', 'HR', 1200.00, '2022-03-15'),
('Tran Thi Bich', 'Accounting', 1500.00, '2021-07-01'),
('Le Hoang Viet', 'IT', 2000.00, '2023-01-10'),
('Pham Minh Quan', 'Sales', 1800.00, '2020-11-20'),
('Tran Trinh Ngoc Ha', 'Marketing', 1700.00, '2022-06-05'),
('Do Anh Tuan', 'IT', 2200.00, '2019-09-18');

--Cập nhật mức lương tăng 10% cho nhân viên thuộc phòng IT
update Employee set salary=salary*1.1 where department ilike 'IT';

--Xóa nhân viên có mức lương dưới 6,000,000
delete from Employee where salary <6000000

--Liệt kê các nhân viên có tên chứa chữ “An” (không phân biệt hoa thường)
select * from Employee where full_name ilike '%An%'

--Hiển thị các nhân viên có ngày vào làm việc trong khoảng từ '2023-01-01' đến '2023-12-31'
select * from Employee where hire_date between '2023-01-01' and '2023-12-31'



--
