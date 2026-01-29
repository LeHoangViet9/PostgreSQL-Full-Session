create table accounts(
account_id serial primary key,
account_name varchar(50),
balance numeric
);

INSERT INTO accounts (account_name, balance)
VALUES 
('Nguyen Van A', 1000.00),
('Tran Thi B', 500.00);

DO $$
DECLARE
    sender_id INT := 1;    -- ID người gửi (A)
    receiver_id INT := 2;  -- ID người nhận (B)
    amount NUMERIC := 200.00;
    current_balance NUMERIC;
BEGIN
    -- a. Kiểm tra số dư tài khoản gửi
    SELECT balance INTO current_balance FROM accounts WHERE account_id = sender_id;

    IF current_balance >= amount THEN
        -- b. Nếu đủ tiền: Trừ tiền người gửi, cộng tiền người nhận
        UPDATE accounts SET balance = balance - amount WHERE account_id = sender_id;
        UPDATE accounts SET balance = balance + amount WHERE account_id = receiver_id;
        
        RAISE NOTICE 'Giao dịch thành công!';
        -- Trong khối DO, các thay đổi sẽ tự động COMMIT nếu không có lỗi
    ELSE
        -- c. Nếu không đủ tiền: Báo lỗi để hệ thống tự động ROLLBACK
        RAISE EXCEPTION 'Giao dịch thất bại: Số dư tài khoản không đủ! (Hiện có: %)', current_balance;
    END IF;
END $$;