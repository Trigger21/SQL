[����38] ������� ���, �޿�, �޿����, �μ��̸��� ����ϼ���.
         �μ���ġ�� ���� �ʴ� ����� ���ܽ����ּ���.(����Ŭ����, ANSIǥ��)
-- oracle
select e.employee_id, e.salary, j.grade_level, d.department_name
from employees e, departments d, job_grades j
where (e.salary between j.lowest_sal and j.highest_sal)
and e.department_id = d.department_id;

-- ansi
select e.employee_id, e.salary, j.grade_level, d.department_name
from employees e join job_grades j
on e.salary between j.lowest_sal and j.highest_sal
join departments d
on e.department_id = d.department_id;

[����39] ������� ���, �޿�, �޿����, �μ��̸�, �ٹ� ���� ������ ����ϼ���.
         �μ���ġ�� ���� �ʴ� ����� ���Խ����ּ���.(����Ŭ����, ANSIǥ��)
         
-- oracle
select e.employee_id, e.salary, j.grade_level, d.department_name, l.city
from employees e, departments d, job_grades j, locations l
where e.department_id = d.department_id(+)
and d.location_id = l.location_id(+)
and e.salary between j.lowest_sal and j.highest_sal;

-- ansi
select e.employee_id, e.salary, j.grade_level, d.department_name, l.city
from employees e left join departments d
on e.department_id = d.department_id
left join locations l
on d.location_id = l.location_id
join job_grades j
on e.salary between j.lowest_sal and j.highest_sal;

[����40] ������� ���, �޿�, �޿����, �μ��̸��� ����ϼ���.
         �μ���ġ�� ���� �ʴ� ����� ���ܽ����ּ���. ��, last_name�� a�� �� �����(����Ŭ����, ANSIǥ��)
select count(*) 
from employees 
where last_name like '%a%' 
and department_id is not null; /* 51�� */

-- oracle
select e.employee_id, e.salary, j.grade_level, d.department_name
from employees e, departments d, job_grades j
where (e.salary between j.lowest_sal and j.highest_sal)
and e.department_id = d.department_id
and e.last_name like '%a%';

-- ansi
select e.employee_id, e.salary, j.grade_level, d.department_name
from employees e join job_grades j
on e.salary between j.lowest_sal and j.highest_sal
join departments d
on e.department_id = d.department_id
where e.last_name like '%a%';

[����41] ������� ���, �޿�, �޿����, �μ��̸��� ����ϼ���.
         �μ���ġ�� ���� �ʴ� ����� ���ܽ����ּ���. ��, last_name�� a�� 2�� �̻� �� �����(����Ŭ����, ANSIǥ��)
select *
from employees 
where last_name like '%a%a%'
and department_id is not null;      

-- oracle
select e.employee_id, e.salary, j.grade_level, d.department_name
from employees e, departments d, job_grades j
where (e.salary between j.lowest_sal and j.highest_sal)
and e.department_id = d.department_id
and e.last_name like '%a%a%'; 
/* instr(e.last_name,'a',1,2) > 0 (last_name 2��° 'a' ��ġ�� ~ 'a' 2�� ����) : index ��ĵ ���� */

-- ansi
select e.employee_id, e.salary, j.grade_level, d.department_name
from employees e join job_grades j
on e.salary between j.lowest_sal and j.highest_sal
join departments d
on e.department_id = d.department_id
where instr(e.last_name,'a',1,2) > 0;

������� employee_id, name, region_name 

select e.employee_id, e.first_name || ' ' || e.last_name name, r.region_name
from employees e, departments d, locations l, countries c, regions r
where e.department_id = d.department_id
and d.location_id = l.location_id
and l.country_id = c.country_id
and c.region_id = r.region_id;

select r.region_name, count(*), avg(salary), min(salary), max(salary)
from employees e, departments d, locations l, countries c, regions r
where e.department_id = d.department_id
and d.location_id = l.location_id
and l.country_id = c.country_id
and c.region_id = r.region_id
group by r.region_name;

================================================================================

-- subquery : SQL�� �ȿ� SELECT���� �ִ� ����(main + sub)

110�� ����� �޿����� �� ����(�ʰ�) �޴� �����?

select salary from employees where employee_id = 110; /* 110�� ��� �޿� : 8200 */

select *
from employees
where salary > 8200; /* ����� ���� ���״�(��ȭ�� ���� ���) */

/* �������(��ȭ�� �ִ� ���) */
select *
from employees 
where salary > (select salary from employees where employee_id = 110);

