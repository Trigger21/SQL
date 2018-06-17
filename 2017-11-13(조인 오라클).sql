[����28] ����� department_id�� 60 �Ǵ� 80�̸� ����� 10000�� �Ѵ� �޿��� �޴� ����� ��ȸ�ϼ���.
SELECT * FROM employees WHERE salary > 10000 AND (department_id IN(60,80));

[����29] job_id�� �������� �Ѿױ޿��� ���մϴ�. �� CLERK���ڰ� �ִ� job_id�� �����ϰ� �Ѿױ޿��� 
        13000�� �Ѵ� ������ ����ϸ鼭 �Ѿ� �޿��� �������� �������� �����ϼ���.
SELECT job_id,
  SUM(salary)
FROM employees
WHERE job_id NOT LIKE '%CLERK%'
GROUP BY job_id -- 10g ���� hash �˰������� ó��, �׷��� ������ �� �Ǿ ����
HAVING SUM(salary) > 13000 
ORDER BY 2 DESC; 

=====================================================================================

select department_id, sum(salary)
from employees 
where department_id in(20,30)
group by department_id;

select department_id, sum(salary)
from employees
group by department_id
having department_id in(20,30); /* �߸��� �� : ó�������� ����ؾ� �� */

======================================================================================

/* �� ���, �μ� ���̺� �и��� ������? */
select employee_id, department_id from employees;
select department_id, department_name from departments; 

�� ���̺� ���� : ���������� ���ؼ� 1. UPDATE 2. DELETE 3. ���丮�� ���� 4. block �ʰ�����
�� ���̺� �и� : ����ȭ �۾�
desc employees;

-- JOIN : �ΰ� �̻��� ���̺��� �����͸� �������� ���
�� ������ ���̺��� ��ġ�Ǵ� Ű ��(�������)�� ���ؼ� ����
1. ������ �̸��� �÷� ã�ƶ�(��, dep���� manager_id�� �μ���, emp������ ���)
2. �������, ���̺��� �ľ� ���϶�

select * from departments where department_id = 50; /* �μ����� 121 */
select * from employees where department_id = 50;


select employee_id, department_name 
from employees, departments /* ���� : emp_id�� 107��, dep_id�� 27�� */
order by 1; 
/* cartesion product */
- ���������� ������ �Ǿ��� ���
- ���������� �������ϰ� ���� ���
��� : ù��° ���̺� �� * �ι�° ���̺� �� �� �߻���Ű�� �ȵ�

## ��������
1. equi join(simple join, inner join, �����) : Ű���� ��ġ�Ǵ� ������ �̾Ƴ��� ����

select employee_id, department_name
from employees, departments
where department_id = department_id; /* �������Ǽ��� */

- parse : ������
 �� sysntax : select, from, where check!! (Ű���� Ȯ��)
 �� semantic : ���̺� ���翩��, ���� ���翩��(���̺�,�� 1:1 ��), �ǹ̺м�

select employees.employee_id, departments.department_name /* ���̺� �� �����ʼ� */
from employees, departments
where employees.department_id = departments.department_id; /* ���̺� �� �����ʼ� */

�� semantic ���� ������, column ���Ǹ�ȣ ���� ����
�� ������ �� ������ ����Ŭ�� ����ϱ� ���� �޸� ��뷮�� ������

select e.employee_id, d.department_name 
from employees e, departments d /* ���̺� ��Ī ����(������ ����) */
where e.department_id = d.department_id /* M�� ����ó�� ���Ͷ� */
      /* M�� ���� */      /* 1�� ���� */
      and e.employee_id = 100; /* ���������Ǽ���(���������) */

select e.employee_id, d.department_name 
from employees e, departments d
where e.department_id = d.department_id /* M�� ����ó�� ���Ͷ� */
      /* M�� ���� */      /* 1�� ���� */
      and e.last_name = 'King'; /* ���������Ǽ���(���������:X) */
      
