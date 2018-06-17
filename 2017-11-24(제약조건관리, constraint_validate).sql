[����83] ���̺��������.pdf�� ERD(Entity Relationship Diagram)�� Ȯ�� ���� table instance chart��  ���鼭 ���̺��� �����ϼ���.

CREATE TABLE dept
  (
    dept_id   NUMBER(3) CONSTRAINT dept_pk PRIMARY KEY,
    dept_name VARCHAR2(50) CONSTRAINT dept_uk UNIQUE 
                           CONSTRAINT dept_nn NOT NULL,
    mgr       NUMBER(5)
  ) tablespace users;
CREATE TABLE emp
  (
    id   NUMBER(5) CONSTRAINT emp_id_pk PRIMARY KEY,
    name VARCHAR2(50) CONSTRAINT emp_name_nn NOT NULL,
    hire_date DATE CONSTRAINT emp_date_nn NOT NULL,
    sal     NUMBER(8,2) CONSTRAINT emp_sal_ck CHECK (sal>100),
    mgr     NUMBER(5) CONSTRAINT emp_mgr_fk REFERENCES emp(id),
    dept_id NUMBER(3) CONSTRAINT emp_dept_id_fk REFERENCES dept(dept_id)
  ) tablespace users;

desc dept;
desc emp;

select * from user_tables;
select * from user_constraints where table_name in('EMP','DEPT');
drop table dept purge;
================================================================================
-- ���̺�_��������_����

/*���̺� ����*/

SQL> create table emp as select employee_id, last_name, salary, department_id from hr.employees where 1=2;

Table created.

SQL> desc emp
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 EMPLOYEE_ID                                        NUMBER(6)
 LAST_NAME                                 NOT NULL VARCHAR2(25)
 SALARY                                             NUMBER(8,2)
 DEPARTMENT_ID                                      NUMBER(4)


SQL> create table dept as select * from hr.departments where 1=2;

Table created.

SQL> desc dept
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 DEPARTMENT_ID                                      NUMBER(4)
 DEPARTMENT_NAME                           NOT NULL VARCHAR2(30)
 MANAGER_ID                                         NUMBER(6)
 LOCATION_ID                                        NUMBER(4)



/*�� �߰�*/

SQL> ALTER TABLE emp ADD (job_id VARCHAR2(9));

Table altered.

SQL> desc emp
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 EMPLOYEE_ID                                        NUMBER(6)
 LAST_NAME                                 NOT NULL VARCHAR2(25)
 SALARY                                             NUMBER(8,2)
 DEPARTMENT_ID                                      NUMBER(4)
 JOB_ID                                             VARCHAR2(9)

/*�� ����*/

SQL> ALTER TABLE emp MODIFY (last_name VARCHAR2(30)); -- not null�� modify

Table altered.

SQL> desc emp
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 EMPLOYEE_ID                                        NUMBER(6)
 LAST_NAME                                 NOT NULL VARCHAR2(30)
 SALARY                                             NUMBER(8,2)
 DEPARTMENT_ID                                      NUMBER(4)
 JOB_ID                                             VARCHAR2(9)


/*�� ����*/

SQL> ALTER TABLE emp DROP COLUMN job_id; -- ���̺� �� �ɸ� ��� ����(����̶�� ���� �������)

Table altered.

SQL> desc emp
 Name                                      Null?    Type
 ----------------------------------------- -------- ---------------------------
 EMPLOYEE_ID                                        NUMBER(6)
 LAST_NAME                                 NOT NULL VARCHAR2(30)
 SALARY                                             NUMBER(8,2)
 DEPARTMENT_ID                                      NUMBER(4)



SQL> ALTER TABLE emp SET UNUSED (salary); -- �� �÷��� ���� ������ ��ųʸ����� ����(��, ���� �����ʹ� ����), �����Ұ�

Table altered.

SQL> desc emp
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 EMPLOYEE_ID                                        NUMBER(6)
 LAST_NAME                                 NOT NULL VARCHAR2(30)
 DEPARTMENT_ID                                      NUMBER(4)


SQL> select * from user_unused_col_tabs; -- unused ������ ����

TABLE_NAME                                                        COUNT
------------------------------------------------------------ ----------
EMP                                                                   1

SQL> ALTER TABLE emp DROP UNUSED COLUMNS; -- �� �̻�� �ð��� ����� 

Table altered.

SQL> select * from user_unused_col_tabs;

no rows selected


/*���� ���� ���� �߰�*/

- ���� ���� �߰� �Ǵ� ����. ���� ������ ������ �������� ����
- ���� ���� Ȱ��ȭ �Ǵ� ��Ȱ��ȭ
- MODIFY ���� ����Ͽ� NOT NULL ���� ���� �߰�

SQL> ALTER TABLE dept ADD CONSTRAINT deptid_pk PRIMARY KEY(department_id);

Table altered.

SQL>  SELECT constraint_name, constraint_type,search_condition, index_name, status
      FROM user_constraints
      WHERE table_name = 'DEPT';


