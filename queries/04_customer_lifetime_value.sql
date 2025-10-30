-- CUSTOMER LIFETIME VALUE (CLV)
-- Business Question:"How much is each customer worth over their entire relationship with us?"

USE ecommerce_analytics;
-- Query 4.1: Calculate CLV
-- Customer Lifetime Value Analysis

WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS total_revenue,
        ROUND(AVG(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS avg_order_value,
        DATEDIFF(MAX(o.order_date), MIN(o.order_date)) AS customer_lifespan_days,
        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS last_order_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name, c.customer_segment
)
SELECT 
    customer_id,
    customer_name,
    customer_segment,
    total_orders,
    total_revenue,
    avg_order_value,
    customer_lifespan_days,
    -- Purchase Frequency (orders per month)
    ROUND(total_orders / NULLIF(customer_lifespan_days / 30.0, 0), 2) AS orders_per_month,
    -- Estimated Annual Value
    ROUND(total_revenue / NULLIF(customer_lifespan_days / 365.0, 0), 2) AS estimated_annual_value,
    -- Simple CLV (assuming 2 year lifespan)
    ROUND((total_revenue / NULLIF(customer_lifespan_days / 365.0, 0)) * 2, 2) AS estimated_clv_2years,
    first_order_date,
    last_order_date
FROM customer_metrics
ORDER BY total_revenue DESC;

-- Query 4.2: CLV by Customer Segment
-- Average CLV by Segment

WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.customer_segment,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS total_revenue,
        DATEDIFF(MAX(o.order_date), MIN(o.order_date)) AS customer_lifespan_days
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_segment
)
SELECT 
    customer_segment,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_customer,
    ROUND(AVG(customer_lifespan_days), 0) AS avg_lifespan_days,
    ROUND(AVG(total_revenue / NULLIF(customer_lifespan_days / 365.0, 0)) * 2, 2) AS avg_clv_2years
FROM customer_metrics
GROUP BY customer_segment
ORDER BY avg_clv_2years DESC;
