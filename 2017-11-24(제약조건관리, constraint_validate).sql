[문제83] 테이블논리적설계.pdf에 ERD(Entity Relationship Diagram)을 확인 한후 table instance chart를  보면서 테이블을 구성하세요.

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
-- 테이블_제약조건_관리

/*테이블 생성*/

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



/*열 추가*/

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

/*열 수정*/

SQL> ALTER TABLE emp MODIFY (last_name VARCHAR2(30)); -- not null은 modify

Table altered.

SQL> desc emp
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 EMPLOYEE_ID                                        NUMBER(6)
 LAST_NAME                                 NOT NULL VARCHAR2(30)
 SALARY                                             NUMBER(8,2)
 DEPARTMENT_ID                                      NUMBER(4)
 JOB_ID                                             VARCHAR2(9)


/*열 삭제*/

SQL> ALTER TABLE emp DROP COLUMN job_id; -- 테이블 락 걸림 즉시 지움(운영중이라면 다음 방법으로)

Table altered.

SQL> desc emp
 Name                                      Null?    Type
 ----------------------------------------- -------- ---------------------------
 EMPLOYEE_ID                                        NUMBER(6)
 LAST_NAME                                 NOT NULL VARCHAR2(30)
 SALARY                                             NUMBER(8,2)
 DEPARTMENT_ID                                      NUMBER(4)



SQL> ALTER TABLE emp SET UNUSED (salary); -- 이 컬럼에 대한 정보만 딕셔너리에서 지워(단, 실제 데이터는 존재), 복원불가

Table altered.

SQL> desc emp
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 EMPLOYEE_ID                                        NUMBER(6)
 LAST_NAME                                 NOT NULL VARCHAR2(30)
 DEPARTMENT_ID                                      NUMBER(4)


SQL> select * from user_unused_col_tabs; -- unused 갯수만 보임

TABLE_NAME                                                        COUNT
------------------------------------------------------------ ----------
EMP                                                                   1

SQL> ALTER TABLE emp DROP UNUSED COLUMNS; -- 고객 미사용 시간에 지우기 

Table altered.

SQL> select * from user_unused_col_tabs;

no rows selected


/*제약 조건 구문 추가*/

- 제약 조건 추가 또는 삭제. 제약 조건의 구조는 수정하지 않음
- 제약 조건 활성화 또는 비활성화
- MODIFY 절을 사용하여 NOT NULL 제약 조건 추가

SQL> ALTER TABLE dept ADD CONSTRAINT deptid_pk PRIMARY KEY(department_id);

Table altered.

SQL>  SELECT constraint_name, constraint_type,search_condition, index_name, status
      FROM user_constraints
      WHERE table_name = 'DEPT';


CONSTRAINT_NAME      CO SEARCH_CONDITION                                   INDEX_NAME STATUS
-------------------- -- -------------------------------------------------- ---------- ----------------
SYS_C007002          C  "DEPARTMENT_NAME" IS NOT NULL                                 ENABLED
DEPTID_PK            P                                                     DEPTID_PK  ENABLED


SQL> ALTER TABLE emp ADD CONSTRAINT empid_pk PRIMARY KEY(employee_id); -- 추가할 땐 pk 지정해야 함다.

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, index_name, status
     FROM user_constraints
     WHERE table_name = 'EMP';                                         -- unique, primary key → index object & segment

CONSTRAINT_NAME      CO SEARCH_CONDITION                                   INDEX_NAME STATUS
-------------------- -- -------------------------------------------------- ---------- ----------------
SYS_C007001          C  "LAST_NAME" IS NOT NULL                                       ENABLED
EMPID_PK             P                                                     EMPID_PK   ENABLED


SQL> ALTER TABLE emp ADD CONSTRAINT emp_dept_id_fk
     FOREIGN KEY (department_id) -- fk 추가할 땐 써야함
     REFERENCES dept(department_id) ON DELETE CASCADE; -- 옵션1 : fk-pk 걸린 pk row를 삭제할 때 참조하는 child row(fk)들을 삭제를 선행(주의해야 함)

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
     REFERENCES dept(department_id) ON DELETE SET NULL; -- 옵션2 : fk-pk 걸린 pk row를 삭제할 때 참조하는 fk field 값만 null로 update(child row값은 그대로 있음)

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
                                                                             /* 이게 기본값 */

