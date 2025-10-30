-- DISCOUNT EFFECTIVENESS ANALYSIS
-- Business Question:"Do discounts increase sales or just reduce profit?"

USE ecommerce_analytics;
-- Query 7.1: Discount Impact on Revenue & Profit
-- Discount Analysis

SELECT 
    CASE 
        WHEN oi.discount = 0 THEN 'No Discount'
        WHEN oi.discount <= 5 THEN '1-5% Discount'
        WHEN oi.discount <= 10 THEN '6-10% Discount'
        WHEN oi.discount <= 15 THEN '11-15% Discount'
        ELSE 'Over 15% Discount'
    END AS discount_category,
    COUNT(DISTINCT oi.order_id) AS orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit,
    ROUND(SUM(oi.profit) / SUM(p.price * oi.quantity * (1 - oi.discount/100)) * 100, 2) AS profit_margin_pct,
    ROUND(AVG(oi.discount), 2) AS avg_discount_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY discount_category
ORDER BY avg_discount_pct;

-- Query 7.2: Products Most Frequently Discounted
-- Which products are discounted most?

SELECT 
    p.product_name,
    p.category,
    p.price,
    COUNT(*) AS times_sold,
    ROUND(AVG(oi.discount), 2) AS avg_discount_pct,
    SUM(CASE WHEN oi.discount > 0 THEN 1 ELSE 0 END) AS times_discounted,
    ROUND(SUM(CASE WHEN oi.discount > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS discount_frequency_pct,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS revenue,
    ROUND(SUM(oi.profit), 2) AS profit
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price
HAVING times_sold >= 1
ORDER BY discount_frequency_pct DESC;