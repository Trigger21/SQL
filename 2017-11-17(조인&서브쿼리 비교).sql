[����60] ���� �μ����� �ڽź��� �Ի��� ��¥�� ���� ������� �޿��� ���� �޴� ����� ǥ���ϴ� query �� �ۼ��մϴ�.(exists ��ǥ�� ����)
-- �� Ǯ��(exists �����ڸ� ����� correlated subquery)
select *
from employees e
where exists
(select 1
 from employees 
 where department_id = e.department_id /* ���� �μ����� */
 and hire_date > e.hire_date           /* ������ �ʰ� �Ի��ߴµ� */
 and salary > e.salary);               /* ������ �� ���� �޳� */

select employee_id, hire_date, salary from employees e where department_id = 90;

-- ������ Ǯ��
select *
from employees o
where exists(select 1
            from employees i -- i : ��Ī ���ص� ��
            where i.department_id = o.department_id
            and i.hire_date > o.hire_date
            and i.salary > o.salary);
            
================================================================================            

-- �ڽ��� �μ� ��ձ޿����� ���� �޴� ���(correlated subquery)

select department_id, last_name, salary, (select avg(salary)
                from employees
                where department_id = e.department_id) avg_dep -- cache���
from employees e
where salary > (select avg(salary) /* �Լ� ���� ����ϸ� cpu ���� */
                from employees
                where department_id = e.department_id);

-- ������ ������� ������ ����϶�

select *
from employees
where employee_id in (select manager_id from employees); -- emp_id : 1��, man_id : M��(�ߺ��� ����)

select *
from employees e
where exists (select 1 from employees where manager_id = e.employee_id);
/* in �� exists ������� ������� ����� ���� */

/* order by������ subquery ��밡��(group by �� �Ұ�) */
select *
from employees o
order by (select department_name 
          from departments
          where department_id = o.department_id);
          
/* inline view */
select e2.*
from (select department_id, avg(salary) avg_sal -- e1 : �ʿ��� �÷����θ� �籸���� ���� ���̺�
      from employees
      group by department_id) e1, employees e2 -- e2 : ���� ���̺�
where e1.department_id = e2.department_id
and e2.salary > e1.avg_sal;

-- �μ��̸��� �Ѿױ޿��� ���ϼ���
/* join */
select d.department_name, sum(e.salary)  -- 4.�Լ����
from employees e, departments d          -- 1.���� ���̺�
where e.department_id = d.department_id  -- 2.join �ǽ�(row 107�� ����)
group by d.department_name;              -- 3.�׷�ȭ �۾�

/* inline view : ���� */
select d.department_name, e.sum_sal
from (select department_id, sum(salary) sum_sal
      from employees
      group by department_id) e, departments d
where e.department_id = d.department_id;

================================================================================

/* join */
select e.last_name, d.department_name
from employees e, departments d          
where e.department_id = d.department_id;  

/* scalar subquery : ����(���ʿ��� �ݺ�����, null�� ��� */
select e.last_name,
       (select department_name
        from departments
        where department_id = e.department_id) -- cache
from employees e;

-- �μ��̸����� �Ѿױ޿��� ���ϼ���.(��, skalar subquery ���)
select d.department_name,
       (select sum(salary) from employees where department_id = d.department_id)
from departments d; -- ū ���̺� group ���ص� ���ڳ�, outer join�� ���ص� ������ ȿ��!

select d.department_name, e.sumsal
from (select department_id, sum(salary) sumsal -- group by�� ���� full scan �ϰԵ�
      from employees
      group by department_id) e, departments d 
where e.department_id = d.department_id;

-- ��ձ޿��� ����;��
select d.department_name,
       (select sum(salary) from employees where department_id = d.department_id),
       (select avg(salary) from employees where department_id = d.department_id)  
from departments d;
/* �� �������� �� 3���� IO �߻� : ������ */

-- �������
select d.department_name,
       (select 'sumsal:'||sum(salary)||', avgsal:' || avg(salary) 
        from employees 
        where department_id = d.department_id)
from departments d;

select d.department_name, 
       (select sum(salary) || avg(salary) from employees where department_id = d.department_id)
from departments d;

/* ���ο� �����Լ� : lpad, rpad */
select last_name, lpad(last_name,20,'*'), -- 20�ڸ��� �������� ��ھ�, ���ʰ����� * ä����
       rpad(last_name,20,'*'),-- 20�ڸ��� �������� ��ھ�, �����ʰ����� * ä����
       lpad(salary,10,'*') -- �峭ġ�°� ����
from employees;

[����61] salary���� 1000�� * ����ϼ���
sal   star
5000  *****
4000  ****

