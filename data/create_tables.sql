USE [sqldb]

EXEC sys.sp_cdc_enable_db;

ALTER DATABASE [sqldb] SET CHANGE_TRACKING = ON (CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON);

DROP TABLE IF EXISTS customers;

CREATE TABLE customers(customer_id INT, name VARCHAR(300), email VARCHAR(300));

INSERT INTO customers (customer_id, name, email) VALUES
(1, 'Ivan Petrov', 'ivan.petrov@test.com'),
(2, 'Petar Hristov', 'petar.hristov@test.com'),
(3, 'Stoyan Videnov', 'stoyan.videnov@test.com'),
(4, 'Elena Petrova', 'elena.petrova@test.com');

DROP TABLE IF EXISTS orders;

CREATE TABLE orders(order_id INT, customer_id INT, item_number INT, item_name VARCHAR(300), item_quantity INT, item_unit_price DECIMAL);

INSERT INTO orders (order_id, customer_id, item_number, item_name, item_quantity, item_unit_price) VALUES
(1, 1, 1, 'Bike: Road-550-W Yellow', 1, 1000),
(1, 1, 2, 'LL Road Handlebars', 1, 20),
(1, 1, 3, 'LL Road Rear Wheel', 2, 50),
(2, 2, 1, 'Bike: Mountain-300 Black', 1, 1500),
(2, 2, 2, 'LL Headset', 1, 15),
(3, 4, 1, 'Bike: Road-650 Red', 1, 2000);

EXEC sys.sp_cdc_enable_table @source_schema = 'dbo', @source_name = 'customers', @role_name = NULL, @supports_net_changes = 0;

EXEC sys.sp_cdc_enable_table @source_schema = 'dbo', @source_name = 'orders', @role_name = NULL, @supports_net_changes = 0;