CONSTRAINT_NAME      CO SEARCH_CONDITION                                   INDEX_NAME STATUS
-------------------- -- -------------------------------------------------- ---------- ----------------
SYS_C007002          C  "DEPARTMENT_NAME" IS NOT NULL                                 ENABLED
DEPTID_PK            P                                                     DEPTID_PK  ENABLED


SQL> ALTER TABLE emp ADD CONSTRAINT empid_pk PRIMARY KEY(employee_id); -- �߰��� �� pk �����ؾ� �Դ�.

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, index_name, status
     FROM user_constraints
     WHERE table_name = 'EMP';                                         -- unique, primary key �� index object & segment

CONSTRAINT_NAME      CO SEARCH_CONDITION                                   INDEX_NAME STATUS
-------------------- -- -------------------------------------------------- ---------- ----------------
SYS_C007001          C  "LAST_NAME" IS NOT NULL                                       ENABLED
EMPID_PK             P                                                     EMPID_PK   ENABLED


SQL> ALTER TABLE emp ADD CONSTRAINT emp_dept_id_fk
     FOREIGN KEY (department_id) -- fk �߰��� �� �����
     REFERENCES dept(department_id) ON DELETE CASCADE; -- �ɼ�1 : fk-pk �ɸ� pk row�� ������ �� �����ϴ� child row(fk)���� ������ ����(�����ؾ� ��)

Table altered.


SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name,delete_rule, status
     FROM user_constraints
     WHERE table_name = 'EMP';
 
CONSTRAINT_NAME      CO SEARCH_CONDITION                                   R_CONSTRAI DELETE_RULE     STATUS
-------------------- -- -------------------------------------------------- ---------- ------------------ ----------------
SYS_C007001          C  "LAST_NAME" IS NOT NULL                                                       ENABLED
EMPID_PK             P                                                                                ENABLED
EMP_DEPT_ID_FK       R                                                     DEPTID_PK  CASCADE         ENABLED

SQL> ALTER TABLE emp DROP CONSTRAINT emp_dept_id_fk;

Table altered.

SQL>
SQL> ALTER TABLE emp ADD CONSTRAINT emp_dept_id_fk
     FOREIGN KEY (department_id)
     REFERENCES dept(department_id) ON DELETE SET NULL; -- �ɼ�2 : fk-pk �ɸ� pk row�� ������ �� �����ϴ� fk field ���� null�� update(child row���� �״�� ����)

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name,delete_rule, status
     FROM user_constraints
     WHERE table_name = 'EMP';

CONSTRAINT_NAME      CO SEARCH_CONDITION                                   R_CONSTRAI DELETE_RULE     STATUS
-------------------- -- -------------------------------------------------- ---------- ------------------ ----------------
SYS_C007001          C  "LAST_NAME" IS NOT NULL                                                       ENABLED
EMPID_PK             P                                                                                ENABLED
EMP_DEPT_ID_FK       R                                                     DEPTID_PK  SET NULL        ENABLED

SQL> ALTER TABLE emp DROP CONSTRAINT emp_dept_id_fk;

Table altered.

SQL> ALTER TABLE emp
     ADD CONSTRAINT emp_dept_id_fk FOREIGN KEY(department_id)
     REFERENCES dept(department_id);

Table altered.


SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name,delete_rule, status
     FROM user_constraints
     WHERE table_name = 'EMP';


CONSTRAINT_NAME      CO SEARCH_CONDITION                                   R_CONSTRAI DELETE_RULE     STATUS
-------------------- -- -------------------------------------------------- ---------- ------------------ ----------------
SYS_C007001          C  "LAST_NAME" IS NOT NULL                                                       ENABLED
EMPID_PK             P                                                                                ENABLED
EMP_DEPT_ID_FK       R                                                     DEPTID_PK  NO ACTION       ENABLED
                                                                             /* �̰� �⺻�� */

SQL> SELECT constraint_name, column_name  FROM user_cons_columns  WHERE table_name = 'EMP';

CONSTRAINT_NAME      COLUMN_NAME
-------------------- --------------------
SYS_C007001          LAST_NAME
EMPID_PK             EMPLOYEE_ID
EMP_DEPT_ID_FK       DEPARTMENT_ID



/*���� ���� ����*/

SQL> ALTER TABLE dept DROP PRIMARY KEY;
ALTER TABLE dept DROP PRIMARY KEY
*
ERROR at line 1:
ORA-02273: this unique/primary key is referenced by some foreign keys

SQL> ALTER TABLE dept DROP PRIMARY KEY CASCADE; -- pk ���� ���1

Table altered.

<OR>

SQL> ALTER TABLE dept DROP CONSTRAINT deptid_pk CASCADE; -- pk ���� ���2

Table altered.



/*�������� ����*/
 not null �������Ǹ� �����Ҽ� �ִ�.


SQL> ALTER TABLE emp MODIFY (last_name VARCHAR2(30) null);

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name,delete_rule, status
     FROM user_constraints
     WHERE table_name = 'EMP';

