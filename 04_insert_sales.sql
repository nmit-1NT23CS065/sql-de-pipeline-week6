-- Load cleaned sales facts and map customer codes to generated dimension IDs.
-- ON CONFLICT prevents duplicate source rows from being inserted on reruns.

INSERT INTO fact_sales (
    sale_id, sale_date, customer_id, product_name,
    quantity, unit_price, status
)
SELECT
    s.source_sale_id,
    s.sale_date,
    c.customer_id,
    s.product_name,
    s.quantity,
    s.unit_price,
    s.status
FROM staging_sales AS s
JOIN dim_customer AS c
  ON c.customer_code = s.customer_code
ON CONFLICT (sale_id, sale_date) DO UPDATE
SET customer_id = EXCLUDED.customer_id,
    product_name = EXCLUDED.product_name,
    quantity = EXCLUDED.quantity,
    unit_price = EXCLUDED.unit_price,
    status = EXCLUDED.status;

SELECT COUNT(*) AS fact_sales_row_count FROM fact_sales;
