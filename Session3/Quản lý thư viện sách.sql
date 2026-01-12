Create database LibrarySession3;
Create schema library;
Create table library.Books(
	book_id serial primary key,
	title varchar(100),
	author varchar(100),
	published_year integer,
	available boolean default (true)
);
Create table library.Members(
	member_id serial primary key,
	name varchar(100),
	email varchar(50) unique,
	join_date date default CURRENT_DATE

);