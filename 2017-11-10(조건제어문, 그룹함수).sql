[����20] �Ͽ��Ͽ� �Ի��� ����� ������ ��ȸ�ϼ���.
select employee_id, 
       first_name || ' ' || last_name "NAME", 
       to_char(hire_date, 'day') "HIRE DAY"
from employees
where to_char(hire_date, 'd') = 1;

[����21] ¦���޿� �Ի��� ����� ������ ��ȸ�ϼ���.
select employee_id,
       first_name || ' ' || last_name "NAME",
       to_char(hire_date, 'month') "HIRE MONTH"
from employees
where mod(to_char(hire_date, 'mm'), 2) = 0
order by to_char(hire_date, 'mm');

[����22] ������̺�(employees)�� last_name, salary, commission_pct, commission_pct ���� 
null �ƴϸ� (salary*12) + (salary*12*commission_pct) �̰��� ����ǰ�
null �̸� salary * 12 �� ������ ���ֵ��� ann_sal �����ϼ���.
(nvl, coalesce, nvl2 �Լ��� ����Ͽ� �������� �����ؼ� ���� �ۼ��� �ּ���)

select last_name, salary, commission_pct,
       (salary*12) + (salary*12*nvl(commission_pct,0)) "ann_sal"
from employees;

select last_name, salary, commission_pct,
       coalesce((salary*12) + (salary*12*commission_pct), salary*12) "ann_sal"
from employees; 

select last_name, salary, commission_pct,
       nvl2(commission_pct, (salary*12) + (salary*12*commission_pct), salary*12)
       "ann_sal"
from employees;

================================================================================

select * from nls_session_parameters; /* ����, �� ���ӵǴ� ������ ��� */

ALTER SESSION SET NLS_TERRITORY = KOREA;
ALTER SESSION SET NLS_LANGUAGE = KOREAN;

ALTER SESSION SET NLS_TERRITORY = GERMANY;
ALTER SESSION SET NLS_LANGUAGE = GERMAN;

ALTER SESSION SET NLS_LANGUAGE = JAPANESE;
ALTER SESSION SET NLS_TERRITORY = JAPAN;

ALTER SESSION SET NLS_LANGUAGE = FRENCH;
ALTER SESSION SET NLS_TERRITORY= FRANCE;

ALTER SESSION SET NLS_TERRITORY= AMERICA;
ALTER SESSION SET NLS_LANGUAGE = AMERICAN;

ALTER SESSION SET NLS_TERRITORY = china;
ALTER SESSION SET NLS_LANGUAGE = 'simplified chinese';

ALTER SESSION SET NLS_TERRITORY = 'United Kingdom';
ALTER SESSION SET NLS_LANGUAGE = ENGLISH;


select employee_id, 
      to_char(salary,'l999g999d00'), /* g : 1000���� ������ ������ �°�, d : �Ҽ��� �ڸ� ������ �°� */
      to_char(hire_date, 'YYYY-MONTH-DD DAY') /* MONTH, DAY : �� ���� */
from employees;

/* ������ ��� �и��ص� �������, ��ҹ��� ���о��� */

================================================================================

-- ������� : decode, case �Լ�

if ���� then ����
else ������
end if;

- decode(���ذ�, �񱳰�1, ����1, �񱳰�2, ����2, ... , �⺻��)
�� ���ذ��� = �θ� ��!!, row ���� ����
/*
if ���ذ� = ��1 then ����1
else if ���ذ� = ��2 then ����2
else if ���ذ� = ��3 then ����3
      ...................
else 
        �⺻��
end if;
*/
select last_name, job_id, salary,
       decode(job_id, 'IT_PROG', salary * 1.10,
                      'ST_CLERK', salary * 1.15,
                      'SA_REP', salary * 1.20,
              salary)
from employees;

- case ���ذ� when ��1 then ��1  /* ���ذ� = �� 1 */
             when ��2 then ��2
             when ��3 then ��3
             else �⺻��
  end
 = case      when ���ذ� = �� then ��1
   ...
   
- case       when ���ذ� >= ��1 then ��1
             when ���ذ� <> ��2 then ��2
             when ���ذ� in(��3,��4,��5) then ��3
             else �⺻��
  end
�� �ٸ� �����ڵ� ��밡��, �ٸ� SQL���� ��밡��

select last_name, job_id, salary,
       case job_id when 'IT_PROG' then salary * 1.10
                   when 'ST_CLERK' then salary * 1.15
                   when 'SA_REP' then salary * 1.20
                   else salary
       end
from employees;

[����22] ������̺�(employees)�� last_name, salary, commission_pct, commission_pct ���� 
null �ƴϸ� (salary*12) + (salary*12*commission_pct) �̰��� ����ǰ�
null �̸� salary * 12 �� ������ ���ֵ��� ann_sal �����ϼ���.

select last_name, salary, commission_pct,
       decode(commission_pct, null, salary * 12, 
              (salary*12) + (salary*12*commission_pct)) "ann_sal"
from employees;

select last_name, salary, commission_pct,
       case nvl(commission_pct,0) when 0 then salary * 12
                                  else (salary*12) + (salary*12*commission_pct)
       end "ann_sal"
from employees;

select last_name, salary, commission_pct,
       case  when commission_pct is null then salary * 12
                                  else (salary*12) + (salary*12*commission_pct)
       end "ann_sal"
from employees;

[����23] JOB_ID ���� ���� ������� ��� ����� ����� ǥ���ϴ� query �� �ۼ��մϴ�.

<ȭ�鿹>
JOB_ID	 	GRADE
------		----	
AD_PRES 	A
ST_MAN 		B
IT_PROG 	C
SA_REP 		D
ST_CLERK 	E
		      Z

select distinct job_id,
       decode(JOB_ID, 'AD_PRES', 'A', 
                      'ST_MAN', 'B', 
                      'IT_PROG', 'C', 
                      'SA_REP', 'D', 
                      'ST_CLERK', 'E', 
                      'Z') "GRADE"
from employees
order by grade;

SELECT DISTINCT job_id,
       CASE job_id WHEN 'AD_PRES' THEN 'A'
                   WHEN 'ST_MAN' THEN 'B'
                   WHEN 'IT_PROG' THEN 'C'
                   WHEN 'SA_REP' THEN 'D'
                   WHEN 'ST_CLERK' THEN 'E'
                   ELSE 'Z'
        END GRADE
FROM EMPLOYEES
ORDER BY GRADE;

[����24] ����� last_name, salary,  �޿��� 5000 �̸��̸� 'Low', 10000 �̸��̸� 'Medium', 
20000�̸��̸� 'Good', 20000 �̻��̸� 'Excellent' �� ����ϼ���.
select last_name, salary,
       case when salary < 5000 then 'Low'
            when salary < 10000 then 'Medium'
            when salary < 20000 then 'Good'
            when salary >= 20000 then 'Excellent' /* �Ǵ� else 'Excellent' */
       end
from employees;

-- �������Լ� : ����, ����, ��¥, ����ȯ, �������, NULL
-- �׷��Լ� : count(���), max(�ִ밪), min(�ּҰ�), sum(��), avg(���), variance(�л�), stddev(ǥ������)
   /* ���� 1. null�� �������� ���� : �������� ���, �л�, ǥ������ ���� �� �����ؾ� ��(nvl�Լ� �����)
      ���� 2. sum(��), avg(���), variance(�л�), stddev(ǥ������) : ���ڸ� �μ������� ��� */

select count(*) from employees; /* count(*) : null�� ������ ��ü row �� */
select count(department_id) from employees; /* column���� null ���� */
select count(distinct department_id) from employees;

select count(*) from employees where department_id = 50;
select count(commission_pct) from employees where department_id = 50; /* 50�� �μ� commission_pct null */

select count(*) from employees where commission_pct is not null;

select count(salary), count(last_name), count(hire_date)
from employees;

select max(salary), max(last_name), max(hire_date)
from employees;

select min(salary), min(last_name), min(hire_date)
from employees;

select sum(salary) from employees where department_id = 50; /* ���ڸ� */
select sum(salary) from employees where last_name like '%i%';

select avg(commission_pct) from employees; /* �߸��� null ������ */
select avg(nvl(commission_pct,0)) from employees;

select variance(nvl(commission_pct,0)) from employees;

- ��ü������� �Ѿױݾ�
select sum(salary) from employees;