CONSTRAINT_NAME      CO SEARCH_CONDITION               R_CONSTRAI DELETE_RULE        STATUS
-------------------- -- ------------------------------ ---------- ------------------ ----------------
EMPID_PK             P                                                               ENABLED
EMP_DEPT_ID_FK       R                                 DEPT_ID_PK NO ACTION          ENABLED

SQL> desc emp
 Name                             Null?    Type
 -------------------------------- -------- -------------------------------
 EMPLOYEE_ID                      NOT NULL NUMBER(6)
 LAST_NAME                                 VARCHAR2(30)
 DEPARTMENT_ID                             NUMBER(4)


SQL> ALTER TABLE emp MODIFY (last_name VARCHAR2(30) constraint emp_name_nn not null);

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name,delete_rule, status
     FROM user_constraints
     WHERE table_name = 'EMP';

CONSTRAINT_NAME      CO SEARCH_CONDITION               R_CONSTRAI DELETE_RULE        STATUS
-------------------- -- ------------------------------ ---------- ------------------ ----------------
EMP_NAME_NN          C  "LAST_NAME" IS NOT NULL                                      ENABLED
EMPID_PK             P                                                               ENABLED
EMP_DEPT_ID_FK       R                                 DEPT_ID_PK NO ACTION          ENABLED

SQL> desc emp
 Name                             Null?    Type
 -------------------------------- -------- --------------
 EMPLOYEE_ID                      NOT NULL NUMBER(6)
 LAST_NAME                        NOT NULL VARCHAR2(30)
 DEPARTMENT_ID                             NUMBER(4)



/*���� ���� ��Ȱ��ȭ*/

SQL> ALTER TABLE emp DISABLE CONSTRAINT empid_pk;

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name,delete_rule, status
     FROM user_constraints
     WHERE table_name = 'EMP';

CONSTRAINT_NAME      CO SEARCH_CONDITION               R_CONSTRAI DELETE_RULE        STATUS
-------------------- -- ------------------------------ ---------- ------------------ ----------------
EMP_NAME_NN          C  "LAST_NAME" IS NOT NULL                                      ENABLED
EMPID_PK             P                                                               DISABLED
EMP_DEPT_ID_FK       R                                 DEPT_ID_PK NO ACTION          ENABLED

- CREATE TABLE ���� ALTER TABLE �� ��ο� DISABLE ���� ����� �� �ֽ��ϴ�.
- CASCADE ���� ���� ���Ἲ ���� ������ ��Ȱ��ȭ�մϴ�.
- UNIQUE �Ǵ� PRIMARY KEY ���� ������ ��Ȱ��ȭ�ϸ� UNIQUE �ε����� ���ŵ˴ϴ�.
  /* pk�� �����ϴ� fk �����, cascade ��� */


/*���� ���� Ȱ��ȭ*/

SQL> ALTER TABLE emp ENABLE CONSTRAINT empid_pk;

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name,delete_rule, status
     FROM user_constraints
     WHERE table_name = 'EMP';

CONSTRAINT_NAME      CO SEARCH_CONDITION               R_CONSTRAI DELETE_RULE        STATUS
-------------------- -- ------------------------------ ---------- ------------------ ----------------
EMP_NAME_NN          C  "LAST_NAME" IS NOT NULL                                      ENABLED
EMPID_PK             P                                                               ENABLED
EMP_DEPT_ID_FK       R                                 DEPTID_PK  NO ACTION          ENABLED


- ���� ������ Ȱ��ȭ�ϸ� �ش� ���� ������ ���̺��� ��� �����Ϳ� ����˴ϴ�.
- UNIQUE key �Ǵ� PRIMARY KEY ���� ������ Ȱ��ȭ�ϸ� UNIQUE �Ǵ� PRIMARY KEY �ε����� �ڵ����� �����˴ϴ�. /* cascade ��� ���� */
- CREATE TABLE ���� ALTER TABLE �� ��ο� ENABLE ���� ����� �� �ֽ��ϴ�.


SQL> SELECT index_name, column_name
     FROM user_ind_columns
     WHERE table_name = 'EMP';

INDEX_NAME                                                   COLUMN_NAME
------------------------------------------------------------ ------------------------------
EMPID_PK                                                     EMPLOYEE_ID



SQL> CREATE TABLE cust (
     id NUMBER CONSTRAINT id_pk PRIMARY KEY,
     sal NUMBER,
     mgr NUMBER,                         /* �� ���� (not null�� �̰͸� ����)*/
     comm NUMBER,
     CONSTRAINT mgr_fk FOREIGN KEY (mgr) REFERENCES cust(id),-- fk�� ���⼭ �ٸ��� ����
     CONSTRAINT id_sal_ck CHECK (id > 0 and sal > 0),           /* ���̺� ���� */
     CONSTRAINT comm_ck CHECK (comm > 0));

Table created.

