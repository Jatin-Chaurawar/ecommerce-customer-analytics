-- SALES PERFORMANCE ANALYSIS
-- Business Question: How is our business performing?

USE ecommerce_analytics;
-- Query 1.1: Overall Business Metrics

SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    COUNT(DISTINCT oi.product_id) AS products_sold,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    ROUND(AVG(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS avg_order_value,
    ROUND(SUM(oi.profit) / SUM(p.price * oi.quantity * (1 - oi.discount/100)) * 100, 2) AS profit_margin_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- =============================================
-- Query 1.2: Monthly Sales Trend
-- =============================================

SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit,
    ROUND(AVG(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;

-- =============================================
-- KEY INSIGHTS:
-- 1. Total revenue: ₹3.45L+
-- 2. Profit margin: ~44%
-- 3. Average order value: ₹17,250
-- =============================================