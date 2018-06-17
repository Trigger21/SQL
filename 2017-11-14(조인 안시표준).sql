[����30] ��� ����� last_name, department_id, department_name�� ǥ���ϱ� ���� query �� �ۼ��մϴ�.
/* oracle */
select e.last_name, e.department_id, d.department_name
from employees e, departments d
where e.department_id = d.department_id(+);

/* ansi */      
select e.last_name, e.department_id, d.department_name
from employees e left outer join departments d
on e.department_id = d.department_id;

[����31] �μ� 80�� ���ϴ� last_name, job_id, department_name,location_id �� ǥ���ϱ� ���� query �� �ۼ��մϴ�.
/* oracle */
select e.last_name, e.job_id, d.department_name, d.location_id
from employees e, departments d
where (e.department_id = d.department_id)
and e.department_id = 80; -- d.department = 80; /* ��������� index�� �־�� �Ѵ� */

/* �籸��(����Ŭ �ӽŷ���) : �ǵ��� ī�׽þ� �� ���� */
select e.last_name, e.job_id, d.department_name, d.location_id
from employees e, departments d
where d.department_id = 80 -- 1��
and e.department_id = 80; -- M�� 

/* ansi */ 
select last_name, job_id, department_name, location_id
from employees cross join departments
where departments.department_id = 80
and employees.department_id = 80;

select last_name, job_id, department_name, location_id
from employees join departments
using(department_id)
where department_id = 80; -- where�� ����� ������ ��������

select e.last_name, e.job_id, d.department_name, d.location_id
from employees e join departments d
on e.department_id = d.department_id 
and d.department_id = 80;

[����32] commission_pct �� null�� �ƴ� ��� ����� last_name, department_name, location_id, city�� ǥ���ϱ� ���� query �� �ۼ��մϴ�.
/* oracle */
select e.last_name, d.department_name, d.location_id, l.city 
from employees e, departments d, locations l
where e.department_id = d.department_id(+)
and d.location_id = l.location_id(+)
and e.commission_pct is not null;

/* ansi */
select e.last_name, d.department_name, d.location_id, l.city 
from employees e left outer join departments d
on e.department_id = d.department_id
left outer join locations l
on d.location_id = l.location_id
where e.commission_pct is not null;

select * from employees where commission_pct is not null;

[����33] last_name�� a(�ҹ���)�� ���Ե� ��� ����� last_name, department_name �� ǥ���ϱ� ���� query �� �ۼ��մϴ�.
/* oracle */
select e.last_name, d.department_name
from employees e, departments d
where (e.department_id = d.department_id(+))
and e.last_name like '%a%';

select e.last_name, d.department_name
from employees e, departments d
where (e.department_id = d.department_id(+))
and instr(e.last_name,'a') > 0;

/* ansi */
select e.last_name, d.department_name
from employees e left outer join departments d
on e.department_id = d.department_id
where instr(last_name,'a') > 0; 

[����34] locations ���̺� �ִ� city�÷���  Toronto���ÿ��� �ٹ��ϴ� ��� ����� last_name, job_id, department_id, department_name �� ǥ���ϱ� ���� query �� �ۼ��մϴ�.
/* oracle */
select e.last_name, e.job_id, d.department_id, d.department_name
from employees e, departments d, locations l
where e.department_id = d.department_id
and d.location_id = l.location_id
and l.city = 'Toronto'; --l.location_id = 1800;

/* ansi */
select last_name, job_id, department_id, department_name
from employees join departments
using(department_id) join locations
using(location_id)
where city = 'Toronto';

select e.last_name, e.job_id, d.department_id, d.department_name
from employees e join departments d
on e.department_id = d.department_id
join locations l
on d.location_id = l.location_id
where city = 'Toronto'; -- where city = 'Toronto';

=================================================================================
drop table job_grades purge; -- ��������

CREATE TABLE job_grades -- F5 ������ �ѹ濡 �� 1����
( grade_level varchar2(3),
  lowest_sal  number,
  highest_sal number);

INSERT INTO job_grades VALUES ('A',1000,2999);
INSERT INTO job_grades VALUES ('B',3000,5999);
INSERT INTO job_grades VALUES ('C',6000,9999);
INSERT INTO job_grades VALUES ('D',10000,14999);
INSERT INTO job_grades VALUES ('E',15000,24999);
INSERT INTO job_grades VALUES ('F',25000,40000);
commit;

select * from job_grades;

select * from employees;
/* salary �� ��� �˷��� */

4. non equi join : Ű���� ��ġ�Ǵ� ���� ���� �������� ���ϴ� ��Ȳ�� ���
select e.last_name, e.salary, j.grade_level
from employees e, job_grades j
where e.salary = j.lowest_sal;

select e.last_name, e.salary, j.grade_level
from employees e, job_grades j
where e.salary = j.lowest_sal(+);

/* between */
select e.last_name, e.salary, j.grade_level
from employees e, job_grades j
where e.salary between j.lowest_sal and j.highest_sal; /* �������Ǽ��� */

=================================================================================

-- ansi 

/* cross join : cartesian product */
select employee_id, department_name
from employees cross join departments; 

/* ����Ŭ���� ī�׽þ��� �̹߻��ϴ� ��� : join */
select employee_id, department_name
from employees, departments;

select e.employee_id, d.department_name
from employees e, departments d
where e.department_id = d.department_id;

/* natural join */
select department_id, department_name, city
from departments natural join locations; 