��ø�������� : �������� ���� ������ ������� ������ ������������ ����Ѵ�.

1. ������ ��������(single row subquery) : ������������ ������ ������� 1���� ����
 - �񱳿�����(= , > , >= , < , <= , <>)
 
2. ������ ��������(multiple row subquery) : ������������ ������ ������� �ټ�
 - �񱳿�����(IN , ALL , ANY)
 
select *
from employees
where salary > (select salary from employees where last_name like '%a%'); /* ���� */

ex. 141�� job_id�� ������ ����� ������ ��ȸ�Ͻÿ�.

select *
from employees
where job_id = (select job_id from employees where employee_id = 141);

[����42] ��� 141�� job_id �� ������ job_id ���� ����� �߿� 141 ����� �޿����� ���� �޴� ����� ����ϼ���.
         �� 141�� ����� ���ܽ��Ѽ� ����ϼ���.

select *
from employees
where salary > (select salary from employees where employee_id = 141)
and job_id = (select job_id from employees where employee_id = 141);

[����43] ȸ�翡�� �ְ� �޿��� �޴� ������� ������ ����ϼ���.
/* ����(���)���� ��û */
select *
from employees e, job_grades j
where (e.salary between j.lowest_sal and j.highest_sal)
and j.grade_level = 'E';

select *
from employees e join job_grades j
on (e.salary between j.lowest_sal and j.highest_sal)
where j.grade_level = 'E';

/* �ְ� ��û */
select *
from employees
where salary = (select max(salary) from employees);

[����44] ȸ�翡�� ���� �޿��� �޴� ������� ������ ����ϼ���.
/* ����(���)���� ��û */
select * 
from employees e, job_grades j
where (e.salary between j.lowest_sal and j.highest_sal)
and j.grade_level = 'A';

select *
from employees e join job_grades j
on (e.salary between j.lowest_sal and j.highest_sal)
where j.grade_level = 'A';

/* ������ ��û */
select *
from employees
where salary = (select min(salary) from employees);

[����45] ȸ�翡�� �ְ� �޿��� �޴� ������� ���, �޿�, �μ��̸� ������ ����ϼ���.

select e.employee_id, e.salary, d.department_name
from employees e, job_grades j, departments d
where (e.salary between j.lowest_sal and j.highest_sal)
and j.grade_level = 'E'
and e.department_id = d.department_id;

select e.employee_id, e.salary, d.department_name
from employees e, departments d
where e.salary = (select max(salary) from employees)
and e.department_id = d.department_id;

[����46] ȸ�翡�� ���� �޿��� �޴� ������� ���, �޿�, �μ��̸� ������ ����ϼ���.

select e.employee_id, e.salary, d.department_name
from employees e, job_grades j, departments d
where (e.salary between j.lowest_sal and j.highest_sal)
and j.grade_level = 'A'
and e.department_id = d.department_id;

select e.employee_id, e.salary, d.department_name
from employees e, departments d
where e.salary = (select min(salary) from employees)
and e.department_id = d.department_id;

================================================================================

select job_id, avg(salary)
from employees
group by job_id;

select job_id, max(avg(salary)) /* ���� : �׷��Լ� ��ø�� ������ ���Ұ� */
from employees
group by job_id; /* 1�� ���� 2������?? */

select job_id, avg(salary)
from employees
group by job_id
having avg(salary) = (select max(avg(salary)) from employees group by job_id); /* ���������� */

================================================================================

/* in : ������ ��ġ�ϴ� �͵� �ѷ� */
select *
from employees
where salary in (select min(salary) from employees group by department_id);

select *
from employees
where salary in (select salary from employees where job_id = 'IT_PROG');
-- in�� = or�� ����

/* any */
select *
from employees
where salary > any (select salary from employees where job_id = 'IT_PROG');
-- > any : > or�� ����, �������� ����� �� �ּҰ����� ŭ�� ��Ȱ

select *
from employees
where salary > (select min(salary) from employees where job_id = 'IT_PROG');
-- min(salary) : 4200

select *
from employees
where salary < any (select salary from employees where job_id = 'IT_PROG');
-- < any : < or�� ����, �������� ����� �� �ִ밪���� ������ ��Ȱ

select *
from employees
where salary < (select max(salary) from employees where job_id = 'IT_PROG');
-- max(salary) : 9000

= any : in �� ����

/* all */
select *
from employees
where salary > all (select salary from employees where job_id = 'IT_PROG');
-- > all : > and�� ����, �������� ����� �� �ִ밪���� ŭ�� ��Ȱ

