-- RFM ANALYSIS (Customer Segmentation)
-- Business Question:"Who are our best customers? How should we segment them?"

-- Recency - When did they last purchase?
-- Frequency - How often do they buy?
-- Monetary - How much do they spend?

USE ecommerce_analytics;
-- Query 2.1: Calculate RFM Scores

-- RFM Analysis with Customer Segmentation
WITH rfm_calc AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.city,
        DATEDIFF('2024-10-16', MAX(o.order_date)) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS monetary_value
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name, c.city
),
rfm_scores AS (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY recency_days) AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary_value DESC) AS m_score
    FROM rfm_calc
)
SELECT 
    customer_id,
    customer_name,
    city,
    recency_days,
    frequency,
    monetary_value,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE 
        WHEN (r_score + f_score + m_score) >= 13 THEN 'Champions'
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal Customers'
        WHEN (r_score + f_score + m_score) >= 7 THEN 'Potential Loyalists'
        WHEN (r_score + f_score + m_score) >= 5 THEN 'At Risk'
        ELSE 'Lost Customers'
    END AS customer_segment
FROM rfm_scores
ORDER BY rfm_total DESC;

-- Query 2.2: RFM Segment Distribution
-- How many customers in each segment?
WITH rfm_calc AS (
    SELECT 
        c.customer_id,
        DATEDIFF('2024-10-16', MAX(o.order_date)) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS monetary_value
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id
),
rfm_scores AS (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY recency_days) AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary_value DESC) AS m_score
    FROM rfm_calc
),
segments AS (
    SELECT 
        CASE 
            WHEN (r_score + f_score + m_score) >= 13 THEN 'Champions'
            WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal Customers'
            WHEN (r_score + f_score + m_score) >= 7 THEN 'Potential Loyalists'
            WHEN (r_score + f_score + m_score) >= 5 THEN 'At Risk'
            ELSE 'Lost Customers'
        END AS customer_segment,
        monetary_value
    FROM rfm_scores
)
SELECT 
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(monetary_value), 2) AS avg_revenue_per_customer,
    ROUND(SUM(monetary_value), 2) AS total_segment_revenue,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM segments), 2) AS pct_of_customers
FROM segments
GROUP BY customer_segment
ORDER BY total_segment_revenue DESC;