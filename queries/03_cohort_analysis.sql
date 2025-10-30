-- COHORT ANALYSIS
-- Business Question:"How well do we retain customers over time? Do customers who joined in January keep buying?"

USE ecommerce_analytics;
-- Query 3.1: Customer Retention Cohort
-- Cohort Analysis: Customer Retention by Month

WITH customer_cohorts AS (
    SELECT 
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM orders
    GROUP BY customer_id
),
customer_activities AS (
    SELECT 
        o.customer_id,
        cc.cohort_month,
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        PERIOD_DIFF(
            DATE_FORMAT(o.order_date, '%Y%m'), 
            DATE_FORMAT(cc.cohort_month, '%Y%m')
        ) AS months_since_first_purchase
    FROM orders o
    JOIN customer_cohorts cc ON o.customer_id = cc.customer_id
)
SELECT 
    cohort_month,
    COUNT(DISTINCT CASE WHEN months_since_first_purchase = 0 THEN customer_id END) AS month_0,
    COUNT(DISTINCT CASE WHEN months_since_first_purchase = 1 THEN customer_id END) AS month_1,
    COUNT(DISTINCT CASE WHEN months_since_first_purchase = 2 THEN customer_id END) AS month_2,
    COUNT(DISTINCT CASE WHEN months_since_first_purchase = 3 THEN customer_id END) AS month_3,
    COUNT(DISTINCT CASE WHEN months_since_first_purchase = 4 THEN customer_id END) AS month_4,
    COUNT(DISTINCT CASE WHEN months_since_first_purchase = 5 THEN customer_id END) AS month_5,
    COUNT(DISTINCT CASE WHEN months_since_first_purchase = 6 THEN customer_id END) AS month_6
FROM customer_activities
GROUP BY cohort_month
ORDER BY cohort_month;

-- Query 3.2: Cohort Retention Rate (%)
-- Retention Rate Percentage by Cohort

WITH customer_cohorts AS (
    SELECT 
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM orders
    GROUP BY customer_id
),
cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
),
customer_activities AS (
    SELECT 
        o.customer_id,
        cc.cohort_month,
        PERIOD_DIFF(
            DATE_FORMAT(o.order_date, '%Y%m'), 
            DATE_FORMAT(cc.cohort_month, '%Y%m')
        ) AS months_since_first_purchase
    FROM orders o
    JOIN customer_cohorts cc ON o.customer_id = cc.customer_id
)
SELECT 
    ca.cohort_month,
    cs.cohort_size,
    ROUND(COUNT(DISTINCT CASE WHEN months_since_first_purchase = 1 THEN ca.customer_id END) * 100.0 / cs.cohort_size, 2) AS month_1_retention,
    ROUND(COUNT(DISTINCT CASE WHEN months_since_first_purchase = 2 THEN ca.customer_id END) * 100.0 / cs.cohort_size, 2) AS month_2_retention,
    ROUND(COUNT(DISTINCT CASE WHEN months_since_first_purchase = 3 THEN ca.customer_id END) * 100.0 / cs.cohort_size, 2) AS month_3_retention,
    ROUND(COUNT(DISTINCT CASE WHEN months_since_first_purchase = 6 THEN ca.customer_id END) * 100.0 / cs.cohort_size, 2) AS month_6_retention
FROM customer_activities ca
JOIN cohort_sizes cs ON ca.cohort_month = cs.cohort_month
GROUP BY ca.cohort_month, cs.cohort_size
ORDER BY ca.cohort_month;