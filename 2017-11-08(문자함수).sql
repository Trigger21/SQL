<���� 9> �޿�(salary)�� 5000 ~ 12000�� ������ ������ �ʴ� ��� ����� ��(last_name) �� �޿�(salary)�� ��ȸ�ϼ���.
select last_name, salary from employees where salary not between 5000 and 12000;

<���� 10> Matos �� Taylor��� ��(last_name)�� ���� ����� ��(last_name), ���� ID(job_id), ä�� ��¥(hire_date)�� ��ȸ�ϼ���.
select last_name, job_id, hire_date from employees where last_name = 'Matos' or last_name = 'Taylor';

<���� 11> job_id�� SA�� �����ϰ� 10000 �̻��� �޿��� �޴� ����˻��� ��ȸ�ϼ���.(employees)
select * from employees where job_id like 'SA%' and salary >= 10000;

<���� 12> last_name�� ����° ���ڰ� 'a' �Ǵ� 'e'�� ���Ե� ��� ����� ��(last_name)�� ��ȸ�ϼ���.
select last_name from employees where last_name like '__a%' or last_name like '__e%';
select last_name from employees where substr(last_name, 3, 1) in('a', 'e');

<���� 13> 2006�⵵ �Ի��� ����� �����ȣ(employee_id), ��(last_name), �Ի��� ��¥(hire_date)�� ��ȸ�ϼ���.
select employee_id, last_name, hire_date from employees where hire_date >= to_date('20060101','yyyymmdd') and hire_date < to_date('20070101','yyyymmdd');
�� to_date : ���� �� ��¥ ����ȯ ��
-- select * from nls_session_parameters; �����ؼ� �ش����� ��¥ ���信 �°� �ۼ��ؾ��� ����Ŭ�� ���������� to_date ���
-- �⵵�� �̾Ƴ����� to_char(hire_date,'yyyy') = '2006' ����ȯ���� ���� full scan �� ���ɼ��� ����
-- sysdate : �ú��� �� �����ִ�

<���� 14> 80�� �μ�(department_id) ����߿� commission_pct ���� 0.2 �̰� job_id�� SA_MAN�� ����� employee_id, last_name, salary�� ��ȸ�ϼ���.
select employee_id, last_name, salary from employees where department_id = 80 and commission_pct = 0.2 and job_id = 'SA_MAN';

=========================================================================================================================================================

-- in �����ڿ� null ����
select * from employees where employee_id in(100, 200, null);
select * from employees where employee_id = 100 or employee_id = 200 or employee_id = null;
�� ��ȸ����

-- in �����ڿ� not ���� (not in)
select * from employees where employee_id not in(100, 200, null);
select * from employees where employee_id <> 100 and employee_id <> 200 and employee_id <> null;
�� ��ȸ�Ұ�(null ���� ������ ����)

-- ���� ������� ������ ��ȣ
select manager_id from employees;
�� null���� ceo(��, ceo�� ���� �����Ѵٴ� ���ΰ�? �翬�� ����)

-- ������ ������� �˻�(�������� ���)
select * from employees where employee_id in(select manager_id from employees);
�� �������� ( )�� ��������, null ���� �����ϰ� �����Ƿ� in ������ ���

-- null �� ������(is null / is not null)
select * from employees where manager_id is null;
select * from employees where department_id is null;
select * from employees where manager_id is not null;

�� ���ǻ���
select * from employees where employee_id is null
�� employee_id�� primary key �̱⶧���� null ����Ұ� 

-- �����ڰ� �ƴ� ��� �˻�
select * from employees where employee_id not in(select manager_id from employees where manager_id is not null);

-- �������� �켱����(and > or > not)
select * from employees where employee_id = 100 or employee_id = 200 and salary > 10000;
�� employee_id = 200 and salary > 10000 ���� �����

select * from employees where (employee_id = 100 or employee_id = 200) and salary > 10000;
�� ( ) ���� �����

-- �����ϱ�(order by)
�� select �˻��� �÷� from ���̺�� where �˻����� order by ������ �÷�(�÷��̸�, ��Ī, ǥ����, ��ġǥ���) asc(��������, �⺻��) desc(��������)

select employee_id, last_name, salary from employees order by salary;
�� order by ���� �������� ó��, �⺻�� ��������
�� ... order by salary asc;(��������) / ... order by salary desc;(��������)

select employee_id, last_name, salary * 12 from employees order by salary * 12;
�� ǥ����
select employee_id, last_name, salary * 12 ann_sal from employees order by salary * 12;
�� ��Ī(ann_sal)
select employee_id, last_name, salary * 12 ann_sal from employees order by ann_sal;
�� ����Ī(ann_sal)

�� ���ǻ���
select employee_id, last_name, salary * 12 "ann_sal" from employees order by "ann_sal";
�� " " ��ġ
select employee_id, last_name, salary * 12 "ann_sal" from employees order by 3;
�� ��ġǥ���(3�� salary * 12)

select department_id, last_name, salary * 12 "ann_sal" from employees order by 1 asc, 3 desc;
�� ��ġǥ��� ����(�μ��� ��������, �μ��� �޿� ��������)

select employee_id from employees order by 1;
select employee_id from employees order by 1 desc;
�� �̹� index�� ���ĵǾ����Ƿ� leaf���� full scan �Ѵ�.

