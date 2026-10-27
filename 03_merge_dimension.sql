-- MERGE: update customer details when the customer exists; insert otherwise.
-- If a customer appears multiple times in staging, use the latest source row
-- per customer_code so that each target row matches at most one source row.

MERGE INTO dim_customer AS target
USING (
    SELECT DISTINCT ON (customer_code)
           customer_code, customer_name, email
    FROM staging_sales
    ORDER BY customer_code, sale_date DESC, source_sale_id DESC
) AS source
ON target.customer_code = source.customer_code
WHEN MATCHED AND (
       target.customer_name IS DISTINCT FROM source.customer_name
    OR target.email IS DISTINCT FROM source.email
) THEN
    UPDATE SET
        customer_name = source.customer_name,
        email = source.email,
        updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
    INSERT (customer_code, customer_name, email)
    VALUES (source.customer_code, source.customer_name, source.email);

-- Review the resulting dimension.
SELECT customer_id, customer_code, customer_name, email, updated_at
FROM dim_customer
ORDER BY customer_code;
