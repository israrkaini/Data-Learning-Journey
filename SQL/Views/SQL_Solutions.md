# SQL Views — Practice Solutions

Solutions to the 13 practice questions, using the same `Employees` dataset (30 rows, 5 departments) used in the window functions exercises.

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

## 1. View showing all employees with their department and salary

```sql
CREATE VIEW EmployeeDepartmentSalary AS
SELECT
    EmployeeName,
    Department,
    Salary
FROM Employees;
```

```sql
SELECT * FROM EmployeeDepartmentSalary;
```

---

## 2. View showing only employees with a salary greater than 70,000

```sql
CREATE VIEW HighEarners AS
SELECT
    EmployeeName,
    Department,
    Salary
FROM Employees
WHERE Salary > 70000;
```

> Single-table, no aggregation — this view is updatable in most databases.

---

## 3. View showing the average salary per department

```sql
CREATE VIEW DepartmentAverageSalary AS
SELECT
    Department,
    AVG(Salary) AS AvgSalary,
    COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY Department;
```

```sql
SELECT * FROM DepartmentAverageSalary;
```

---

## 4. View showing the highest-paid employee in each department

```sql
CREATE VIEW TopEarnerPerDepartment AS
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

> `RANK()` is used instead of `ROW_NUMBER()` so a genuine tie for highest salary in a department (e.g. IT's 90,000, shared by Usman Malik and Mehwish Noor) returns **both** employees rather than arbitrarily picking one.

---

## 5. View combining employee details with department employee count

```sql
CREATE VIEW EmployeeWithDeptCount AS
SELECT
    e.EmployeeName,
    e.Department,
    e.Salary,
    d.EmployeeCount
FROM Employees e
JOIN (
    SELECT Department, COUNT(*) AS EmployeeCount
    FROM Employees
    GROUP BY Department
) d ON e.Department = d.Department;
```

---

## 6. Redefine an existing view to add a new column

```sql
CREATE OR REPLACE VIEW HighEarners AS
SELECT
    EmployeeName,
    Department,
    Salary,
    JobTitle
FROM Employees
WHERE Salary > 70000;
```

> `JobTitle` is appended to the original definition from Q2. It's added at the **end** — `CREATE OR REPLACE VIEW` generally can't reorder or remove the existing `EmployeeName`, `Department`, `Salary` columns, only extend them.

---

## 7. Rename an existing view using `ALTER VIEW`

```sql
-- PostgreSQL
ALTER VIEW HighEarners RENAME TO TopEarners;
```

```sql
-- SQL Server / MySQL: ALTER VIEW redefines the query instead of renaming;
-- rename with database-specific rename syntax, e.g. SQL Server:
EXEC sp_rename 'HighEarners', 'TopEarners';
```

> `ALTER VIEW` behaves differently across databases — in PostgreSQL it only changes metadata (rename, ownership), while in SQL Server and MySQL it redefines the underlying query, similar to `CREATE OR REPLACE VIEW`.

---

## 8. View that hides the Salary column for general access

```sql
CREATE VIEW EmployeePublicInfo AS
SELECT
    EmployeeName,
    Department,
    JobTitle,
    HireDate
FROM Employees;
```

> Grant `SELECT` on `EmployeePublicInfo` to general users instead of the base `Employees` table, so `Salary` is never exposed at the permissions level.

---

## 9. View with `WITH CHECK OPTION`

```sql
CREATE VIEW HighEarners AS
SELECT
    EmployeeName,
    Department,
    Salary
FROM Employees
WHERE Salary > 70000
WITH CHECK OPTION;
```

```sql
-- This update fails: 60000 no longer satisfies Salary > 70000,
-- so the row would disappear from the view — WITH CHECK OPTION blocks it
UPDATE HighEarners
SET Salary = 60000
WHERE EmployeeName = 'Sara Ahmed';
```

---

## 10. Materialized view summarizing total salary cost per department

```sql
CREATE MATERIALIZED VIEW DepartmentSalaryCost AS
SELECT
    Department,
    SUM(Salary) AS TotalSalaryCost,
    COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY Department;
```

---

## 11. Refresh a materialized view after underlying data changes

```sql
REFRESH MATERIALIZED VIEW DepartmentSalaryCost;

-- PostgreSQL: refresh without blocking concurrent reads
-- (requires a unique index on the materialized view)
REFRESH MATERIALIZED VIEW CONCURRENTLY DepartmentSalaryCost;
```

> Without this step, `DepartmentSalaryCost` keeps returning numbers from whenever it was last refreshed — e.g. adding employee #31 to Finance wouldn't show up in `TotalSalaryCost` until the view is refreshed.

---

## 12. List all views in the current database

```sql
-- PostgreSQL
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public';
```

```sql
-- SQL Server
SELECT name
FROM sys.views;
```

---

## 13. Drop a view that is no longer needed, safely

```sql
DROP VIEW IF EXISTS EmployeePublicInfo;
```

> `IF EXISTS` prevents an error if the view has already been removed or was never created. `DROP VIEW` only removes the saved query — the underlying `Employees` table and its data are untouched.