select *
from employees
where salary > (select max(salary) from employees where job_id = 'IT_PROG');
-- max(salary) : 9000

select *
from employees
where salary < all (select salary from employees where job_id = 'IT_PROG');
-- < all : < and�� ����, �������� ����� �� �ּҰ����� ������ ��Ȱ

select *
from employees
where salary < (select min(salary) from employees where job_id = 'IT_PROG');
-- min(salary) : 4200


�� ���(���⼭ 1�� �ּҰ�, n�� �ִ밪���� �����Ѵ�)
 A in (1,2,3,...,n) : A = 1 or A = 2 or ... or A = n

 A > any (1,2,3,...,n) : A > 1 or A > 2 or ... or A > n �� ��A > 1�� 
 A >= any (1,2,3,...,n) : A >= 1 or A >= 2 or ... or A >= n �� ��A >= 1��
 A < any (1,2,3,...,n) : A < 1 or A < 2 or ... or A < n �� ��A < n��
 A <= any (1,2,3,...,n) : A <= 1 or A <= 2 or ... or A <= n �� ��A <= n��
 A = any (1,2,3,...,n) : A = 1 or A = 2 or ... or A = n �� ��A in (1,2,3,...,n)��

 A > all (1,2,3,...,n) : A > 1 and A > 2 and ... and A > n �� ��A > n�� 
 A >= all (1,2,3,...,n) : A >= 1 and A >= 2 and ... and A >= n �� ��A >= n��
 A < all (1,2,3,...,n) : A < 1 and A < 2 and ... and A < n �� ��A < 1��
 A <= all (1,2,3,...,n) : A <= 1 and A <= 2 and ... and A <= n �� ��A <= 1��
 
[����47] ��ü ���(avg) �޿�(salary) �̻��� �޴� ��� ����� ��� employee_id, last_name, salary �� ����ϼ���.

select employee_id, last_name, salary
from employees
where salary >= (select avg(salary) from employees);

[����48] last_name �� ���� "u"�� ���Ե� ����� ���� �μ��� �ٹ��ϴ� ��� ����� employee_id, last_name �� ����ϼ���.

select employee_id, last_name
from employees
where department_id in (select department_id from employees where instr(last_name, 'u') > 0);

[����49] �μ� ��ġ(location_id) ID �� 1700 �� ��� ����� last_name, department_id, job_id �� ����ϼ���.
/* equi join*/
select e.last_name, d.department_id, e.job_id 
from employees e, departments d
where e.department_id = d.department_id
and d.location_id = 1700;

select last_name, department_id, job_id
from employees join departments
using(department_id)
where location_id = 1700;

select e.last_name, d.department_id, e.job_id 
from employees e join departments d
on e.department_id = d.department_id
where d.location_id = 1700; 

/* subquery(in) */
select last_name, department_id, job_id
from employees
where department_id in (select department_id from departments where location_id = 1700);

[����50] King ���� �����ϴ� ��� ����� last_name �� salary ����ϼ���. (e.mananger_id)
/* self join */
select e.last_name, e.salary
from employees e, employees m
where e.manager_id = m.employee_id
and m.last_name = 'King';

select e.last_name, e.salary
from employees e join employees m
on e.manager_id = m.employee_id
where m.last_name = 'King';

/* subquery(in) */
select last_name, salary
from employees
where manager_id in (select employee_id from employees where last_name = 'King'); 

[����51] �μ� �̸�(department_name) �� Executive �μ��� ��� ����� ���� department_id, last_name, job_id  ����ϼ���.
/* equi join */
select d.department_id, e.last_name, e.job_id
from employees e, departments d
where e.department_id = d.department_id
and d.department_name = 'Executive';

/* subquery(in) */
select department_id, last_name, job_id
from employees
where department_id in (select department_id from departments where department_name = 'Executive');

[����52] �μ� department_id 60�� �Ҽӵ� ��� ����� �޿�(salary)���� ����(max) �޿��� �޴� ��� ��� ����ϼ���.(�� ������ ����� �ľ�)
ex. '... � ����� �޿� ...' �̶�� any
/* equi join */
select *
from employees e, departments d
where e.department_id = d.department_id(+)
and e.salary > all (select salary from employees where department_id = 60);

select *
from employees e, departments d
where e.department_id = d.department_id(+)
and e.salary > (select max(salary) from employees where department_id = 60);

/* subquery(any) */
select *
from employees
where salary > all (select salary from employees where department_id = 60);

select *
from employees
where salary > (select max(salary) from employees where department_id = 60);