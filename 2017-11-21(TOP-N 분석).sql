[����70] �⵵�� �Ի��� �ο����� pivot�� �̿��ؼ� ������ּ���.

      2001       2002       2003       2004       2005       2006       2007       2008
---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
         1          7          6         10         29         24         19         11
         
select *
from (select to_char(hire_date,'yyyy') year from employees)
pivot (count(*) for year in('2001' "2001",'2002' "2002",'2003' "2003",'2004' 
"2004",'2005' "2005",'2006' "2006",'2007' "2007",'2008' "2008")); 

select *
from (select to_char(hire_date,'yyyy') year, nvl(null,1) num from employees)
pivot (sum(num) for year in('2001' "2001",'2002' "2002",'2003' "2003",'2004' 
"2004",'2005' "2005",'2006' "2006",'2007' "2007",'2008' "2008"));

[����71] ��ü ����� ��, �⵵�� �Ի��� �ο����� pivot�� �̿��ؼ� ������ּ���.

select *
from (select to_char(hire_date,'yyyy') year, count(*) cnt 
      from employees 
      group by rollup(to_char(hire_date,'yyyy')))
pivot (max(cnt) for year in(null "total",'2001' "2001",'2002' "2002",'2003' 
"2003",'2004' "2004",'2005' "2005",'2006' "2006",'2007' "2007",'2008' "2008"));

select *
from(select to_char(hire_date,'yyyy') -- ��Ī�� ������ ���������� �ܺο��� ���Ұ�
     from employees)
where to_char(hire_date,'yyyy') = '2001';

select *
from(select to_char(hire_date,'yyyy') year
     from employees)
where year = '2001';

[����72] 20�� �μ��� ������� �޿��� ���� �հ踦 ���ϼ���.(self join, >= �����)

EMPLOYEE_ID     SALARY DEPARTMENT_ID      TOTAL
----------- ---------- ------------- ----------
        201      13000            20      13000
        202       6000            20      19000
        
select e1.employee_id, e1.salary, e1.department_id, sum(e2.salary) total
from (select employee_id, salary, department_id from employees where department_id = 20) e1,
     (select employee_id, salary from employees where department_id = 20) e2
where e1.employee_id >= e2.employee_id -- >= �� �ٽ�
group by e1.employee_id, e1.salary, e1.department_id;

================================================================================
-- �������� ���ϴ� �м��Լ� : over(order by ����)
select employee_id, salary, department_id, 
       sum(salary) over(order by employee_id)
from employees
where department_id = 20;

-- ��ü���� ���ϴ� �м��Լ� : over()
select employee_id, salary, department_id, sum(salary) over()/*��ü��*/, avg(salary) over()/*��ü���*/
from employees
where department_id = 20;

select employee_id, salary, department_id,
sum(salary) over(partition by department_id) as dept_total,/*�μ��� ����*/
sum(salary) over(partition by department_id order by employee_id) as running_total, /*�μ��� ������*/
sum(salary) over() as total /*��ü ����*/
from employees;

select employee_id, salary, job_id,
sum(salary) over(partition by job_id order by employee_id) as running
from employees;

================================================================================
-- rownum : fetch(ȭ��� ���) ��ȣ (n�� ��½� ���)
-- rowid : �������� row �ּҰ�
select rownum, rowid, employee_id
from employees;

-- TOP-N �м�

select last_name, salary
from employees
order by salary desc;

/* ������(�߸��� ���) : ������ �޿��� �޴� ����� ������ ���ɼ� ���� */
select rownum, last_name, salary
from (
      select last_name, salary
      from employees
      order by salary desc
      )
where rownum <= 2; -- fetch number�� = , >, >= �� �ȵ�

/* rank(), dense_rank() */
select employee_id, last_name, salary,
       rank() over(order by salary desc) rank, -- 2�� 2���̸� 3���� ����
       dense_rank() over(order by salary desc) dense_rank -- ������ ����
from employees;

