# SQL DE Pipeline — Week 6

A hands-on PostgreSQL project demonstrating **MERGE on a dimension table, range partitioning, COPY bulk loading, composite indexes, and partial indexes** using a small sales analytics pipeline.

## Project scenario

A retail business receives daily sales transactions in CSV files. The pipeline bulk-loads the raw data into a staging table, maintains a customer dimension with `MERGE`, inserts sales into a date-range-partitioned fact table, and creates indexes for common analytical queries.

## Concepts demonstrated

1. **`COPY` bulk load** — import CSV rows into a staging table efficiently.
2. **`MERGE` dimension table** — update existing customers and insert new customers from staging data.
3. **Range partitioning** — split sales facts by month using `sale_date`.
4. **Composite index** — speed up queries filtering by customer and date.
5. **Partial index** — index only pending transactions, reducing index size for a common targeted query.

## Requirements

- PostgreSQL **15 or later** (`MERGE` was added in PostgreSQL 15)
- `psql` command-line client, or a PostgreSQL GUI such as pgAdmin

## Repository structure

```text
sql-de-pipeline-week6/
├── README.md
├── data/
│   └── sales_input.csv
├── sql/
│   ├── 01_schema.sql
│   ├── 02_load_csv.sql
│   ├── 03_merge_dimension.sql
│   ├── 04_insert_sales.sql
│   ├── 05_indexes.sql
│   └── 06_validation_queries.sql
└── outputs/
    └── .gitkeep
```

## Run the project

### Option A — using `psql`

1. Create an empty database, for example `sql_pipeline_week6`.
2. Open a terminal in this repository folder and connect:

   ```bash
   psql -U postgres -d sql_pipeline_week6
   ```

3. Run the schema script:

   ```sql
   \i sql/01_schema.sql
   ```

4. Load the sample CSV. **Important:** the `COPY` command in `02_load_csv.sql` uses PostgreSQL server-side file access. If PostgreSQL cannot access your local file, use the `\copy` alternative below.

   ```sql
   \i sql/02_load_csv.sql
   \i sql/03_merge_dimension.sql
   \i sql/04_insert_sales.sql
   \i sql/05_indexes.sql
   \i sql/06_validation_queries.sql
   ```

### Option B — easiest local CSV import with `\copy`

In `psql`, first run `sql/01_schema.sql`. Then run the following from the **repository root** in the `psql` prompt:

```sql
\copy staging_sales (source_sale_id, sale_date, customer_code, customer_name, email, product_name, quantity, unit_price, status) FROM 'data/sales_input.csv' WITH (FORMAT csv, HEADER true)
```

Then run `03_merge_dimension.sql`, `04_insert_sales.sql`, `05_indexes.sql`, and `06_validation_queries.sql` in that order. Skip `02_load_csv.sql` if you used `\copy`, since the same rows have already been loaded.

> `COPY` reads files from the database server's filesystem and may require elevated file permissions. `\copy` is a `psql` client command that reads the file from your computer and is usually easier for student projects.

## Expected workflow

```text
CSV file → staging_sales → MERGE → dim_customer
                           └──────→ fact_sales (monthly partitions)
                                      ↓
                             composite + partial indexes
                                      ↓
                             validation / analytics queries
```

## Sample analysis queries

The validation script includes:
- total sales by month
- sales by customer over a date range
- pending transactions using the partial index predicate
- row counts for the dimension, staging table, and partitioned fact table
- a partition inspection query

## Notes

- The sample data is synthetic and intended for learning.
- The scripts are designed to be run in order in a **fresh database**.
- The example creates monthly partitions for January–March 2026 plus a default partition for dates outside those months.
- `EXPLAIN` output can vary depending on PostgreSQL version, table statistics, and data volume. The sample dataset is small, so an index may not always be selected by the query planner; the scripts still demonstrate the index definitions and predicates correctly.

## Learning outcomes

After running the project, you should be able to explain how staging tables support ETL, how `MERGE` performs insert/update logic, how range partitions organize large fact tables, and how composite and partial indexes can support common query patterns.
