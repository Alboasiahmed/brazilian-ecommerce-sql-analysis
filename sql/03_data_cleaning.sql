USE olist_ecommerce;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE analytics_order_reviews;
TRUNCATE TABLE analytics_order_payments;
TRUNCATE TABLE analytics_order_items;
TRUNCATE TABLE analytics_orders;
TRUNCATE TABLE analytics_products;
TRUNCATE TABLE analytics_sellers;
TRUNCATE TABLE analytics_customers;
TRUNCATE TABLE analytics_geolocation_zip;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO analytics_customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT DISTINCT
    TRIM(customer_id),
    TRIM(customer_unique_id),
    CAST(NULLIF(customer_zip_code_prefix, '') AS UNSIGNED),
    LOWER(TRIM(customer_city)),
    UPPER(TRIM(customer_state))
FROM raw_customers
WHERE NULLIF(customer_id, '') IS NOT NULL;

INSERT INTO analytics_sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
SELECT DISTINCT
    TRIM(seller_id),
    CAST(NULLIF(seller_zip_code_prefix, '') AS UNSIGNED),
    LOWER(TRIM(seller_city)),
    UPPER(TRIM(seller_state))
FROM raw_sellers
WHERE NULLIF(seller_id, '') IS NOT NULL;

INSERT INTO analytics_products (
    product_id,
    product_category_name,
    product_category_name_english,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT
    TRIM(p.product_id),
    COALESCE(NULLIF(TRIM(p.product_category_name), ''), 'unknown') AS product_category_name,
    COALESCE(t.product_category_name_english, NULLIF(TRIM(p.product_category_name), ''), 'unknown') AS product_category_name_english,
    CAST(NULLIF(p.product_name_lenght, '') AS UNSIGNED) AS product_name_length,
    CAST(NULLIF(p.product_description_lenght, '') AS UNSIGNED) AS product_description_length,
    CAST(NULLIF(p.product_photos_qty, '') AS UNSIGNED),
    CAST(NULLIF(p.product_weight_g, '') AS UNSIGNED),
    CAST(NULLIF(p.product_length_cm, '') AS UNSIGNED),
    CAST(NULLIF(p.product_height_cm, '') AS UNSIGNED),
    CAST(NULLIF(p.product_width_cm, '') AS UNSIGNED)
FROM raw_products p
LEFT JOIN raw_product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE NULLIF(p.product_id, '') IS NOT NULL;

INSERT INTO analytics_orders (
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    is_delivered,
    is_late,
    delivery_days
)
SELECT
    TRIM(o.order_id),
    TRIM(o.customer_id),
    LOWER(TRIM(o.order_status)),
    STR_TO_DATE(NULLIF(o.order_purchase_timestamp, ''), '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(NULLIF(o.order_approved_at, ''), '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(NULLIF(o.order_delivered_carrier_date, ''), '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(NULLIF(o.order_delivered_customer_date, ''), '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(NULLIF(o.order_estimated_delivery_date, ''), '%Y-%m-%d %H:%i:%s'),
    CASE WHEN LOWER(TRIM(o.order_status)) = 'delivered' THEN 1 ELSE 0 END AS is_delivered,
    CASE
        WHEN NULLIF(o.order_delivered_customer_date, '') IS NULL
          OR NULLIF(o.order_estimated_delivery_date, '') IS NULL
        THEN NULL
        WHEN STR_TO_DATE(o.order_delivered_customer_date, '%Y-%m-%d %H:%i:%s')
           > STR_TO_DATE(o.order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s')
        THEN 1
        ELSE 0
    END AS is_late,
    CASE
        WHEN NULLIF(o.order_delivered_customer_date, '') IS NULL
          OR NULLIF(o.order_purchase_timestamp, '') IS NULL
        THEN NULL
        ELSE ROUND(
            TIMESTAMPDIFF(
                SECOND,
                STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'),
                STR_TO_DATE(o.order_delivered_customer_date, '%Y-%m-%d %H:%i:%s')
            ) / 86400,
            2
        )
    END AS delivery_days
FROM raw_orders o
JOIN analytics_customers c
    ON TRIM(o.customer_id) = c.customer_id
WHERE NULLIF(o.order_id, '') IS NOT NULL;

INSERT INTO analytics_order_items (
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
)
SELECT
    TRIM(order_id),
    CAST(NULLIF(order_item_id, '') AS UNSIGNED),
    NULLIF(TRIM(product_id), ''),
    NULLIF(TRIM(seller_id), ''),
    STR_TO_DATE(NULLIF(shipping_limit_date, ''), '%Y-%m-%d %H:%i:%s'),
    CAST(NULLIF(price, '') AS DECIMAL(12, 2)),
    CAST(NULLIF(freight_value, '') AS DECIMAL(12, 2))
FROM raw_order_items
WHERE NULLIF(order_id, '') IS NOT NULL
  AND NULLIF(order_item_id, '') IS NOT NULL;

INSERT INTO analytics_order_payments (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
SELECT
    TRIM(order_id),
    CAST(NULLIF(payment_sequential, '') AS UNSIGNED),
    LOWER(TRIM(payment_type)),
    CAST(NULLIF(payment_installments, '') AS UNSIGNED),
    CAST(NULLIF(payment_value, '') AS DECIMAL(12, 2))
FROM raw_order_payments
WHERE NULLIF(order_id, '') IS NOT NULL
  AND NULLIF(payment_sequential, '') IS NOT NULL;

INSERT INTO analytics_order_reviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
)
SELECT
    TRIM(review_id),
    TRIM(order_id),
    CAST(NULLIF(review_score, '') AS UNSIGNED),
    NULLIF(TRIM(review_comment_title), ''),
    NULLIF(TRIM(review_comment_message), ''),
    CASE
        WHEN review_creation_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
        THEN STR_TO_DATE(review_creation_date, '%Y-%m-%d %H:%i:%s')
        ELSE NULL
    END,
    CASE
        WHEN review_answer_timestamp REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
        THEN STR_TO_DATE(review_answer_timestamp, '%Y-%m-%d %H:%i:%s')
        ELSE NULL
    END
FROM raw_order_reviews
WHERE NULLIF(review_id, '') IS NOT NULL
  AND NULLIF(order_id, '') IS NOT NULL;

INSERT INTO analytics_geolocation_zip (
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state,
    avg_lat,
    avg_lng,
    source_rows
)
SELECT
    CAST(NULLIF(geolocation_zip_code_prefix, '') AS UNSIGNED),
    MIN(LOWER(TRIM(geolocation_city))) AS geolocation_city,
    MAX(UPPER(TRIM(geolocation_state))) AS geolocation_state,
    ROUND(AVG(CAST(NULLIF(geolocation_lat, '') AS DECIMAL(12, 8))), 6) AS avg_lat,
    ROUND(AVG(CAST(NULLIF(geolocation_lng, '') AS DECIMAL(12, 8))), 6) AS avg_lng,
    COUNT(*) AS source_rows
FROM raw_geolocation
WHERE NULLIF(geolocation_zip_code_prefix, '') IS NOT NULL
GROUP BY CAST(NULLIF(geolocation_zip_code_prefix, '') AS UNSIGNED);

-- Data quality checks.
SELECT 'customers' AS table_name, COUNT(*) AS rows_loaded FROM analytics_customers
UNION ALL SELECT 'orders', COUNT(*) FROM analytics_orders
UNION ALL SELECT 'order_items', COUNT(*) FROM analytics_order_items
UNION ALL SELECT 'payments', COUNT(*) FROM analytics_order_payments
UNION ALL SELECT 'reviews', COUNT(*) FROM analytics_order_reviews
UNION ALL SELECT 'products', COUNT(*) FROM analytics_products
UNION ALL SELECT 'sellers', COUNT(*) FROM analytics_sellers
UNION ALL SELECT 'geolocation_zip', COUNT(*) FROM analytics_geolocation_zip;

SELECT
    SUM(CASE WHEN order_delivered_customer_date IS NULL AND is_delivered = 1 THEN 1 ELSE 0 END) AS delivered_orders_missing_delivery_date,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS orders_missing_estimated_delivery_date,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS orders_missing_purchase_timestamp
FROM analytics_orders;
