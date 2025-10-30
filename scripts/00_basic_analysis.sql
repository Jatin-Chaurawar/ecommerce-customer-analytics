-- BASIC SQL ANALYSIS

USE ecommerce_analytics;

-- SECTION 1: BASIC AGGREGATIONS

-- Query 1.1: Count Total Records in Each Table
-- Question: "How many customers do we have?"

SELECT 'Total Customers' AS metric, COUNT(*) AS count FROM customers
UNION ALL
SELECT 'Total Products', COUNT(*) FROM products
UNION ALL
SELECT 'Total Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Total Order Items', COUNT(*) FROM order_items
UNION ALL
SELECT 'Total Reviews', COUNT(*) FROM reviews;

-- Query 1.2: Calculate Average, Min, Max Prices
-- Question: "What's the price range of our products?"

SELECT 
    ROUND(AVG(price), 2) AS average_price,
    ROUND(MIN(price), 2) AS minimum_price,
    ROUND(MAX(price), 2) AS maximum_price,
    ROUND(AVG(cost), 2) AS average_cost,
    ROUND(MAX(price) - MIN(price), 2) AS price_range
FROM products;

-- Query 1.3: Average Rating Across All Products
-- Question: "What's our overall customer satisfaction?"

SELECT 
    ROUND(AVG(rating), 2) AS average_rating,
    MIN(rating) AS lowest_rating,
    MAX(rating) AS highest_rating,
    COUNT(*) AS total_reviews
FROM reviews;

-- Query 1.4: Count Reviews by Rating (Distribution)
-- Question: "How many 5-star vs 1-star reviews?"

SELECT 
    rating,
    COUNT(*) AS review_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM reviews), 2) AS percentage
FROM reviews
GROUP BY rating
ORDER BY rating DESC;

-- SECTION 2: BASIC FILTERING & SORTING

-- Query 2.1: Top 5 Most Expensive Products
-- Question: "Show me our premium products"

SELECT 
    product_id,
    product_name,
    category,
    brand,
    price AS selling_price
FROM products
ORDER BY price DESC
LIMIT 5;


-- Query 2.2: Cheapest Products (Budget Items)

SELECT 
    product_id,
    product_name,
    category,
    price
FROM products
ORDER BY price ASC
LIMIT 5;

-- Query 2.3: Products with High Stock (Inventory Check)
-- Question: "Which products do we have most of?"

SELECT 
    product_name,
    category,
    stock_quantity
FROM products
WHERE stock_quantity > 100
ORDER BY stock_quantity DESC;

-- Query 2.4: Products with Low Stock (Reorder Alert)
-- Question: "Which products need restocking?"

SELECT 
    product_name,
    category,
    stock_quantity,
    'LOW STOCK - REORDER!' AS alert
FROM products
WHERE stock_quantity < 50
ORDER BY stock_quantity ASC;

-- SECTION 3: BASIC GROUP BY ANALYSIS

-- Query 3.1: Count Products by Category
-- Question: "How many products in each category?"

SELECT 
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(stock_quantity), 0) AS avg_stock
FROM products
GROUP BY category
ORDER BY product_count DESC;

-- Query 3.2: Count Customers by City
-- Question: "Where are most customers from?"

SELECT 
    city,
    state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY city, state
ORDER BY customer_count DESC;

-- Query 3.3: Count Customers by Segment
-- Question: "How many VIP vs Regular customers?"

SELECT 
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2) AS percentage
FROM customers
GROUP BY customer_segment
ORDER BY customer_count DESC;

-- Query 3.4: Orders by Shipping Mode
-- Question: "Do customers prefer Express or Standard?"

SELECT 
    ship_mode,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY ship_mode
ORDER BY order_count DESC;

-- SECTION 4: BASIC JOINS (2 TABLES)

-- Query 4.1: Customer Names with Their Cities
-- Question: "Show me customer contact details"

SELECT 
    customer_name,
    email,
    phone,
    city,
    state,
    customer_segment
