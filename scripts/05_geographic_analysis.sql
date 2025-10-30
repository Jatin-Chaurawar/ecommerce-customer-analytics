-- GEOGRAPHIC PERFORMANCE ANALYSIS
-- Business Question:"Which cities/states drive the most revenue? Where should we expand?"

USE ecommerce_analytics;
-- Query 5.1: Top Performing Cities
-- Revenue by City

SELECT 
    c.city,
    c.state,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    ROUND(AVG(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS avg_order_value,
    ROUND(COUNT(DISTINCT o.order_id) * 1.0 / COUNT(DISTINCT c.customer_id), 2) AS orders_per_customer
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.city, c.state
ORDER BY total_revenue DESC;

-- Query 5.2: State-Level Performance
-- Revenue by State with Market Share

SELECT 
    c.state,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS revenue,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)) * 100.0 / 
        (SELECT SUM(p2.price * oi2.quantity * (1 - oi2.discount/100))
         FROM order_items oi2
         JOIN products p2 ON oi2.product_id = p2.product_id), 2) AS revenue_market_share_pct
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.state
ORDER BY revenue DESC;