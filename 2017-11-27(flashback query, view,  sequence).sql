[����85] EMPLOYEES ���̺��� ���� EMP_COPY �̸����� �����ϼ���.

create table emp_copy
tablespace users
as select *
from hr.employees;

[����86] EMP_COPY���̺� employee_id�� primary key ���������� �߰��ϼ���.

alter table emp_copy
add constraint emp_copy_empid_pk
primary key (employee_id);
commit;
desc emp_copy;
select * from user_constraints where table_name = 'EMP_COPY';

[����87] EMP_COPY ���̺� department_name varchar2(30) �÷��� �߰��ϼ���.

alter table emp_copy
add (department_name varchar2(30));

desc emp_copy;
select department_name from emp_copy;

[����88] DEPARTMENTS ���̺� �ִ� department_name�� �������� EMP_COPY ���̺� department_name�� ���� �����ϼ���.(UPDATE)

update emp_copy ec
set department_name = (select department_name 
                       from hr.departments 
                       where department_id = ec.department_id);
commit; -- update�� transantion�� �����ؼ� ������ ����� ��.

[����89] EMP_COPY ���̺� department_name�� ���� NULL ������ �����ϼ���. (MERGE)

merge into emp_copy e
using hr.departments d
on (e.department_id = d.department_id)
when matched then
  update set e.department_name = null;

select department_name from emp_copy;
commit;

================================================================================

-- savepoint a, rollback to a (����Ŭ ����) �� commit�� �ȵ�

/* test ���̺� ���� */
drop table test purge;
create table test(id number);

/* row�� �Է� */
insert into test (id) values(1);
savepoint a;

insert into test (id) values(2);
savepoint b;

insert into test (id) values(3);

/* savepoint b������ �ݿ� */
rollback to b;

/* ���Ȯ�� */
select * from test;
rollback;

================================================================================
drop table test purge;

-- default �� : �Է� �ȵǸ� null ��� ������ ��(�Լ�)���� �ڵ��Է�(��, ����ġ �ʼ�)
create table test
(id number, name varchar2(20), sal number default 0, day date default sysdate)
tablespace users;

insert into test(id, name) values(1, 'james');

select * from test;

insert into test(id, name, sal, day)
values(2, 'harden', default, default);

insert into test(id, name, sal, day)
values(3, '������', null, null); /* null�� �켱���� �� ���� */

================================================================================

-- flashback query : dml �۾��� �߸� �����ϰ� commit���� �����ٸ�... 
--                   Ư���ð��� ���� query�� ���� �������� Ȯ�ΰ��� 

/* dba ���� */
show parameter undo;
/* 
undo : dml �۾��� ������ ������ ������(���丮�� ����) why? 1.rollback, 2.�б��ϰ���

NAME                                               TYPE        VALUE                                                                                                
-------------------------------------------------- ----------- --------
undo_management                                    string      AUTO                                                                                                 
undo_retention                                     integer     900(�� ���ȸ� ����) : 9i ver                                                                                                  
undo_tablespace                                    string      UNDOTBS1                                                                                             
*/

/* insa ���� */
create table emp_30
as select * from hr.employees where department_id = 30;

select systimestamp from dual;

select employee_id, salary from emp_30;

update emp_30
set salary = 1000
where employee_id = 114;

commit;

/* as of timestamp to_timestamp */
select employee_id, salary from emp_30
as of timestamp to_timestamp('20171127 11:17:00', 'yyyymmdd hh24:mi:ss')
where employee_id = 114;

update emp_30
set salary = 11000
where employee_id = 114;

select employee_id, salary from emp_30;
commit;

-- flashback table

create table emp_20
as select * from hr.employees
where department_id = 20;

select * from emp_20;
select systimestamp from dual;

delete from emp_20;

commit; /* �Ǽ��߻�!! */

/* ������ ������ Ȯ�� */
select * from emp_20
as of timestamp to_timestamp('20171127 11:37:30', 'yyyymmdd hh24:mi:ss');

alter table emp_20 enable row movement;

/* XE�� �ȵ�... */
flashback table emp_20 to timestamp to_timestamp('20171127 11:37:30', 'yyyymmdd hh24:mi:ss');

alter table emp_20 disable row movement;

================================================================================

-- flashback ~ drop (purge ��? ���� �ȵǴ�)
drop table emp_copy;

create table emp_copy
as select * from hr.employees;

/* ������ */
show recyclebin;
select * from user_recyclebin;

/* ���� */
flashback table emp_copy before drop;
flashback table emp_copy before drop rename to emp_new; /* �̸� ������ �ִٸ� */

