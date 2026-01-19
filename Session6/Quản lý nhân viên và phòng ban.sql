-- Tạo bảng Phòng ban
CREATE TABLE Department (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Tạo bảng Nhân viên
CREATE TABLE Employee (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    department_id INT,
    salary NUMERIC(10,2),
    CONSTRAINT fk_department FOREIGN KEY(department_id) REFERENCES Department(id)
);

-- Thêm dữ liệu vào bảng Department
INSERT INTO Department (name) VALUES 
('Phòng Kỹ thuật'),
('Phòng Kinh doanh'),
('Phòng Nhân sự');

-- Thêm dữ liệu vào bảng Employee
INSERT INTO Employee (full_name, department_id, salary) VALUES 
('Nguyễn Văn A', 1, 15000000.00),
('Trần Thị B', 1, 18500000.50),
('Lê Văn C', 2, 12000000.00),
('Phạm Minh D', 3, 20000000.00);

--Liệt kê danh sách nhân viên cùng tên phòng ban của họ (INNER JOIN)
select d.name, e.full_name
from Department d join Employee e on d.id = e.department_id

--Tính lương trung bình của từng phòng ban, hiển thị:
--department_name
--avg_salary
--Gợi ý: dùng GROUP BY và bí danh cột
select d.name as department_name, avg(e.salary) as avg_salary
from Department d join Employee e on d.id = e.department_id
group by d.name

--Hiển thị các phòng ban có lương trung bình > 10 triệu (HAVING)
select d.name as department_name, avg(e.salary) as avg_salary
from Department d join Employee e on d.id = e.department_id
group by d.name
having avg(e.salary)>10000000

--Liệt kê phòng ban không có nhân viên nào (LEFT JOIN + WHERE employee.id IS NULL)
select d.name from Department d left join Employee e on d.id = e.department_id
where e.id is null