USE olist_ecommerce;
GO

-- 1. What are the top product categories by revenue?
SELECT TOP 10
    p.product_category_name_english AS product_category,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM analytics_order_items oi
JOIN analytics_products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name_english
ORDER BY revenue DESC;

-- 2. Which customer states generate the most sales?
SELECT TOP 10
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_sales
FROM analytics_orders o
JOIN analytics_customers c
    ON o.customer_id = c.customer_id
JOIN analytics_order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_sales DESC;

-- 3. Which sellers have the highest revenue?
SELECT TOP 10
    s.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS seller_revenue
FROM analytics_order_items oi
JOIN analytics_sellers s
    ON oi.seller_id = s.seller_id
GROUP BY s.seller_id, s.seller_state
ORDER BY seller_revenue DESC;

-- 4. What percentage of delivered orders were late?
SELECT
    COUNT(*) AS delivered_orders,
    SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        100.0 * SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS late_order_percentage
FROM analytics_orders
WHERE is_delivered = 1
  AND is_late IS NOT NULL;

-- 5. Does late delivery affect review scores?
SELECT
    CASE
        WHEN o.is_late = 1 THEN 'Late'
        ELSE 'On time or early'
    END AS delivery_status,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(CAST(r.review_score AS DECIMAL(10, 2))), 2) AS average_review_score
FROM analytics_orders o
JOIN analytics_order_reviews r
    ON o.order_id = r.order_id
WHERE o.is_delivered = 1
  AND o.is_late IS NOT NULL
GROUP BY
    CASE
        WHEN o.is_late = 1 THEN 'Late'
        ELSE 'On time or early'
    END;

-- 6. What are the most common payment types?
SELECT
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM analytics_order_payments
GROUP BY payment_type
ORDER BY payment_count DESC;

-- 7. Which months had the highest revenue?
SELECT TOP 10
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM analytics_orders o
JOIN analytics_order_items oi
    ON o.order_id = oi.order_id
GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY revenue DESC;

-- 8. Which products have high sales but low customer satisfaction?
SELECT TOP 10
    oi.product_id,
    p.product_category_name_english AS product_category,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(CAST(r.review_score AS DECIMAL(10, 2))), 2) AS average_review_score
FROM analytics_order_items oi
JOIN analytics_products p
    ON oi.product_id = p.product_id
JOIN analytics_order_reviews r
    ON oi.order_id = r.order_id
GROUP BY oi.product_id, p.product_category_name_english
HAVING COUNT(*) >= 20
   AND ROUND(AVG(CAST(r.review_score AS DECIMAL(10, 2))), 2) < 3.5
ORDER BY revenue DESC;
GO

