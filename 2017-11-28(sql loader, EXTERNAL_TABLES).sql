[����91]30�� �μ� ������� EMPLOYEE_ID, LAST_NAME, HIRE_DATE,SALARY�� 15% �λ�� �޿�
       �����鸸 VIEW�� ���ؼ� ���� �մϴ�. ���̸��� v_dept30���� ���弼��.

create or replace view v_dept30
as select employee_id, last_name, hire_date, salary*1.15 sal
   from employees
   where department_id = 30;
   
select * from v_dept30;
select * from user_objects where object_name = 'V_DEPT30';
select * from user_views where view_name = 'V_DEPT30';

grant select on v_dept30 to insa;
revoke select on v_dept30 from insa;
select * from hr.v_dept30;

================================================================================

create table emp_2017
as select * from employees where 1=2;

-- sql loader
/*
�����
1. control file ����
- �޸��忡  emp.ctl�� ����

load data
infile emp.csv <-- �����͸� �ְ�
insert <-- ����ִ� ���̺� ���� �ɼ� (append : �����Ͱ� �ִ� ���̺� ���� �ɼ�)
into table emp_2017
fields terminated by ',' -- field�� ���й�� ����
(EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID)

�� fields terminated by ',' optionally enclosed by '"' : " " ���� �ְڴ�

2. cmd ����
> cd c:\data
> dir *.csv
> dir *.ctl
> sqlldr userid=hr/hr control=emp.ctl direct=true <-- �������� ���ݿ��� üũ ����/disable ��/�޸� ��ġ�� �ʰ� �ٷ� ���丮��

insert : ����ִ� ���̺� �����͸� ������
append : �����Ͱ� �ִ� ���̺� ���ο� �����͸� �߰��� ��
replace : �����Ͱ� �ִ� ���̺� ���������͸� delete�ϰ� ���ο� ������ �߰� (�����ض� ���� truncate �ض�)
truncate : �����Ͱ� �ִ� ���̺� ���������͸� truncate�ϰ� ���ο� ������ �߰� 
*/

select count(*)
from emp_2017;

select * from emp_2017;

select * from user_constraints;
SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated, index_name
FROM user_constraints
WHERE table_name = 'EMP_2017';

================================================================================
-- sql loader : ��뷮 ������ ����Ŭ db�� �ִ�??
 
insa.ctl <-- �޸��忡 �Ʒ��������� ���� 

LOAD DATA
INFILE *
INSERT
INTO TABLE test 
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(ID, NAME, PHONE)
BEGINDATA
1, "JAMES", "010-9999-0000"
2, "ORACLE", "010-7777-7777"
3, "HONG", "010-8888-8888"
3, "KT","010-777-9999"

--------------------------------------------------------------------------------
SQL> CREATE TABLE test
    (
     id    NUMBER CONSTRAINT test_id_pk PRIMARY KEY,
     name  VARCHAR2(30),
     phone VARCHAR2(15)
    );


SQL> SELECT constraint_name,
            constraint_type
     FROM user_constraints
     WHERE table_name = 'TEST';
/*
CONSTRAINT_NAME                C
------------------------------ -
TEST_ID_PK                     P
*/

--------------------------------------------------------------------------------


c:\data> sqlldr hr/hr control=insa.ctl <- conventional load /* ��������(�߿��� �͸�) üũ */
/* userid �����ʾƵ� �ȴ� */

--------------------------------------------------------------------------------

SQL> SELECT * FROM test;
/*
        ID NAME                           PHONE
---------- ------------------------------ ---------------
         1 JAMES                          010-9999-0000
         2 ORACLE                         010-7777-7777
         3 HONG                           010-8888-8888
*/
--------------------------------------------------------------------------------
insa.bad <-- �ڵ������Ǵ� �޸���(������ �ݿ����� ���� ������)

3, "KT","010-777-9999"

--------------------------------------------------------------------------------
SQL> TRUNCATE TABLE test;
--------------------------------------------------------------------------------

c:\data> sqlldr hr/hr control=insa.ctl direct=true <- direct path load 
/* �������� üũ �̽ǽ÷� unique index ������ */

--------------------------------------------------------------------------------

SQL> SELECT * FROM test;
/*
        ID NAME                           PHONE
---------- ------------------------------ ---------------
         1 JAMES                          010-9999-0000
         2 ORACLE                         010-7777-7777
         3 HONG                           010-8888-8888
         3 KT                             010-777-9999
*/        


SQL> SELECT index_name,
            status uniqueness
     FROM user_indexes
     WHERE table_name = 'TEST';
/*
INDEX_NAME                     UNIQUENE
------------------------------ --------
TEST_ID_PK                     UNUSABLE
*/

SQL> INSERT INTO test(id, name, phone) 
     VALUES(4,'sk','010-0000-0000');
