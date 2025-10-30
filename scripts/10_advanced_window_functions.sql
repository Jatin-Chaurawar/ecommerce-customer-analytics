-- ADVANCED WINDOW FUNCTIONS
-- Query: Running Total & Moving Average


USE ecommerce_analytics;
-- Advanced: Revenue Running Total and 3-Month Moving Average
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT 
    month,
    revenue,
    SUM(revenue) OVER (ORDER BY month) AS running_total,
    ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3months,
    LAG(revenue, 1) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND((revenue - LAG(revenue, 1) OVER (ORDER BY month)) / LAG(revenue, 1) OVER (ORDER BY month) * 100, 2) AS month_over_month_growth_pct
FROM monthly_revenue
ORDER BY month;