SQL> ALTER TABLE cust DROP (id);
ALTER TABLE cust DROP (id)
                       *
ERROR at line 1:
ORA-12992: cannot drop parent key column -- fk & check �������̶�...


SQL> ALTER TABLE cust DROP (sal);
ALTER TABLE cust DROP (sal)
                       *
ERROR at line 1:
ORA-12991: column is referenced in a multi-column constraint -- check ���� �ɷ�����


SQL> ALTER TABLE cust DROP COLUMN sal CASCADE CONSTRAINTS; -- ������ ������ �����ϴ� ���

Table altered.


SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name,delete_rule, status
     FROM user_constraints
     WHERE table_name = 'CUST'; 

CONSTRAINT_NAME      CO SEARCH_CONDITION               R_CONSTRAI DELETE_RULE        STATUS
-------------------- -- ------------------------------ ---------- ------------------ ----------------
COMM_CK              C  comm > 0                                                     ENABLED
ID_PK                P                                                               ENABLED
MGR_FK               R                                 ID_PK      NO ACTION          ENABLED



/*���̺� �� �� ���� ���� �̸� �ٲٱ�*/


SQL> ALTER TABLE cust RENAME COLUMN id TO cust_id;

Table altered.

SQL> desc cust
 Name                                                                                Null?    Type
 ----------------------------------------------------------------------------------- -------- -------------------------------
 CUST_ID                                                                             NOT NULL NUMBER
 MGR                                                                                          NUMBER
 COMM                                                                                         NUMBER

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name,delete_rule, status
     FROM user_constraints
     WHERE table_name = 'CUST';

CONSTRAINT_NAME      CO SEARCH_CONDITION               R_CONSTRAI DELETE_RULE        STATUS
-------------------- -- ------------------------------ ---------- ------------------ ----------------
COMM_CK              C  comm > 0                                                     ENABLED
ID_PK                P                                                               ENABLED
MGR_FK               R                                 ID_PK      NO ACTION          ENABLED

SQL> SELECT index_name, column_name
     FROM user_ind_columns
     WHERE table_name = 'CUST';

INDEX_NAME                                                   COLUMN_NAME
------------------------------------------------------------ ------------------------------
ID_PK                                                        CUST_ID


SQL> ALTER TABLE cust RENAME CONSTRAINT id_pk TO cust_id_pk;

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name,delete_rule, status
     FROM user_constraints
     WHERE table_name = 'CUST';

CONSTRAINT_NAME      CO SEARCH_CONDITION               R_CONSTRAI DELETE_RULE        STATUS
-------------------- -- ------------------------------ ---------- ------------------ ----------------
COMM_CK              C  comm > 0                                                     ENABLED
CUST_ID_PK           P                                                               ENABLED
MGR_FK               R                                 CUST_ID_PK NO ACTION          ENABLED

SQL> SELECT index_name, column_name  FROM user_ind_columns WHERE table_name = 'CUST';

INDEX_NAME                                                   COLUMN_NAME
------------------------------------------------------------ ------------------------------
ID_PK                                                        CUST_ID

================================================================================
-- constraint_validate
/*
enable validate : �̰Ŵ� ���������͵� ���Ŀ� �ԷµǴ� �ű� �����͵� ��� �����͸� ���� �˻�(�⺻��)
                  �׷��� enalbe validate�� �ϰ� �Ǹ� ����Ŭ�� �ش� ���̺� �����Ͱ� ������� ���ϵ��� 
                  lock�� ������ �ֳ�? ���� �����͸� �˻��ؾ��ϴϱ�.
                  �˻� ���߿� ���������� �����ϴ� �� not null�ε� null���� �ִٴ��� �̷��� �߰ߵǸ� 
                  ������ �߻��ϸ鼭 enable �۾��� �����.
                  [����: ALTER TABLE ���̺�� ENABLE VALIDATE CONSTRAINT ���������̸�;]

enable novalidate : enalbe �ϴ� �������� ���̺� ����ִ� ���� �����͵��� �˻����� �ʰ�
                    enable �ϴ� ���� ���ĺ��� �ԷµǴ� �����͸� ���������� �����ؼ� �˻���
                  [����: ALTER TABLE ���̺�� ENABLE NOVALIDATE CONSTRAINT ���������̸�;]
                  
diable validate : ������ ������ �ȵǰԲ� �ϴ� �ɼ�, �ش�Į���� ������ ������ ������.
                  insert, update, delete �۾��� ������ �� ����. 11g ������ read only�� ����� ����
                  [����: ALTER TABLE ���̺�� DISABLE VALIDATE CONSTRAINT ���������̸�;]

diable novalidate : �ش� ���� ������ ��� �����Ͱ� ���� ����, �������� �ɷ��ִ°� �ı���Ű�� �����°���.(�⺻��)
                    alter table test_enable disable constraint te_name_nn
                    �̷��� novalidate�� validate �Ⱦ��� novalidate�� ����
                   [����: ALTER TABLE ���̺�� DISABLE NOVALIDATE CONSTRAINT ���������̸�;]
*/