/* index�� ������ ������ �� �߰��� �����߻�
insert into test(id,name,phone) values(4,'sk','010-0000-0000')
*
ERROR at line 1: 
ORA-01502: index 'HR.TEST_ID_PK' or partition of such index is in unusable state
*/

SQL> DELETE FROM test WHERE name = 'KT';
/*
delete from test where name = 'KT'
*
ERROR at line 1:
ORA-01502: index 'HR.TEST_ID_PK' or partition of such index is in unusable state
*/

SQL> alter table test disable constraint test_id_pk; /* pk index drop�� */
/*
diable novalidate : �ش� ���� ������ ��� �����Ͱ� ���� ����, �������� �ɷ��ִ°� �ı���Ű�� �����°���.(�⺻��)
                    alter table test_enable disable constraint te_name_nn
                    �̷��� novalidate�� validate �Ⱦ��� novalidate�� ����
*/
Table altered.


SQL> @$ORACLE_HOME/rdbms/admin/utlexpt1.sql <--- exceptions ���̺� ���� �ϴ� ��ũ��Ʈ

/* window : SQLPlus ������ */@%ORACLE_HOME%\rdbms\admin\utlexpt1  
/* Linux/Unix */(@$ORACLE_HOME/rdbms/admin/utlexpt1)

SQL> ALTER TABLE test enable VALIDATE CONSTRAINT test_id_pk exceptions INTO exceptions;
/*
alter table test enable validate constraint test_id_pk exceptions into exceptions
*
ERROR at line 1:
ORA-02437: cannot validate (HR.TEST_ID_PK) - primary key violated
*/

SQL> select rowid, id, name, phone 
     from test 
     where rowid in (select row_id from exceptions) 
     for update;
/*
ROWID                      ID NAME                           PHONE
------------------ ---------- ------------------------------ ---------------
AAASNTAAEAAAAILAAC          3 HONG                           010-8888-8888
AAASNTAAEAAAAILAAD          3 KT                             010-777-9999
*/

SQL> DELETE FROM test WHERE rowid = 'AAAFBYAAEAAAAI7AAD';

1 row deleted.

SQL> COMMIT;

Commit complete.


SQL> TRUNCATE TABLE exceptions;

Table truncated.

SQL> ALTER TABLE test enable VALIDATE CONSTRAINT test_id_pk exceptions INTO exceptions;

Table altered.

SQL> select rowid, id, name, phone 
     from test 
     where rowid in (select row_id from exceptions) 
     for update;
/*
ROWID                      ID NAME                           PHONE
------------------ ---------- ------------------------------ ---------------
*/

SQL> SELECT index_name,
            status uniqueness
     FROM user_indexes
     WHERE table_name = 'TEST';
/*
INDEX_NAME                     UNIQUENE
------------------------------ --------
TEST_ID_PK                     VALID
*/

SQL> SELECT constraint_name,
            constraint_type,
            status
     FROM user_constraints
     WHERE table_name = 'TEST';
/*
CONSTRAINT_NAME                C STATUS
------------------------------ - --------
TEST_ID_PK                     P ENABLED
*/
================================================================================
insa.ctl

LOAD DATA
INFILE *
INSERT
INTO TABLE test
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(ID, NAME, PHONE, SAL, MGR)
BEGINDATA
1, "JAMES", "010-9999-0000",200,,
2, "ORACLE", "010-7777-7777",300,1
3, "HONG", "010-8888-8888",10,2
3, "KT","010-777-9999",500,2
4, "SK", "010-777-9999",600,3
5, , "010-555-5555",800,4
7,"LG","010-100-1000",200,8

SQL> CREATE TABLE test
    (
     id    NUMBER CONSTRAINT test_id_pk PRIMARY KEY,
     name  VARCHAR2(30) CONSTRAINT test_name_nn NOT NULL,
     phone VARCHAR2(15) CONSTRAINT test_phone_uk UNIQUE,
     sal   NUMBER CONSTRAINT test_sal_ck CHECK(sal>100),
     mgr   NUMBER CONSTRAINT test_mgr_fk REFERENCES test(id)
    );


SQL> select constraint_name, constraint_type from user_constraints where table_name = 'TEST';
/*
CONSTRAINT_NAME                                              CO
------------------------------------------------------------ --
TEST_NAME_NN                                                 C
TEST_SAL_CK                                                  C
TEST_ID_PK                                                   P
TEST_PHONE_UK                                                U
TEST_MGR_FK                                                  R
*/




c:\data> sqlldr hr/hr control=insa.ctl <- conventional load
s



SQL> select * from test;
/*
        ID NAME       PHONE                                 SAL        MGR
--------- ---------- ------------------------------ ---------- ----------
        1 JAMES      010-9999-0000                         200
        2 ORACLE     010-7777-7777                         300          1
        3 KT         010-777-9999                          500          2
*/


