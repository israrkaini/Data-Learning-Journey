# SQL Window Functions

A complete reference guide to understanding and using window functions in SQL.

---

## 1. Overview

### 1.1 What Are Window Functions?

Window functions are SQL functions that perform calculations across a set of rows related to the current row — **without reducing the number of rows returned**.

Unlike `GROUP BY`, which collapses multiple rows into a single summarized result, window functions preserve every row while adding analytical calculations such as rankings, running totals, averages, and row-to-row comparisons.

### 1.2 Key Characteristics

| Characteristic | Description |
|---|---|
| Row preservation | Every original row remains in the output |
| Requires `OVER()` | The `OVER()` clause defines the "window" of rows |
| Partitioning | `PARTITION BY` splits data into logical groups |
| Ordering | `ORDER BY` controls row sequence within a partition |

---

## 2. Syntax

```sql
function_name(expression)
OVER (
    [PARTITION BY column_name]
    [ORDER BY column_name]
)
```

### 2.1 Syntax Components

| Component | Description |
|---|---|
| `function_name()` | The window function to execute (e.g., `ROW_NUMBER()`, `RANK()`, `SUM()`) |
| `OVER()` | Defines the window over which the function operates |
| `PARTITION BY` | Divides rows into logical groups *(optional)* |
| `ORDER BY` | Specifies row order within each partition *(optional for some functions, required for ranking functions)* |

---

## 3. Introductory Example

**Goal:** Display each employee alongside the average salary of their department.

```sql
SELECT
    EmployeeName,
    Department,
    Salary,
    AVG(Salary) OVER (PARTITION BY Department) AS DepartmentAverage
FROM Employees;
```

**Output:**

| Employee | Department | Salary | DepartmentAverage |
|---|---|---:|---:|
| Ali | IT | 65,000 | 80,833 |
| Sara | IT | 85,000 | 80,833 |
| Usman | IT | 90,000 | 80,833 |

> **Note:** All employee records remain in the result — unlike `GROUP BY`, no rows are collapsed.

---

## 4. Major Window Functions

### 4.1 `ROW_NUMBER()`

Assigns a **unique sequential number** to each row based on the specified ordering. Even when two rows share the same value, each still receives a different number.

**Syntax**

```sql
ROW_NUMBER() OVER (ORDER BY Salary DESC)
```

**Example**

```sql
SELECT
    EmployeeName,
    Salary,
    ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNumber
FROM Employees;
```

**Use Cases**

- Pagination
- Removing duplicate records
- Assigning serial numbers
- Finding the Top N records

---

### 4.2 `LAG()` and `LEAD()`

#### `LAG()`

Returns the value from a **previous row** within the same result set.

```sql
SELECT
    EmployeeName,
    Salary,
    LAG(Salary) OVER (ORDER BY HireDate) AS PreviousSalary
FROM Employees;
```

#### `LEAD()`

Returns the value from the **next row** within the same result set.

```sql
SELECT
    EmployeeName,
    Salary,
    LEAD(Salary) OVER (ORDER BY HireDate) AS NextSalary
FROM Employees;
```

**Use Cases**

- Month-over-month comparisons
- Comparing current and previous values
- Time-series analysis
- Trend analysis

---

### 4.3 `RANK()` and `DENSE_RANK()`

Both functions assign rankings based on the specified ordering, but they treat tied values differently.

#### `RANK()`

Rows with the same value receive the same rank, **leaving gaps** afterward.

```text
95,000 → Rank 1
90,000 → Rank 2
90,000 → Rank 2
85,000 → Rank 4
```

```sql
SELECT
    EmployeeName,
    Salary,
    RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
FROM Employees;
```

#### `DENSE_RANK()`

Rows with the same value receive the same rank, **without leaving gaps**.

```text
95,000 → Rank 1
90,000 → Rank 2
90,000 → Rank 2
85,000 → Rank 3
```

```sql
SELECT
    EmployeeName,
    Salary,
    DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
FROM Employees;
```

#### When to Use Which

| Function | Best Used For |
|---|---|
| `ROW_NUMBER()` | Unique numbering |
| `RANK()` | Competition-style ranking |
| `DENSE_RANK()` | Finding nth-highest values |

---

### 4.4 Aggregate Window Functions

Standard aggregate functions can also act as window functions when combined with `OVER()`. Common ones include:

- `SUM()`
- `AVG()`
- `COUNT()`
- `MIN()`
- `MAX()`

#### Example: Department Average Salary

```sql
SELECT
    EmployeeName,
    Department,
    Salary,
    AVG(Salary) OVER (PARTITION BY Department) AS DepartmentAverage
FROM Employees;
```

#### Example: Running Total

```sql
SELECT
    EmployeeName,
    HireDate,
    Salary,
    SUM(Salary) OVER (ORDER BY HireDate) AS RunningTotal
FROM Employees;
```

#### Example: Employee Count per Department

```sql
SELECT
    EmployeeName,
    Department,
    COUNT(*) OVER (PARTITION BY Department) AS EmployeeCount
FROM Employees;
```

**Common Use Cases**

- Running totals
- Department-wise averages
- Employee counts
- Maximum and minimum values
- Cumulative calculations
- Dashboard reporting

---

## 5. Summary

Window functions are powerful analytical tools that perform calculations across related rows while preserving the original result set. They are commonly used for ranking, cumulative calculations, row-to-row comparisons, and reporting — making them essential for writing efficient SQL queries in analytics, reporting, and real-world business scenarios.