-- Bulk load sample CSV into the staging table.
-- Edit the absolute path for your computer. PostgreSQL server-side COPY
-- requires the database server process to be able to read the file.
-- Easier alternative: use the psql \copy command shown in README.md.

COPY staging_sales (
    source_sale_id, sale_date, customer_code, customer_name, email,
    product_name, quantity, unit_price, status
)
FROM '/absolute/path/to/sql-de-pipeline-week6/data/sales_input.csv'
WITH (FORMAT csv, HEADER true);

-- Check imported rows before continuing.
SELECT COUNT(*) AS staging_row_count FROM staging_sales;
SELECT * FROM staging_sales ORDER BY source_sale_id;