SQL> conn hr/hr

SQL> create table test(id number, name char(10), sal number);

Table created.

SQL> insert into test(id, name, sal) values(1,'a',1000);

1 row created.

SQL> insert into test(id, name, sal) values(2,'b',100);

1 row created.

SQL> insert into test(id, name, sal) values(1,'a',2000);

1 row created.

SQL> commit;

Commit complete.

SQL> select * from test;

        ID NAME                                                      SAL
---------- -------------------------------------------------- ----------
         1 a                                                        1000
         2 b                                                         100
         1 a                                                        2000

SQL> alter table test add constraint test_id_pk primary key(id); -- �� ���� enable validate �⺻�� : ���������� Ȱ��ȭ �� ������ �˻�
alter table test add constraint test_id_pk primary key(id)
                                *
ERROR at line 1:
ORA-02437: cannot validate (HR.TEST_ID_PK) - primary key violated


SQL> alter table test add constraint test_id_pk primary key(id) disable; -- ������ �ϵ�, Ȱ��ȭ�� ������(�ǵ���) / �⺻�� : disable novalidate / disable validate : dml ����

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated, index_name
FROM user_constraints
WHERE table_name = 'TEST';   

CONSTRAINT_NAME                C SEARCH_CON R_CONSTRAINT_NAME              STATUS   VALIDATED     INDEX_NAME
------------------------------ - ---------- ------------------------------ -------- ------------- ------------------------------
TEST_ID_PK                     P                                           DISABLED NOT VALIDATED

SQL> /* window : SQLPlus ������ */@%ORACLE_HOME%\rdbms\admin\utlexpt1  /* Linux/Unix */(@$ORACLE_HOME/rdbms/admin/utlexpt1) -- regidit : ����

Table created. /* EXCEPTIONS ���̺��� �����ȴ� */


SQL> desc exceptions
 Name                                                                                                              Null?    Type
 ----------------------------------------------------------------------------------------------------------------- -------- -----------
 ROW_ID                                                                                                                     ROWID
 OWNER                                                                                                                      VARCHAR2(30)
 TABLE_NAME                                                                                                                 VARCHAR2(30)
 CONSTRAINT                                                                                                                 VARCHAR2(30)


SQL> alter table test enable constraint test_id_pk exceptions into exceptions; -- exceptions into ���̺��
alter table test enable constraint test_id_pk exceptions into exceptions
*
ERROR at line 1:
ORA-02437: cannot validate (HR.TEST_ID_PK) - primary key violated

SQL> select * from exceptions;

ROW_ID                         OWNER                          TABLE_NAME                     CONSTRAINT
------------------------------ ------------------------------ ------------------------------ ------------------------------
AAASTeAAEAAAB4YAAC             HR                             TEST                           TEST_ID_PK
AAASTeAAEAAAB4YAAA             HR                             TEST                           TEST_ID_PK


SQL> select rowid, id, name, sal from test where rowid in (select row_id from exceptions) for update; -- for update : ��ȸ������ �̸� ���� �Ŵ� ���(�ɼ�)

ROWID                                  ID NAME                                                                SAL
------------------------------ ---------- ------------------------------------------------------------ ----------
AAASTeAAEAAAB4YAAA                      1 a                                                                  1000
AAASTeAAEAAAB4YAAC                      1 a                                                                  2000



SQL> update test
     set id = 3
     where rowid = 'AAASTeAAEAAAB4YAAC'; 

1 row updated.

SQL> commit; -- for update ���� ����

Commit complete.


SQL> select * from test;

        ID NAME                                                                SAL
---------- ------------------------------------------------------------ ----------
         1 a                                                                  1000
         2 b                                                                   100
         3 a                                                                  2000

SQL> truncate table exceptions;

Table truncated.

SQL> alter table test enable constraint test_id_pk exceptions into exceptions;

Table altered.


SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated/*���� ������*/, index_name
FROM user_constraints
WHERE table_name = 'TEST';

CONSTRAINT_NAME                C SEARCH_CON R_CONSTRAINT_NAME              STATUS   VALIDATED     INDEX_NAME
------------------------------ - ---------- ------------------------------ -------- ------------- ------------------------------
TEST_ID_PK                     P                                           ENABLED  VALIDATED     TEST_ID_PK


SQL> alter table test add constraint test_sal_ck check(sal > 1000) enable novalidate;  -- �������� Ȱ���ϸ鼭 ���Ӱ� ������ �����ʹ� ����, ���� �����ʹ� �����н� / pk���� �� �� ����.

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated, index_name
FROM user_constraints
WHERE table_name = 'TEST';

CONSTRAINT_NAME                C SEARCH_CON R_CONSTRAINT_NAME              STATUS   VALIDATED     INDEX_NAME
------------------------------ - ---------- ------------------------------ -------- ------------- ------------------------------
TEST_ID_PK                     P                                           ENABLED  VALIDATED     TEST_ID_PK
TEST_SAL_CK                    C sal > 1000                                ENABLED  NOT VALIDATED