select rank, last_name, salary
from (select dense_rank() over(order by salary desc) rank,
             last_name, salary
      from employees)
where rank <= 10; 

select department_id, employee_id, last_name, salary,
       rank() over(partition by department_id order by salary desc) rank, -- �μ��� ��� �޿�����
       dense_rank() over(partition by department_id order by salary desc) dense_rank -- �μ��� ��� �޿�����
from employees;

================================================================================

[����73] ������� 3�� �̸��� �μ���ȣ, �μ��̸�, �ο����� ���

select department_id, (select department_name
                       from departments
                       where department_id = e.department_id)
       , count(*) cnt
from employees e
where department_id is not null
group by department_id
having count(*) < 3;

-- ������ Ǯ��
select d.department_id, d.department_name, e.cnt
from(select department_id, count(*) cnt
     from employees
     group by department_id
     having count(*)<3) e, departments d
where d.department_id = e.department_id;

select department_id, count(*)
from employees
group by rollup(department_id)
order by 2;

[����74] ��� ���� ���� ���� �μ���ȣ, �μ��̸�, �ο����� ���

select department_id, (select department_name
                       from departments
                       where department_id = b.department_id) dept_name
       , cnt
from (select dense_rank() over(order by  count(*) desc) rank, department_id, count(*) cnt
      from employees
      group by department_id) b
where rank = 1
group by department_id, cnt;

-- ������ Ǯ��
select d.department_id, d.department_name, e.cnt
from (select department_id, count(*) cnt
      from employees
      group by department_id
      having count(*) = (select max(count(*))
                         from employees
                         group by department_id)) e, 
      departments d
where d.department_id = e.department_id;

[����75] �ڽ��� �μ� ��ձ޿� ���� �� ���� �޴� ����� ���, �޿�, �μ��̸��� ������ּ���.(���̺� 3��)
         (join, correlated subquery); -- ����������

select e.employee_id, e.salary, d.department_name -- f10 window buffer : ����Ŭ�� �м��Լ��� �̿��ߴٴ�...
from employees e, departments d
where e.department_id = d.department_id
and e.salary > (select avg(salary)
                from employees
                where department_id = d.department_id);

[����76] �ڽ��� �μ� ��ձ޿� ���� �� ���� �޴� ����� ���, �޿�, �μ��̸��� ������ּ���.(���̺� 3��)
         (inline view, join);

select e.employee_id, e.salary, d.department_name
from (select department_id, employee_id, salary
      from employees) e,
     (select department_id, department_name
      from departments) d,
     (select department_id, avg(salary) avg_sal
      from employees
      group by department_id) av  
where e.department_id = d.department_id
and d.department_id = av.department_id
and e.salary > av.avg_sal;

[����77] �ڽ��� �μ� ��ձ޿� ���� �� ���� �޴� ����� ���, �޿�, �μ��̸��� ������ּ���.(���̺� 2��)
         (inline view, join, �м��Լ�);
         
select e.employee_id, e.salary, d.department_name
from (select avg(salary) over(partition by department_id) avg_sal, department_id, employee_id, salary
      from employees) e,
     (select department_id, department_name
      from departments) d
where e.department_id = d.department_id
and e.salary > e.avg_sal;

select e.*
from employees e
where e.salary > any 
(select avg(salary) over(partition by department_id) from employees where department_id = e.department_id) ;

-- ������ Ǯ��
/*
inline view �ȿ��� ������ ���� ���ϴ� ���̺��� �����ϰ� case when���� �����ؼ� 
�μ��� ��հ����� ���� �޿��� �޴� ������� rowid��� ������ ���� ����
*/
select employee_id, salary, department_name
from (select e.employee_id, e.salary, d.department_name,
      case when e.salary > avg(salary) over(partition by e.department_id)
      then e.rowid end VW_COL_4 /*column name*/
      from employees e, departments d
      where e.department_id = d.department_id) 
where VW_COL_4 is not null;