insa.bad
/*
3, "HONG", "010-8888-8888",10,2 
4, "SK", "010-777-9999",600,3
5, , "010-555-5555",800,4
7,"LG","010-100-1000",200,8
*/


SQL> truncate table test;


c:\data> sqlldr hr/hr control=insa.ctl direct=true <- direct path load /* not null�� üũ�� */


insa.bad

5, , "010-555-5555",800,4



SQL> select * from test;

 /*
       ID NAME       PHONE                                 SAL        MGR
--------- ---------- ------------------------------ ---------- ----------
        1 JAMES      010-9999-0000                         200
        2 ORACLE     010-7777-7777                         300          1
        3 HONG       010-8888-8888                          10          2
        3 KT         010-777-9999                          500          2
        4 SK         010-777-9999                          600          3
        7 LG         010-100-1000                          200          8
*/


SQL> select index_name, status uniqueness from user_indexes where table_name = 'TEST';
/*
INDEX_NAME                                                   UNIQUENESS
------------------------------------------------------------ ----------------
TEST_ID_PK                                                   UNUSABLE
TEST_PHONE_UK                                                UNUSABLE
*/


SQL> select  constraint_name,constraint_type,search_condition,status, validated
 from user_constraints
 where table_name = 'TEST';

/*
CONSTRAINT_NAME CO SEARCH_CONDITION     STATUS           VALIDATED
--------------- -- -------------------- ---------------- --------------------------
TEST_NAME_NN    C  "NAME" IS NOT NULL   ENABLED          VALIDATED
TEST_SAL_CK     C  sal>100              DISABLED         NOT VALIDATED
TEST_ID_PK      P                       ENABLED          VALIDATED
TEST_PHONE_UK   U                       ENABLED          VALIDATED
TEST_MGR_FK     R                       DISABLED         NOT VALIDATED
*/
--> dml ������ / �޿��� ����� ������ ���� ������ enabled novalidate / 

================================================================================

select * from test
as of timestamp to_timestamp('20171128 14:27:00', 'yyyymmdd hh24:mi:ss');

================================================================================

-- EXTERNAL_TABLES
/*
external ���̺��� DB �ܺο� ����� data ������ �����ϱ� ���� ���� ����� �ϳ��� 
�б� ���� ���̺��̴�.
external ���̺��� ���� �����ʹ� DB �ܺο� ����������, external ���̺� ���� 
metadata�� DB ���ο� �����ϴ� ������ ���� ���̺��̴�.
*/
conn sys/oracle as sysdba

create directory data_dir as 'C:\DATA\';
/* data_dir : ���� ���͸�
   'C:\data\' : �������� ���͸� */

SELECT owner, directory_name, directory_path
FROM all_directories;   

drop directory data_dir;

GRANT READ, WRITE ON DIRECTORY data_dir TO hr;    



CREATE TABLE hr.empxt /* ���ο� �ּ��� ������ ������ �߻��� �� ����(����� ����) */
  (
    EMPLOYEE_ID  NUMBER(6),
    FIRST_NAME   VARCHAR2(20),
    LAST_NAME    VARCHAR2(25),
    EMAIL        VARCHAR2(25),
    PHONE_NUMBER VARCHAR2(20),
    HIRE_DATE DATE,
    JOB_ID         VARCHAR2(10),
    SALARY         NUMBER(8,2),
    COMMISSION_PCT NUMBER(2,2),
    MANAGER_ID     NUMBER(6),
    DEPARTMENT_ID  NUMBER(4)
  )   
      ORGANIZATION EXTERNAL      
      (      
       TYPE ORACLE_LOADER      
       DEFAULT DIRECTORY data_dir      
       ACCESS PARAMETERS      
      (      
         records delimited by newline /* ���྿ �о� �������ÿ� */
         badfile 'empxt.bad'          /* �������� badfile ���� */
         logfile 'empxt.log'          /* �����ϸ� logfile ���� */
         fields terminated by ','      
         missing field values are null /* ���� ������ row�ϰ� ���������� null�� �־� */  
         (
          employee_id, first_name, last_name, email, phone_number, 
          hire_date char date_format date mask "RR/MM/DD", /* ������ ��翡 �°� ���� */    
          job_id, salary, commission_pct, manager_id, department_id      
         )      
      )      
       LOCATION ('emp.csv')      
     )      
       reject limit unlimited /* �������� �� ������ ���ߴ� ��츦 ���� */
/
 
drop table hr.empxt purge;          
desc empxt;

select * from hr.empxt;

select * from USER_EXTERNAL_TABLES ;      
     	
select * from USER_EXTERNAL_LOCATIONS;
	
select * from  all_directories; /* ������ ���͸� ������ dba���� */

delete from empxt; 		-- ����(external table �� dml ���� �ȵ�. index ���� �ȵ�.)