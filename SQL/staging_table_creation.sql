BEGIN;

DROP TABLE IF EXISTS staging.stg_abs_store_inventory_and_sale_items;

CREATE TABLE staging.stg_abs_store_inventory_and_sale_items (
    code            TEXT PRIMARY KEY,
    category        TEXT,
    description     TEXT,
    size            TEXT,
    total_inventory NUMERIC(12,2),
    price           NUMERIC(10,2),
    sale_price      NUMERIC(10,2),
    sale_end_date   DATE,
    on_sales        BOOLEAN,
    stock_status    TEXT
);

INSERT INTO staging.stg_abs_store_inventory_and_sale_items
    (code, category, description, size, total_inventory,
     price, sale_price, sale_end_date, on_sales, stock_status)
SELECT
    code,
    category,
    description,
    size,
    total_inventory,
    price,
    sale_price,
    sale_end_date::DATE,
    on_sales,
    CASE
        WHEN total_inventory = 0   THEN 'Zero'
        WHEN total_inventory < 100 THEN 'Low'
        ELSE 'Healthy'
    END
FROM raw.abs_store_inventory_and_sale_items;

COMMIT;