SQL> SELECT constraint_name, column_name  FROM user_cons_columns  WHERE table_name = 'EMP';

CONSTRAINT_NAME      COLUMN_NAME
-------------------- --------------------
SYS_C007001          LAST_NAME
EMPID_PK             EMPLOYEE_ID
EMP_DEPT_ID_FK       DEPARTMENT_ID



/*제약 조건 삭제*/

SQL> ALTER TABLE dept DROP PRIMARY KEY;
ALTER TABLE dept DROP PRIMARY KEY
*
ERROR at line 1:
ORA-02273: this unique/primary key is referenced by some foreign keys

SQL> ALTER TABLE dept DROP PRIMARY KEY CASCADE; -- pk 삭제 방법1

Table altered.

<OR>

SQL> ALTER TABLE dept DROP CONSTRAINT deptid_pk CASCADE; -- pk 삭제 방법2

Table altered.



/*제약조건 수정*/
 not null 제약조건만 수정할수 있다.


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



/*제약 조건 비활성화*/

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

- CREATE TABLE 문과 ALTER TABLE 문 모두에 DISABLE 절을 사용할 수 있습니다.
- CASCADE 절은 종속 무결성 제약 조건을 비활성화합니다.
- UNIQUE 또는 PRIMARY KEY 제약 조건을 비활성화하면 UNIQUE 인덱스가 제거됩니다.
  /* pk를 참조하는 fk 존재시, cascade 사용 */


/*제약 조건 활성화*/

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


- 제약 조건을 활성화하면 해당 제약 조건이 테이블의 모든 데이터에 적용됩니다.
- UNIQUE key 또는 PRIMARY KEY 제약 조건을 활성화하면 UNIQUE 또는 PRIMARY KEY 인덱스가 자동으로 생성됩니다. /* cascade 사용 못함 */
- CREATE TABLE 문과 ALTER TABLE 문 모두에 ENABLE 절을 사용할 수 있습니다.


SQL> SELECT index_name, column_name
     FROM user_ind_columns
     WHERE table_name = 'EMP';

INDEX_NAME                                                   COLUMN_NAME
------------------------------------------------------------ ------------------------------
EMPID_PK                                                     EMPLOYEE_ID



SQL> CREATE TABLE cust (
     id NUMBER CONSTRAINT id_pk PRIMARY KEY,
     sal NUMBER,
     mgr NUMBER,                         /* 열 정의 (not null은 이것만 가능)*/
     comm NUMBER,
     CONSTRAINT mgr_fk FOREIGN KEY (mgr) REFERENCES cust(id),-- fk는 여기서 다르게 적음
     CONSTRAINT id_sal_ck CHECK (id > 0 and sal > 0),           /* 테이블 정의 */
     CONSTRAINT comm_ck CHECK (comm > 0));

Table created.

SQL> ALTER TABLE cust DROP (id);
ALTER TABLE cust DROP (id)
                       *
ERROR at line 1:
ORA-12992: cannot drop parent key column -- fk & check 참조중이라서...


SQL> ALTER TABLE cust DROP (sal);
ALTER TABLE cust DROP (sal)
                       *
ERROR at line 1:
ORA-12991: column is referenced in a multi-column constraint -- check 제약 걸려있음


SQL> ALTER TABLE cust DROP COLUMN sal CASCADE CONSTRAINTS; -- 제약을 제거후 삭제하는 방법

Table altered.


SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name,delete_rule, status
     FROM user_constraints
     WHERE table_name = 'CUST'; 

CONSTRAINT_NAME      CO SEARCH_CONDITION               R_CONSTRAI DELETE_RULE        STATUS
-------------------- -- ------------------------------ ---------- ------------------ ----------------
COMM_CK              C  comm > 0                                                     ENABLED
ID_PK                P                                                               ENABLED
MGR_FK               R                                 ID_PK      NO ACTION          ENABLED



