USE olist_ecommerce;

-- MySQL import notes:
-- 1. This script uses absolute paths so it can run from MySQL Workbench.
-- 2. If LOCAL import is disabled, enable it in your client connection.
--    Example CLI flag: mysql --local-infile=1 -u root -p

LOAD DATA LOCAL INFILE 'C:/Users/alboa/Documents/New project/olist-ecommerce-sql-project/data/raw/olist_customers_dataset.csv'
INTO TABLE raw_customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/alboa/Documents/New project/olist-ecommerce-sql-project/data/raw/olist_geolocation_dataset.csv'
INTO TABLE raw_geolocation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/alboa/Documents/New project/olist-ecommerce-sql-project/data/raw/olist_order_items_dataset.csv'
INTO TABLE raw_order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/alboa/Documents/New project/olist-ecommerce-sql-project/data/raw/olist_order_payments_dataset.csv'
INTO TABLE raw_order_payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/alboa/Documents/New project/olist-ecommerce-sql-project/data/raw/olist_order_reviews_dataset.csv'
INTO TABLE raw_order_reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/alboa/Documents/New project/olist-ecommerce-sql-project/data/raw/olist_orders_dataset.csv'
INTO TABLE raw_orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/alboa/Documents/New project/olist-ecommerce-sql-project/data/raw/olist_products_dataset.csv'
INTO TABLE raw_products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/alboa/Documents/New project/olist-ecommerce-sql-project/data/raw/olist_sellers_dataset.csv'
INTO TABLE raw_sellers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/alboa/Documents/New project/olist-ecommerce-sql-project/data/raw/product_category_name_translation.csv'
INTO TABLE raw_product_category_translation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