/*purge ���ؼ� �̸��� �ٲ��� �����ʹ� ����*/
select * from "BIN$HLRpRexXTyCj/gtTQJc62A==$0"; 

/* ������ ���� */
purge recyclebin;

/* ������ �׸� ����
drop/ truncate/ delete
drop table emp purge; -- ���̺� �ƿ� ����. (purge���� ������ bin$�� rename�� ��)
truncate table emp;   -- ù��° extent �� ���ΰ� ������ extent ��� ����. rollback �ȵ�.
delete from emp;      -- extent�� ���ΰ� emp ���̺��� row ����. �߸��ϸ� rollback ����.
(��� row���� undo tbs �ȿ� �׿�����)
select * from v$option
> flashback table false.
*/
================================================================================
-- VIEW (�� view�� select���� ������ �ִ°Ŷ��~)
/*
1. ����
- �ܼ�view : ���ξ���, dml ��
- ����view : ��������, �׷��Լ�, group by, having / DML �۾� �Ұ�
2. ����
view�� object�� �ƴ�. (��ġ ���� �ִ� ��ó��)select������ ���ư� ��
*/
select * from v$option; /* false�� �߰���� �� �����ؾ� ��밡�� */

select * from session_privs; 
select * from role_sys_privs; /* role �ȿ� �ִ� �ý��� ���� */
select * from role_tab_privs; /* ���� ���� role �ȿ� � object ������ ����ִ��� Ȯ�� */
select * from user_sys_privs; /* dba���� ���� ���� �ý��۱��� Ȯ�� */
select * from user_tab_privs; /* ���� ��ų� ���� object ���� */

select * from emp;

create table emp_30
as select * from hr.employees -- ctas : ���丮�� ����, �������� ������
where department_id = 30;

select * from emp_30;
--------------------------------------------------------------------------------
/* hr ���� */

create view emp_vw_30
as select * from employees
where department_id = 30;

select * from emp_vw_30;

grant select on emp_vw_30 to insa;
--------------------------------------------------------------------------------
/* insa ���� */
select * from hr.emp_vw_30; /* ���� ������ */
--------------------------------------------------------------------------------
/* hr ���� */
/*
���̺��̶�� ����üũ, �ø�ƽüũ �ǽõ�����
���� �Ʒ� dictionary view���� Ȯ�ε� select���� ����
*/

/* ���� ���� object Ȯ�� */
select * from user_objects where object_name = 'EMP_VW_30';

/* ��¥ ���̺�(dba) */
select * from obj$; 

/* dictionary view */
select * from user_views where view_name = 'EMP_VW_30';
--------------------------------------------------------------------------------
/* insa ���� */
select * from user_views where view_name = 'EMP_VW_30'; /* null��(����� ������) */
select * from all_views where view_name = 'EMP_VW_30'; /* insa ���忡�� Ȯ�� */

update hr.emp_vw_30
set salary = 1000;
/* 
���� ����: 
SQL ����: ORA-01031: insufficient privileges
*/

--------------------------------------------------------------------------------
/* hr ���� */
grant select, insert, update, delete on emp_vw_30 to insa;
--------------------------------------------------------------------------------
/* insa */
-- ���������� : dml �۾�����
update hr.emp_vw_30
set salary = 1000;

select * from hr.emp_vw_30;

rollback;

================================================================================

[����90] �μ��̸��� �Ѿױ޿�, ��ձ޿�, �ְ�޿�, �����޿���
      ����ϴ� query���� �ۼ��� �� dept_sal_vw�� �����ϼ���.

select d.department_name, sum(e.salary), avg(e.salary), max(e.salary), min(e.salary)
from (select department_id, salary
      from employees) e, 
     (select department_id, department_name
      from departments) d
where e.department_id=d.department_id
group by d.department_name;

create view dept_sal_vw
as select *
from (
   select d.department_name, sum(e.salary), avg(e.salary), max(e.salary), min(e.salary)
   from (select department_id, salary from employees) e, 
        (select department_id, department_name from departments) d
   where e.department_id=d.department_id
   group by d.department_name 
     );

-- ������ Ǯ��
create view dept_sal_vw
as
select d.department_name, sumsal, avgsal, maxsal, minsal
from (select department_id, sum(salary) sumsal,
        avg(salary) avgsal,
        max(salary) maxsal, min(salary) minsal
        from empoyees
        group by department_id) e, departments d
where e.department_id = d.department_id;

select * from dept_sal_vw;
grant select on dept_sal_vw to insa;
revoke select on dept_sal_vw from insa;
/* ����view ���� DML�۾� �Ϸ��� plsql�� Ʈ���Ÿ� ������ ��.
�� �ʿ�������� ����ϸ� ��. ��� ��� �� recyclebin ��� ����. */

