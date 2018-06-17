[����62] 1500 �μ� ��ġ�� �ٹ��ϴ� ������߿� 2007�⵵�� �Ի��� ������� �ٹ� ����, �μ� �̸�, �����ȣ, �Ի����� ����ϼ���.

select l.city, d.department_name, e.employee_id, e.hire_date
from employees e, departments d, locations l
where e.department_id = d.department_id
and d.location_id = l.location_id
and (e.hire_date >= to_date('20070101','yyyymmdd') and e.hire_date < to_date('20080101','yyyymmdd'))
and l.location_id = 1500;
-- inline view ���� ���� �ʾƵ� �� ��쿡�� ������(����Ŭ�� ũ�� ���� �ذ��Ѵٴ�...??)
/*
select (select city
        from locations
        where , department_name, employee_id, hire_date
from 

with
l_1500 as (select city, department_name, employee_id, hire_date 
           from 
h_2007 as (select hire_date from employees where hire_date >= to_date('20070101','yyyymmdd') and hire_date < to_date('20080101','yyyymmdd'))

select city, department_name, employee_id, hire_date
from l_1500
where h_2007
*/

[����63] job_history ���̺��� job_id�� �ѹ��̶� �ٲۻ������ ������ ����Ǿ� �ֽ��ϴ�.
         ������̺��� �ι��̻� job_id�� �ٲ� ��������� ����ϼ���.(correlated subquery)

select employee_id
from job_history
group by employee_id
having count(*) >1;

-- ������ Ǯ��
select e.*
from employees e
where 2 <= (select count(*)
            from job_history
            where employee_id = e.employee_id); 
            -- �����ɼ� �ִ� �κ�(�Ǽ��� ���ؾ� �Ǹ� ��������)

select * from user_ind_columns; /*index Ȯ��*/

[����64] job_history ���̺��� job_id�� �ѹ��̶� �ٲۻ������ ������ ����Ǿ� �ֽ��ϴ�.
         ������̺��� �ι��̻� job_id�� �ٲ� ��������� ����ϼ���.(����&inline view)
         
select e.*
from employees e,
     (select employee_id, count(*)
      from job_history
      group by employee_id
      having count(*) > 1) h
where e.employee_id = h.employee_id;

[����65] ������̺��� �� �μ����� �ο����� ����ּ���.

<ȭ����>

    10�μ�     20�μ�     30�μ�     40�μ�     50�μ�     60�μ�
---------- ---------- ---------- ---------- ---------- ----------
         1          2          6          1         45          5

select department_id, count(*) 
from employees
where department_id between 10 and 60
group by department_id;

select max(decode(dep_id, 10, cnt)) "10�μ�",
       max(decode(dep_id, 20, cnt)) "20�μ�",
       max(decode(dep_id, 30, cnt)) "30�μ�",
       max(decode(dep_id, 40, cnt)) "40�μ�",
       max(decode(dep_id, 50, cnt)) "50�μ�",
       max(decode(dep_id, 60, cnt)) "60�μ�"
from (select department_id dep_id, count(*) cnt
      from employees
      where department_id between 10 and 60 
      group by department_id); 
      
================================================================================

-- 11g���� ���� pivot : row�� data�� column���� �����ϴ� �Լ�
ex. 
dept_id  cn
10       1
20       2
30       10

10 20 30
-- -- --
1  2  10

/* �μ��� ����� */
select *
from (select department_id from employees) --inline view�� ���� ǥ���Ǿ�� ��
pivot(count(*) for department_id in (10 "10�μ�",20 "20�μ�",30 "30�μ�",40 "40�μ�",50 "50�μ�",60 "60�μ�")); --pivot���� ������ ǥ��

/* �μ��� �޿����� */
select *
from (select department_id, salary from employees) --inline view�� ���� ǥ���Ǿ�� ��
pivot(sum(salary) for department_id in (10 "10�μ�",20 "20�μ�",30 "30�μ�",40 "40�μ�",50 "50�μ�",60 "60�μ�"));

/* �μ��� �޿���� */
select *
from (select department_id, salary from employees) --inline view�� ���� ǥ���Ǿ�� ��
pivot(avg(salary) for department_id in (10 "10�μ�",20 "20�μ�",30 "30�μ�",40 "40�μ�",50 "50�μ�",60 "60�μ�"));

/* �μ��� �޿�ǥ������ */
select *
from (select department_id, salary from employees) --inline view�� ���� ǥ���Ǿ�� ��
pivot(stddev(salary) for department_id in (10 "10�μ�",20 "20�μ�",30 "30�μ�",40 "40�μ�",50 "50�μ�",60 "60�μ�"));

