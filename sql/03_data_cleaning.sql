USE olist_ecommerce;
GO

DELETE FROM analytics_order_reviews;
DELETE FROM analytics_order_payments;
DELETE FROM analytics_order_items;
DELETE FROM analytics_orders;
DELETE FROM analytics_products;
DELETE FROM analytics_sellers;
DELETE FROM analytics_customers;
DELETE FROM analytics_geolocation_zip;
GO

INSERT INTO analytics_customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM (
    SELECT
        TRIM(customer_id) AS customer_id,
        TRIM(customer_unique_id) AS customer_unique_id,
        TRY_CONVERT(INT, NULLIF(customer_zip_code_prefix, '')) AS customer_zip_code_prefix,
        LOWER(TRIM(customer_city)) AS customer_city,
        UPPER(TRIM(customer_state)) AS customer_state,
        ROW_NUMBER() OVER (
            PARTITION BY TRIM(customer_id)
            ORDER BY TRIM(customer_unique_id)
        ) AS row_num
    FROM raw_customers
    WHERE NULLIF(customer_id, '') IS NOT NULL
) customers_deduped
WHERE row_num = 1;

INSERT INTO analytics_sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM (
    SELECT
        TRIM(seller_id) AS seller_id,
        TRY_CONVERT(INT, NULLIF(seller_zip_code_prefix, '')) AS seller_zip_code_prefix,
        LOWER(TRIM(seller_city)) AS seller_city,
        UPPER(TRIM(seller_state)) AS seller_state,
        ROW_NUMBER() OVER (
            PARTITION BY TRIM(seller_id)
            ORDER BY TRIM(seller_city)
        ) AS row_num
    FROM raw_sellers
    WHERE NULLIF(seller_id, '') IS NOT NULL
) sellers_deduped
WHERE row_num = 1;

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
FROM (
    SELECT
        TRIM(p.product_id) AS product_id,
        COALESCE(NULLIF(TRIM(p.product_category_name), ''), 'unknown') AS product_category_name,
        COALESCE(t.product_category_name_english, NULLIF(TRIM(p.product_category_name), ''), 'unknown') AS product_category_name_english,
        TRY_CONVERT(INT, NULLIF(p.product_name_lenght, '')) AS product_name_length,
        TRY_CONVERT(INT, NULLIF(p.product_description_lenght, '')) AS product_description_length,
        TRY_CONVERT(INT, NULLIF(p.product_photos_qty, '')) AS product_photos_qty,
        TRY_CONVERT(INT, NULLIF(p.product_weight_g, '')) AS product_weight_g,
        TRY_CONVERT(INT, NULLIF(p.product_length_cm, '')) AS product_length_cm,
        TRY_CONVERT(INT, NULLIF(p.product_height_cm, '')) AS product_height_cm,
        TRY_CONVERT(INT, NULLIF(p.product_width_cm, '')) AS product_width_cm,
        ROW_NUMBER() OVER (
            PARTITION BY TRIM(p.product_id)
            ORDER BY TRIM(p.product_category_name)
        ) AS row_num
    FROM raw_products p
    LEFT JOIN raw_product_category_translation t
        ON p.product_category_name = t.product_category_name
    WHERE NULLIF(p.product_id, '') IS NOT NULL
) products_deduped
WHERE row_num = 1;

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
    TRY_CONVERT(DATETIME2, NULLIF(o.order_purchase_timestamp, '')),
    TRY_CONVERT(DATETIME2, NULLIF(o.order_approved_at, '')),
    TRY_CONVERT(DATETIME2, NULLIF(o.order_delivered_carrier_date, '')),
    TRY_CONVERT(DATETIME2, NULLIF(o.order_delivered_customer_date, '')),
    TRY_CONVERT(DATETIME2, NULLIF(o.order_estimated_delivery_date, '')),
    CASE WHEN LOWER(TRIM(o.order_status)) = 'delivered' THEN 1 ELSE 0 END AS is_delivered,
    CASE
        WHEN TRY_CONVERT(DATETIME2, NULLIF(o.order_delivered_customer_date, '')) IS NULL
          OR TRY_CONVERT(DATETIME2, NULLIF(o.order_estimated_delivery_date, '')) IS NULL
        THEN NULL
        WHEN TRY_CONVERT(DATETIME2, o.order_delivered_customer_date)
           > TRY_CONVERT(DATETIME2, o.order_estimated_delivery_date)
        THEN 1
        ELSE 0
    END AS is_late,
    CASE
        WHEN TRY_CONVERT(DATETIME2, NULLIF(o.order_delivered_customer_date, '')) IS NULL
          OR TRY_CONVERT(DATETIME2, NULLIF(o.order_purchase_timestamp, '')) IS NULL
        THEN NULL
        ELSE ROUND(
            DATEDIFF(
                SECOND,
                TRY_CONVERT(DATETIME2, o.order_purchase_timestamp),
                TRY_CONVERT(DATETIME2, o.order_delivered_customer_date)
            ) / 86400.0,
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
    TRY_CONVERT(INT, NULLIF(order_item_id, '')),
    NULLIF(TRIM(product_id), ''),
    NULLIF(TRIM(seller_id), ''),
    TRY_CONVERT(DATETIME2, NULLIF(shipping_limit_date, '')),
    TRY_CONVERT(DECIMAL(12, 2), NULLIF(price, '')),
    TRY_CONVERT(DECIMAL(12, 2), NULLIF(freight_value, ''))
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
    TRY_CONVERT(INT, NULLIF(payment_sequential, '')),
    LOWER(TRIM(payment_type)),
    TRY_CONVERT(INT, NULLIF(payment_installments, '')),
    TRY_CONVERT(DECIMAL(12, 2), NULLIF(payment_value, ''))
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
    TRY_CONVERT(INT, NULLIF(review_score, '')),
    NULLIF(TRIM(review_comment_title), ''),
    NULLIF(TRIM(review_comment_message), ''),
    TRY_CONVERT(DATETIME2, NULLIF(review_creation_date, '')),
    TRY_CONVERT(DATETIME2, NULLIF(review_answer_timestamp, ''))
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
    TRY_CONVERT(INT, NULLIF(geolocation_zip_code_prefix, '')),
    MIN(LOWER(TRIM(geolocation_city))) AS geolocation_city,
    MAX(UPPER(TRIM(geolocation_state))) AS geolocation_state,
    ROUND(AVG(TRY_CONVERT(DECIMAL(12, 8), NULLIF(geolocation_lat, ''))), 6) AS avg_lat,
    ROUND(AVG(TRY_CONVERT(DECIMAL(12, 8), NULLIF(geolocation_lng, ''))), 6) AS avg_lng,
    COUNT(*) AS source_rows
FROM raw_geolocation
WHERE TRY_CONVERT(INT, NULLIF(geolocation_zip_code_prefix, '')) IS NOT NULL
GROUP BY TRY_CONVERT(INT, NULLIF(geolocation_zip_code_prefix, ''));

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
GO