FROM customers
ORDER BY customer_name;

-- Query 4.2: Products with Reviews (Simple JOIN)
-- Question: "Which products have been reviewed?"


SELECT 
    p.product_name,
    p.category,
    r.rating,
    r.review_text,
    r.review_date
FROM products p
INNER JOIN reviews r ON p.product_id = r.product_id
ORDER BY r.rating DESC, r.review_date DESC;

-- Query 4.3: Customer Orders (Who ordered what?)

SELECT 
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date,
    o.ship_mode
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_date DESC;

-- Query 4.4: Products Never Reviewed (LEFT JOIN)
-- Question: "Which products have no reviews?"

SELECT 
    p.product_name,
    p.category,
    p.price,
    r.review_id
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
WHERE r.review_id IS NULL;

-- SECTION 5: BASIC CALCULATIONS

-- Query 5.1: Calculate Profit Margin for Each Product
-- Question: "Which products are most profitable?"

SELECT 
    product_name,
    price AS selling_price,
    cost AS cost_price,
    (price - cost) AS gross_profit,
    ROUND((price - cost) / price * 100, 2) AS profit_margin_percentage
FROM products
ORDER BY profit_margin_percentage DESC;

-- Query 5.2: Total Revenue from Each Order (3-Table JOIN)
-- Question: "How much did each order generate?"

SELECT 
    o.order_id,
    o.order_date,
    COUNT(oi.order_item_id) AS items_in_order,
    SUM(oi.quantity) AS total_units,
    ROUND(SUM(p.price * oi.quantity), 2) AS revenue_before_discount,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS revenue_after_discount,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id, o.order_date
ORDER BY revenue_after_discount DESC;

-- Query 5.3: Average Discount Given Per Order

SELECT 
    o.order_id,
    ROUND(AVG(oi.discount), 2) AS avg_discount_percentage,
    MAX(oi.discount) AS max_discount_in_order
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id
HAVING AVG(oi.discount) > 0
ORDER BY avg_discount_percentage DESC;

-- SECTION 6: DATE-BASED ANALYSIS

-- Query 6.1: Orders by Month
-- Question: "How many orders per month?"

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    DATE_FORMAT(order_date, '%M %Y') AS month_name,
    COUNT(*) AS order_count
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m'), DATE_FORMAT(order_date, '%M %Y')
ORDER BY month;

-- Query 6.2: Shipping Time Analysis (Days to Ship)
-- Question: "How fast do we ship orders?"

SELECT 
    order_id,
    order_date,
    ship_date,
    DATEDIFF(ship_date, order_date) AS days_to_ship,
    ship_mode,
    CASE 
        WHEN DATEDIFF(ship_date, order_date) <= 2 THEN 'Fast'
        WHEN DATEDIFF(ship_date, order_date) <= 4 THEN 'Normal'
        ELSE 'Slow'
    END AS shipping_speed
FROM orders
WHERE ship_date IS NOT NULL
ORDER BY days_to_ship ASC;

-- Query 6.3: How Long Have Customers Been with Us?

SELECT 
    customer_name,
    registration_date,
    DATEDIFF(CURDATE(), registration_date) AS days_as_customer,
    ROUND(DATEDIFF(CURDATE(), registration_date) / 30, 1) AS months_as_customer
FROM customers
ORDER BY days_as_customer DESC;

-- SECTION 7: BASIC SUBQUERIES

-- Query 7.1: Products Above Average Price
-- Question: "Show premium products (above avg price)"

SELECT 
    product_name,
    category,
    price,
    (SELECT ROUND(AVG(price), 2) FROM products) AS avg_price,
    ROUND(price - (SELECT AVG(price) FROM products), 2) AS price_difference
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- Query 7.2: Customers Who Ordered More Than Average

