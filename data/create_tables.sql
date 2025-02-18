USE [sqldb]

EXEC sys.sp_cdc_enable_db;

ALTER DATABASE [sqldb] SET CHANGE_TRACKING = ON (CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON);

DROP TABLE IF EXISTS customers;

CREATE TABLE customers(customer_id INT, name VARCHAR(300), email VARCHAR(300), created_at DATETIME2, valid_from DATETIME2, valid_to DATETIME2, is_current INT);

INSERT INTO customers (customer_id, name, email, created_at, valid_from, valid_to, is_current) VALUES
(1, 'Ivan Petrov', 'ivan.petrov@test.com', CONVERT(datetime2, '2025-02-10 08:30:43.143'), CONVERT(datetime2, '2025-02-10 08:30:43.143'), CONVERT(datetime2, '2999-12-31 23:59:59.999'), 1),
(2, 'Petar Hristov', 'petar.hristov@test.com', CONVERT(datetime2, '2025-02-11 09:30:43.143'), CONVERT(datetime2, '2025-02-11 09:30:43.143'), CONVERT(datetime2, '2999-12-31 23:59:59.999'), 1),
(3, 'Stoyan Videnov', 'stoyan.videnov@test.com', CONVERT(datetime2, '2025-02-11 10:45:43.143'), CONVERT(datetime2, '2025-02-11 10:45:43.143'), CONVERT(datetime2, '2999-12-31 23:59:59.999'), 1),
(4, 'Elena Petrova', 'elena.petrova@test.com', CONVERT(datetime2, '2025-02-15 12:30:43.143'), CONVERT(datetime2, '2025-02-15 12:30:43.143'), CONVERT(datetime2, '2999-12-31 23:59:59.999'), 1);

DROP TABLE IF EXISTS orders;

CREATE TABLE orders(order_id INT, customer_id INT, created_at DATETIME2, item_number INT, item_name VARCHAR(300), item_quantity INT, item_unit_price DECIMAL);

INSERT INTO orders (order_id, customer_id, created_at, item_number, item_name, item_quantity, item_unit_price) VALUES
(1, 1, CONVERT(datetime2, '2025-02-10 08:30:43.143'), 1, 'Bike: Road-550-W Yellow', 1, 1000),
(1, 1, CONVERT(datetime2, '2025-02-10 08:30:43.143'), 2, 'LL Road Handlebars', 1, 20),
(1, 1, CONVERT(datetime2, '2025-02-10 08:30:43.143'), 3, 'LL Road Rear Wheel', 2, 50),
(2, 2, CONVERT(datetime2, '2025-02-11 09:30:43.143'), 1, 'Bike: Mountain-300 Black', 1, 1500),
(2, 2, CONVERT(datetime2, '2025-02-11 09:30:43.143'), 2, 'LL Headset', 1, 15),
(3, 4, CONVERT(datetime2, '2025-02-11 10:45:43.143'), 1, 'Bike: Road-650 Red', 1, 2000);

EXEC sys.sp_cdc_enable_table @source_schema = 'dbo', @source_name = 'customers', @role_name = NULL, @supports_net_changes = 0;

EXEC sys.sp_cdc_enable_table @source_schema = 'dbo', @source_name = 'orders', @role_name = NULL, @supports_net_changes = 0;
