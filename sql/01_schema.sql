DROP DATABASE IF EXISTS olist_ecommerce;
CREATE DATABASE olist_ecommerce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE olist_ecommerce;

CREATE TABLE raw_customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(20),
    customer_city VARCHAR(255),
    customer_state VARCHAR(10)
);

CREATE TABLE raw_geolocation (
    geolocation_zip_code_prefix VARCHAR(20),
    geolocation_lat VARCHAR(50),
    geolocation_lng VARCHAR(50),
    geolocation_city VARCHAR(255),
    geolocation_state VARCHAR(10)
);

CREATE TABLE raw_orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp VARCHAR(50),
    order_approved_at VARCHAR(50),
    order_delivered_carrier_date VARCHAR(50),
    order_delivered_customer_date VARCHAR(50),
    order_estimated_delivery_date VARCHAR(50)
);

CREATE TABLE raw_order_items (
    order_id VARCHAR(50),
    order_item_id VARCHAR(20),
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date VARCHAR(50),
    price VARCHAR(30),
    freight_value VARCHAR(30)
);

CREATE TABLE raw_order_payments (
    order_id VARCHAR(50),
    payment_sequential VARCHAR(20),
    payment_type VARCHAR(50),
    payment_installments VARCHAR(20),
    payment_value VARCHAR(30)
);

CREATE TABLE raw_order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score VARCHAR(20),
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date VARCHAR(50),
    review_answer_timestamp VARCHAR(50)
);

CREATE TABLE raw_products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(255),
    product_name_lenght VARCHAR(20),
    product_description_lenght VARCHAR(20),
    product_photos_qty VARCHAR(20),
    product_weight_g VARCHAR(20),
    product_length_cm VARCHAR(20),
    product_height_cm VARCHAR(20),
    product_width_cm VARCHAR(20)
);

CREATE TABLE raw_sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix VARCHAR(20),
    seller_city VARCHAR(255),
    seller_state VARCHAR(10)
);

CREATE TABLE raw_product_category_translation (
    product_category_name VARCHAR(255),
    product_category_name_english VARCHAR(255)
);

CREATE TABLE analytics_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix INT,
    customer_city VARCHAR(255),
    customer_state CHAR(2)
);

CREATE TABLE analytics_sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(255),
    seller_state CHAR(2)
);

CREATE TABLE analytics_products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(255),
    product_category_name_english VARCHAR(255),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE analytics_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(50),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    is_delivered TINYINT(1),
    is_late TINYINT(1),
    delivery_days DECIMAL(10, 2),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES analytics_customers(customer_id)
);

CREATE TABLE analytics_order_items (
    order_id VARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(12, 2),
    freight_value DECIMAL(12, 2),
    PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_items_order
        FOREIGN KEY (order_id) REFERENCES analytics_orders(order_id),
    CONSTRAINT fk_items_product
        FOREIGN KEY (product_id) REFERENCES analytics_products(product_id),
    CONSTRAINT fk_items_seller
        FOREIGN KEY (seller_id) REFERENCES analytics_sellers(seller_id)
);

CREATE TABLE analytics_order_payments (
    order_id VARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(12, 2),
    PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id) REFERENCES analytics_orders(order_id)
);

CREATE TABLE analytics_order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50) NOT NULL,
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,
    PRIMARY KEY (review_id, order_id),
    CONSTRAINT fk_reviews_order
        FOREIGN KEY (order_id) REFERENCES analytics_orders(order_id)
);

CREATE TABLE analytics_geolocation_zip (
    geolocation_zip_code_prefix INT PRIMARY KEY,
    geolocation_city VARCHAR(255),
    geolocation_state CHAR(2),
    avg_lat DECIMAL(10, 6),
    avg_lng DECIMAL(10, 6),
    source_rows INT
);

CREATE INDEX idx_orders_customer_id ON analytics_orders(customer_id);
CREATE INDEX idx_orders_purchase_timestamp ON analytics_orders(order_purchase_timestamp);
CREATE INDEX idx_order_items_product_id ON analytics_order_items(product_id);
CREATE INDEX idx_order_items_seller_id ON analytics_order_items(seller_id);
CREATE INDEX idx_order_payments_type ON analytics_order_payments(payment_type);
CREATE INDEX idx_reviews_order_id ON analytics_order_reviews(order_id);