--------------------------------------------------------------------------------
-- create or replace view
/*
�� CREATE VIEW�� ���� ������ �ٲٷ��� �並 �����ϰ� �ٽ� ������ ��.
�� CREATE OR REPLACE VIEW�� ���ο� �並 ����ų� ������ �並 ���� ���ο� ������ �� ��������

- VIEW���� VIEW�� �����ϴ� SELECT ���� ����(������ ���̺��� �������� ����)
- VIEW�� SELECT ������ �˻��ϴ� ���� ���� ���̺��� �����Ͽ� �����ش�.
- VIEW�� query������ ORDER BY ���� ����� �� ����
- WITH CHECK OPTION�� ����ϸ�, �ش� VIEW�� ���ؼ� �� �� �ִ� ���� �������� UPDATE/INSERT ����
ex)
CREATE OR REPLACE VIEW V_EMP_SKILL
        AS
        SELECT *
        FROM EMP_SKILL
        WHERE AVAILABLE = 'YES'
        WITH CHECK OPTION;

���� ���� WITH CHECK OPTION�� ����Ͽ� �並 �����, 
AVAILABLE �÷��� 'YES'�� �ƴ� �����ʹ� VIEW�� ���� �ԷºҰ�
(��, �Ʒ��� ���� �Է��ϴ� ���� '�Ұ���'�ϴ�)

INSERT INTO V_EMP_SKILL
VALUES('10002', 'C101', '01/11/02','NO');

- WITH READ ONLY�� ����ϸ� �ش� VIEW�� ���ؼ��� SELECT�� �����ϸ� 
  INSERT/UPDATE/DELETE�� �� �� ���� �˴ϴ�. ���� �̰��� �����Ѵٸ�, 
  �並 ����Ͽ� Create, Update, Delete �� ��� �����մϴ�.
*/

create or replace view emp_vw_30
as select employee_id, last_name || first_name name, salary*1.10 sal
from employees
where department_id = 30;
/*
1.view�� ���鶧 ������ �� 
  �� columnó�� ���� ���� ǥ����, * ���� ���ڿ��� ������ �ȵ�
    (��Ī�� �� ����� �����)
2.���� view�� �ܼ���(���� X, �׷� X)����, ������ ǥ������ �� column�� �ִ� 
  view�� insert/update �۾� �Ұ���
  (���� ���� : sal�� ���Ǿ��ְ� name�� 2�� ���ΰŶ� update �Ұ�
   employee_id�� update ����, delete�� employee_id�� ���ؼ� ����)
*/
select * from emp_vw_30;

grant select on emp_vw_30 to insa;

commit;
select * from user_objects where object_name = 'EMP_VW_30';
select * from obj$ where name = 'EMP_VW_30'; /* ������ġ */
select * from user_views where view_name = 'EMP_VW_30';

================================================================================

-- sequence : �ڵ� �Ϸù�ȣ �����ϴ� object

create table emp_seq
(id number, name varchar2(20), day timestamp default systimestamp)
tablespace users;

create sequence emp_id_seq
increment by 1 /* 1�� ���� */
start with 1 
maxvalue 50 /* ������� */
cache 30 /* �ɼ�(�⺻�� 20) */
nocycle; /* 51��° ���� */
/*
create sequence emp_id_seq
increment by -1
start with 0 
maxvalue 0
minvalue -100
cache 20 
nocycle;
*/
select * from user_sequences where sequence_name = 'EMP_ID_SEQ';
select * from user_sequences;
/* cache_size : �ӵ� ����� ���� �޸� ���� �̸� ���� �÷���(�� ��� 20��) */

/* sequence name.nextval */
insert into emp_seq(id, name, day)
values(emp_id_seq.nextval, user, default); 

select * from emp_seq;

/* ���� ����� ��ȣ */
select emp_id_seq.currval from dual; 

rollback; /* ���� ����Ǿ 1���� ���� ���ϰ� �Էµ� max(id) ���������� ����(�����ϰ� ����ؾ���) */

/* ���θ�, ���� �� sequence ���, �Ϸù�ȣ ���� ������ �� �ȴٸ� max �����. 
   ������ index�� ź�ٸ� ���� �������� ã�ư��� �� */
   
alter sequence emp_id_seq
maxvalue 100
cache 50;

/* �����Ұ��� ������ */

drop sequence emp_id_seq;

select emp_id_seq.currval from dual; /* ��ȸ : ����� ��ȣ */
select emp_id_seq.nextval from dual; /* ���� : ��밡���� ��ȣ */