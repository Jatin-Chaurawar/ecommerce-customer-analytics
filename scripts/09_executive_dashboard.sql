-- THE ULTIMATE EXECUTIVE DASHBOARD QUERY
-- Business Question:"Give me everything important in ONE query!"

USE ecommerce_analytics;
-- Executive Dashboard: Complete Business Overview
WITH revenue_metrics AS (
    SELECT 
        ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS total_revenue,
        ROUND(SUM(oi.profit), 2) AS total_profit,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(DISTINCT o.customer_id) AS active_customers
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
),
top_product AS (
    SELECT 
        p.product_name,
        ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
    ORDER BY revenue DESC
    LIMIT 1
),
top_category AS (
    SELECT 
        p.category,
        ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.category
    ORDER BY revenue DESC
    LIMIT 1
),
top_city AS (
    SELECT 
        c.city,
        ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.city
    ORDER BY revenue DESC
    LIMIT 1
),
customer_satisfaction AS (
    SELECT 
        ROUND(AVG(rating), 2) AS avg_rating,
        COUNT(*) AS total_reviews
    FROM reviews
)
SELECT 
    rm.total_revenue,
    rm.total_profit,
    ROUND(rm.total_profit / rm.total_revenue * 100, 2) AS profit_margin_pct,
    rm.total_orders,
    rm.active_customers,
    ROUND(rm.total_revenue / rm.total_orders, 2) AS avg_order_value,
    ROUND(rm.total_orders * 1.0 / rm.active_customers, 2) AS orders_per_customer,
    tp.product_name AS top_selling_product,
    tp.revenue AS top_product_revenue,
    tc.category AS top_category,
    tc.revenue AS top_category_revenue,
    tci.city AS top_city,
    tci.revenue AS top_city_revenue,
    cs.avg_rating AS customer_satisfaction_score,
    cs.total_reviews
FROM revenue_metrics rm
CROSS JOIN top_product tp
CROSS JOIN top_category tc
CROSS JOIN top_city tci
CROSS JOIN customer_satisfaction cs;