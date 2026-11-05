

--DIM_DATE
CREATE TABLE analytics.dim_date(
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL,
    year INTEGER,
    month INTEGER,
    quarter INTEGER,
    month_name VARCHAR(20)
);
INSERT INTO analytics.dim_date
SELECT DISTINCT
    TO_CHAR(sale_end_date, 'YYYYMMDD')::INTEGER AS date_key,
    sale_end_date AS full_date,
    EXTRACT(YEAR FROM sale_end_date)::INTEGER AS year,
    EXTRACT(MONTH FROM sale_end_date)::INTEGER AS month,
    EXTRACT(QUARTER FROM sale_end_date)::INTEGER AS quarter,
    TRIM(TO_CHAR(sale_end_date, 'Month')) AS month_name
FROM staging.stg_abs_store_inventory_and_sale_items
WHERE sale_end_date IS NOT NULL;


--DIM_ITEMS
CREATE TABLE analytics.dim_items(
    item_key INTEGER PRIMARY KEY,
    code        TEXT UNIQUE NOT NULL,     -- natural key from the source
    description TEXT,
    size        TEXT
);

INSERT INTO analytics.dim_items
SELECT 
    ROW_NUMBER() OVER(ORDER BY code) AS item_key,
    code,
    description,
    size
FROM staging.stg_abs_store_inventory_and_sale_items;


--DIM_CATEGORY
CREATE TABLE analytics.dim_category(
    category_key INTEGER PRIMARY KEY,
    category TEXT
);

INSERT INTO analytics.dim_category
SELECT DISTINCT
    ROW_NUMBER() OVER(ORDER BY category) AS category_key,
    category
FROM staging.stg_abs_store_inventory_and_sale_items
GROUP BY category
ORDER BY ;


--FACT_ABS_STORE_INVENTORY_AND_SALE_ITEMS
CREATE TABLE analytics.fact_abs_store_inventory_and_sale_items(
    date_key INTEGER REFERENCES Analytics.dim_date(date_key),
    item_key INTEGER REFERENCES Analytics.dim_items(item_key),
    category_key INTEGER REFERENCES Analytics.dim_category(category_key),
    total_inventory NUMERIC,
    price NUMERIC,
    sale_price NUMERIC,
    on_sales BOOLEAN,
    stock_status TEXT
);

INSERT INTO analytics.fact_abs_store_inventory_and_sale_items
SELECT 
    d.date_key,
    i.item_key,
    c.category_key,
    a.total_inventory,
    a.price,
    a.sale_price,
    a.on_sales,
    a.stock_status
FROM staging.stg_abs_store_inventory_and_sale_items a
JOIN  analytics.dim_date d
    ON a.sale_end_date = d.full_date
JOIN analytics.dim_items i                  
    ON a.code = i.code  
JOIN analytics.dim_category c  
    ON a.category = c.category;