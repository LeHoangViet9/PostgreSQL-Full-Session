-- Tạo bảng Sinh viên
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    major VARCHAR(50)
);

-- Tạo bảng Khóa học
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100),
    credit INT
);

-- Tạo bảng Đăng ký (Bảng trung gian)
CREATE TABLE enrollments (
    student_id INT REFERENCES students(student_id),
    course_id INT REFERENCES courses(course_id),
    score NUMERIC(5,2)
);

-- Thêm dữ liệu cho bảng students
INSERT INTO students (full_name, major) VALUES 
('Nguyen Van A', 'Computer Science'),
('Le Thi B', 'Data Science'),
('Tran Van C', 'Information Technology');

-- Thêm dữ liệu cho bảng courses
INSERT INTO courses (course_name, credit) VALUES 
('Database Systems', 3),
('Mathematics for CS', 4),
('Web Development', 3);

-- Thêm dữ liệu cho bảng enrollments (Kết nối sinh viên với khóa học)
INSERT INTO enrollments (student_id, course_id, score) VALUES 
(1, 1, 85.50),
(1, 2, 90.00),
(2, 1, 78.25),
(3, 3, 88.00);

--Liệt kê danh sách sinh viên cùng tên môn học và điểm
--dùng bí danh bảng ngắn (vd. s, c, e)
--và bí danh cột như Tên sinh viên, Môn học, Điểm
select s.full_name as "Tên sinh viên", c.course_name as "Môn học", e.score as "Điểm"
from students s join enrollments e on s.student_id = e.student_id
join courses c on c.course_id = e.course_id;

--Aggregate Functions:
--Tính cho từng sinh viên:
--Điểm trung bình
--Điểm cao nhất
--Điểm thấp nhất

select s.full_name as "Tên sinh viên", avg(score) as "Điểm trung bình", max(score) as "Điểm cao nhất", min(score) as "Điểm thấp nhất"
from students s join enrollments e on s.student_id = e.student_id
group by s.full_name

--Tìm ngành học (major) có điểm trung bình cao hơn 7.5
select s.major as "Ngành học", avg(e.score) as "Điểm trung bình"
from students s join enrollments e on s.student_id = e.student_id
group by s.major
having avg(e.score)>7.5

--Liệt kê tất cả sinh viên, môn học, số tín chỉ và điểm (JOIN 3 bảng)
select s.student_id as "Mã", s.full_name as "Tên sinh viên", c.course_name as "Môn học",c.credit as "Số tín chỉ", e.score as "Điểm"
from students s join enrollments e on s.student_id = e.student_id
join courses c on c.course_id = e.course_id

--Tìm sinh viên có điểm trung bình cao hơn điểm trung bình toàn trường
select s.full_name, avg(e.score) as "Điểm trung bình" from students s join enrollments e on s.student_id = e.student_id
group by s.full_name
having avg(score)>
(select  avg(e.score) as"Điểm trung bình"
from enrollments e )

--UNION: Danh sách sinh viên có điểm >= 9
-- hoặc đã học ít nhất một môn
select s.full_name from students s join enrollments e on e.student_id = s.student_id
where e.score >9
union 
select s.full_name from  students s join enrollments e on e.student_id = s.student_id
--INTERSECT: Danh sách sinh viên thỏa cả hai điều kiện trên
select s.full_name from students s join enrollments e on e.student_id = s.student_id where e.score >9
intersect 
select s.full_name from  students s join enrollments e on e.student_id = s.student_id
