Create database LibraryDB_Session3_QuanLiBanHang;
Create schema sales;

Create table sales.Products(
	product_id serial primary key,
	product_name varchar(100) not null,
	price numeric(10,2),
	stock_quantity integer
);
CREATE TABLE sales.Members (
    member_id SERIAL PRIMARY KEY,
    member_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);
Create table sales.Orders(
	order_id serial primary key,
	order_date date default current_date,
	member_id int REFERENCES sales.Members(member_id)
);
CREATE TABLE sales.OrderDetails (
    order_detail_id SERIAL PRIMARY KEY,
    quantity INTEGER NOT NULL,
    product_id int  REFERENCES sales.Products(product_id),
	order_id int REFERENCES sales.Orders(order_id)
);