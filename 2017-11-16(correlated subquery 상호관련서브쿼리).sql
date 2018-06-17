[����53] department_name�� IT �μ��� ��� ����� ���� employee_id, last_name, job_id ����ϼ���(��������, ����)

/* subquery */
select employee_id, last_name, job_id
from employees
where department_id 
      = (select department_id from departments where department_name = 'IT');

/* join */
select e.employee_id, e.last_name, e.job_id
from employees e, departments d
where e.department_id = d.department_id
and d.department_name = 'IT';

select employee_id, last_name, job_id
from employees join departments
using(department_id)
where department_name = 'IT';

[����54] ��ü ��� �޿����� ���� �޿��� �ް� last_name�� "u"�� ���Ե� ����� �ִ� �μ����� �ٹ��ϴ� 
��� ����� employee_id, last_name, salary ����ϼ���

select employee_id, last_name, salary
from employees
where salary > (select avg(salary) from employees)
and department_id in (select distinct department_id from employees where instr(last_name,'u') > 0);

/* M�� �� 1��(��������) ���� ��쿡�� JOIN�� �ǽ�, �� �ܿ��� X */

[����55] ������ ������� ������ ������ּ���.
/* subquery */
select *
from employees
where employee_id in (select /*+ no_unnest */ manager_id from employees);

/*+ no_unnest */ : semi ������ ���ͼ���� Ǯ����~ ��Ʈ��(�����ȹ ����)

/* self join */
select distinct m.* -- distinct �����;��� ������ ��� ������ �ȴ�(����δ�) 
from employees e, employees m
where e.manager_id = m.employee_id;

-- ����δ� ��
select w.*e.ma
from (select distinct manager_id
      from employees) m, employees w
where m.manager_id = w.employee_id;

-- ���� : inline view(from�� subquery)

select w.*
from (select manager_id
      from employees) m, employees w
where m.manager_id = w.employee_id; 

[����56] �����ڰ� �ƴ� ������� ������ ������ּ���.

select *
from employees
where employee_id not in (select manager_id from employees where manager_id is not null);
/* not in �� <> all ����. */

================================================================================

-- �ֺ�(���߿� ������ ��������)
select *
from employees
where (manager_id, department_id) in (select manager_id, department_id
                                      from employees
                                      where first_name = 'John');
                                      
/* �������� ���� ������ ���� �������� ���� �� */
ex. 
100 10 �� 100 10
200 20 �� 200 20
300 30 �� 300 30
300 10
                                      
-- ��ֺ�
select *
from employees
where manager_id in (select manager_id
                     from employees
                     where first_name = 'John')
and department_id in (select department_id
                      from employees
                      where first_name = 'John');

/* �������� ���� ���� ���� �������� ���� ��(�ֺ񱳶� ����� �ٸ�) */

[����57] �ڽ��� �μ� ��ձ޿����� �� ���� �޴� ��� ������ּ���(��Ʈ : �������� ���� ����, ���� ������ ����)
/* ��ȣ���� ��������(��� ��������) : ��ø���������� �����ݴ� */
select e.*
from employees e
where e.salary > (select avg(salary) 
                  from employees 
                  where department_id = e.department_id/*����*/);

1. ������������ ���� ����(��� ���̺� ����)
2. ù��° ���� �ĺ������� ��´�(���ϱ� ���� ����)
3. �ĺ��� ���� �������� ���� ����
4. �ĺ��� ���� ������ �������� �� ����
5. �ĺ����� ��� �ִ� ���ϰ� ��
6. N������ ��� �ݺ� (���� �ĺ��� ���� �����ϴٸ� ���ʿ��� �ݺ��������� ���ϰ� �߻�)

-- �������
nested subquery(��ø��������) : ���������� ���� ������ ���� �������� ���
correlated subquery(��ȣ���ü�������) : ���������� �÷��� �������� �ȿ� �ִ� ���

-- ��������(�μ��� ��ձ޿�)�� �̿��ؼ� �ذ� : ���� �������� �ᵵ ����Ŭ�� �ڵ����� �Ʒ��� ��ȯ��Ŵ(�ӽŷ���)

select e2.*
from (select department_id, avg(salary) avgsal /* �������̺� �÷��� �� ��Ī���� ǥ�� */
      from employees
      group by department_id) e1, employees e2
where e1.department_id = e2.department_id
and e2.salary > e1.avgsal;