/* �μ��� �޿��л� */
select *
from (select department_id, salary from employees) --inline view�� ���� ǥ���Ǿ�� ��
pivot(variance(salary) for department_id in (10 "10�μ�",20 "20�μ�",30 "30�μ�",40 "40�μ�",50 "50�μ�",60 "60�μ�"));

-- unpivot �Լ� : pivot�Լ��� �ݴ밳������ column�� rowdata�� �����ϴ� �Լ�

select *
from (
      select *
      from (select department_id from employees)
      pivot(count(*) for department_id in(10,20,30,40,50,60))
      )
unpivot(cnt for dept_id in("10","20","30","40","50","60")); -- �ٽú���

select *
from (
      select *
      from (select department_id from employees)
      pivot(count(*) for department_id in(10 "10�μ�",20 "20�μ�",30 "30�μ�",40 "40�μ�",50 "50�μ�",60 "60�μ�"))
      )
unpivot(cnt for dept_id in("10�μ�","20�μ�","30�μ�","40�μ�","50�μ�","60�μ�"));

[����66] ������̺��� ���Ϻ� �Ի��� �ο����� ������ּ���.

<ȭ����>

   �Ͽ���     ������     ȭ����     ������     �����     �ݿ���     �����
--------- ---------- ---------- ---------- ---------- ---------- ----------
       15         10         13         15         16         19         19

select to_char(hire_date,'dy'), count(*)
from employees
group by to_char(hire_date,'dy');

select *
from (select to_char(hire_date,'day') day from employees) -- ���⼭�� �׳� �� ����� �Ի��� ���� �÷� ���� 
pivot(count(*) for day in('�Ͽ���','������','ȭ����','������','�����','�ݿ���','�����')); 
-- in ������ ������ ���� ��(�� �� �̸� ��ġ)���� ī��Ʈ �Ǹ鼭 ������ �Ǵµ�

select *
from (
     select *
     from (select to_char(hire_date,'day') day from employees) -- ���⼭�� �׳� �� ����� �Ի��� ���� �÷� ���� 
     pivot(count(*) for day in('�Ͽ���' "��",'������' "��",'ȭ����' "ȭ",'������' "��",'�����' "��",'�ݿ���' "��",'�����' "��"))
     ) /* unpivot�� �Ϸ��� ������ ��� ��Ī�� �����ؾ� �Ǵ� �� ���� */
unpivot(cnt for day in("��","��","ȭ","��","��","��","��"));


select *
from (select to_char(hire_date,'d') day from employees)
pivot(count(*) for day in(1 "�Ͽ���",2 "������",3 "ȭ����",4 "������",5 "�����", 6 "�ݿ���", 7"�����"));

select *
from (
     select *
from (select to_char(hire_date,'d') day from employees)
pivot(count(*) for day in(1 "�Ͽ���",2 "������",3 "ȭ����",4 "������",5 "�����", 6 "�ݿ���", 7"�����"))
     )
unpivot(cnt for day in("�Ͽ���","������","ȭ����","������","�����","�ݿ���","�����"));

================================================================================

-- ���տ����� : ���� �Ĺ� �������� �� �� Ÿ�� ��ġ �ʼ�

/* ������(union, union all : all�� ���) */
select employee_id, job_id
from employees
union -- �ߺ��� ����(��Ʈ �˰���)�� �� ���� : ������ ���� ������ ���� ���� �ʴ�.
select employee_id, job_id
from job_history;

select employee_id, job_id
from employees
union all -- �ߺ��� ������ �� ����
select employee_id, job_id
from job_history;

/* ������(intersect) : �ֺ�, 'join' �̳� 'exists' ��� */
select employee_id, job_id
from employees
intersect -- ����� �����͸� ��� : ���� ������ �̾��ٰ� �ѹ� �ߴٰ� �ٽ� ���������� ���� ����
select employee_id, job_id
from job_history;

/* ������(minus) : 'not exists' ��� */
select employee_id, job_id
from employees
minus -- �ѹ��� job_id ���� ����
select employee_id, job_id
from job_history
order by 1,2; -- ���������� �̷��� �ȴٰ� ��. ù��° ������ �÷��� �������� �����ؾ���.

-- �� ���ǻ��� : ��Ʈ��� ���۷����Ͱ� ���ư���. ���忡�� ���� ���� ����

select employee_id, job_id, salary sal -- ù��° �������� ��Ī����
from employees
union 
select employee_id, job_id, to_number(null) -- ���� salary �� 
from job_history
order by 1,2,3;

select employee_id, job_id, salary
from employees
union 
select employee_id, job_id, to_number(0) -- ���� salary �� 
from job_history;

