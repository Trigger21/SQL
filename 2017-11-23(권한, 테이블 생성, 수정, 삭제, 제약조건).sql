[����79] ����Ŭ DB�� ������ �����ؼ� �۾��ؾ� �մϴ�.
         ���ο� user�� �����ϼ���.
         
	 �����̸� : insa
         default tablespace : users
	 temporary tablespace : temp
	 users tablespace ��뷮 : unlimited

create user insa
identified by insa 
default tablespace users 
temporary tablespace temp
quota unlimited on users;

/*
# DML~DDL (~DCL) ����â �۾� ����
# transantion ���� : �������� select ������ dml��  �� �б� �ϰ���, �۾��� �δ㰨 ����
                     �ϳ��� ��� ó���ϴ� �۾�����
  - �׷��� �߰��߰� commit �Ǵ� rollback�� ���ϴٰ� ���߿� �ϸ� �ѹ濡 �� ����
# auto commit : ddl, dcl ���� �� exit, conn�� �����ϸ� �߻���
# auto rollback : �ý������, ��Ʈ��ũ���, â�ݱ� Ŭ��
*/
select * from dba_tablespaces; 
-- view�� ����, system : ����Ŭ ���忡�� �ڽ��� �����ϱ� ���� ����, sysaux : 10g���� ���� machine learning, 
-- undotbs1 : �۾��� �ӽ������(�����ϸ� dml �߰��Է� �Ұ�)
-- users : ���ð����� ����
select * from dba_data_files;
select * from dba_temp_files;
select * from dba_users;
select * from ts$; -- ���� ���̺�

[����80] insa �������� create session, create table �ý��� ������ �ο����ּ���.
	
grant create session to insa;
grant create table to insa;

select * from user_sys_privs;
select * from user_tab_privs;
select * from user_users;
select * from user_views;

[����81] insa ������ ��������� �����ϱ����� emp ���̺��� �����ϼ���.
	�÷� �̸�   	�÷� Ÿ��
	  id		number(3)
	  name		varchar2(20)
	  day		date

create table insa.emp
(id number(3), name varchar2(20), day date) -- date 7byte ����
tablespace users;

[����82] emp Ÿ���� �űԵ����͸� �Է����ּ���.
	100,ȫ�浿,�ý��۽ð�����
  
insert into insa.emp(id,name,day) -- block�� ����
values(100,'ȫ�浿',sysdate);
commit;

select * from insa.emp;
commit;
================================================================================
/* insa���� */
select * from emp;
select * from hr.employees; -- hr�� ���� ��ȸ���� ���޾Ƽ� �����߻�

/* hr���� */
grant select, insert, update, delete on hr.employees to insa; -- �̷��� �ο��� ���������� ������ ��ġ����
grant select on hr.employees to insa; 

select * from user_tab_privs; -- ������ �� Ȯ��

/* insa���� */
select * from user_tab_privs; -- ���ѹ��� �� Ȯ��

select * from hr.employees;

/* hr���� */
grant select on hr.departments to insa; 
-- insa������ hr������ departments ���̺��� select�� �� �ִ� ������ �ο�

/* insa���� */
-- ���̺�� ���̺��� ���� ����

-- c.t.a.s : ���̺� ���� (create table + tablespace + object ���� �ʿ�(select))
create table copy_emp -- ������ ���� ���̺� ����
tablespace users -- �̰� ������ defualt�� �����
as select * from hr.employees; -- �м��� ���̺�

desc copy_emp;
select * from copy_emp;

create table copy_dept
tablespace users
as select department_id, department_name from hr.departments;

desc copy_dept;
select * from copy_dept;

delete from copy_emp; -- ��ü row�� ����, undotbs1�� �ӽ�����
select * from copy_emp;
rollback;

truncate table copy_emp; -- ��ü row�� ����, ������ ������(�����ؾ� �Ѵ�)
rollback;
select * from copy_emp;

insert into copy_emp
select * from hr.employees; -- row�� �ٽ� ����
commit;
select * from copy_emp;

create table temp_emp
as select * from hr.employees where 1 = 2; -- ���̺� ���븸 ���������� where�� false ����

-- add : column �߰��ϴ� ���(������ ���� �������� ����)
desc emp;

alter table emp add(sal number(10));

create table emp1
(id number(3), name varchar2(20), sal number(10), day date)
tablespace users;

insert into emp1(id, name, day)
select id, name, day from emp;

select * from emp1;

-- modify : column Ÿ�� ����
alter table emp modify(name varchar2(30));