�� ������ ������ ���鼭 �޸� ��뷮�� ���� �� �ִ� ���̺� ��Ī ���
�� Ű���� ��ġ�Ǵ� �����͸� ����, ����� ������ �ʿ�����

select * from locations; /* �μ��� �ּҰ� */

select e.employee_id, l.street_address
from employees e, departments d, locations l
where e.department_id = d.department_id
and d.location_id = l.location_id; /* ¡�˴ٸ�(d�� ����) */

select e.employee_id, d.department_name 
from employees e, departments d
where e.department_id = d.department_id;

2. outer join : Ű���� ���� �����ͱ��� �̾Ƴ��� JOIN

select e.employee_id, d.department_name 
from employees e, departments d
where e.department_id = d.department_id(+); /* Ű�� ����ġ�� + ���� �� ������ �� �̾ƴ޶� */

select e.employee_id, d.department_name 
from employees e, departments d
where e.department_id(+) = d.department_id; /* �Ҽӻ���� ���� �μ����� �̾ƴ޶� */

�� ���������Ϳ� NULL�� �߰��Ǽ� ������ ���� (+)��� ��������(�� ����)

ex) 
       ��� ���̺�                            �μ� ���̺�                      �μ���ġ ���̺�
���  �̸�    �μ��ڵ�                  �μ��ڵ�   �μ��̸�    �μ���ġ            �μ���ġ   �ּ�
100  ȫ�浿    10                       10      �ѹ���      1000               1000   �����                  
101  ����ȣ    20                       20      ������      2000               2000   ��⵵
102  �����                             30      ������      3000               3000   ������

/* null, ����ġ�� equi ���� */

select e.employee_id, l.street_address
from employees e, departments d, locations l
where e.department_id = d.department_id(+) -- �� : emp ~ dep
and d.location_id = l.location_id(+); -- �� : ��_������� ~ loc
/*
�� �������      �� �������
100  1000       100  �����
101  2000       101  ��⵵
102  null       102  null
*/
�� �������� �� ������տ� �����Ǿ���� ������? �μ���ġ ���̵� �ľ�
�� ��������? select ��� ��

�ƹ��� �б����� ȫ�浿, ����ȣ, ����� �̶�� ���� �� �п���� �ֽ��ϴ�. ���� ���� �� �ƹ��� �б��� ���и� �Խ��ϴ�.
���� ������ ������ ��ġ�� ������ ���ư����� �ϴµ�, �������� ���ڱ� ���� �ҷ��� ȫ�浿, ����ȣ, ������� �� �޾ư� 
������ �����ֶ�� �߽��ϴ�. �׷��� �� 3���� ���� ġ�ڸ��� �ٷ� �������� ���� ģ���� ������ ã�ư��� ��ߵ� �� ���ƿ�.

3. self join 

ex) 
         ��� ���̺�(���)                                 ��� ���̺�(������)
���  �̸�    �����ڹ�ȣ  �μ��ڵ�                   ���  �̸�    �����ڹ�ȣ  �μ��ڵ�  
100  ȫ�浿     null     10                      100  ȫ�浿     null     10             
101  ����ȣ     100      20                      101  ����ȣ     100      20
102  �����     101     null                     102  �����     101     null

������� ������ �̸� �ľ� : ��� �̸� �����ڹ�ȣ �������̸�
                       100 ȫ�浿 null    null
                       101 ����ȣ 100     ȫ�浿
                       102 ����� 101     ����ȣ

select ���.���, ���.�̸�, ������.���, ������.�̸�
from ������̺� ���, ������̺� ������
where ���.�����ڹ�ȣ = ������.���;

select e1.employee_id, e1.last_name, e2.employee_id, e2.last_name
from employees e1, employees e2
where e1.manager_id = e2.employee_id;

select e1.employee_id, e1.last_name, e2.employee_id, e2.last_name
from employees e1, employees e2
where e1.manager_id = e2.employee_id(+);

