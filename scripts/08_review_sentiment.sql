--  CUSTOMER REVIEW & SENTIMENT ANALYSIS
-- Business Question:"Are customers satisfied? Which products need improvement?"

USE ecommerce_analytics;
-- Query 8.1: Product Rating Analysis
-- Product Ratings & Review Analysis

SELECT 
    p.product_name,
    p.category,
    p.brand,
    COUNT(DISTINCT r.review_id) AS review_count,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    SUM(CASE WHEN r.rating = 5 THEN 1 ELSE 0 END) AS five_star_reviews,
    SUM(CASE WHEN r.rating <= 2 THEN 1 ELSE 0 END) AS poor_reviews,
    ROUND(SUM(CASE WHEN r.rating = 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_five_star,
    -- Correlate with sales
    COUNT(DISTINCT oi.order_id) AS times_ordered,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount/100)), 2) AS revenue
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category, p.brand
HAVING review_count > 0
ORDER BY avg_rating DESC, review_count DESC;

-- Query 8.2: Rating Trends Over Time
-- Are ratings improving or declining?

SELECT 
    DATE_FORMAT(r.review_date, '%Y-%m') AS month,
    COUNT(*) AS review_count,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    SUM(CASE WHEN r.rating >= 4 THEN 1 ELSE 0 END) AS positive_reviews,
    SUM(CASE WHEN r.rating <= 2 THEN 1 ELSE 0 END) AS negative_reviews,
    ROUND(SUM(CASE WHEN r.rating >= 4 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS positive_sentiment_pct
FROM reviews r
GROUP BY DATE_FORMAT(r.review_date, '%Y-%m')
ORDER BY month;


