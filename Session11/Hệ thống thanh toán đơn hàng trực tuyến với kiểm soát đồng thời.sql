CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    balance NUMERIC(12,2)
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    stock INT,
    price NUMERIC(10,2)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    total_amount NUMERIC(12,2),
    created_at TIMESTAMP DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'PENDING'
);

CREATE TABLE order_items (
    item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT,
    subtotal NUMERIC(10,2)
);

-- Khách hàng
INSERT INTO customers(name, balance)
VALUES ('Tran Thi B', 5000);

-- Sản phẩm
INSERT INTO products(name, stock, price) VALUES
('Product 1', 1, 1000),  
('Product 2', 10, 500),
('Product 3', 2, 800);    

BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

DO $$
DECLARE
    v_customer_id INT;
    v_balance NUMERIC;
    v_order_id INT;
    v_total NUMERIC := 0;
BEGIN
    -- 1. Khóa khách hàng
    SELECT customer_id, balance
    INTO v_customer_id, v_balance
    FROM customers
    WHERE name = 'Tran Thi B'
    FOR UPDATE;

    IF v_balance <= 0 THEN
        RAISE NOTICE 'Không đủ tiền';
        RETURN;
    END IF;

    -- 2. Tạo order
    INSERT INTO orders(customer_id, total_amount)
    VALUES (v_customer_id, 0)
    RETURNING order_id INTO v_order_id;

    BEGIN
        IF (SELECT stock FROM products WHERE product_id = 1 FOR UPDATE) < 1 THEN
            RAISE EXCEPTION 'Product 1 hết hàng';
        END IF;

        INSERT INTO order_items(order_id, product_id, quantity, subtotal)
        SELECT v_order_id, 1, 1, price FROM products WHERE product_id = 1;

        UPDATE products SET stock = stock - 1 WHERE product_id = 1;

        v_total := v_total + (SELECT price FROM products WHERE product_id = 1);

    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Bỏ qua product 1: %', SQLERRM;
    END;

    BEGIN
        IF (SELECT stock FROM products WHERE product_id = 3 FOR UPDATE) < 2 THEN
            RAISE EXCEPTION 'Product 3 không đủ hàng';
        END IF;

        INSERT INTO order_items(order_id, product_id, quantity, subtotal)
        SELECT v_order_id, 3, 2, price * 2 FROM products WHERE product_id = 3;

        UPDATE products SET stock = stock - 2 WHERE product_id = 3;

        v_total := v_total + (SELECT price * 2 FROM products WHERE product_id = 3);

    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Bỏ qua product 3: %', SQLERRM;
    END;

    IF v_total > 0 THEN
        UPDATE customers
        SET balance = balance - v_total
        WHERE customer_id = v_customer_id;

        UPDATE orders
        SET total_amount = v_total,
            status = 'COMPLETED'
        WHERE order_id = v_order_id;
    ELSE
        UPDATE orders
        SET status = 'CANCELLED'
        WHERE order_id = v_order_id;
    END IF;

END $$;

COMMIT;


ROLLBACK;
