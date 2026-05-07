USE olist_ecommerce;
GO

-- SQL Server import notes:
-- 1. Run this script in SQL Server Management Studio.
-- 2. The CSV files must exist at the paths below.
-- 3. This loads SQL Server-friendly pipe-delimited files from data\processed.
--    These were generated from the original Kaggle CSV files to avoid issues
--    with commas, quotes, and line breaks inside review text.
-- 4. If SQL Server cannot access files in Documents, move the project to a simple
--    folder such as C:\SQL\olist-ecommerce-sql-project and update the paths.

DELETE FROM raw_product_category_translation;
DELETE FROM raw_sellers;
DELETE FROM raw_products;
DELETE FROM raw_orders;
DELETE FROM raw_order_reviews;
DELETE FROM raw_order_payments;
DELETE FROM raw_order_items;
DELETE FROM raw_geolocation;
DELETE FROM raw_customers;
GO

BULK INSERT raw_customers
FROM 'C:\Users\alboa\Documents\New project\olist-ecommerce-sql-project\data\processed\olist_customers_dataset.psv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);

BULK INSERT raw_geolocation
FROM 'C:\Users\alboa\Documents\New project\olist-ecommerce-sql-project\data\processed\olist_geolocation_dataset.psv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);

BULK INSERT raw_order_items
FROM 'C:\Users\alboa\Documents\New project\olist-ecommerce-sql-project\data\processed\olist_order_items_dataset.psv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);

BULK INSERT raw_order_payments
FROM 'C:\Users\alboa\Documents\New project\olist-ecommerce-sql-project\data\processed\olist_order_payments_dataset.psv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);

BULK INSERT raw_order_reviews
FROM 'C:\Users\alboa\Documents\New project\olist-ecommerce-sql-project\data\processed\olist_order_reviews_dataset.psv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);

BULK INSERT raw_orders
FROM 'C:\Users\alboa\Documents\New project\olist-ecommerce-sql-project\data\processed\olist_orders_dataset.psv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);

BULK INSERT raw_products
FROM 'C:\Users\alboa\Documents\New project\olist-ecommerce-sql-project\data\processed\olist_products_dataset.psv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);

BULK INSERT raw_sellers
FROM 'C:\Users\alboa\Documents\New project\olist-ecommerce-sql-project\data\processed\olist_sellers_dataset.psv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);

BULK INSERT raw_product_category_translation
FROM 'C:\Users\alboa\Documents\New project\olist-ecommerce-sql-project\data\processed\product_category_name_translation.psv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO
