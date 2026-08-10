# SQL Views

A complete reference guide to understanding and using views in SQL.

---

## 1. Overview

### 1.1 What Is a View?

A view is a **virtual table** based on the result of a stored SQL query. It does not store data itself — it stores the query definition, and the underlying data is computed each time the view is queried.

Views let you save a complex query once and reuse it like a regular table, without duplicating data or rewriting logic repeatedly.

### 1.2 Key Characteristics

| Characteristic | Description |
|---|---|
| Virtual, not physical | A view holds no data of its own — it re-runs its defining query on access |
| Reusability | Complex joins, filters, and calculations can be saved once and reused |
| Abstraction | Hides underlying table structure and complexity from end users |
| Security | Can expose only specific columns or rows, restricting access to sensitive data |
| Always current | Reflects the latest data in the underlying tables at query time |

---

## 2. Introductory Example

**Goal:** Create a reusable view showing IT department employees along with their department average salary.

```sql
CREATE VIEW ITDepartmentSummary AS
SELECT
    EmployeeName,
    JobTitle,
    Salary,
    AVG(Salary) OVER (PARTITION BY Department) AS DepartmentAverage
FROM Employees
WHERE Department = 'IT';
```

**Usage:**

```sql
SELECT * FROM ITDepartmentSummary;
```

> Once created, the view can be queried exactly like a table — without repeating the underlying join, filter, or window-function logic every time.

---

## 3. Managing Views (DDL Operations)

### 3.1 `CREATE VIEW`

Defines a new view from a query.

```sql
CREATE VIEW view_name AS
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

Fails with an error if a view with the same name already exists.

---

### 3.2 `CREATE OR REPLACE VIEW`

Creates the view if it doesn't exist, or redefines it in place if it does — without needing to drop it first. Existing permissions and dependent objects are generally preserved.

```sql
CREATE OR REPLACE VIEW HighEarners AS
SELECT EmployeeName, Department, Salary, JobTitle
FROM Employees
WHERE Salary > 70000;
```

> **Restriction:** most databases only allow this if the new query keeps all originally defined columns, in the same order, with the same names and data types. You can typically append new columns at the end, but you can't remove, reorder, or retype existing ones this way — that requires `DROP` and re-`CREATE`.

---

### 3.3 `ALTER VIEW`

Support and behavior vary by database:

- **SQL Server / MySQL:** `ALTER VIEW` redefines the view's query, similar to `CREATE OR REPLACE VIEW`.

```sql
-- SQL Server / MySQL
ALTER VIEW HighEarners AS
SELECT EmployeeName, Department, Salary
FROM Employees
WHERE Salary > 80000;
```

- **PostgreSQL:** `ALTER VIEW` cannot change the underlying query — it's used for metadata operations like renaming or changing ownership. Changing the query itself requires `CREATE OR REPLACE VIEW`.

```sql
-- PostgreSQL: rename a view
ALTER VIEW HighEarners RENAME TO TopEarners;

-- PostgreSQL: change owner
ALTER VIEW TopEarners OWNER TO analytics_team;
```

---

### 3.4 `DROP VIEW`

Permanently removes a view definition. It does not affect the underlying base tables or their data.

```sql
DROP VIEW view_name;

-- Avoid an error if the view may not exist
DROP VIEW IF EXISTS view_name;
```

---

### 3.5 `WITH CHECK OPTION`

Enforces that any `INSERT` or `UPDATE` made through an updatable view must still satisfy the view's `WHERE` clause — preventing rows from being changed into ones the view itself wouldn't show.

```sql
CREATE VIEW HighEarners AS
SELECT EmployeeName, Department, Salary
FROM Employees
WHERE Salary > 70000
WITH CHECK OPTION;

-- This fails, because 60000 doesn't satisfy Salary > 70000
UPDATE HighEarners SET Salary = 60000 WHERE EmployeeName = 'Ali Khan';
```

---

### 3.6 Inspecting View Definitions

```sql
-- PostgreSQL / general
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public';

-- MySQL
SHOW CREATE VIEW HighEarners;