/*테이블 열 및 제약 조건 이름 바꾸기*/


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
enable validate : 이거는 기존데이터든 이후에 입력되는 신규 데이터든 모든 데이터를 전부 검사(기본값)
                  그래서 enalbe validate를 하게 되면 오라클이 해당 테이블에 데이터가 변경되지 못하도록 
                  lock을 설정함 왜냐? 기존 데이터를 검사해야하니까.
                  검사 도중에 제약조건을 위반하는 값 not null인데 null값이 있다던지 이런게 발견되면 
                  에러를 발생하면서 enable 작업을 취소함.
                  [문법: ALTER TABLE 테이블명 ENABLE VALIDATE CONSTRAINT 제약조건이름;]

enable novalidate : enalbe 하는 시점까지 테이블에 들어있던 기존 데이터들은 검사하지 않고
                    enable 하는 시점 이후부터 입력되는 데이터만 제약조건을 적용해서 검사함
                  [문법: ALTER TABLE 테이블명 ENABLE NOVALIDATE CONSTRAINT 제약조건이름;]
                  
diable validate : 데이터 변경이 안되게끔 하는 옵션, 해당칼럼의 내용을 변경할 수없다.
                  insert, update, delete 작업을 수행할 수 없음. 11g 에서의 read only의 개념과 같음
                  [문법: ALTER TABLE 테이블명 DISABLE VALIDATE CONSTRAINT 제약조건이름;]

diable novalidate : 해당 제약 조건이 없어서 데이터가 전부 들어옴, 제약조건 걸려있는걸 파괴시키고 들어오는거임.(기본값)
                    alter table test_enable disable constraint te_name_nn
                    이렇게 novalidate랑 validate 안쓰면 novalidate로 간주
                   [문법: ALTER TABLE 테이블명 DISABLE NOVALIDATE CONSTRAINT 제약조건이름;]
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

SQL> alter table test add constraint test_id_pk primary key(id); -- 안 쓰면 enable validate 기본값 : 제약조건을 활성화 전 데이터 검사
alter table test add constraint test_id_pk primary key(id)
                                *
ERROR at line 1:
ORA-02437: cannot validate (HR.TEST_ID_PK) - primary key violated


SQL> alter table test add constraint test_id_pk primary key(id) disable; -- 생성은 하되, 활성화는 하지마(의도적) / 기본값 : disable novalidate / disable validate : dml 불허

Table altered.

SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated, index_name
FROM user_constraints
WHERE table_name = 'TEST';   

CONSTRAINT_NAME                C SEARCH_CON R_CONSTRAINT_NAME              STATUS   VALIDATED     INDEX_NAME
------------------------------ - ---------- ------------------------------ -------- ------------- ------------------------------
TEST_ID_PK                     P                                           DISABLED NOT VALIDATED

SQL> /* window : SQLPlus 에서만 */@%ORACLE_HOME%\rdbms\admin\utlexpt1  /* Linux/Unix */(@$ORACLE_HOME/rdbms/admin/utlexpt1) -- regidit : 레지

Table created. /* EXCEPTIONS 테이블이 생성된다 */


SQL> desc exceptions
 Name                                                                                                              Null?    Type
 ----------------------------------------------------------------------------------------------------------------- -------- -----------
 ROW_ID                                                                                                                     ROWID
 OWNER                                                                                                                      VARCHAR2(30)
 TABLE_NAME                                                                                                                 VARCHAR2(30)
 CONSTRAINT                                                                                                                 VARCHAR2(30)


SQL> alter table test enable constraint test_id_pk exceptions into exceptions; -- exceptions into 테이블명
alter table test enable constraint test_id_pk exceptions into exceptions
*
ERROR at line 1:
ORA-02437: cannot validate (HR.TEST_ID_PK) - primary key violated

SQL> select * from exceptions;

ROW_ID                         OWNER                          TABLE_NAME                     CONSTRAINT
------------------------------ ------------------------------ ------------------------------ ------------------------------
AAASTeAAEAAAB4YAAC             HR                             TEST                           TEST_ID_PK
AAASTeAAEAAAB4YAAA             HR                             TEST                           TEST_ID_PK


SQL> select rowid, id, name, sal from test where rowid in (select row_id from exceptions) for update; -- for update : 조회시점에 미리 락을 거는 방법(옵션)

