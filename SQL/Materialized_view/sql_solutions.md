# SQL Materialized Views — Practice Solutions

Solutions to the 10 practice questions, using the same `Employees` dataset (30 rows, 5 departments) used in the window functions and views exercises. Syntax shown is PostgreSQL unless noted.

---

## 0. Dataset

```sql
CREATE TABLE Employees (
    EmployeeID   INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Department   VARCHAR(50),
    JobTitle     VARCHAR(100),
    Salary       DECIMAL(10, 2),
    HireDate     DATE
);

INSERT INTO Employees
(EmployeeID, EmployeeName, Department, JobTitle, Salary, HireDate)
VALUES
(1, 'Ali Khan', 'IT', 'Data Analyst', 65000, '2021-01-15'),
(2, 'Sara Ahmed', 'IT', 'Data Engineer', 85000, '2020-03-10'),
(3, 'Usman Malik', 'IT', 'Software Engineer', 90000, '2019-07-22'),
(4, 'Ayesha Noor', 'IT', 'Data Analyst', 72000, '2022-05-18'),
(5, 'Hamza Tariq', 'IT', 'Database Administrator', 78000, '2021-11-01'),
(6, 'Fatima Zahra', 'HR', 'HR Manager', 75000, '2018-06-12'),
(7, 'Bilal Ahmed', 'HR', 'HR Executive', 50000, '2022-01-20'),
(8, 'Hina Shah', 'HR', 'Recruiter', 55000, '2021-08-14'),
(9, 'Omar Farooq', 'HR', 'HR Executive', 52000, '2023-02-11'),
(10, 'Maham Ali', 'HR', 'Recruiter', 58000, '2020-10-05'),
(11, 'Zain Abbas', 'Finance', 'Financial Analyst', 68000, '2021-04-17'),
(12, 'Iqra Javed', 'Finance', 'Accountant', 60000, '2019-09-25'),
(13, 'Ahmed Raza', 'Finance', 'Finance Manager', 95000, '2017-03-19'),
(14, 'Maryam Khan', 'Finance', 'Accountant', 60000, '2022-07-30'),
(15, 'Danish Iqbal', 'Finance', 'Financial Analyst', 70000, '2023-01-12'),
(16, 'Saad Hussain', 'Sales', 'Sales Manager', 82000, '2018-11-21'),
(17, 'Laiba Aslam', 'Sales', 'Sales Executive', 48000, '2022-04-15'),
(18, 'Waleed Khan', 'Sales', 'Sales Executive', 48000, '2021-06-09'),
(19, 'Anum Fatima', 'Sales', 'Sales Executive', 52000, '2023-03-01'),
(20, 'Fahad Ali', 'Sales', 'Sales Manager', 85000, '2019-12-12'),
(21, 'Rizwan Ahmed', 'Marketing', 'Marketing Manager', 88000, '2018-02-28'),
(22, 'Sana Malik', 'Marketing', 'Marketing Executive', 55000, '2021-05-19'),
(23, 'Asad Khan', 'Marketing', 'SEO Specialist', 62000, '2022-09-10'),
(24, 'Nimra Shah', 'Marketing', 'Content Writer', 50000, '2023-04-25'),
(25, 'Kashif Raza', 'Marketing', 'Marketing Executive', 55000, '2020-01-17'),
(26, 'Hassan Ali', 'IT', 'Data Engineer', 85000, '2023-06-12'),
(27, 'Mehwish Noor', 'IT', 'Software Engineer', 90000, '2022-10-20'),
(28, 'Talha Ahmed', 'Finance', 'Accountant', 65000, '2023-05-15'),
(29, 'Areeba Khan', 'Sales', 'Sales Executive', 52000, '2022-12-01'),
(30, 'Shahzaib Malik', 'HR', 'HR Executive', 52000, '2023-07-10');
```

---

## 1. Materialized view summarizing total and average salary per department

```sql
CREATE MATERIALIZED VIEW DepartmentSalaryCost AS
SELECT
    Department,
    SUM(Salary) AS TotalSalaryCost,
    AVG(Salary) AS AvgSalary,
    COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY Department;
```

---

## 2. Query the materialized view

```sql
SELECT * FROM DepartmentSalaryCost
ORDER BY TotalSalaryCost DESC;
```

> This reads the stored snapshot directly — it does **not** re-scan or re-aggregate `Employees`.

---

## 3. Add a new employee, then show the materialized view is stale

```sql
INSERT INTO Employees
(EmployeeID, EmployeeName, Department, JobTitle, Salary, HireDate)
VALUES
(31, 'Noreen Sheikh', 'Finance', 'Financial Analyst', 72000, '2024-01-10');
```

```sql
-- The base table now shows 6 Finance employees...
SELECT COUNT(*) FROM Employees WHERE Department = 'Finance';

-- ...but the materialized view still reports the old count of 5,
-- and TotalSalaryCost / AvgSalary do not include Noreen Sheikh yet
SELECT * FROM DepartmentSalaryCost WHERE Department = 'Finance';
```

---

## 4. Refresh the materialized view

```sql
REFRESH MATERIALIZED VIEW DepartmentSalaryCost;
```

```sql
-- Now reflects all 6 Finance employees
SELECT * FROM DepartmentSalaryCost WHERE Department = 'Finance';
```

---

## 5. Create a unique index required for a concurrent refresh

```sql
CREATE UNIQUE INDEX idx_dept_salary_cost ON DepartmentSalaryCost (Department);
```

> PostgreSQL requires a unique index on the materialized view before `REFRESH ... CONCURRENTLY` can be used — it's how the refresh identifies matching rows to update in place instead of locking the whole view.

---

## 6. Refresh the materialized view concurrently

```sql
REFRESH MATERIALIZED VIEW CONCURRENTLY DepartmentSalaryCost;
```

> Unlike a plain `REFRESH`, this doesn't block `SELECT` queries against `DepartmentSalaryCost` while the rebuild happens — useful when the view backs a live dashboard.

---

## 7. Index the materialized view to speed up department lookups

```sql
CREATE INDEX idx_dept_lookup ON DepartmentSalaryCost (Department);
```

> This is only possible because the data is physically stored — a standard view has nothing to index directly.

---

## 8. Materialized view showing the highest-paid employee per department

```sql
CREATE MATERIALIZED VIEW TopEarnerPerDepartment AS
SELECT *
FROM (
    SELECT
        EmployeeName,
        Department,
        Salary,
        RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS SalaryRank
    FROM Employees
) ranked
WHERE SalaryRank = 1;
```

> `RANK()` ensures a genuine tie (e.g. IT's 90,000, shared by Usman Malik and Mehwish Noor) keeps both employees in the materialized result instead of dropping one arbitrarily.

---

## 9. Drop a materialized view safely

```sql
DROP MATERIALIZED VIEW IF EXISTS TopEarnerPerDepartment;
```

> `IF EXISTS` avoids an error if it was already dropped. This only removes the stored snapshot and its indexes — the `Employees` table is untouched.

---

## 10. List all materialized views in the current database

```sql
-- PostgreSQL
SELECT matviewname
FROM pg_matviews
WHERE schemaname = 'public';
```

```sql
-- Oracle
SELECT mview_name
FROM user_mviews;
```