-- SQL Server
SELECT name FROM sys.views;
sp_helptext 'HighEarners';
```

---

## 4. Materialized Views

A materialized view is a **fundamentally different object** from a standard view — it is not just a "type" of view, but a separate concept that trades data freshness for performance.

| | Standard View | Materialized View |
|---|---|---|
| Data storage | None — re-runs the query each time | Physically stores the query result on disk |
| Freshness | Always current | Current only as of the last refresh |
| Performance | Cost paid on every access | Fast reads; cost paid only during refresh |
| Indexing | Not directly indexable | Can be indexed like a table |
| Best for | Lightweight, frequently-changing data | Expensive aggregations queried often, tolerant of some staleness |

### 4.1 Creating a Materialized View

```sql
CREATE MATERIALIZED VIEW DepartmentSalaryCost AS
SELECT
    Department,
    SUM(Salary) AS TotalSalaryCost,
    COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY Department;
```

### 4.2 Refreshing a Materialized View

Because the data is physically stored, it goes stale as soon as the base tables change — it must be refreshed explicitly (or on a schedule) to stay current.

```sql
REFRESH MATERIALIZED VIEW DepartmentSalaryCost;

-- PostgreSQL: refresh without blocking reads (requires a unique index on the view)
REFRESH MATERIALIZED VIEW CONCURRENTLY DepartmentSalaryCost;
```

### 4.3 Dropping a Materialized View

```sql
DROP MATERIALIZED VIEW IF EXISTS DepartmentSalaryCost;
```

---

## 5. Advantages of Views

- **Simplifies complex logic** — a multi-join, multi-filter query gets written once, then reused with a simple `SELECT * FROM view_name`.
- **Improves readability and maintainability** — business logic lives in one place instead of being copy-pasted across dozens of reports and scripts.
- **Adds a security layer** — a view can expose only approved columns or rows (e.g. hiding `Salary`), so you grant access to the view instead of the sensitive base table.
- **Provides schema abstraction** — if a base table's internal structure changes, the view can often be redefined once to keep every downstream query working unchanged.
- **Encapsulates business rules** — calculations like "active employee" or "high earner" are defined once in the view, removing the risk of two teams implementing the same rule differently.
- **Eases collaboration** — analysts and BI tools can query a clean, well-named view instead of needing to understand the full underlying schema.

---

## 6. Common Issues and Limitations

Views are convenient, but because they are just a saved query pointing at live tables, they are sensitive to changes in those tables.

- **`SELECT *` and column order** — a view defined with `SELECT *` binds to the base table's column order in some databases (e.g. PostgreSQL) at creation time. If you later add, drop, or reorder columns on the base table, the view can silently return wrong or misaligned data, or break entirely. Always list columns explicitly in a view's definition to avoid this.
- **Changing a base column's data type** — most databases will block the change (or invalidate the view) if a view depends on that column, since the view's output type contract can no longer be guaranteed.
- **Dropping or renaming a referenced column** — immediately breaks any view that selects it; the view either errors on next use or, in some databases, is marked invalid until redefined.
- **`CREATE OR REPLACE VIEW` column restrictions** — as noted in §3.2, you typically can't drop, reorder, or retype existing output columns this way; doing so requires a full `DROP` and `CREATE`.
- **Performance cost** — a standard view re-executes its underlying query on every access. A view built on top of other views (nested views) can compound this cost significantly.
- **Limited updatability** — views involving joins, aggregation, `DISTINCT`, or `GROUP BY` are generally read-only; only simple, single-table views without these are updatable in most databases.
- **Stale data in materialized views** — because the data is physically stored, forgetting to refresh a materialized view means downstream reports silently work off outdated numbers.
- **Cascading breakage** — dropping or restructuring a base table can break every view built on it, and every view built on those views, so dependency chains need to be tracked deliberately.

---

## 7. Common Use Cases

- Simplifying complex, repeated joins and calculations
- Restricting access to sensitive columns or rows (security layer)
- Providing a stable, simplified interface over a changing schema
- Powering BI dashboards and reports with a consistent data model
- Encapsulating business logic in one reusable place
- Improving query readability and maintainability

---

## 8. Summary

Views are a foundational SQL tool for reusability, abstraction, and security. A standard view acts as a saved query that always reflects live data, while a materialized view is a distinct object that trades that freshness for performance by physically storing results. Understanding how to create, redefine, and drop views correctly — and being aware of how base-table schema changes can silently break them — is essential for building clean, maintainable, and secure data models.