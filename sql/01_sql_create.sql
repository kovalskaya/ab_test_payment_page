CREATE DATABASE ab_test_db;
USE ab_test_db;

create table users (
user_id INT PRIMARY KEY AUTO_INCREMENT,
registration_date DATE,
country VARCHAR (10),
device VARCHAR (10),
experiment_group VARCHAR(1)
);

create table sessions (
session_id INT PRIMARY KEY AUTO_INCREMENT,
user_id INT,
session_date DATE,
page_type VARCHAR (20),
foreign key (user_id) references users (user_id)
);

create table payments (
payment_id INT PRIMARY KEY AUTO_INCREMENT,
user_id INT,
payment_date DATE,
amount DECIMAL(10,2),
is_refund TINYINT,
foreign key (user_id) references users (user_id)
);

	
