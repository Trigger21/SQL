<����15>
last_name�� "J" �Ǵ� "A" �Ǵ� "M"���� �����ϴ� �̸��� ���� ��� ����� last_name(ù��° ���ڴ�
�빮��, �������� ��� �ҹ���)�� last_name�� ���̸� ǥ���ϴ� query �� �ۼ��մϴ�.
�� �� ������ ����Ī�� �����մϴ�. ����� ��(last_name)�� �������� ����� �������� �����մϴ�.
select initcap(last_name) as "last name", length(last_name) as "length" 
from employees 
where substr(last_name, 1, 1) in('J','A','M') /* substr : ���� ���� */
order by 1;

select initcap(last_name) as "last name", length(last_name) as "length" 
from employees 
where last_name like 'J%' or last_name like 'A%' or last_name like 'M%' 
order by 1;

select initcap(last_name) as "last name", length(last_name) as "length" 
from employees 
where instr(last_name, 'J') = 1 or instr(last_name, 'A') = 1 or instr(last_name, 'M') =1 
order by 1; /* instr : ������ ��ġ����(����) ���� */

<����16>
department_id(�μ��ڵ�)�� 50�� ����� �߿� last_name�� �ι�° ��ġ�� "a"���ڰ� �ִ� ������� ��ȸ�ϼ���.
select * from employees where department_id = 50 and substr(last_name, 2, 1) = 'a';
select * from employees where department_id = 50 and last_name like '_a%';
select * from employees where department_id = 50 and instr(last_name, 'a', 1, 1) = 2;

-- index�� ���� �ٲ�� �Լ�, ��ҹ��� �ٲ�� �Լ��� ��ɻ�� ������ substr, instr�� �������(�Լ��� �����Ѵٰ� �� ��ǵǴ� �� �ƴ�)
-- select ���� �ʿ��� ���� ã�ƶ�(����)

select * from user_ind_columns;
-- view ��
select * from ind$;
-- ����Ŭ �ε��� ���� �ٰ��� ��¥ ���̺�(sys������ ����)

======================================================================================================================

-- �����Լ�
- round : �ݿø� �Լ�, round(����, ������� �ݿø�)
select 45.926, round(45.926, 0), round(45.926, 1), round(45.926, 2), round(45.926, 3), round(45.926, -1), round(45.926, -2) from dual;

 4 5.9 2 6
-1 0 1 2 3

- trunc : �����Լ�, trunc(����, ��������� ����)
select 45.926, trunc(45.926, 0), trunc(45.926, 1), trunc(45.926, 2), trunc(45.926, 3), trunc(45.926, -1), trunc(45.926, -2) from dual;

- mod : ���� �ƴ� ������ ���� ����ϴ� �Լ� /* ¦��, Ȧ�� �Ǻ��� �����ϰ� ���� */
select mod(10, 3) from dual;

<����17> employees ���̺� �ִ� employee_id, last_name, salary, salary�� 10% �λ�� �޿��� ����ϸ鼭 ���� �޿��� 
        �Ҽ����� �ݿø��ؼ� ���������� ǥ���ϰ� ����Ī�� New Salary�� ǥ���ϼ���.
select employee_id, last_name, round(salary * 1.10, 0) "New Salary" from employees;        

-- ��¥�Լ�
date : �������Ͻú��� 5�ڸ�
select * from nls_session_parameters; /* ���� ������ Ȯ��(������ ���� ����) */

- sysdate : ������ �ð������� ����ϴ� �Լ�
select sysdate from dual;
�� ������ ��¥�ð������� ����ϴ� ������
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss.sssss') from dual; /* 24�ð� ���� */
select to_char(sysdate,'yyyy-mm-dd hh:mi:ss.sssss am') from dual; /* 12�ð� ���� */

alter session set nls_date_format = 'yyyy-mm-dd hh24:mi:ss.sssss';
�� ���� ���ϴ� ��¥�𵨷� ��ȯ(�� session������ �����ִ� ���ȸ� ����)
select sysdate from dual;
select employee_id, hire_date from employees;
�� �����ѵ��� �ٲ�

- current_date : client�� ���� �ð������� ����ϴ� �Լ�
alter session set time_zone = '+08:00'; /* �̰����� ���� */
select sysdate "korea", current_date "singapore" from dual;

alter session set time_zone = '-05:00'; /* ���� ���� */
select sysdate "korea", current_date "new york" from dual;

�� os�� ������ �ð��븦 ������ ��, ����Ŭ�� �ð������� ������ �ִ� ���� �ƴ�

- ��¥���
��¥(DATE) + ����(NUM) = ��¥(DATE)
��¥(DATE) - ����(NUM) = ��¥(DATE)
select sysdate + 100, sysdate - 100 from dual;

��¥(DATE) - ��¥(DATE) = ����(NUM)
select sysdate - hire_date from employees;

�� ��¥(DATE) + ��¥(DATE) = ����
select sysdate + hire_date from employees;

��¥(DATE) �� �ð�/24 = ��¥(DATE)
��¥(DATE) �� ��/(24*60) = ��¥(DATE)
��¥(DATE) �� ��/(24*60*60) = ��¥(DATE)
select sysdate + 3/24, sysdate + 10/(24*60), sysdate + 30/(24*60*60) from dual;
/* 3�ð� ����, 10�� ����, 30�� ���� */

ex) ������� �Ի��Ϸ� ���� ������� �ٹ��Ⱓ�� �ִ��� ���
select trunc((sysdate - hire_date)/7) from employees;

