# SQL Views — Interview Questions

A structured reference of theoretical questions, practice queries, and advanced topics for interview preparation.

---

## 1. Theoretical Questions

### 1.1 What is a View in SQL?

A view is a virtual table based on the result of a stored SQL query. It does not store data itself — the underlying query runs each time the view is accessed.

---

### 1.2 What is the difference between a View and a Table?

| Table | View |
|---|---|
| Stores actual data on disk | Stores a query definition, not data |
| Data must be maintained directly | Data is always derived from the underlying tables |
| Independent of other tables | Depends entirely on its base table(s) |
| Fully modifiable | Modifiable only under certain conditions |

---

### 1.3 What is the difference between `CREATE VIEW` and `CREATE OR REPLACE VIEW`?

| `CREATE VIEW` | `CREATE OR REPLACE VIEW` |
|---|---|
| Fails if the view already exists | Creates the view, or redefines it in place if it exists |
| Requires an explicit `DROP` before recreating | No need to drop first |
| No restriction, since it's a fresh definition | Generally can't drop, reorder, or retype existing output columns — only append new ones |

---

### 1.4 What does `ALTER VIEW` do?

Its behavior is database-specific:

- In **SQL Server** and **MySQL**, it redefines the view's query — similar to `CREATE OR REPLACE VIEW`.
- In **PostgreSQL**, it cannot change the underlying query at all — it only handles metadata changes such as renaming the view or changing its owner. Changing the query requires `CREATE OR REPLACE VIEW`.

---

### 1.5 What does `DROP VIEW` do, and does it affect the base table?

It permanently removes the view definition. It has **no effect** on the underlying base tables or their data — only the saved query is deleted.

---

### 1.6 What is `WITH CHECK OPTION` used for?

It ensures that rows inserted or updated through an updatable view still satisfy the view's `WHERE` clause, preventing a row from being modified into something the view would no longer show.

---

### 1.7 Can a View Be Updated?

Yes, but only under certain conditions. A view is generally updatable if it:

- Is based on a single table
- Does not use `GROUP BY`, `DISTINCT`, or aggregate functions
- Does not use `UNION`, `JOIN` across multiple tables, or subqueries in the `SELECT` list

Views involving joins or aggregations are typically read-only.

---

### 1.8 What is a Materialized View, and how is it different from a regular View?

A materialized view physically stores its query result on disk instead of recalculating it on every access — it's a distinct object from a standard view, not just a variant of one.

| View | Materialized View |
|---|---|
| No data stored | Data physically stored |
| Always reflects live data | Reflects data as of the last refresh |
| Slower for expensive underlying queries | Faster, since results are precomputed |
| Not indexable | Can be indexed like a table |
| No refresh needed | Requires manual or scheduled refresh |

---

### 1.9 How do you refresh a Materialized View?

```sql
REFRESH MATERIALIZED VIEW view_name;

-- PostgreSQL: refresh without blocking concurrent reads
REFRESH MATERIALIZED VIEW CONCURRENTLY view_name;
```

---

### 1.10 What are the advantages of using Views?

- Simplifies complex, repeated queries into a single reusable object
- Improves readability and maintainability of downstream queries
- Adds a security layer by restricting columns or rows
- Provides schema abstraction if underlying tables change
- Encapsulates business logic in a single, reusable place
- Eases collaboration between analysts and BI tools

---

### 1.11 What issues can arise from changes to the base table?

- A view built with `SELECT *` can silently break or misalign if the base table's columns are reordered, added, or dropped
- Changing a referenced column's data type is usually blocked, or invalidates the view
- Dropping or renaming a referenced column breaks any view that selects it
- Restructuring or dropping a base table cascades and breaks every view (and nested view) built on it

---

### 1.12 What are the limitations of Views in general?

- Standard views can be slower than querying base tables directly, since the underlying query re-runs each time
- Views with joins or aggregation are often not updatable
- Indexing options are limited compared to physical tables (except materialized views)
- Nesting views within views can make performance and debugging harder to reason about
- `CREATE OR REPLACE VIEW` can't drop, reorder, or retype existing columns

---

### 1.13 Can a View Be Used for Security Purposes?

Yes. Views can expose only specific columns or filtered rows to certain users, hiding sensitive data (like salaries or personal information) without altering the underlying table's permissions.

---

## 2. Real-World Use Cases

- Simplifying complex joins for reporting
- Restricting access to sensitive columns (e.g., salary, personal data)
- Powering BI dashboards with a stable data model
- Standardizing business logic across multiple queries and teams
- Presenting a simplified schema to end users or applications
- Speeding up expensive aggregate queries via materialized views

---

## 3. Practice Query Questions

| # | Question |
|---|---|
| Q1 | Create a view showing all employees with their department and salary. |
| Q2 | Create a view showing only employees with a salary greater than 70,000. |
| Q3 | Create a view showing the average salary per department. |
| Q4 | Create a view showing the highest-paid employee in each department. |
| Q5 | Create a view combining employee details with their department's employee count. |
| Q6 | Redefine an existing view to add a new column using `CREATE OR REPLACE VIEW`. |
| Q7 | Rename an existing view using `ALTER VIEW`. |
| Q8 | Create a view that hides the `Salary` column for a general-access user group. |
| Q9 | Create a view with `WITH CHECK OPTION` and show what happens on a violating update. |
| Q10 | Create a materialized view summarizing total salary cost per department. |
| Q11 | Refresh a materialized view after underlying data changes. |
| Q12 | Write a query to list all views that exist in the current database. |
| Q13 | Drop a view that is no longer needed, safely. |

---

## 4. Advanced Topics (Experienced Level)

- Why views involving joins or aggregation are usually not updatable
- How views affect query execution plans compared to querying base tables directly
- Difference between a view and a Common Table Expression (CTE)
- When to choose a materialized view over a regular view
- How indexing works with materialized views
- Performance implications of nesting views within views
- How permissions and access control interact with views
- Whether views can include window functions, and how that affects updatability
- Trade-offs between using views vs. building the logic directly into the application layer
- Why `SELECT *` inside a view is risky if the base table's schema changes
- What happens to a view when a column it depends on is dropped, renamed, or retyped