[����58] �μ��̸����� �Ѿ� �ݿ��� ���ϼ���.
/* inline view(����Ǯ��) : �� + ���� */
select d.department_name, e.sum_salary
from (select department_id, sum(salary) sum_salary
      from employees
      group by department_id) e, departments d
where e.department_id = d.department_id;

/* inline view(����Ǯ��) */
select d.department_name, sum(e.salary)
from (select department_id, department_name
      from departments) d, employees e
where d.department_id = e.department_id
group by d.department_name; -- group by�� ���� ������

/* join : ���� + �׷� + �� */
select d.department_name, sum(e.salary)
from employees e, departments d
where e.department_id = d.department_id 
group by d.department_name; 

/* ��� : �� ��쿡 inline view �� join�� ���� �Ϸ��� ����. ��ü ���̺��� ����ϱ⿡
         ���ϰ� ����Ǵ� ��� ����ؼ� ����ϰ��� �� �� inline view */

================================================================================
/* �������� ��� ��ȸ�ϴ� ���� */
select *
from employees
where employee_id in (select /*+ no_unnest */ manager_id from employees);
-- 1�� �� M�� ���ؼ� ã���� break ����� �� �� ������? �Ʒ��� ��

/* ��ȣ���ü������� : ���۰͸��� �ƴϴ�(exists�� ����Ѵٸ�) */
select *
from employees e
where exists (select 'x'
              from employees
              where manager_id = e.employee_id);
              
�� exists : ���翩�θ� Ȯ���ϴ� ������(boolean) / �ĺ��� ���� �������������� ã�ƺ��� ������ TRUE �˻�����
            �հ� ���������� �÷��� ���� �ȵ�(��, �������� �����ϱ� ���� ���ǹ� �� ���´�('x',1,...))

select *
from employees e
where not exists (select 'x'
                  from employees
                  where manager_id = e.employee_id);

================================================================================
/* ������ �μ����� �ݺ��Ǵ� �÷��� ���� join�� �� �� �߻��Ǵ� ������ */
select e.last_name, e.department_id, d.department_id, d.department_name
from employees e, departments d
where e.department_id = d.department_id /* ������ �μ����� ���� �μ����̺� ���� �ʰ� ĳ�ÿ� �ִ� ���� �ִ� ����� ����? */
order by 2, 3;
-- department_name�� ã�������� �����μ� ����� �� ã�ƾ� �Ѵ�.(���ʿ��� IO �߻�)

/* skalar subquery : query cache�� �ִ� subquery */
select e.last_name, e.department_id, (select department_name
                                      from departments
                                      where department_id = e.department_id) -- cache���, e.department_id : ����
from employees e
order by 2;


1. ���Ͽ�, ������ ���� ���� / ������ ���߿� return �ȵ� �� �׷��� �ؾߵȴٸ� ||���� ���� �ϳ��� ������
2. �������Լ�ó�� �����ؼ� skalar ǥ���� �̶�� �Ѵ�
3. �ߺ��� �ִ� ������ ��� �Ѵ�. �ƴϸ� ĳ�ø� Ŀ���� ���� ������

/* DBA�� �˾ƾ� �Ѵ� */
scalar subquery 
- scalar subquery ǥ������ �� �࿡�� ��Ȯ�� �ϳ��� �� ���� ��ȯ�ϴ� subquery
- ����Ƚ���� �ּ�ȭ�Ϸ��� �Է°��� ��°��� query execution cache�� ����
- 9i������ 256�� cache, 10g "_query_execution_cache_max_size" parameter�� ������ cache size �����ȴ�.(�� �̻��̸� �о��� ó��)
alter session set "_query_execution_cache_max_size"= 65536; -- �⺻��
alter session set "_query_execution_cache_max_size"=131072;

�����Ǵ�
select count(distinct department_id) from employees;
select count(distinct department_name) from departments;

[����59] �μ��̸����� �Ѿױ޿�, ��ձ޿��� ���ϼ���.(��, skalar subquery ���)
select d.department_name,
       (select sum(salary) from employees where department_id = d.department_id),
       (select avg(salary) from employees where department_id = d.department_id)
from departments d;
-- ��� d.department_id�� 1���̶� cacheȿ���� �� ������ join ���� ���ɿ��� ���� ����̶�� ���� ����
-- group by�� ������� �ʾƵ� �Ǽ� ����

select d.department_name,
       (select sum(salary) || ' ' || avg(salary) from employees where department_id = d.department_id)
from departments d;

select * from departments;