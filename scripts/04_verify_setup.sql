USE ecommerce_analytics;

-- Count records
SELECT 
    'customers' AS table_name, COUNT(*) AS record_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews;

-- Sample data preview
SELECT '=== Sample Customers ===' AS info;
SELECT * FROM customers LIMIT 3;

SELECT '=== Sample Orders ===' AS info;
SELECT * FROM orders LIMIT 3;

SELECT 'Setup verification complete!' AS status;