-- �ּ�(��)�� ���ϱ�(min/max �˰���)
select min(employee_id) from employees;
select max(employee_id) from employees;
�� index�� ���ĵǾ �ּ�(��)�� ���� ã��(�ּҰ� : ����, �ִ밪 : ����)

-- select * from user_ind_columns; index ����Ȯ��

/* 
- �ߺ����� Ű���� : distinct
- ���Ῥ���� : ||
 ���� || ���� �� ����
 ���� || ���� �� ���� || to_char(����) �� ����
 ���� || ��¥ �� ����
 ���� || NULL �� ����
- ��������� : * / + - (�켱���� 1 : * /, 2 : + -)
- �񱳿����� : =, <, >, <=, >=, <>, !=, ^=
- �������� : and, or, not
- ��Ÿ�񱳿�����
   between ������ and ū�� ( >= and <= )
   in ( ~ or ~ )
   like (wild card : %, _ )
   is null
*/

-- �Լ� : ����� ���α׷�
1. �������Լ�(�ϳ��� ����־ �ϳ��� ó���ϴ�), �׷��Լ�(������ ����־ �ϳ��� ����)
ex)
select lower(last_name) from employees;
�� �������Լ�
select min(salary) from employees;
�� �׷��Լ�

2. �����Լ�
-- ��ҹ��� ��ȯ�Լ�
lower(last_name) : �ҹ���, upper(last_name) : �빮��, initcap(last_name) : ù���ڸ� �빮��

-- ���ڸ� �����ϴ� �����Լ�
concat(last_name, first_name) : last_name || first_name ���� ����� ���ڸ� �����ϴ� �Լ�(�μ��� �ΰ��� ����)
select concat(last_name, first_name) from employees;

substr(last_name, 1, 2) : ���ڸ� �����ϴ� �Լ�(��ŸƮ ����, ���� ��)
substr(last_name, -2, 2) : ���ڸ� �����ϴ� �Լ�(��ŸƮ ����, ���� ��)
  k i n g
  1 2 3 4
 -4-3-2-1
select last_name, substr(last_name, 1, 1) from employees;
�� ����Ǵ� ������ �¿��� ���

select * from nls_database_parameters;
�� XE�� �̱��� �������� ����

select substr('hong', 1, 2), substr('ȫ�浿', 1, 2) from dual;
select substrb('hong', 1, 2), substrb('ȫ�浿', 1, 3) from dual;
�� b = byte �� �������� ���� ����(�ѱ��ڴ� 3byte)
select substrc('hong', 1, 2), substrc('ȫ�浿', 1, 2) from dual;

-- ����Ÿ��
/* NLS_CHARACTERSET AL32UTF8(���� 1byte, �ѱ� 3byte) */
varchar2 : ����, �Է��� ũ�� ����� ��ŭ�� ������ ��(����� ����)
char : ����, ����� �׷��� ��(������Ʈ���� ����ϰ� �߻��Ǵ� ���ڿ��� �̰ɷ�)

NLS_NCHAR_CHARACTERSET AL16UTF16
nvarchar2 : national ��
nchar
�ѱ�, ����, �Ͼ�, ��� �ִ� MS ���ü�� NLS_CHARACTERSET = KO16MSWIN949(���� 1byte, �ѱ� 2byte)

select * from user_objects where object_name = 'EMPLOYEES';
�� object_id ó�� ���鶧 ����
�� data_object_id�� �ٸ��� �籸���� ��

-- length(������ ���� �� ũ��)
select last_name, length(last_name) from employees;
select length('hong'), length('ȫ�浿') from dual;
select lengthb('hong'), lengthb('ȫ�浿') from dual;
�� b = byte �� �������� ũ�� ����(�ѱ��ڴ� 3byte)

-- instr(������ ��ġ����)
select instr('aabbcc', 'b') from dual;
�� ù��° b ��ġ

select instr('aabbcc', 'b', 1, 1) from dual;
�� ù��° b ��ġ

select instr('aabbcc', 'b', 1, 2) from dual;
�� �ι�° b ��ġ

-- replace(ġȯ�Լ�)
select replace('100-001', '-', '%') from dual;
�� - �� % ��
select replace('  100  001  ', ' ', '') from dual;
�� ����� ����

-- trim(���ӵǴ� ���� �� ���̸� ���� ����)
select trim('a' from 'aabbcaa') from dual;
�� �Ѵ�

select ltrim('aabbcaa', 'a') from dual;
�� ���ʸ�

select rtrim('aabbcaa', 'a') from dual;
�� ���ʸ�

select replace('aabbcaa', 'b') from dual;
/*
�� ����� ����� ����, ������� replace Ȱ��
�� dual : �Լ� �� ������ ���̺� ���� ���� �����ϱ� ���� 'dummy' ���̺�
          ���� ������� ���� �ӽ��� ����
          1. ����Ŭ�� ���ؼ� �ڵ����� �����Ǵ� ���̺�
          2. sys��Ű���� ������ ��� ����ڰ� ������ ����
          3. VARCHAR2(1)�� ���ǵ� dummy��� �ϴ� �ϳ��� �÷�
          4. �Լ� �� ����� ������ �� �ӽû�뿡 ����
*/