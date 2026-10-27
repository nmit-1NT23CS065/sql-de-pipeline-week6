-- Composite index: supports queries filtering by customer and date.
CREATE INDEX IF NOT EXISTS idx_fact_sales_customer_date
    ON fact_sales (customer_id, sale_date);

-- Partial index: stores entries only for pending sales.
CREATE INDEX IF NOT EXISTS idx_fact_sales_pending_date
    ON fact_sales (sale_date)
    WHERE status = 'PENDING';

-- A second useful composite index for product analysis.
CREATE INDEX IF NOT EXISTS idx_fact_sales_product_date
    ON fact_sales (product_name, sale_date);

-- Inspect the indexes created on the partitioned parent and its partitions.
SELECT schemaname, tablename, indexname, indexdef
FROM pg_indexes
WHERE tablename LIKE 'fact_sales%'
ORDER BY tablename, indexname;