-- column ����
alter table emp drop column sal;
select * from emp;

================================================================================

/* hr���� */

-- �������̺� insert : �����͸�Ʈ �۾�
insert into copy_emp
select * from hr.employees;

create table sal_history
as select employee_id, hire_date, salary
from employees
where 1=2;

desc sal_history;

create table mgr_history
as select employee_id, manager_id, salary
from employees
where 1=2;

/* ������ insert all : ���� ���� */
insert all 
into sal_history(employee_id, hire_date, salary) values(empid, hiredate, sal) 
into mgr_history(employee_id, manager_id, salary) values(empid, mgr, sal)
select employee_id empid, hire_date hiredate, manager_id mgr, salary sal /*��Ī ���� values���� ��Ī���� �ƴϸ� �����̸�*/
from employees;

select * from sal_history;
select * from mgr_history;

commit;
================================================================================
create table emp_history
as select employee_id, hire_date, salary
from employees
where 1=2;

create table emp_sal
as select employee_id, commission_pct, salary
from employees
where 1=2;

desc emp_history;
desc emp_sal;

/* ���� insert all : oracle ����, ������ ����Ǹ� �Ѵ� ������ ���� */
insert all
when hire < to_date('20050101', 'yyyymmdd') then -- ������1
 into emp_history(employee_id, hire_date,salary)
  values(id, hire, sal)
when comm is not null then -- ������2
 into emp_sal(employee_id, commission_pct, salary)
  values(id, comm, sal)
select employee_id id, hire_date hire, salary sal, commission_pct comm
from employees;

commit;
select * from emp_history;
select employee_id, hire_date, salary from employees where hire_date < to_date('20050101', 'yyyymmdd');

select * from emp_sal;
select employee_id, commission_pct, salary from employees where commission_pct is not null;

select eh.*, es.commission_pct
from emp_history eh, emp_sal es
where eh.employee_id = es.employee_id;

================================================================================
/* ���� first insert : ������� ��Ÿ�Ϸ� ���ǿ� �´� �͸� �� */
create table sal_low
as select employee_id, last_name, salary
from employees
where 1 = 2;

create table sal_mid
as select employee_id, last_name, salary
from employees
where 1 = 2;

create table sal_high
as select employee_id, last_name, salary
from employees
where 1 = 2;

insert first
when sal < 5000 then -- select�� �ִ� salary��
into sal_low(employee_id, last_name, salary)
values(id, name, sal)
when sal between 5000 and 10000 then
into sal_mid(employee_id, last_name, salary)
values(id, name, sal)
else
into sal_high(employee_id, last_name, salary)
values(id, name, sal)
select employee_id id, last_name name, salary sal
from employees;

commit; 

select * from sal_low;
select * from sal_mid;
select * from sal_high;

================================================================================

-- merge : ����(insert, delete, update)
create table oltp_emp
as select employee_id, last_name, salary, department_id
   from employees;
   
create table dw_emp
as select employee_id, last_name, salary, department_id
   from employees
   where department_id = 20;

select * from oltp_emp;

alter table oltp_emp add flag char(1); -- flag��� ���� �߰�

desc oltp_emp;

update oltp_emp
set flag = 'd'
where employee_id = 202; -- merge �� delete Ȯ�ο�

update oltp_emp
set salary = '20000'
where employee_id = 201; -- merge �� update Ȯ�ο�

commit;

select * from oltp_emp where employee_id between 201 and 202;
select * from oltp_emp where department_id = 20;

select * from dw_emp; -- ���⿡�� ��ġ�Ǵ� Ű�� �����͸� update or delete


merge into dw_emp d -- target table, ����� insert, delete, update
using oltp_emp o /* �������� �� �� (select * from oltp_emp) o */
on (d.employee_id = o.employee_id) 
when matched then -- merge keyword / Ű���� ��ġ�Ǵ� ����� ...
      update set -- �ʼ�
        d.last_name = o.last_name,
        d.salary = o.salary * 1.1,
        d.department_id = o.department_id
      delete where o.flag = 'd' -- �ɼ�
when not matched then  -- merge keyword /  Ű���� �� ��ġ�Ǵ� ����� ... / �ɼ�
      insert(d.employee_id, d.last_name, d.salary, d.department_id)
      values(o.employee_id, o.last_name, o.salary, o.department_id);
commit;
select * from dw_emp;

merge into (select * from dw_emp d)
using (select * from oltp_emp where department_id = 30)
on (d.employee_id = o.employee_id) 
when matched then
      update set
        d.last_name = o.last_name,
        d.salary = o.salary * 1.1,
        d.department_id = o.department_id
      delete where o.flag = 'd'