SQL> insert into test(id, name, sal) values(4,'c',500);
insert into test(id, name, sal) values(4,'c',500)
*
ERROR at line 1:
ORA-02290: check constraint (HR.TEST_SAL_CK) violated


SQL> alter table test enable /*validated*/constraint test_sal_ck exceptions into exceptions
                                   *
ERROR at line 1:
ORA-02293: cannot validate (HR.TEST_SAL_CK) - check constraint violated

SQL> select rowid, id, name, sal from test where rowid in (select row_id from exceptions);

ROWID                      ID NAME                                                      SAL
------------------ ---------- -------------------------------------------------- ----------
AAASN2AAEAAAAJ0AAA          1 a                                                        1000
AAASN2AAEAAAAJ0AAB          2 b                                                         100


SQL> alter table test disable validate constraint test_id_pk ; -- disable validate : �׿����� dml �����Ѵ�

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated, index_name
FROM user_constraints
WHERE table_name = 'TEST'; 


CONSTRAINT_NAME                C SEARCH_CON R_CONSTRAINT_NAME              STATUS   VALIDATED     INDEX_NAME
------------------------------ - ---------- ------------------------------ -------- ------------- ------------------------------
TEST_ID_PK                     P                                           DISABLED VALIDATED
TEST_SAL_CK                    C sal > 1000                                ENABLED  NOT VALIDATED

SQL> insert into test(id, name, sal) values(5,'d',2000);
insert into test(id, name, sal) values(5,'d',2000)
*
ERROR at line 1:
ORA-25128: No insert/update/delete on table with constraint (HR.TEST_ID_PK) disabled and validated



SQL> alter table test enable validate constraint test_id_pk ;

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated, index_name
FROM user_constraints
WHERE table_name = 'TEST'; 

CONSTRAINT_NAME                C SEARCH_CON R_CONSTRAINT_NAME              STATUS   VALIDATED     INDEX_NAME
------------------------------ - ---------- ------------------------------ -------- ------------- ------------------------------
TEST_ID_PK                     P                                           ENABLED  VALIDATED     TEST_ID_PK
TEST_SAL_CK                    C sal > 1000                                ENABLED  NOT VALIDATED

SQL> insert into test(id, name, sal) values(5,'d',2000);

1 row created.

SQL> commit;

Commit complete.

================================================================================
-- constraint_not_null

SQL> desc emp
 Name                                                                                                              Null?    Type
 ----------------------------------------------------------------------------------------------------------------- -------- ------------
 EMPLOYEE_ID                                                                                                       NOT NULL NUMBER(6)
 FIRST_NAME                                                                                                                 VARCHAR2(20)
 LAST_NAME                                                                                                         NOT NULL VARCHAR2(25)
 EMAIL                                                                                                             NOT NULL VARCHAR2(25)
 PHONE_NUMBER                                                                                                               VARCHAR2(20)
 HIRE_DATE                                                                                                         NOT NULL DATE
 JOB_ID                                                                                                            NOT NULL VARCHAR2(10)
 SALARY                                                                                                                     NUMBER(8,2)
 COMMISSION_PCT                                                                                                             NUMBER(2,2)
 MANAGER_ID                                                                                                                 NUMBER(6)
 DEPARTMENT_ID                                                                                                              NUMBER(4)

SQL> alter table hr.emp modify commission_pct constraint emp_comm_nn not null;
alter table hr.emp modify commission_pct constraint emp_comm_nn not null
                                                    *
ERROR at line 1:
ORA-02296: cannot enable (HR.EMP_COMM_NN) - null values found


SQL> alter table hr.emp modify commission_pct constraint emp_comm_nn not null enable novalidate;

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated, index_name
FROM user_constraints
WHERE table_name = 'EMP'; 

CONSTRAINT_NAME                C SEARCH_CONDITION               R_CONSTRAINT_NAME              STATUS   VALIDATED     INDEX_NAME
------------------------------ - ------------------------------ ------------------------------ -------- ------------- ------------------------------
SYS_C0011571                   C "LAST_NAME" IS NOT NULL                                       ENABLED  VALIDATED
SYS_C0011572                   C "EMAIL" IS NOT NULL                                           ENABLED  VALIDATED
SYS_C0011573                   C "HIRE_DATE" IS NOT NULL                                       ENABLED  VALIDATED
SYS_C0011574                   C "JOB_ID" IS NOT NULL                                          ENABLED  VALIDATED
EMPID_PK                       P                                                               ENABLED  VALIDATED     EMPID_PK
EMP_DEPT_ID_FK                 R                                DEPTID_PK                      ENABLED  VALIDATED
EMP_COMM_NN                    C "COMMISSION_PCT" IS NOT NULL                                  ENABLED  NOT VALIDATED


SQL> alter table hr.emp drop constraint emp_comm_nn;

Table altered.

<<��?��?>>