ex) ������� �Ի��Ϸ� ���� ������� �ٹ��Ⱓ�� ������ ���
???
- months_between : �� ��¥���� �޼��� ������ִ� �Լ�
select months_between(sysdate, hire_date) from employees;
select months_between(hire_date, sysdate) from employees;

- add_months : �޼��� ���ϴ� �Լ�, (��¥,����)�� ��¥
select add_months(sysdate, 6) from dual;

- next_day : �����Ϸ� ���� ���� ����� ����(�̷�����)�� �ش��ϴ� ��¥���� ����ϴ� �Լ�(session �� ����)
select next_day(sysdate, '�ݿ���') from dual;

- last_day : �� ���� ������ ��¥����
select last_day(sysdate) from dual;

<����18> ����� last_name,hire_date �� �ٹ� 6 ���� �� ù��° �����Ͽ� �ش��ϴ� ��¥�� ��ȸ�ϼ���.
        ����Ī�� REVIEW �� �����մϴ�.
select last_name, hire_date, next_day(add_months(hire_date, 6), '������') "REVIEW" from employees; 

<����19> 15�� �̻� �ٹ��� ������� �����ȣ, �Ի糯¥, �ٹ��������� ��ȸ�ϼ���.
select employee_id, hire_date, trunc(months_between(sysdate, hire_date), 0) 
from employees 
where trunc((sysdate - hire_date)/365)>= 15;

select employee_id, hire_date, trunc(months_between(sysdate, hire_date), 0) 
from employees 
where  trunc((months_between(sysdate, hire_date))/12, 0)>= 15;

-- �� ��ü���� �����ε�(���� �̸�, �ٸ� ��� �Լ�) : round�� �μ����� ���� ���� 2�� �̻��� ��ɰ���
select round(to_date('20171116','yyyymmdd'),'month') from dual;
�� ���� ����(16��)���� �ݿø�(������ 1�Ϸ�)
select round(to_date('20171116','yyyymmdd'),'year') from dual;
�� ���� ����(7��)���� �ݿø�(������ 1�� 1�Ϸ�)

95-10-27 1995 ? 2095 ?
������ yyŸ���� 21���� ���� ������ �߻� �� RRŸ��
                                     ������ �Է¿���
                            00~49                   50~99
���翬�� 00~49        ��ȯ��¥�� ���缼�⸦ �ݿ�   ��ȯ��¥�� ���������� ��¥
        50~99        ��ȯ��¥�� ���ļ��⸦ �ݿ�   ��ȯ��¥�� ���缼���� ��¥
  -------------------------------------------------------------------
���翬��   �������Է³�¥             RR                YY(���翬���� ���⸦ �ݿ�)
1994      95-10-27               1995                   1995
1994      17-10-27               2017                   1917
2001      17-10-27               2017                   2017
2048      52-10-27               1952                   2052
2051      47-10-27               2147                   2047
  -------------------------------------------------------------------
  
-- ����ȯ �Լ�
- to_char : ���� ��
  NUM �� Char
  DATE �� Char
select to_char(sysdate, 'yyyymmdd'), 
       to_char(sysdate, 'year'), /* ������ ���縵���� */
       to_char(sysdate, 'mm month mon'), 
       to_char(sysdate, 'ddd dd d'), /* ddd : �� ���� ��, dd : �� ���� ��, d : �� ���� �� */
       to_char(sysdate, 'day, dy'), /* ����, ���Ͼ�� */
       to_char(sysdate, 'ww w iw'), /* ww : �� ���� ��, w : �� ���� ��, iw : iso���� */
       to_char(sysdate, 'ddspth'), /* �� ���� ��, ���縵 �������� */
       to_char(sysdate, 'hh24:mi:ss.sssss am'),
       to_char(sysdate, 'fmdd "of" month') /* ��¥ �߰��� ���ڿ� ������ " ", fm : �տ� 0 ���� */
from dual;  
  
select employee_id, to_char(hire_date, 'day') 
from employees 
order by to_char(hire_date, 'd'); /* �� : 1, �� :2, ... , �� : 7 */
  
select salary, to_char(salary, 'l999,999.00'), to_char(salary, 'l099,999.00') 
from employees;    /* l : ���� ��ġ ��ȭ��ġ, 999.999.00 : �ڸ��� ǥ�� */
  
- to_number : ����(���ڸ��) �� ����
select to_number('1', '9'), to_number('1') from dual;
select to_number('one') from dual; /* ���� */

- to_date : ����(��¥) �� ��¥

- nvl : null���� ���������� ġȯ�ϴ� �Լ�
nvl(��� Ÿ���μ� , ġȯ�� ��)
select salary, commission_pct, salary * 12 + nvl(commission_pct, 0),
       nvl(to_char(commission_pct), 'no comm') /* commission_pct ������ */
from employees;
  
nvl2( , , ) 
select nvl2(commission_pct, 'salary * 12 + commission_pct', salary * 12)
from employees;
/* ù��° �μ��� null�� �ƴϸ� �ι�° �μ��� ����, null�̸� ����° �μ��� ���� */  
/* 2, 3��° �μ��� �� ��ġ�Ǿ� �� */

- coalesce( , , , , ) : null�� �ƴ� ���� ã�� �Լ�(�μ��� ���� ����)
select commission_pct, salary, coalesce(salary * 12 + commission_pct, salary * 12, 10000)
from employees;

- nullif(a,b) : �μ��� �ΰ��� ����, null�� ����� �Լ�(��, �μ��� ���� ��ġ)
/* 
if a = b then
       null;
else
       a;
end if;
*/
select last_name, first_name, nullif(length(last_name), length(first_name))
from employees;