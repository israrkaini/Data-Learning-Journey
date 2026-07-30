# SQL Window Functions — Practice Solutions

14 practice questions, using the `Employees` dataset (30 rows, 5 departments, with intentional duplicate salaries to illustrate `ROW_NUMBER()` vs `RANK()` vs `DENSE_RANK()`).

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

## 1. Unique row number for every employee based on salary

```sql
SELECT
    EmployeeName,
    Department,
    Salary,
    ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNum
FROM Employees;
```

---

## 2. Rank employees by salary, highest to lowest

```sql
SELECT
    EmployeeName,
    Department,
    Salary,
    RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
FROM Employees;
```

---

## 3. Top 3 highest-paid employees in each department

```sql
SELECT *
FROM (
    SELECT
        EmployeeName,
        Department,
        Salary,
        DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DeptRank
    FROM Employees
) ranked
WHERE DeptRank <= 3;
```

> `DENSE_RANK()` is used so tied salaries (e.g., Usman Malik and Mehwish Noor both at 90,000 in IT) share a rank instead of pushing a distinct employee out of the top 3.

---

## 4. Second-highest salary in each department

```sql
SELECT *
FROM (
    SELECT
        EmployeeName,
        Department,
        Salary,
        DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DeptRank
    FROM Employees
) ranked
WHERE DeptRank = 2;
```

---

## 5. Compare each employee's salary with the previous employee's salary

```sql
SELECT
    EmployeeName,
    Department,
    Salary,
    LAG(Salary) OVER (ORDER BY HireDate) AS PreviousEmployeeSalary
FROM Employees;
```

---

## 6. Next employee hired after each employee

```sql
SELECT
    EmployeeName,
    HireDate,
    LEAD(EmployeeName) OVER (ORDER BY HireDate) AS NextHiredEmployee,
    LEAD(HireDate) OVER (ORDER BY HireDate) AS NextHireDate
FROM Employees;
```

---

## 7. Average salary of each department alongside every employee

```sql
SELECT
    EmployeeName,
    Department,
    Salary,
    AVG(Salary) OVER (PARTITION BY Department) AS DepartmentAverage
FROM Employees;
```

---

## 8. Running total of salaries ordered by hire date

```sql
SELECT
    EmployeeName,
    HireDate,
    Salary,
    SUM(Salary) OVER (ORDER BY HireDate) AS RunningTotal
FROM Employees;
```

---

## 9. Difference between an employee's salary and the department's average

```sql
SELECT
    EmployeeName,
    Department,
    Salary,
    AVG(Salary) OVER (PARTITION BY Department) AS DepartmentAverage,
    Salary - AVG(Salary) OVER (PARTITION BY Department) AS DifferenceFromAvg
FROM Employees;
```

---

## 10. Rank employees by salary within each department

```sql
SELECT
    EmployeeName,
    Department,
    Salary,
    RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DeptSalaryRank
FROM Employees;
```

---

## 11. Employees who share the same salary, using `DENSE_RANK()`

```sql
SELECT *
FROM (
    SELECT
        EmployeeName,
        Department,
        Salary,
        DENSE_RANK() OVER (ORDER BY Salary) AS SalaryGroup,
        COUNT(*) OVER (PARTITION BY Salary) AS SalaryOccurrences
    FROM Employees
) t
WHERE SalaryOccurrences > 1
ORDER BY Salary;
```

> Example matches in this dataset: Waleed Khan / Laiba Aslam (48,000); Ali Khan's tier doesn't repeat, but Iqra Javed / Maryam Khan (60,000); Usman Malik / Mehwish Noor and Sara Ahmed / Hassan Ali (85,000 / 90,000 pairs); Bilal Ahmed / Shahzaib Malik / Omar Farooq's near-tier (52,000, shared with Anum Fatima and Areeba Khan), etc.

---

## 12. First employee hired in each department

```sql
SELECT *
FROM (
    SELECT
        EmployeeName,
        Department,
        HireDate,
        ROW_NUMBER() OVER (PARTITION BY Department ORDER BY HireDate ASC) AS HireOrder
    FROM Employees
) t
WHERE HireOrder = 1;
```

---

## 13. Latest employee hired in each department

```sql
SELECT *
FROM (
    SELECT
        EmployeeName,
        Department,
        HireDate,
        ROW_NUMBER() OVER (PARTITION BY Department ORDER BY HireDate DESC) AS HireOrder
    FROM Employees
) t
WHERE HireOrder = 1;
```

---

## 14. Cumulative average salary based on hire date

```sql
SELECT
    EmployeeName,
    HireDate,
    Salary,
    AVG(Salary) OVER (
        ORDER BY HireDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS CumulativeAverage
FROM Employees;
```

> `AVG() OVER (ORDER BY HireDate)` alone works the same way in most databases (the default frame is `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`), but the explicit `ROWS BETWEEN` version avoids surprises when hire dates repeat.