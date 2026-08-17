# SQL Materialized Views

A complete reference guide to understanding and using materialized views in SQL.

---

## 1. Overview

### 1.1 What Is a Materialized View?

A materialized view is a **database object that physically stores the result of a query** on disk, rather than recalculating it on every access like a standard view.

It behaves like a snapshot: fast to read, but only as current as its last refresh. This makes it a deliberate trade-off — you give up real-time freshness in exchange for performance on expensive, repeatedly-run queries.

### 1.2 How It Differs From a Standard View

| | Standard View | Materialized View |
|---|---|---|
| Data storage | None — re-runs the query each time | Physically stores the query result |
| Freshness | Always current | Current only as of the last refresh |
| Read performance | Cost paid on every access | Fast; cost paid only during refresh |
| Indexing | Not directly indexable | Can be indexed like a regular table |
| Storage cost | Minimal | Consumes disk space proportional to the result set |
| Best for | Lightweight or frequently-changing data | Expensive aggregations, queried often, tolerant of some staleness |

---

## 2. Syntax

### 2.1 Creating a Materialized View

```sql
CREATE MATERIALIZED VIEW view_name AS
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

### 2.2 Example

**Goal:** Precompute total salary cost and headcount per department, since this aggregation is queried on every dashboard load.

```sql
CREATE MATERIALIZED VIEW DepartmentSalaryCost AS
SELECT
    Department,
    SUM(Salary) AS TotalSalaryCost,
    COUNT(*) AS EmployeeCount,
    AVG(Salary) AS AvgSalary
FROM Employees
GROUP BY Department;
```

```sql
SELECT * FROM DepartmentSalaryCost;
```

> Unlike a standard view, this query is **not** re-executed against `Employees` on every read — it reads the stored snapshot instead.

---

## 3. Refreshing a Materialized View

Because the data is physically stored, it goes stale the moment the base tables change. It must be refreshed — manually, on a schedule, or automatically, depending on the database.

### 3.1 Manual Refresh

```sql
REFRESH MATERIALIZED VIEW DepartmentSalaryCost;
```

### 3.2 Concurrent Refresh (PostgreSQL)

By default, `REFRESH MATERIALIZED VIEW` locks the view against reads while it rebuilds. `CONCURRENTLY` avoids this, at the cost of requiring a unique index on the view first.

```sql
CREATE UNIQUE INDEX idx_dept_salary_cost ON DepartmentSalaryCost (Department);

REFRESH MATERIALIZED VIEW CONCURRENTLY DepartmentSalaryCost;
```

### 3.3 Refresh Strategies

| Strategy | Description |
|---|---|
| **Complete refresh** | Recomputes the entire result set from scratch. Simple, but expensive on large data. |
| **Incremental / fast refresh** | Applies only the changes since the last refresh (supported natively in databases like Oracle via materialized view logs). Cheaper, but requires extra setup and has more restrictions on what queries qualify. |
| **On-demand refresh** | Triggered manually or by an external job/scheduler (e.g. a cron job, Airflow DAG, or `pg_cron`). |
| **On-commit refresh** | Refreshes automatically whenever the underlying data changes (supported in some databases, e.g. Oracle's `ON COMMIT`) — trades write performance for always-fresh reads. |

> **Note:** PostgreSQL only supports full (complete) refreshes natively — there's no built-in incremental refresh, so large materialized views can be expensive to refresh frequently. Oracle and some managed platforms (e.g. Snowflake, BigQuery) support incremental refresh natively.

---

## 4. Indexing a Materialized View

Because a materialized view physically stores data, it can be indexed just like a regular table — something a standard view cannot do.

```sql
CREATE INDEX idx_dept_salary ON DepartmentSalaryCost (Department);
```

This is one of the biggest practical advantages over a standard view: repeated filtered lookups against the materialized result can be as fast as querying an indexed table.

---

## 5. Dropping a Materialized View

```sql
DROP MATERIALIZED VIEW IF EXISTS DepartmentSalaryCost;
```

This removes only the stored snapshot and its definition — the underlying base tables and their data are untouched.

---

## 6. Advantages

- **Performance** — expensive joins, aggregations, or window-function calculations are computed once at refresh time, not on every read.
- **Reduced load on source systems** — dashboards and reports hit the materialized snapshot instead of repeatedly hammering large base tables.
- **Indexable** — supports its own indexes, enabling fast filtered or sorted access.
- **Predictable query cost** — read performance no longer depends on the complexity of the underlying query, only on the size of the stored result.
- **Good fit for reporting/BI** — most dashboards can tolerate data being a few minutes or hours old in exchange for speed.

---

## 7. Limitations and Issues

- **Staleness** — data is only as current as the last refresh; forgetting to refresh (or a failed scheduled job) means reports silently work off outdated numbers.
- **Refresh cost** — a full refresh re-runs the entire underlying query, which can be as expensive as the query it's meant to optimize, especially without incremental refresh support.
- **Storage overhead** — the result set is physically duplicated on disk, unlike a standard view.
- **Locking during refresh** — a non-concurrent refresh can block reads while it rebuilds (mitigated in PostgreSQL via `CONCURRENTLY`, but that requires a unique index).
- **Base table changes still cascade** — dropping or retyping a column the materialized view depends on breaks it, the same as a standard view.
- **Limited incremental refresh support** — not all databases support fast/incremental refresh, so keeping large materialized views current can require careful scheduling.
- **Not always the right tool** — for data that must be real-time accurate (e.g. account balances), a materialized view's staleness window can be a real correctness problem, not just a minor delay.

---

## 8. Common Use Cases

- BI dashboards and reports built on expensive aggregations
- Precomputed rollups (daily/monthly sales summaries, department cost totals)
- Denormalized read models for reporting, separate from a normalized transactional schema
- Caching results of slow, complex joins across large tables
- Data warehouse layers where some staleness (e.g. refreshed nightly) is acceptable

---

## 9. Summary

A materialized view trades real-time freshness for read performance by physically storing a query's result and refreshing it on a schedule or on demand. It's the right tool when a query is expensive, run frequently, and can tolerate being slightly out of date — but it introduces its own operational concerns: refresh scheduling, storage cost, and the risk of silently stale data if refreshes are missed.