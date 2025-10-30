-- SHIPPING & OPERATIONAL EFFICIENCY
-- Business Question:"Are we delivering orders on time? Is express shipping worth it?"

USE ecommerce_analytics;
-- Query 6.1: Delivery Performance
-- Shipping Performance Analysis

SELECT 
    ship_mode,
    COUNT(*) AS total_orders,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 1) AS avg_days_to_ship,
    MIN(DATEDIFF(ship_date, order_date)) AS fastest_delivery,
    MAX(DATEDIFF(ship_date, order_date)) AS slowest_delivery,
    ROUND(SUM(CASE WHEN DATEDIFF(ship_date, order_date) <= 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_delivered_within_2days
FROM orders
WHERE ship_date IS NOT NULL
GROUP BY ship_mode
ORDER BY avg_days_to_ship;

-- Query 6.2: Revenue by Shipping Mode
-- Does shipping mode affect revenue? 

SELECT 
    o.ship_mode,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS revenue,
    ROUND(AVG(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS avg_order_value,
    ROUND(AVG(DATEDIFF(o.ship_date, o.order_date)), 1) AS avg_delivery_days
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.ship_mode
ORDER BY revenue DESC;