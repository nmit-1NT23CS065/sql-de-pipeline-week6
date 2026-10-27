-- 1. Monthly sales summary (partition pruning can apply on date filters).
SELECT date_trunc('month', sale_date)::date AS sales_month,
       COUNT(*) AS transaction_count,
       SUM(total_amount) AS revenue
FROM fact_sales
WHERE sale_date >= DATE '2026-01-01'
  AND sale_date <  DATE '2026-04-01'
GROUP BY 1
ORDER BY 1;

-- 2. Customer-specific sales in a date range (composite index pattern).
SELECT c.customer_code, c.customer_name,
       f.sale_date, f.product_name, f.quantity, f.total_amount
FROM fact_sales AS f
JOIN dim_customer AS c ON c.customer_id = f.customer_id
WHERE f.customer_id = (
    SELECT customer_id FROM dim_customer WHERE customer_code = 'C001'
)
  AND f.sale_date >= DATE '2026-01-01'
  AND f.sale_date <  DATE '2026-04-01'
ORDER BY f.sale_date;

-- 3. Pending transactions (matches the partial-index predicate).
SELECT sale_id, sale_date, product_name, total_amount, status
FROM fact_sales
WHERE status = 'PENDING'
ORDER BY sale_date;

-- 4. Basic pipeline row counts.
SELECT 'staging_sales' AS table_name, COUNT(*) AS row_count FROM staging_sales
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM fact_sales;

-- 5. Show which partition contains each row.
SELECT tableoid::regclass AS partition_name, COUNT(*) AS row_count
FROM fact_sales
GROUP BY tableoid
ORDER BY partition_name::text;

-- 6. Optional: inspect query plans. With tiny sample data, PostgreSQL may
-- prefer a sequential scan; larger datasets make index benefits easier to see.
EXPLAIN (ANALYZE, BUFFERS)
SELECT sale_id, sale_date, total_amount
FROM fact_sales
WHERE status = 'PENDING'
  AND sale_date >= DATE '2026-01-01'
  AND sale_date < DATE '2026-04-01';
