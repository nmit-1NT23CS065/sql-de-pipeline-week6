-- SQL Week 6: schema setup
-- PostgreSQL 15+

DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS staging_sales CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;

CREATE TABLE dim_customer (
    customer_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_code    VARCHAR(20) NOT NULL UNIQUE,
    customer_name    VARCHAR(100) NOT NULL,
    email            VARCHAR(150),
    updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Raw landing/staging table. CSV values are loaded here before transformation.
CREATE TABLE staging_sales (
    source_sale_id   BIGINT NOT NULL,
    sale_date        DATE NOT NULL,
    customer_code    VARCHAR(20) NOT NULL,
    customer_name    VARCHAR(100) NOT NULL,
    email            VARCHAR(150),
    product_name     VARCHAR(100) NOT NULL,
    quantity         INTEGER NOT NULL CHECK (quantity > 0),
    unit_price       NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    status           VARCHAR(20) NOT NULL
);

-- Partitioned fact table. The primary key includes the partition key.
CREATE TABLE fact_sales (
    sale_id          BIGINT NOT NULL,
    sale_date        DATE NOT NULL,
    customer_id      BIGINT NOT NULL REFERENCES dim_customer(customer_id),
    product_name     VARCHAR(100) NOT NULL,
    quantity         INTEGER NOT NULL CHECK (quantity > 0),
    unit_price       NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    total_amount     NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    status           VARCHAR(20) NOT NULL,
    loaded_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (sale_id, sale_date)
) PARTITION BY RANGE (sale_date);

-- Monthly range partitions for the example period.
CREATE TABLE fact_sales_2026_01 PARTITION OF fact_sales
    FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE fact_sales_2026_02 PARTITION OF fact_sales
    FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
CREATE TABLE fact_sales_2026_03 PARTITION OF fact_sales
    FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');

-- Catch dates outside the explicitly defined monthly partitions.
CREATE TABLE fact_sales_default PARTITION OF fact_sales DEFAULT;
