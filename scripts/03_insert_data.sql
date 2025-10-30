-- INSERT DATA

USE ecommerce_analytics;

-- =============================================
-- INSERT DATA
-- Run after creating tables
-- =============================================

USE ecommerce_analytics;

-- Insert Customers
INSERT INTO customers VALUES
(1, 'Rahul Sharma', 'rahul.sharma@email.com', '9876543210', 'Mumbai', 'Maharashtra', 'India', '2023-01-15', 'Premium'),
(2, 'Priya Patel', 'priya.patel@email.com', '9876543211', 'Ahmedabad', 'Gujarat', 'India', '2023-02-20', 'Regular'),
-- ... ALL 15 CUSTOMERS
(15, 'Sanjay Pillai', 'sanjay.pillai@email.com', '9876543224', 'Thiruvananthapuram', 'Kerala', 'India', '2024-03-20', 'Regular');

-- Insert Products
INSERT INTO products VALUES
(101, 'iPhone 15 Pro', 'Electronics', 'Smartphones', 'Apple', 129900.00, 95000.00, 50),
-- ... ALL 15 PRODUCTS
(115, 'PlayStation 5', 'Electronics', 'Gaming', 'Sony', 49990.00, 38000.00, 25);

-- Insert Orders (ALL 20)
INSERT INTO orders VALUES
(1001, 1, '2024-01-15', '2024-01-17', 'Express', 'Delivered'),
-- ...
(1020, 7, '2024-10-10', '2024-10-14', 'Standard', 'Delivered');

-- Insert Order Items (ALL 24)
INSERT INTO order_items VALUES
(1, 1001, 101, 1, 0.00, 34900.00),
-- ...
(24, 1020, 112, 1, 5.00, 2399.05);

-- Insert Reviews (ALL 15)
INSERT INTO reviews VALUES
(1, 101, 1, 5, 'Amazing phone! Camera quality is outstanding.', '2024-01-20'),
-- ...
(15, 105, 10, 4, 'Powerful laptop for work and gaming.', '2024-06-10');

SELECT 'Data inserted successfully!' AS status;