SQL> alter table hr.emp modify commission_pct null;

Table altered.



SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated, index_name
FROM user_constraints
WHERE table_name = 'EMP';

CONSTRAINT_NAME                C SEARCH_CONDITION               R_CONSTRAINT_NAME              STATUS   VALIDATED     INDEX_NAME
------------------------------ - ------------------------------ ------------------------------ -------- ------------- ------------------------------
SYS_C0011571                   C "LAST_NAME" IS NOT NULL                                       ENABLED  VALIDATED
SYS_C0011572                   C "EMAIL" IS NOT NULL                                           ENABLED  VALIDATED
SYS_C0011573                   C "HIRE_DATE" IS NOT NULL                                       ENABLED  VALIDATED
SYS_C0011574                   C "JOB_ID" IS NOT NULL                                          ENABLED  VALIDATED
EMPID_PK                       P                                                               ENABLED  VALIDATED     EMPID_PK
EMP_DEPT_ID_FK                 R                                DEPTID_PK                      ENABLED  VALIDATED

================================================================================

[����84] FOREIGN KEY ���������� �����Ϸ��� �մϴ�. ������ �ذ����ּ���.

SQL> drop table emp purge;

Table dropped.

SQL> create table emp as select * from hr.employees;

SQL> drop table dept purge;

Table dropped.

SQL> create table dept as select * from hr.departments;

Table created.

SQL> ALTER TABLE emp ADD CONSTRAINT empid_pk PRIMARY KEY(employee_id);
desc emp;
Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated, index_name
FROM user_constraints
WHERE table_name = 'EMP'; 

CONSTRAINT_NAME                C SEARCH_CONDITION               R_CONSTRAINT_NAME              STATUS   VALIDATED     INDEX_NAME
------------------------------ - ------------------------------ ------------------------------ -------- ------------- ------------------------------
SYS_C0011571                   C "LAST_NAME" IS NOT NULL                                       ENABLED  VALIDATED
SYS_C0011572                   C "EMAIL" IS NOT NULL                                           ENABLED  VALIDATED
SYS_C0011573                   C "HIRE_DATE" IS NOT NULL                                       ENABLED  VALIDATED
SYS_C0011574                   C "JOB_ID" IS NOT NULL                                          ENABLED  VALIDATED
EMPID_PK                       P                                                               ENABLED  VALIDATED     EMPID_PK


SQL> ALTER TABLE dept ADD CONSTRAINT deptid_pk PRIMARY KEY(department_id);

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated, index_name
FROM user_constraints
WHERE table_name = 'DEPT';

CONSTRAINT_NAME                C SEARCH_CONDITION               R_CONSTRAINT_NAME              STATUS   VALIDATED     INDEX_NAME
------------------------------ - ------------------------------ ------------------------------ -------- ------------- ------------------------------
SYS_C0011576                   C "DEPARTMENT_NAME" IS NOT NULL                                 ENABLED  VALIDATED
DEPTID_PK                      P                                                               ENABLED  VALIDATED     DEPTID_PK



SQL> update emp
     set department_id = 55
     where department_id is null;

1 row updated.
select * from emp where department_id = 55;
SQL> commit;
select * from emp where department_id = 55;
Commit complete.

SQL> ALTER TABLE emp ADD CONSTRAINT emp_dept_id_fk FOREIGN KEY (department_id) REFERENCES dept(department_id);
ALTER TABLE emp ADD CONSTRAINT emp_dept_id_fk FOREIGN KEY (department_id) REFERENCES dept(department_id)
                               *
ERROR at line 1:
ORA-02298: cannot validate (HR.EMP_DEPT_ID_FK) - parent keys not found

/* Ǯ��1 : dept�� ����μ� 55�� ���� */
desc dept; select * from dept;
insert into dept(department_id,department_name,manager_id,location_id) -- block�� ����
values(55,'null',null,null) ; commit;

-- <<�ذ���>>

SQL>  ALTER TABLE emp ADD CONSTRAINT emp_dept_id_fk FOREIGN KEY (department_id) REFERENCES dept(department_id) enable novalidate; -- ���� �����н�, ���ο� �Ŵ� ����                                     

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated, index_name
FROM user_constraints
WHERE table_name = 'EMP'; 

CONSTRAINT_NAME                C SEARCH_CONDITION               R_CONSTRAINT_NAME              STATUS   VALIDATED     INDEX_NAME
------------------------------ - ------------------------------ ------------------------------ -------- ------------- ------------------------------
SYS_C0011571                   C "LAST_NAME" IS NOT NULL                                       ENABLED  VALIDATED
SYS_C0011572                   C "EMAIL" IS NOT NULL                                           ENABLED  VALIDATED
SYS_C0011573                   C "HIRE_DATE" IS NOT NULL                                       ENABLED  VALIDATED
SYS_C0011574                   C "JOB_ID" IS NOT NULL                                          ENABLED  VALIDATED
EMPID_PK                       P                                                               ENABLED  VALIDATED     EMPID_PK
EMP_DEPT_ID_FK                 R                                DEPTID_PK                      ENABLED  NOT VALIDATED