select employee_id, job_id, salary
from employees
union 
select employee_id, job_id, null -- ���� salary �� 
from job_history;

select employee_id, job_id, salary
from employees
union 
select employee_id, job_id, 0 -- ���� salary �� 
from job_history;

================================================================================
[����67] �Ʒ��� ���� SQL���� ������ ������� �ʰ� Ʃ���ϼ���.
/*
select employee_id, job_id
from employees
intersect
select employee_id, job_id
from job_history;
*/
select e.employee_id, e.job_id
from employees e
where exists (select 1 
              from job_history 
              where employee_id = e.employee_id 
              and job_id = e.job_id); 

select e.employee_id, e.job_id
from employees e, job_history h
where e.employee_id = h.employee_id
and e.job_id = h.job_id;

/* �� intersect �� exists (or join) */

[����68] �Ʒ��� ���� SQL���� ������ ������� �ʰ� Ʃ���ϼ���.
/*
select employee_id, job_id
from employees
minus
select employee_id, job_id
from job_history
*/

select e.employee_id, e.job_id
from employees e
where not exists (select 1 
                  from job_history 
                  where employee_id = e.employee_id 
                  and job_id = e.job_id); 

/* �� minus �� not exists */
                
================================================================================

[����69] �Ʒ��� ���� SQL���� ������ ������� �ʰ� Ʃ���ϼ���.(union �� union all �ߺ��� ����)
/*
select e.employee_id, d.department_name
from employees e, departments d
where e.department_id = d.department_id(+)
union
select e.employee_id, d.department_name
from employees e, departments d
where e.department_id(+) = d.department_id;
*/
select e.employee_id, d.department_name
from employees e, departments d
where e.department_id = d.department_id(+)
union all
select null, d.department_name -- employee_id �ڸ��� null(�ٽ�)
from departments d
where not exists (select 1 
                  from employees -- ����� ���� �μ��� �̴� ������
                  where department_id = d.department_id);

/* �� union �� union all + not exists */
================================================================================
sum(salary)={department_id, job_id, manager_id} -- 3�� ���� ���� �޿�����
sum(salary)={department_id, job_id} -- 2�� ���� ���� �޿�����
sum(salary)={department_id} -- 1�� ���� ���� �޿�����
sum(salary)={} -- ��ü �޿����� 

select department_id, job_id, manager_id, sum(salary)
from employees
group by department_id, job_id, manager_id
union all
select department_id, job_id, null, sum(salary)
from employees
group by department_id, job_id
union all
select department_id, null, null, sum(salary)
from employees
group by department_id
union all
select null,null,null,sum(salary)
from employees;

/* ���� : ����(�����Ϳ����Ͽ�¡(�Ͽ콺) : ���굵����) */

sum(salary)={department_id, job_id, manager_id} 
sum(salary)={department_id, job_id} 
sum(salary)={department_id}
sum(salary)={} 

/* rollup : ���� �÷��� �������� �������� �ؼ� �������� �ϳ��� ����鼭 ���谪 ���� */
select department_id, job_id, manager_id, sum(salary)
from employees
group by rollup(department_id, job_id, manager_id);

================================================================================

sum(salary)={department_id, job_id, manager_id} 
sum(salary)={department_id, job_id} 
sum(salary)={department_id, manager_id}
sum(salary)={job_id, manager_id} 
sum(salary)={department_id}
sum(salary)={job_id} 
sum(salary)={manager_id}
sum(salary)={} 

/* cube : rollup ��� �����ϰ� ���հ����� ��츦 ���� ������ */
select department_id, job_id, manager_id, sum(salary)
from employees
group by cube(department_id, job_id, manager_id);

================================================================================

-- ���� ���ϴ� ���谪�� ���Ϸ��� ��¿��?
sum(salary)={department_id, job_id} 
sum(salary)={department_id, manager_id}

select department_id, job_id, null, sum(salary)
from employees
group by department_id, job_id
union all
select department_id, null, manager_id, sum(salary)
from employees
group by department_id, manager_id;

/* grouping sets : ���� ���ϴ� �׷� ���� */
select department_id, job_id, manager_id, sum(salary) -- �������� �׷���̿� 1�� �̻� �����
from employees
group by grouping sets((department_id, job_id), (department_id, manager_id));

sum(salary)={department_id, job_id} 
sum(salary)={department_id, manager_id}
sum(salary)={} 

select department_id, job_id, manager_id, sum(salary)
from employees
group by grouping sets((department_id, job_id), (department_id, manager_id), ()); -- () : ��ü��

================================================================================

