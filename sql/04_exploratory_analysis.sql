USE olist_ecommerce;
GO

-- 1. How many rows are in each main table?
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM analytics_customers
UNION ALL
SELECT 'orders', COUNT(*) FROM analytics_orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM analytics_order_items
UNION ALL
SELECT 'products', COUNT(*) FROM analytics_products
UNION ALL
SELECT 'sellers', COUNT(*) FROM analytics_sellers
UNION ALL
SELECT 'payments', COUNT(*) FROM analytics_order_payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM analytics_order_reviews;

-- 2. What order statuses exist?
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM analytics_orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- 3. What review scores do customers usually give?
SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM analytics_order_reviews
GROUP BY review_score
ORDER BY review_score;

-- 4. How much revenue was made each month?
SELECT
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS product_revenue
FROM analytics_orders o
JOIN analytics_order_items oi
    ON o.order_id = oi.order_id
GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY order_month;

-- 5. Which customer states have the most orders?
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM analytics_orders o
JOIN analytics_customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;
GO