SQL> update hr.emp
     set department_id = 10
     where employee_id = 200;

1 row updated.

SQL> commit;

Commit complete.

SQL> update hr.emp
     set department_id = 55 /* enable novalidate �������Ŀ��� ������Ѵٴ� ���� */
     where employee_id = 200; 
update hr.emp
*
ERROR at line 1:
ORA-02291: integrity constraint (HR.EMP_DEPT_ID_FK) violated - parent key not found





SQL> alter table hr.emp enable validate constraint emp_dept_id_fk exceptions into exceptions;
alter table hr.emp enable validate constraint emp_dept_id_fk exceptions into exceptions
                                              *
ERROR at line 1:
ORA-02298: cannot validate (HR.EMP_DEPT_ID_FK) - parent keys not found





SQL> select rowid, employee_id, department_id from hr.emp where rowid in (select row_id from exceptions) for update;

ROWID              EMPLOYEE_ID DEPARTMENT_ID
------------------ ----------- -------------
AAASgJAAEAAAAQEABX         178            55


SQL> update hr.emp
     set department_id = null
     where rowid = 'AAASgJAAEAAAAQEABX';

1 row updated.

SQL> commit;

Commit complete.

SQL> truncate table exceptions;

Table truncated.

SQL> alter table hr.emp enable validate constraint emp_dept_id_fk exceptions into exceptions;

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated, index_name
FROM user_constraints
WHERE table_name = 'EMP';

CONSTRAINT_NAME                C SEARCH_CONDITION               R_CONSTRAINT_NAME              STATUS   VALIDATED     INDEX_NAME
------------------------------ - ------------------------------ ------------------------------ -------- ------------- ------------------------------
SYS_C0011571                   C "LAST_NAME" IS NOT NULL                                       ENABLED  VALIDATED
SYS_C0011572                   C "EMAIL" IS NOT NULL                                           ENABLED  VALIDATED
SYS_C0011573                   C "HIRE_DATE" IS NOT NULL                                       ENABLED  VALIDATED
SYS_C0011574                   C "JOB_ID" IS NOT NULL                                          ENABLED  VALIDATED
EMPID_PK                       P                                                               ENABLED  VALIDATED     EMPID_PK
EMP_DEPT_ID_FK                 R                                DEPTID_PK                      ENABLED  VALIDATED

===================================================================================
-- timestamp
create table time_test
(a date,
 b timestamp(6), -- �ڸ��� ��� �� �ϸ� �⺻�� 6�ڸ�(������ Ȯ��Ÿ��, ���� ���� ��)
 c timestamp with time zone, -- ex. client +9:00(�ѱ�), server +8:00(�̰���) sysdate ��� �̰��� �ð����� ��!!, �׷��� time zone(+9:00) �� ǥ�� / ansi ǥ��
 d timestamp with local time zone, -- �ش����� �ð���� �ڵ�ȯ�� / ansi ǥ��
 e interval year(3) to month, -- �Ⱓ(�⵵ 3�ڸ�)�� ����ϴ� ��¥Ÿ��
 f interval day(3) to second); -- �ϼ�, �ú��� ���� 9�ڸ� ���� �Ⱓ �Է�


select sysdate/*a*/, systimestamp/*c*/, current_date/*a*/, current_timestamp/*c*/, localtimestamp/*b*/
from dual;


alter session set time_zone = '+08:00';

select sysdate, systimestamp, current_date, current_timestamp, localtimestamp
from dual;


insert into time_test(a,b,c,d,e,f)
values(current_date, current_date, current_timestamp, current_timestamp, 
	to_yminterval('10-02'),to_dsinterval('100 10:00:00')); -- to_yminterval e ����ȯ �Լ�, to_dsinterval f ����ȯ �Լ�

insert into time_test(a,b,c,d,e,f)
values(current_date, current_date, current_timestamp, current_timestamp, '01-00','365 10:00:00');

select * from time_test;

select sysdate + e, sysdate + f from time_test;

-- ��¥���(+)�� �� to_yminterval, to_dsinterval ���� ���ٰ�??

select extract(year from sysdate) from dual; -- ���ڳ⵵ 4�ڸ� �̾�
select extract(month from sysdate) from dual; -- ���ڴ� 2�ڸ� �̾�
select extract(day from sysdate) from dual; -- �����ϼ� 2�ڸ� �̾�
select extract(hour from localtimestamp) from dual; -- ���ڽð� 2�ڸ� �̾�
select extract(minute from localtimestamp) from dual; -- ���ں� 2�ڸ� �̾�
select extract(second from localtimestamp) from dual; -- ������ 2�ڸ� �̾�
select extract(timezone_hour from systimestamp) from dual; -- �ش����� �ð��� �̾�
select extract(timezone_minute from systimestamp) from dual; -- �ش����� �д� �̾�
