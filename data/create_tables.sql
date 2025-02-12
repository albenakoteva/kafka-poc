USE [db-kafka-poc]

EXEC sys.sp_cdc_enable_db;
ALTER DATABASE [db-kafka-poc] SET CHANGE_TRACKING = ON (CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON);

DROP TABLE IF EXISTS customer;

CREATE TABLE customer(id INT IDENTITY(1, 1) PRIMARY KEY, name VARCHAR(300), email VARCHAR(300));

INSERT INTO customer (name, email) VALUES
('Ivan Petrov', 'ivan.petrov@test.com'),
('Petar Hristov', 'petar.hristov@test.com'),
('Stoyan Videnov', 'stoyan.videnov@test.com'),
('Elena Petrovq', 'elena.petrova@test.com');

DROP TABLE IF EXISTS customer_relatives;

CREATE TABLE customer_relatives(customer_id1 INT, customer_id2 INT, relationship VARCHAR(300));

INSERT INTO customer_relatives (customer_id1, customer_id2, relationship) VALUES
(1, 2, 'Father'),
(1, 4, 'Husband'),
(4, 1, 'Spouse'),
(2, 1, 'Son'),
(2, 4, 'Son'),
(3, 2, 'Son'),
(3, 1, 'Grand Son'),
(2, 3, 'Father'),
(1, 3, 'Grand Father');