- �μ��� �Ѿױ޿�
select department_id, sum(salary), count(*) from employees
group by department_id; /* group by : �׷캰 ���� */

select job_id, sum(salary), count(*) from employees
group by job_id; 

select department_id, job_id, manager_id, sum(salary) /* department_id, job_id, manager_id ��ġ�� ����� salary �� */
from employees
group by department_id, job_id, manager_id; /* ���� 3 : select�� ������ �׷����� �״�� ����*/

select department_id dept_id, sum(salary)
from employees
group by department_id; /* ���� 4 : group by�� ��Ī��� �ȵ� */

select department_id dept_id, sum(salary)
from employees
where department_id in(10, 20, 30) /* ���� 5 : where ��ġ group by ���� */
group by department_id;

select department_id dept_id, sum(salary)
from employees
where sum(salary) >= 10000 /* ���� 6 : �׷��Լ��� where�� �����ϸ� �ȵ�(������) */
group by department_id;

select department_id dept_id, sum(salary)
from employees
group by department_id
having sum(salary) >= 10000; /* having : �׷��Լ��� ����� �����ϴ� �� */

select max(avg(salary)), department_id /* �׷��Լ� �ι� ��ø�Ǹ� ������ ������ */
from employees
group by department_id;

select department_id, sum(salary)
from employees
where job_id not like '%REP%' /* ���� �����ϴ� ���� �׷��� ���� �����ϰ� ������ ���� */
group by department_id
having sum(salary) > 10000
order by 1;
�� ó������ 1.from 2.where 3.group by(�ұ׷� ����) 4.select 5.having 6.order by 

select max(avg(salary)) /* �׷��Լ� 2������ ��ø ����, �� ������ ���� */
from employees
group by department_id;

[����25] ��� ����� �ְ�޿�, �����޿�, �հ� �� ��� �޿��� ã���ϴ�. 
�� ���̺��� ���� Maximum, Minimum, Sum �� Average �� �����մϴ�. 
����� �Ҽ����� �ݿø��ؼ� ���������� ����ϼ���.

   Maximum    Minimum        Sum    Average
---------- ---------- ---------- ----------
     24000       2100     691416       6462

select max(salary) "Maximum",
       min(salary) "Minimum",
       sum(salary) "Sum",
       round(avg(salary),0) "Average"
from employees;

[����26] 2008�⵵�� �Ի��� ������� job_id�� �ο����� ���ϰ� �ο����� ���� ������ ����ϼ���. 

JOB_ID     COUNT(*)
---------- --------
SA_REP            6 
SH_CLERK          2 
ST_CLERK          2 
SA_MAN            1 

select distinct job_id, count(*)
from employees
where to_char(hire_date,'yyyy') = '2008'
group by job_id
order by 2 desc;

select job_id, count(*)
from employees
where hire_date >= to_date('20080101','yyyymmdd')
and hire_date < to_date('20090101','yyyymmdd') /* to_date('hire_date', 'yyyymmdd') ������ ����ϴ°� indexȰ���ؼ� �� ����. */
group by job_id
order by 2 desc;

[����27] ����� �Ѽ��� 2005��, 2006��, 2007��, 2008�⿡ �Ի��� ����� �� ����ϼ���.

   TOTAL       2005       2006       2007       2008
-------- ---------- ---------- ---------- ----------
     107         29         24         19         11
/*     
select to_char(hire_date,'yyyy'), count(*)
from employees
group by to_char(hire_date,'yyyy')/*                �� ������ ���������� �ٲٴ� �� ����
having to_char(hire_date,'yyyy') >= 2005
order by 1;
*/
-- 27�� ���� �� �ϳ�, �̵� �� �Ǽ��̴�. �ֳ��ϸ� ��ü row�� 4���� �ݺ������� ���Ѵ�. ������ ũ�Ⱑ Ŀ���� ���� ����
select count(*) "TOTAL", 
       count(decode(to_char(hire_date,'yyyy'),'2005',1)) "2005",
       count(decode(to_char(hire_date,'yyyy'),'2006',1)) "2006",
       count(decode(to_char(hire_date,'yyyy'),'2007',1)) "2007",
       count(decode(to_char(hire_date,'yyyy'),'2008',1)) "2008" /* decode, case �ȿ� �׷��Լ� ����ϸ� �ȵ� */
from employees;