�� ���� ���̺� �Ȱ��� �̸��� �÷��� ��� ã�Ƽ� �������� �����. (����Ŭ���� « ��Ű��)
   �׷��� ������ ����� �ʷ��� �� �ִ�. (�� : manager_id) 
   �׸��� �÷��� Ÿ���� �ٸ��� �����߻�(����ȯ ����) 

select d.department_id, d.department_name, l.city
from departments d, locations l
where d.location_id = l.location_id;

/* join using : natural join �������� */
select e.last_name, department_id, d.department_name -- using�� ���� ���� ��Ī ���ξ� ������
from employees e join departments d
using(department_id) -- ���ؿ��� ���̺� ��Ī ���ξ�� ������
where department_id = 50;

select e.last_name, d.department_name
from employees e, departments d
where d.department_id = e.department_id;

/* join on : equi, non, self */
select e.last_name, d.department_id, d.department_name
from employees e join departments d 
on e.department_id = d.department_id; -- �������Ǽ���

select e.last_name, d.department_id, d.department_name, l.city
from employees e join departments d 
on e.department_id = d.department_id
join locations l -- 3�� ���̺� ����
on d.location_id = l.location_id; 

/* left outer join */
select e.last_name, d.department_id, d.department_name
from employees e, departments d 
where e.department_id = d.department_id(+);

select e.last_name, d.department_id, d.department_name
from employees e left outer join departments d 
on e.department_id = d.department_id;

/* right outer join */

select e.last_name, d.department_id, d.department_name
from employees e, departments d 
where e.department_id(+) = d.department_id;

select e.last_name, d.department_id, d.department_name
from employees e right outer join departments d 
on e.department_id = d.department_id;

/* full outer join */

select e.last_name, d.department_id, d.department_name
from employees e, departments d 
where e.department_id(+) = d.department_id
union
select e.last_name, d.department_id, d.department_name
from employees e, departments d 
where e.department_id = d.department_id(+); -- �����ͷ��� �������� ���ϰ� �������� ����

select e.last_name, d.department_id, d.department_name
from employees e full outer join departments d 
on e.department_id = d.department_id; -- �� ���� ����϶�(�߿�)

/* ���� : �� ������ ansi ǥ������ Ǯ��� */

=================================================================================

[����35] 2006�⵵�� �Ի��� ������� �μ��̸����� �޿��� �Ѿ�, ����� ����ϼ���.
select * from employees where to_date('20060101','yyyymmdd') <= hire_date and to_date('20070101','yyyymmdd') > hire_date;

select d.department_name, sum(e.salary), round(avg(e.salary),1)
from employees e, departments d
where e.department_id = d.department_id
and (to_date('20060101','yyyymmdd') <= e.hire_date and to_date('20070101','yyyymmdd') > e.hire_date)
group by d.department_name;

select department_name, sum(salary), round(avg(salary),1)
from employees join departments
using(department_id)
where to_date('20060101','yyyymmdd') <= hire_date and to_date('20070101','yyyymmdd') > hire_date
group by d.department_name;

select d.department_name, sum(e.salary), round(avg(e.salary),1)
from employees e join departments d
on e.department_id = d.department_id
and to_date('20060101','yyyymmdd') <= e.hire_date and to_date('20070101','yyyymmdd') > e.hire_date
group by d.department_name;

[����36] 2006�⵵�� �Ի��� ������� �����̸����� �޿��� �Ѿ�, ����� ����ϼ���.

select l.city, sum(e.salary), round(avg(e.salary),1) 
from employees e, departments d, locations l
where (to_date('20060101','yyyymmdd') <= e.hire_date and to_date('20070101','yyyymmdd') > e.hire_date) and
e.department_id = d.department_id
and d.location_id = l.location_id
group by l.city;

select city, sum(salary), round(avg(salary),1)
from employees join departments
using(department_id)
join locations
using(location_id)
where to_date('20060101','yyyymmdd') <= hire_date and to_date('20070101','yyyymmdd') > hire_date
group by l.city;

select l.city, sum(e.salary), round(avg(e.salary),1) 
from employees e join departments d
on e.department_id = d.department_id
join locations l
on d.location_id = l.location_id
where (to_date('20060101','yyyymmdd') <= e.hire_date and to_date('20070101','yyyymmdd') > e.hire_date)
group by l.city;

[����37] 2007�⵵�� �Ի��� ������� �����̸����� �޿��� �Ѿ�, ����� ����ϼ���.
       �� �μ� ��ġ�� ���� �ʴ� ������� �޿��� �Ѿ�, ��յ� ���ϼ���.
       
select * from employees where to_date('20070101','yyyymmdd') <= hire_date and to_date('20080101','yyyymmdd') > hire_date;       
       
select l.city, sum(e.salary), round(avg(e.salary),1)
from employees e, departments d, locations l
where (to_date('20070101','yyyymmdd') <= e.hire_date and to_date('20080101','yyyymmdd') > e.hire_date)
and e.department_id = d.department_id(+)
and d.location_id = l.location_id(+)
group by l.city;
       
select l.city, sum(e.salary), round(avg(e.salary),1)
from employees e left outer join departments d
on e.department_id = d.department_id
left outer join locations l
on d.location_id = l.location_id
where to_date('20070101','yyyymmdd') <= e.hire_date and to_date('20080101','yyyymmdd') > e.hire_date
group by l.city;       
       
       