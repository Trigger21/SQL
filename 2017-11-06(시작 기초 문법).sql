-- ����Ŭ �ٿ� ���� ��(��ȣ ���� : oracle)
cmd â ����
sqlplus sys/oracle as sysdba -- �ý��� ����(�ֻ���)���� ����

select * from dba_users; 
alter user hr identified by hr account unlock; (expired/locked ����)
===================================================================
select * from tab;

desc employees

select * from employees;

-- select �� ��� : projection(column), selection(row), join(���� �ٸ� ���̺��� ������)

=================================================================================================================================================

- ������ SQL���� ���� : 

1. ��ҹ���, ����, tab key, enter key ��ġ

2. �ּ� -- /* */

3. ��Ʈ /*+  */ �����ȹ�� �����ϴ� ���

4. �����, ���ͷ���(���ڰ�) ���� (select first_name || ',' || last_name from employees; / select 'My name''s ' || first_name || ' ' || last_name from employees;)

|| : ���� Ÿ�� �´°ɷ�(����+����, ����+����-> no)

==================================================================================================================================================

- ���ڿ� ���� ���

select department_name || ' Department is manager id:' || manager_id from departments;

select department_name || ' Department''s manager id:' || manager_id from departments;

select department_name || q'[ Department's manager id:]' || manager_id from departments;

select department_name || q'< Department's manager id:>' || manager_id from departments;

select department_name || q'! Department's manager id:!' || manager_id from departments;

select department_name || q'{ Department's manager id:}' || manager_id from departments;

select department_name || q'( Department's manager id:)' || manager_id from departments;

select department_name || q'+ Department's manager id:+' || manager_id from departments;

====================================================================================================================================================

last_name || first_name : ǥ����

select last_name || first_name name from employees; 
SELECT last_name || first_name as name FROM employees;
: ����Ī(�� �̸� NAME)

SELECT last_name || first_name as "name" FROM employees;
(�� �̸� name)

select last_name || first_name "�̸�@" from employees;

====================================================================================================================================================

- ��������� : * : ����, / : ������, + : ����, - : ����

number : ���δ� ����

date : +, -

char : ���Ұ�

select employee_id, last_name, salary, salary * 12 , salary / 2, salary + 100, salary - 100 from employees;

- �켱���� 

 1���� : *, /
 2���� : +, -

ex) (((a * b) / c) + d)

- �ٸ�����

select power(10,2)
from dual; -- 10^2 

====================================================================================================================================================

- nvl : Null ���� ���� ������ ��ü�ϴ� �Լ� ex) nvl(x , y) �� x, y �� ��ġ
select last_name, salary, commission_pct, salary * 12 + commission_pct from employees;
select last_name, salary, commission_pct, salary * 12 + nvl(commission_pct,0) from employees;
(Null �� 0)

- to_char : ����ȯ �Լ�(���� �� ����)
select last_name, nvl(commission_pct, 'no comm') from employees; 
(X) : commission_pct ����

select last_name, nvl(to_char(commission_pct), 'no comm') from employees; 
(O)

- ����/�� ���
select employee_id, salary, to_char(salary, '999,999.00') from employees; -- (���ڸ� �� , / �Ҽ��� ǥ���ϴ� ���) - 9�� ���� �ȳ�����
select employee_id, salary, to_char(salary, '000,999.9') "SALARY" from employees; -- 0�� 0�� ����ä�쵵��

select employee_id, salary, to_char(salary * 12 + nvl(commission_pct,0), '000,999.9') "Salary" from employees; -- (������ ���� ��Ĵ��)
select employee_id, salary, to_char(salary * 12 + nvl(commission_pct,0), 'l900,999.9') "Salary" from employees;-- (l : ����������� �������� ���� ȭ���ȣ �ٲ�)

=====================================================================================================================================================

select department_id from employees;

-- �ߺ��� ���� ���
select distinct department_id from employees;(Hash �˰��� ����)

=====================================================================================================================================================

--���� �����ϴ� ���(where ���)
select * from employees where employee_id = 100; (�񱳿����� = , > , >= , < , <= , <> , != , ^=)

select * from employees where last_name = 'King';(���ڷ� ã��, ��ҹ��� ����)

--lower / upper / initcap�Լ� ���(�Է¿� ���) �ش�ҹ��� ����!!
select * from employees where last_name = 'king';(index ����)

last_name �� ���� ���� ���ڿ� ������ ���� ��ҹ��� ��ȯ�� �ǽ��ϰ� ��ü��(��ȿ����) �� �Է½� ������ �������� ���Ե� �� �ֵ��� ����
select * from employees where lower(last_name) = 'king';(����)
select * from employees where upper(last_name) = 'KING';(����)
select * from employees where initcap(last_name) = 'King';(����)

=====================================================================================================================================================

-- ��¥�� ���������� ������ ���ӵ�, �ΰ��ϰ� �����϶�

select * from nls_session_parameters; --(nls ��������)

- to_date : char �� date (oracle ���������� ����)
select * from employees where hire_date = to_date('2002-06-07','yyyy-mm-dd');
select * from employees where hire_date = to_date('20020607','yyyymmdd'); (������������� ��ȸ����)
select * from employees where hire_date = to_date('06072002','mmddyyyy');

=====================================================================================================================================================

�������� : and, or, not

and : 
select * from employees where salary >= 10000 and salary <= 20000; [10000, 20000]
select * from employees where salary between 10000 and 20000; 

or : 
select * from employees where employee_id = 100 or employee_id = 200; 
select * from employees where employee_id in(100,200);

not :
select * from employees where salary not between 10000 and 20000; (10000 �̸�, 20000 �ʰ�)
select * from employees where employee_id not in(100,200); (100, 200 ����)

=====================================================================================================================================================