select salary, lpad('*',(salary/1000),'*'), lpad(' ',salary/1000+1,'*')
from employees;

-- �Ʒ� ������(�μ��̸� �� �޿��� �� �޿����)�� inline ���� �ٲٰ� lpad ����ؼ�

select d.department_name, 
       (select sum(salary) || avg(salary) from employees where department_id = d.department_id) sal
from departments d;

select *
from (
select d.department_name, 
       (select rpad(substr(sum(salary) || avg(salary), 0, length(sum(salary))),20)
        from employees 
        where department_id = d.department_id) sal
from departments d);

substr(sum(salary))

-- ������ Ǯ��
select department_name, substr(sal, 1, 10) sumsal, -- �� ����
                        substr(sal, 11) avgsal -- ��� ����
from (
       select d.department_name, 
              (select lpad(sum(salary),10) || lpad(avg(salary),10) -- ���� 10ĭ ����� �� �Ǵ� ��հ��� �Ϸ�, ������ĭ�� ���� 
               from employees 
               where department_id = d.department_id) sal
       from departments d
      )
where sal is not null;
/*
�� inline view�� object�� �ƴ����� ��븸 ����, �ٸ� from �� ������ ����.
select
from (select ... ) e, (select ... from e) e1
*/
-- ������ �Ի��� ��� �� (1�� ���̺��)
select count(decode(to_char(hire_date,'yyyy')/*���ذ�*/ , '2001' , 1 )) "2001", -- 107�� row�� ��ü�� �� ���ϰ� �ȴ�(�Ǽ��ڵ�)
       count(decode(to_char(hire_date,'yyyy')/*���ذ�*/ , '2002' , 1 )) "2002",
       count(decode(to_char(hire_date,'yyyy')/*���ذ�*/ , '2003' , 1 )) "2003",
       count(decode(to_char(hire_date,'yyyy')/*���ذ�*/ , '2004' , 1 )) "2004",
       count(decode(to_char(hire_date,'yyyy')/*���ذ�*/ , '2005' , 1 )) "2005",
       count(decode(to_char(hire_date,'yyyy')/*���ذ�*/ , '2006' , 1 )) "2006",
       count(decode(to_char(hire_date,'yyyy')/*���ذ�*/ , '2007' , 1 )) "2007",
       count(decode(to_char(hire_date,'yyyy')/*���ذ�*/ , '2008' , 1 )) "2008"
from employees;

select count(decode((select to_char(hire_date,'yyyy')
                     from (
                           select to_char(hire_date,'yyyy') year , 
                                  count(*) cnt
                           from employees
                           group by to_char(hire_date,'yyyy')
                           )
                      group by to_char(hire_date,'yyyy')) , '2001'  , 1 )) "2001" 
from employees;

select to_char(hire_date,'yyyy'), count(*)
from employees
group by to_char(hire_date,'yyyy');

-- ������ Ǯ��

select max(decode(year,'2001',cnt)) "2001", -- max(�ٸ� �׷��Լ��� ok)�� ���ؼ� null �� ������ 1�� ǥ���Ϸ���
       max(decode(year,'2002',cnt)) "2002",
       max(decode(year,'2003',cnt)) "2003",
       max(decode(year,'2004',cnt)) "2004",
       max(decode(year,'2005',cnt)) "2005",
       max(decode(year,'2006',cnt)) "2006",
       max(decode(year,'2007',cnt)) "2007",
       max(decode(year,'2008',cnt)) "2008"      
from (
      select to_char(hire_date,'yyyy') year , count(*) cnt
      from employees
      group by to_char(hire_date,'yyyy') -- 107������ 8���� ���� ���� �������̺�
      );

================================================================================
/* �μ��� �޿� ������ ����� ��� ���ұ�? �� ��պ��� �޿������� �� ū �μ���? */
select *
from (select d.department_name, 
            (select sum(salary) 
             from employees 
             where department_id = d.department_id) dept_total
      from departments d) dept_cost, -- �������̺�
     (select sum(dept_total)/count(*) from dept_cost); -- ���� : table or view does not exist

/* �� �ذ��� : with�� */
with
dept_cost as (select d.department_name, 
                    (select sum(salary) 
                     from employees 
                     where department_id = d.department_id) dept_total -- �μ��� ������� �޿�����
              from departments d), -- dept_cost : �������̺� ��
avg_cost as (select sum(dept_total)/count(*) dept_avg/*25348.7*/ from dept_cost) -- ���� ȣ���
select *
from dept_cost
where dept_total > (select dept_avg
                    from avg_cost);


select (select sum(salary) 
        from employees 
        where department_id = d.department_id) dept_avg,
        sum(dept_total)/count(*)    
from departments d;