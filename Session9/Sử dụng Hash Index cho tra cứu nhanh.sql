--Tạo Hash Index trên cột email
create or replace index idx_Users_email on Users using Hash(email);
--Viết truy vấn SELECT * FROM Users WHERE email = 'example@example.com'; và kiểm tra kế hoạch thực hiện bằng EXPLAIN
Explain ANALYZE 
SELECT * FROM Users WHERE email = 'example@example.com'; 


--Chưa có index	Seq Scan	~85 ms
--Có index	Index Scan	~1 ms