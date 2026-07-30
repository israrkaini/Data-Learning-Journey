-- Windows function 
/* performs calculations across a set of table rows that are related to the current row, without collapsing the data into a 
single summary row */


-- 1. Row Number 
select e.*,
row_number() over(partition by salary) as rn
from Employees e;

-- first 2 emp from each dep
select * from (
	select e.*,
	row_number() over(partition by department order by employeeid) as rn
	from Employees e) X
where x.rn < 3;


--2. Rank and Dense Rank
select e.*,
rank() over(partition by department order by salary desc) as rnk,
dense_rank() over(partition by department order by salary desc) as d_rnk
from Employees e


-- fetch top 5 emp in each dep with max salary
select * from (
	select e.*,
	rank() over(partition by department order by salary desc) as rnk,
	dense_rank() over(partition by department order by salary desc) as d_rnk
	from Employees e) Y
where Y.rnk < 5;



--3.lag and lead

select e.*,
lag(salary) over(partition by department) as prev_emp_salary,
lead(salary) over(partition by department) as next_emp_salary
from employees e;


-- find the empl salry as greater, less, equal or not applicable
select e.*,
lag(salary) over(partition by department order by employeeid) as prev_emp_salary,
case when e.salary > lag(salary) over(partition by department order by employeeid) then 'Greater then previous Employee'
     when e.salary < lag(salary) over(partition by department order by employeeid) then 'less then previous Employee'
	 when e.salary = lag(salary) over(partition by department order by employeeid) then 'Equal to  previous Employee'
	 when e.salary > lag(salary) over(partition by department order by employeeid) then 'Greater then previous Employee'
	 end sal_range
from employees e;









	