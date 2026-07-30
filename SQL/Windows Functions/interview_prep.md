# SQL Window Functions — Interview Questions

A structured reference of theoretical questions, practice queries, and advanced topics for interview preparation.

---

## 1. Theoretical Questions

### 1.1 What is a Window Function?

A window function performs calculations across a set of related rows while preserving every row in the result set. Unlike `GROUP BY`, it does not collapse multiple rows into a single row.

---

### 1.2 What is the difference between `GROUP BY` and Window Functions?

| GROUP BY | Window Functions |
|---|---|
| Reduces multiple rows into one row per group | Preserves all rows |
| Used for summarization | Used for analytics and reporting |
| Cannot access individual row values after grouping | Can access both individual rows and aggregated values |

---

### 1.3 What is the purpose of the `OVER()` clause?

The `OVER()` clause defines the window (set of rows) over which a window function performs its calculation. Every window function must use the `OVER()` clause.

---

### 1.4 What is `PARTITION BY`?

`PARTITION BY` divides the result set into logical groups. The window function is then applied independently to each partition.

**Example uses:**

- Rank employees within each department
- Calculate average salary per department

---

### 1.5 What is the purpose of `ORDER BY` in Window Functions?

`ORDER BY` determines the sequence of rows within a partition. Ranking functions such as `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()` require it.

---

### 1.6 Difference between `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`

| Function | Duplicate Values | Gap in Ranking |
|---|---|---|
| `ROW_NUMBER()` | No | No |
| `RANK()` | Yes | Yes |
| `DENSE_RANK()` | Yes | No |

---

### 1.7 What is the difference between `LEAD()` and `LAG()`?

| Function | Purpose |
|---|---|
| `LAG()` | Returns a value from the previous row |
| `LEAD()` | Returns a value from the next row |

---

### 1.8 Can aggregate functions be used as Window Functions?

Yes. Aggregate functions such as `SUM()`, `AVG()`, `COUNT()`, `MIN()`, and `MAX()` can be converted into window functions by using the `OVER()` clause.

---

### 1.9 When should you use Window Functions instead of `GROUP BY`?

Use window functions when you need aggregated values while still displaying every row in the result — for example:

- Displaying employee salary alongside the department average
- Ranking employees within each department
- Calculating cumulative sales

---

## 2. Real-World Use Cases

- Ranking employees
- Running totals
- Sales analysis
- Leaderboards
- Financial reporting
- Trend analysis
- Year-over-Year (YoY) comparison
- Month-over-Month (MoM) comparison
- Top N analysis
- Finding duplicate records
- Moving averages

---

## 3. Practice Query Questions

| # | Question |
|---|---|
| Q1 | Display employees along with a unique row number ordered by salary (highest first). |
| Q2 | Rank employees by salary using `RANK()`. |
| Q3 | Rank employees using `DENSE_RANK()`. |
| Q4 | Display the top 3 highest-paid employees in each department. |
| Q5 | Find the second-highest salary in each department. |
| Q6 | Display each employee along with the average salary of their department. |
| Q7 | Calculate the running total of employee salaries based on hire date. |
| Q8 | Display each employee's previous salary using `LAG()`. |
| Q9 | Display each employee's next salary using `LEAD()`. |
| Q10 | Compare each employee's salary with the average salary of their department. |
| Q11 | Find employees earning more than the average salary of their department. |
| Q12 | Display the first employee hired in each department. |
| Q13 | Display the most recently hired employee in each department. |
| Q14 | Divide employees into four salary groups using `NTILE(4)`. |
| Q15 | Find the employee with the highest salary in each department without using a subquery. |

---

## 4. Advanced Topics (Experienced Level)

- Execution order of window functions
- Using multiple window functions in a single query
- Whether window functions can be used in the `WHERE` clause, and why
- Difference between `ROWS` and `RANGE` in window functions
- Performance impact of window functions
- Choosing a CTE over a window function
- Whether window functions can be nested
- What a window frame is
- `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` explained
- Optimizing queries that use multiple window functions