SELECT 
    c.customer_name,
    COUNT(o.order_id) AS order_count,
    (SELECT ROUND(AVG(order_cnt), 2) 
     FROM (SELECT customer_id, COUNT(*) AS order_cnt FROM orders GROUP BY customer_id) AS avg_orders) AS avg_orders_per_customer
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > (SELECT AVG(order_cnt) 
                             FROM (SELECT customer_id, COUNT(*) AS order_cnt FROM orders GROUP BY customer_id) AS sub)
ORDER BY order_count DESC;

-- Query 7.3: Products with Highest Ratings
-- (Equal to max rating)

SELECT 
    p.product_name,
    p.category,
    r.rating
FROM products p
JOIN reviews r ON p.product_id = r.product_id
WHERE r.rating = (SELECT MAX(rating) FROM reviews)
ORDER BY p.product_name;

-- SECTION 8: BASIC STRING OPERATIONS

-- Query 8.1: Customer Emails - Domain Analysis
-- Question: "Which email providers do customers use?"

SELECT 
    SUBSTRING_INDEX(email, '@', -1) AS email_domain,
    COUNT(*) AS customer_count
FROM customers
GROUP BY email_domain
ORDER BY customer_count DESC;

-- Query 8.2: Product Name Length Analysis
-- (Just for practice!)

SELECT 
    product_name,
    LENGTH(product_name) AS name_length,
    CASE 
        WHEN LENGTH(product_name) < 15 THEN 'Short'
        WHEN LENGTH(product_name) < 25 THEN 'Medium'
        ELSE 'Long'
    END AS name_type
FROM products
ORDER BY name_length DESC;

-- Query 8.3: Extract Brand from Product Name (If applicable)

SELECT 
    product_name,
    brand,
    UPPER(brand) AS brand_uppercase,
    LOWER(brand) AS brand_lowercase
FROM products;

-- SECTION 9: BASIC CASE STATEMENTS

-- Query 9.1: Categorize Products by Price
-- Question: "Classify products as Budget/Mid/Premium"

SELECT 
    product_name,
    price,
    CASE 
        WHEN price < 5000 THEN 'Budget'
        WHEN price < 50000 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS price_category
FROM products
ORDER BY price;

-- Query 9.2: Customer Loyalty Classification
-- (Based on registration date)


SELECT 
    customer_name,
    registration_date,
    DATEDIFF(CURDATE(), registration_date) AS days_registered,
    CASE 
        WHEN DATEDIFF(CURDATE(), registration_date) > 500 THEN 'Loyal Customer'
        WHEN DATEDIFF(CURDATE(), registration_date) > 300 THEN 'Regular Customer'
        ELSE 'New Customer'
    END AS loyalty_status
FROM customers
ORDER BY days_registered DESC;

-- Query 9.3: Review Sentiment Classification

SELECT 
    r.review_id,
    p.product_name,
    r.rating,
    CASE 
        WHEN r.rating >= 4 THEN 'Positive'
        WHEN r.rating = 3 THEN 'Neutral'
        ELSE 'Negative'
    END AS sentiment,
    r.review_text
FROM reviews r
JOIN products p ON r.product_id = p.product_id
ORDER BY r.rating DESC;

-- SECTION 10: QUICK SUMMARY QUERIES
-
-- Query 10.1: Complete Business Summary (One Query!)
-- Question: "Give me a quick business overview"

SELECT 
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM products) AS total_products,
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT COUNT(*) FROM reviews) AS total_reviews,
    (SELECT ROUND(AVG(rating), 2) FROM reviews) AS avg_customer_rating,
    (SELECT ROUND(AVG(price), 2) FROM products) AS avg_product_price,
    (SELECT COUNT(*) FROM products WHERE stock_quantity < 50) AS low_stock_products;

-- Query 10.2: Top 3 Customers by Number of Orders

SELECT 
    c.customer_name,
    c.city,
    COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY order_count DESC
LIMIT 3;

-- Query 10.3: Most Reviewed Products
-- Question: "Which products get most feedback?"

SELECT 
    p.product_name,
    p.category,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name, p.category
HAVING review_count > 0
ORDER BY review_count DESC, avg_rating DESC;

