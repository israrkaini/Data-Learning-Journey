# SQL Materialized Views — Interview Questions

A structured reference of theoretical questions, practice queries, and advanced topics for interview preparation.

---

## 1. Theoretical Questions

### 1.1 What is a Materialized View?

A database object that physically stores the result of a query on disk, instead of recalculating it on every access like a standard view. It behaves like a snapshot that's fast to read but only as current as its last refresh.

---

### 1.2 How is a Materialized View different from a standard View?

| View | Materialized View |
|---|---|
| No data stored | Data physically stored |
| Always reflects live data | Reflects data as of the last refresh |
| Slower for expensive underlying queries | Faster, since results are precomputed |
| Cannot be indexed directly | Can be indexed like a table |
| No storage overhead | Consumes disk space |

---

### 1.3 Why would you choose a Materialized View over a regular View?

When the underlying query is expensive (heavy joins, aggregations, or window functions) and is run frequently, but the use case can tolerate the data being slightly out of date — e.g. a BI dashboard refreshed every 15 minutes rather than needing live numbers on every load.

---

### 1.4 How do you keep a Materialized View up to date?

By refreshing it — manually, on a schedule (e.g. via a cron job or orchestrator), or automatically, depending on what the database supports.

```sql
REFRESH MATERIALIZED VIEW view_name;
```

---

### 1.5 What is the difference between a complete refresh and an incremental (fast) refresh?

| Complete Refresh | Incremental / Fast Refresh |
|---|---|
| Recomputes the entire result set from scratch | Applies only the changes since the last refresh |
| Simple, no extra setup | Requires extra setup (e.g. materialized view logs) and has restrictions on qualifying queries |
| Can be expensive on large datasets | Cheaper on large datasets with small deltas |

---

### 1.6 What is `REFRESH MATERIALIZED VIEW CONCURRENTLY` (PostgreSQL), and why use it?

A refresh mode that rebuilds the materialized view without locking it against reads, so queries against it can continue during the refresh. It requires a unique index to already exist on the materialized view.

---

### 1.7 Can a Materialized View be indexed?

Yes — and this is one of its core advantages over a standard view. Because the data is physically stored, you can create indexes on it exactly like a regular table, speeding up filtered or sorted access.

---

### 1.8 What are the main risks of using Materialized Views?

- Staleness — reports can silently reflect outdated data if a refresh is missed or fails
- Refresh cost — a full refresh can be as expensive as the original query
- Storage overhead — the result set is duplicated on disk
- Locking during a non-concurrent refresh, which can block reads

---

### 1.9 Does PostgreSQL support incremental refresh?

No — PostgreSQL only supports complete (full) refreshes natively. Databases like Oracle support incremental/fast refresh via materialized view logs, and some managed platforms (e.g. Snowflake, BigQuery) offer native incremental refresh.

---

### 1.10 If a base table column that a Materialized View depends on is dropped or retyped, what happens?

The same as with a standard view — the materialized view breaks or is invalidated, since it can no longer guarantee its stored output matches the query definition. It typically needs to be dropped and recreated (or redefined) after the base table change.

---

### 1.11 What is `ON COMMIT` refresh, and which databases support it?

A refresh mode (available in databases like Oracle) where the materialized view refreshes automatically whenever the underlying data changes, keeping it always current at the cost of slower writes on the base tables.

---

## 2. Real-World Use Cases

- BI dashboards built on expensive aggregations
- Precomputed daily/monthly sales or cost rollups
- Denormalized reporting layers separate from a normalized transactional schema
- Caching results of slow, complex joins across large tables
- Data warehouse layers refreshed nightly or on a schedule

---

## 3. Practice Query Questions

| # | Question |
|---|---|
| Q1 | Create a materialized view summarizing total and average salary per department. |
| Q2 | Query the materialized view to confirm it returns the precomputed result. |
| Q3 | Add a new employee to the base table, then show that the materialized view is now stale. |
| Q4 | Refresh the materialized view so it reflects the new employee. |
| Q5 | Create a unique index required for a concurrent refresh. |
| Q6 | Refresh the materialized view concurrently (PostgreSQL). |
| Q7 | Create an index on the materialized view to speed up department lookups. |
| Q8 | Create a materialized view showing the highest-paid employee per department. |
| Q9 | Drop a materialized view that is no longer needed, safely. |
| Q10 | Write a query to list all materialized views in the current database. |

---

## 4. Advanced Topics (Experienced Level)

- Trade-offs between materialized views and a scheduled ETL job writing to a real table
- How to design a refresh schedule for materialized views feeding a production dashboard
- Handling failed or partial refreshes in a pipeline
- Materialized view logs and how they enable incremental refresh (Oracle-style)
- When a materialized view is the wrong choice (e.g. data requiring real-time accuracy)
- How to chain materialized views without compounding staleness or refresh cost
- Monitoring and alerting on materialized view refresh failures or staleness
- Storage and cost implications of materializing very large aggregations
- How materialized views interact with row-level security or access control
- Comparing materialized views to caching layers built outside the database (e.g. Redis, application-level caches)