when not matched then 
      insert(d.employee_id, d.last_name, d.salary, d.department_id)
      values(o.employee_id, o.last_name, o.salary, o.department_id);

/* merge ������ ������ ����, ���� ��쿡 dw_emp�� insert, delete, update ����
   oltp_emp�� select ������ �־�� �Ѵ�(�ٸ� �������� ����� ��)*/

================================================================================

create table copy_emp
as select * from employees;

-- Ű���� Ʋ���� update
update copy_emp
set job_id = (select job_id
              from copy_emp
              where employee_id = 200),
    salary = (select salary
              from copy_emp
              where employee_id = 202)
where employee_id = 113;

select employee_id, job_id, salary from copy_emp where employee_id in(200,113);

-- Ű���� ������ update
update copy_emp
set(job_id, salary) = (select job_id, salary
                       from copy_emp
                       where employee_id = 200)
where employee_id = 113;

================================================================================
-- delete���� �������� Ȱ��
delete from copy_emp 
where department_id in(select department_id
                       from departments
                       where department_name like '%Public%');
select * from copy_emp where department_id = 70;
commit;
================================================================================
-- ���� ���� : dml �۾��� ������ ǰ�������� ���� ���

- NOT NULL : null�� üũ�ؼ� �����ϴ� ����(�ߺ� ���)
- UNIQUE : �ߺ����� üũ�ؼ� ���㳪�� ����(null ��� / unique index �ڵ�����)
- PRIMARY KEY : null & unique �Ѵ� üũ�ؼ� ���㳪�� ����(���̺��� ��ǥ���� ��� �� / unique index �ڵ�����)
- FOREIGN KEY : primary key �Ǵ� unique ���������� �����ؼ� �����ϴ� ����(primary key�� ���� ���� �Ÿ���)(null, �ߺ� ���) �������Ἲ
- CHECK : ���ǽ��� true�� ��쿡�� �Է°� ������ ����(null, �ߺ� ���)


CREATE TABLE copy_emp
( employee_id NUMBER(6) CONSTRAINT copy_emp_employee_id PRIMARY KEY
, first_name VARCHAR2(20)
, last_name VARCHAR2(25)  CONSTRAINT copy_emp_last_name_nn NOT NULL
, email VARCHAR2(25)
CONSTRAINT copy_emp_email_nn NOT NULL /* CONSTRAINT �̸�(30��) Ÿ�� */
CONSTRAINT copy_emp_email_uk UNIQUE
, phone_number VARCHAR2(20)
, hire_date DATE CONSTRAINT copy_emp_hire_date_nn NOT NULL
, job_id VARCHAR2(10)
CONSTRAINT copy_emp_job_nn NOT NULL
, salary NUMBER(8,2) CONSTRAINT copy_emp_salary_ck CHECK (salary>0)
, commission_pct NUMBER(2,2)
, manager_id NUMBER(6) CONSTRAINT copy_emp_manager_fk REFERENCES copy_emp (employee_id) /* REFERENCES : foreign key ���� */
, department_id NUMBER(4) CONSTRAINT copy_emp_dept_fk REFERENCES departments (department_id)); 
  /* foreign key ���������� �ɾ���� pk ������ ����(���Ӱ���), ǰ������ */

select * from user_tables;
select * from user_constraints where table_name = 'COPY_EMP'; -- ���̺� �ɸ� �������� �����ȸ 
/* �׳� ������ ���̺��� not null �������Ǹ� �ڵ����� ������ �ǰ� �������� ����ڰ� ������ �ؾ��� */
select * from user_cons_columns; -- �÷��� �ɸ� �������� �����ȸ

select * from copy_emp;

================================================================================
-- �������� �׽�Ʈ
create table copy_dept
(dept_id number(2) unique,
dept_name varchar2(20) );

insert into copy_dept values(10,'�λ���');
insert into copy_dept values(null,'������');
commit;

select * from copy_dept;

select * from user_cons_columns where table_name = 'COPY_DEPT';

create table copy_emp
(id number(2),
name varchar2(20),
dept_id number(20) references copy_dept(dept_id));

insert into copy_emp values(1,'ȫ�浿',10);
insert into copy_emp values(2,'����ȣ',null);
commit;

select * from copy_emp;

select e.*, d.*
from copy_emp e, copy_dept d
where e.dept_id = d.dept_id;

-- fk�������� ���ָ鼭 �����ϴ� ������
drop table copy_dept cascade constraints purge;