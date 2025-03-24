USE [pocdb]

EXEC sys.sp_cdc_enable_db;

ALTER DATABASE [pocdb] SET CHANGE_TRACKING = ON (CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON);

CREATE SCHEMA poc;

DROP TABLE IF EXISTS poc.customers;

CREATE TABLE poc.customers(customer_id INT PRIMARY KEY, name VARCHAR(300), email VARCHAR(300), country VARCHAR(10), created_at DATETIME2);

INSERT INTO poc.customers (customer_id, name, email, country, created_at) VALUES
(1, 'Ivan Petrov', 'ivan.petrov@test.com', 'BG', CONVERT(datetime2, '2025-02-10 08:30:43.143')),
(2, 'Petar Hristov', 'petar.hristov@test.com', 'AT', CONVERT(datetime2, '2025-02-11 09:30:43.143')),
(3, 'Stoyan Videnov', 'stoyan.videnov@test.com', 'DE', CONVERT(datetime2, '2025-02-11 10:45:43.143')),
(4, 'Elena Petrova', 'elena.petrova@test.com', 'FR', CONVERT(datetime2, '2025-02-15 12:30:43.143'));

DROP TABLE IF EXISTS poc.orders;

CREATE TABLE poc.orders(order_id INT, customer_id INT, created_at DATETIME2, country VARCHAR(10), item_number INT, item_name VARCHAR(300), item_quantity INT, item_unit_price DECIMAL);

INSERT INTO poc.orders (order_id, customer_id, created_at, country, item_number, item_name, item_quantity, item_unit_price) VALUES
(1, 1, CONVERT(datetime2, '2025-02-10 08:30:43.143'), 'BG', 1, 'Bike: Road-550-W Yellow', 1, 1000.00),
(1, 1, CONVERT(datetime2, '2025-02-10 08:30:43.143'), 'BG', 2, 'LL Road Handlebars', 1, 20.47),
(1, 1, CONVERT(datetime2, '2025-02-10 08:30:43.143'), 'BG', 3, 'LL Road Rear Wheel', 2, 50.35),
(2, 2, CONVERT(datetime2, '2025-02-11 09:30:43.143'), 'AT', 1, 'Bike: Mountain-300 Black', 1, 1500.00),
(2, 2, CONVERT(datetime2, '2025-02-11 09:30:43.143'), 'AT', 2, 'LL Headset', 1, 15.25),
(3, 4, CONVERT(datetime2, '2025-02-11 10:45:43.143'), 'FR', 1, 'Bike: Road-650 Red', 1, 2000.00);

EXEC sys.sp_cdc_enable_table @source_schema = 'poc', @source_name = 'customers', @role_name = NULL, @supports_net_changes = 0;

EXEC sys.sp_cdc_enable_table @source_schema = 'poc', @source_name = 'orders', @role_name = NULL, @supports_net_changes = 0;



-- Sales schema with VARCHAR PKs

CREATE SCHEMA sales;

DROP TABLE IF EXISTS sales.customers;

CREATE TABLE sales.customers(customer_id VARCHAR(30) PRIMARY KEY, name VARCHAR(300), email VARCHAR(300), country VARCHAR(10), created_at DATETIME2);

INSERT INTO sales.customers (customer_id, name, email, country, created_at) VALUES
('C00001', 'Ivan Petrov', 'ivan.petrov@test.com', 'BG', CONVERT(datetime2, '2025-02-10 08:30:43.143')),
('C00002', 'Petar Hristov', 'petar.hristov@test.com', 'AT', CONVERT(datetime2, '2025-02-11 09:30:43.143')),
('C00003', 'Stoyan Videnov', 'stoyan.videnov@test.com', 'DE', CONVERT(datetime2, '2025-02-11 10:45:43.143')),
('C00004', 'Elena Petrova', 'elena.petrova@test.com', 'FR', CONVERT(datetime2, '2025-02-15 12:30:43.143'));

DROP TABLE IF EXISTS sales.orders;

CREATE TABLE sales.orders(order_id VARCHAR(30) NOT NULL, customer_id INT, created_at DATETIME2, country VARCHAR(10), item_number VARCHAR(3) NOT NULL, item_name VARCHAR(300), item_quantity INT, item_unit_price DECIMAL);

ALTER TABLE sales.orders ADD PRIMARY KEY (order_id, item_number);

INSERT INTO sales.orders (order_id, customer_id, created_at, country, item_number, item_name, item_quantity, item_unit_price) VALUES
('O00001', 1, CONVERT(datetime2, '2025-02-10 08:30:43.143'), 'BG', 'I01', 'Bike: Road-550-W Yellow', 1, 1000.00),
('O00001', 1, CONVERT(datetime2, '2025-02-10 08:30:43.143'), 'BG', 'I02', 'LL Road Handlebars', 1, 20.47),
('O00001', 1, CONVERT(datetime2, '2025-02-10 08:30:43.143'), 'BG', 'I03', 'LL Road Rear Wheel', 2, 50.35),
('O00002', 2, CONVERT(datetime2, '2025-02-11 09:30:43.143'), 'AT', 'I01', 'Bike: Mountain-300 Black', 1, 1500.00),
('O00002', 2, CONVERT(datetime2, '2025-02-11 09:30:43.143'), 'AT', 'I02', 'LL Headset', 1, 15.25),
('O00003', 4, CONVERT(datetime2, '2025-02-11 10:45:43.143'), 'FR', 'I01', 'Bike: Road-650 Red', 1, 2000.00);

EXEC sys.sp_cdc_enable_table @source_schema = 'sales', @source_name = 'customers', @role_name = NULL, @supports_net_changes = 0;

EXEC sys.sp_cdc_enable_table @source_schema = 'sales', @source_name = 'orders', @role_name = NULL, @supports_net_changes = 0;