ROWID                                  ID NAME                                                                SAL
------------------------------ ---------- ------------------------------------------------------------ ----------
AAASTeAAEAAAB4YAAA                      1 a                                                                  1000
AAASTeAAEAAAB4YAAC                      1 a                                                                  2000



SQL> update test
     set id = 3
     where rowid = 'AAASTeAAEAAAB4YAAC'; 

1 row updated.

SQL> commit; -- for update 락도 종료

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


SQL> SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated/*위반 데이터*/, index_name
FROM user_constraints
WHERE table_name = 'TEST';

CONSTRAINT_NAME                C SEARCH_CON R_CONSTRAINT_NAME              STATUS   VALIDATED     INDEX_NAME
------------------------------ - ---------- ------------------------------ -------- ------------- ------------------------------
TEST_ID_PK                     P                                           ENABLED  VALIDATED     TEST_ID_PK


SQL> alter table test add constraint test_sal_ck check(sal > 1000) enable novalidate;  -- 제약조건 활성하면서 새롭게 들어오는 데이터는 검증, 기존 데이터는 하이패스 / pk에는 할 수 없다.

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


SQL> alter table test disable validate constraint test_id_pk ; -- disable validate : 테에블의 dml 불허한다

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

<<¶?´?>>

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

[문제84] FOREIGN KEY 제약조건을 생성하려고 합니다. 문제를 해결해주세요.

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

/* 풀이1 : dept에 가상부서 55를 생성 */
desc dept; select * from dept;
insert into dept(department_id,department_name,manager_id,location_id) -- block에 저장
values(55,'null',null,null) ; commit;

-- <<해결방법>>

SQL>  ALTER TABLE emp ADD CONSTRAINT emp_dept_id_fk FOREIGN KEY (department_id) REFERENCES dept(department_id) enable novalidate; -- 기존 하이패스, 새로운 거는 검증                                     

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
     set department_id = 55 /* enable novalidate 설정이후에는 제약당한다는 예시 */
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
 b timestamp(6), -- 자리수 명시 안 하면 기본값 6자리(데이터 확장타입, 요즘에 많이 씀)
 c timestamp with time zone, -- ex. client +9:00(한국), server +8:00(싱가폴) sysdate 사용 싱가폴 시간으로 뜸!!, 그래서 time zone(+9:00) 도 표시 / ansi 표준
 d timestamp with local time zone, -- 해당지역 시간대로 자동환산 / ansi 표준
 e interval year(3) to month, -- 기간(년도 3자리)을 명시하는 날짜타입
 f interval day(3) to second); -- 일수, 시분초 이하 9자리 까지 기간 입력


select sysdate/*a*/, systimestamp/*c*/, current_date/*a*/, current_timestamp/*c*/, localtimestamp/*b*/
from dual;


alter session set time_zone = '+08:00';

select sysdate, systimestamp, current_date, current_timestamp, localtimestamp
from dual;


insert into time_test(a,b,c,d,e,f)
values(current_date, current_date, current_timestamp, current_timestamp, 
	to_yminterval('10-02'),to_dsinterval('100 10:00:00')); -- to_yminterval e 형변환 함수, to_dsinterval f 형변환 함수

insert into time_test(a,b,c,d,e,f)
values(current_date, current_date, current_timestamp, current_timestamp, '01-00','365 10:00:00');

select * from time_test;

select sysdate + e, sysdate + f from time_test;

-- 날짜계산(+)할 때 to_yminterval, to_dsinterval 많이 쓴다고??

select extract(year from sysdate) from dual; -- 숫자년도 4자리 뽑아
select extract(month from sysdate) from dual; -- 숫자달 2자리 뽑아
select extract(day from sysdate) from dual; -- 숫자일수 2자리 뽑아
select extract(hour from localtimestamp) from dual; -- 숫자시각 2자리 뽑아
select extract(minute from localtimestamp) from dual; -- 숫자분 2자리 뽑아
select extract(second from localtimestamp) from dual; -- 숫자초 2자리 뽑아
select extract(timezone_hour from systimestamp) from dual; -- 해당지역 시간대 뽑아
select extract(timezone_minute from systimestamp) from dual; -- 해당지역 분대 뽑아
