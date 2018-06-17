[����78] �� �μ� �ο����� ��ü �ο� ��� �����ϴ� ������ ����ϼ���.;

select department_id dept_id, round((count(*)/(sum(count(*)) over()+1))*100, 2) per
from employees
where department_id is not null
group by department_id;

-- ������ Ǯ�� : ratio_to_report() �Լ�
select department_id, cn, cn/107, ratio_to_report(cn) over() /* �������ϴ� �м��Լ� */
from (select department_id, count(*) cn
      from employees
      group by department_id)
order by 1;

-- �������
select department_id dept_id, round((cn/(sum(cn) over()))*100, 2) per
from (select department_id, count(*) cn
      from employees
      group by department_id)
order by 1;

-- �м��Լ� �ɼ�
SELECT employee_id, salary,
sum(salary) over (ORDER BY employee_id ) sum_sal1, /* ���� */
sum(salary) over (ORDER BY employee_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) sum_sal2, /* ���� */
sum(salary) over ( ) sum_sal3, /* ��ü�� */
sum(salary) over (ORDER BY employee_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) sum_sal4 /* ��ü�� */
FROM employees;


- ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING : ���İ���� ó���� ���� ���
- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW : ���İ�� ó������ ���� ������� ���

select department_id, salary, 
first_value(salary) over (partition by department_id order by salary rows between unbounded preceding and unbounded following) first,
/* �������� : ù��°, �������� : �������� */
last_value(salary) over (partition by department_id order by salary rows between unbounded preceding and unbounded following) last
/* �������� : ��������, �������� : ù��° */
from employees;

select department_id, salary, 
first_value(salary) over (partition by department_id order by salary) first,
/* �������� : ù��°, �������� : �������� */
last_value(salary) over (partition by department_id) last
/* �������� : ��������, �������� : ù��° */
from employees;

================================================================================

select employee_id, last_name, manager_id
from employees
order by 1;

/*
������?? �����غ���~  �����˻�����!! �Խ����� �ٷ� ���̺��̴�. ��ۿ� ����� �� ��
*/

select employee_id, last_name, manager_id
from employees
start with employee_id = 101 -- ������
connect by prior employee_id = manager_id; -- connect by : �����

select employee_id, last_name, manager_id
from employees
start with employee_id = 206 -- ������
connect by employee_id = prior manager_id; -- prior ��ġ�� ���� �ö󰥼��� ���������� �ִ�
                                           -- �ε��� �ɷ������� �ε��� Ǯ��ĵ�ؼ� �� ������

-- ��޺� �鿩����
select level, lpad('�� ',level*2-2,' ')||last_name
from employees        /*��������*/
start with employee_id = 100
connect by prior employee_id = manager_id;

select level, lpad(last_name,length(last_name)+level*2-2)
from employees                                /*��������*/
start with employee_id = 101
connect by prior employee_id = manager_id;

-- �����ϱ�
select employee_id, last_name, manager_id
from employees
where employee_id <> 101 -- 101�� �ุ ����
start with employee_id = 100
connect by prior employee_id = manager_id;

select employee_id, last_name, manager_id
from employees
start with employee_id = 100
connect by prior employee_id = manager_id
and employee_id <> 101; -- 101�� ���� ���������� ����(101�� ������ ����)

-- sys_connect_by_path(������,'���б�ȣ') : 1���� �ʵ忡 �������� ǥ���ϴ� �Լ�
select sys_connect_by_path(last_name,'/') path_1,
       ltrim(sys_connect_by_path(last_name,'/'), '/') path_2 /*ltrim : ���ӵǴ� ����(/)�� ���� ����*/
from employees
start with employee_id = 100
connect by prior employee_id = manager_id;

================================================================================

select department_id, last_name
from employees
order by 1;

-- ���� ������ �μ��� �̸����� ��Ÿ����(���η� ���) : listagg(������,'����') within group(order by ����)
select department_id, listagg(last_name,',') within group(order by last_name)/*���η� ����ϴ� ���*/
from employees
group by department_id;

================================================================================
/*
database(�����Ͱ� ����Ǵ� ����(����))                       OS(������)
   ��                                                          ��
tablespace(��������)                                         datafile
   ��                                                          ��
segment = object �� ��������� �ʿ��� ��(table, index)            
   ��
extent
   ��
block(����Ŭ �ּ� I/O����)                                    os block 

���� : � SQL ������ ������ �� �ִ� �Ǹ�
*/
-- DBA�� ���� ��ȸ : ������ HR�� �� ���� ����, ������ ��������
select * from session_privs; /* �ý��۱��� Ȯ�� */
select * from user_sys_privs; 
select * from dba_sys_privs;
select * from user_tab_privs;

�����ڷ� ���� object ���� �޾ƾ� å�� ���ĺ����ִ�.


-- ��������
create user ������ �ʿ�(DBA DB������);
/* 
���� : Ư���� SQL���� ������ �� �ִ� �Ǹ� 
- �ý��۱���(�����ͺ��̽��� ������ �ټ� �ִ�/DBA�� �ش�), 
- ��ü����(Ÿ���� ������ �ִ� �ٸ� ������ �����ϰ� �ִ� ���� ������ �ҷ���/�ٸ������� �ش�)

�� : ���� ���(������)
*/
-- �� ��ȸ
select * from session_roles;

-- �� �ȿ� �ý��� ���� ��ȸ
select * from role_sys_privs;

-- �� �ȿ� ������ ���� ��ȸ
select * from role_tab_privs;
