USE olist_ecommerce;
GO

-- This file is still more advanced than files 04 and 05,
-- but each query is kept short so it is easier to understand.

-- 1. Monthly revenue with previous month revenue.
-- Skill used: CTE + LAG window function.
WITH monthly_revenue AS (
    SELECT
        FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM analytics_orders o
    JOIN analytics_order_items oi
        ON o.order_id = oi.order_id
    GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
)
SELECT
    order_month,
    revenue,
    LAG(revenue) OVER (ORDER BY order_month) AS previous_month_revenue
FROM monthly_revenue
ORDER BY order_month;

-- 2. Rank product categories by revenue.
-- Skill used: aggregate function + RANK window function.
SELECT
    p.product_category_name_english AS product_category,
    ROUND(SUM(oi.price), 2) AS revenue,
    RANK() OVER (ORDER BY SUM(oi.price) DESC) AS revenue_rank
FROM analytics_order_items oi
JOIN analytics_products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name_english
ORDER BY revenue_rank;

-- 3. Group products into simple satisfaction labels.
-- Skill used: CASE statement.
SELECT
    oi.product_id,
    COUNT(*) AS items_sold,
    ROUND(AVG(CAST(r.review_score AS DECIMAL(10, 2))), 2) AS average_review_score,
    CASE
        WHEN AVG(CAST(r.review_score AS DECIMAL(10, 2))) >= 4 THEN 'Good reviews'
        WHEN AVG(CAST(r.review_score AS DECIMAL(10, 2))) >= 3 THEN 'Average reviews'
        ELSE 'Poor reviews'
    END AS review_group
FROM analytics_order_items oi
JOIN analytics_order_reviews r
    ON oi.order_id = r.order_id
GROUP BY oi.product_id
HAVING COUNT(*) >= 10
ORDER BY average_review_score ASC;

-- 4. Find sellers who made more revenue than the average seller.
-- Skill used: subquery.
SELECT
    seller_id,
    ROUND(SUM(price), 2) AS seller_revenue
FROM analytics_order_items
GROUP BY seller_id
HAVING SUM(price) > (
    SELECT AVG(seller_total)
    FROM (
        SELECT SUM(price) AS seller_total
        FROM analytics_order_items
        GROUP BY seller_id
    ) seller_revenue_summary
)
ORDER BY seller_revenue DESC;

-- 5. Number each customer's orders in purchase order.
-- Skill used: ROW_NUMBER window function.
SELECT
    c.customer_unique_id,
    o.order_id,
    o.order_purchase_timestamp,
    ROW_NUMBER() OVER (
        PARTITION BY c.customer_unique_id
        ORDER BY o.order_purchase_timestamp
    ) AS customer_order_number
FROM analytics_orders o
JOIN analytics_customers c
    ON o.customer_id = c.customer_id
ORDER BY c.customer_unique_id, customer_order_number;
GO

