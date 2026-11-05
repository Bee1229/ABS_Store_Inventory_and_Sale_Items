DROP TABLE IF EXISTS "abs_store_inventory_and_sale_items";

CREATE TABLE IF NOT EXISTS raw."abs_store_inventory_and_sale_items"(
	code VARCHAR PRIMARY KEY,
	category TEXT,
	description TEXT,
	size VARCHAR,
	total_inventory FLOAT,
	price FLOAT,
	sale_price FLOAT,
	sale_end_date DATE,
	on_sales BOOL,
	stock_status TEXT);


SELECT *
FROM raw."abs_store_inventory_and_sale_items";