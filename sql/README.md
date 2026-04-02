# SQL

Contains schema and sample queries for Postgres.

## Files
- `create_tables.sql` — creates `users`, `loan_products`, `matches` tables with indexes
- `sample_queries.sql` — example queries to validate data

## Usage
```bash
psql -h <host> -U <user> -d <db> -f create_tables.sql
