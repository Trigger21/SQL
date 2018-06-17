[문제91]30번 부서 사원들의 EMPLOYEE_ID, LAST_NAME, HIRE_DATE,SALARY는 15% 인상된 급여
       정보들만 VIEW를 통해서 보려 합니다. 뷰이름은 v_dept30으로 만드세요.

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
사용방법
1. control file 생성
- 메모장에  emp.ctl로 저장

load data
infile emp.csv <-- 데이터만 있게
insert <-- 비워있는 테이블에 쓰는 옵션 (append : 데이터가 있는 테이블에 쓰는 옵션)
into table emp_2017
fields terminated by ',' -- field별 구분방법 지정
(EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID)

※ fields terminated by ',' optionally enclosed by '"' : " " 빼고 넣겠다

2. cmd 접속
> cd c:\data
> dir *.csv
> dir *.ctl
> sqlldr userid=hr/hr control=emp.ctl direct=true <-- 제약조건 위반여부 체크 안함/disable 됨/메모리 거치지 않고 바로 스토리지

insert : 비어있는 테이블에 데이터를 넣을때
append : 데이터가 있는 테이블에 새로운 데이터를 추가할 때
replace : 데이터가 있는 테이블에 기존데이터를 delete하고 새로운 데이터 추가 (주의해라 차라리 truncate 해라)
truncate : 데이터가 있는 테이블에 기존데이터를 truncate하고 새로운 데이터 추가 
*/

select count(*)
from emp_2017;

select * from emp_2017;

select * from user_constraints;
SELECT constraint_name, constraint_type,search_condition, r_constraint_name, status, validated, index_name
FROM user_constraints
WHERE table_name = 'EMP_2017';

================================================================================
-- sql loader : 대용량 데이터 오라클 db에 넣는??
 
insa.ctl <-- 메모장에 아래내용으로 저장 

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


c:\data> sqlldr hr/hr control=insa.ctl <- conventional load /* 제약조건(중요한 것만) 체크 */
/* userid 쓰지않아도 된다 */

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
insa.bad <-- 자동생성되는 메모장(오류로 반영되지 못한 데이터)

3, "KT","010-777-9999"

--------------------------------------------------------------------------------
SQL> TRUNCATE TABLE test;
--------------------------------------------------------------------------------

c:\data> sqlldr hr/hr control=insa.ctl direct=true <- direct path load 
/* 제약조건 체크 미실시로 unique index 깨진다 */

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
/* index가 깨져서 데이터 값 추가시 에러발생
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

SQL> alter table test disable constraint test_id_pk; /* pk index drop됨 */
/*
diable novalidate : 해당 제약 조건이 없어서 데이터가 전부 들어옴, 제약조건 걸려있는걸 파괴시키고 들어오는거임.(기본값)
                    alter table test_enable disable constraint te_name_nn
                    이렇게 novalidate랑 validate 안쓰면 novalidate로 간주
*/
Table altered.


SQL> @$ORACLE_HOME/rdbms/admin/utlexpt1.sql <--- exceptions 테이블 생성 하는 스크립트

/* window : SQLPlus 에서만 */@%ORACLE_HOME%\rdbms\admin\utlexpt1  
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


c:\data> sqlldr hr/hr control=insa.ctl direct=true <- direct path load /* not null은 체크함 */


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
--> dml 불허함 / 급여를 맘대로 수정할 수는 없으니 enabled novalidate / 

================================================================================

select * from test
as of timestamp to_timestamp('20171128 14:27:00', 'yyyymmdd hh24:mi:ss');

================================================================================

-- EXTERNAL_TABLES
/*
external 테이블은 DB 외부에 저장된 data 파일을 조작하기 위한 접근 방법의 하나로 
읽기 전용 테이블이다.
external 테이블의 실제 데이터는 DB 외부에 존재하지만, external 테이블에 대한 
metadata는 DB 내부에 존재하는 일종의 가상 테이블이다.
*/
conn sys/oracle as sysdba

create directory data_dir as 'C:\DATA\';
/* data_dir : 논리적 디렉터리
   'C:\data\' : 물리적인 디렉터리 */

SELECT owner, directory_name, directory_path
FROM all_directories;   

drop directory data_dir;

GRANT READ, WRITE ON DIRECTORY data_dir TO hr;    



CREATE TABLE hr.empxt /* 내부에 주석이 있으면 오류가 발생할 수 있음(실행시 제거) */
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
         records delimited by newline /* 한행씩 읽어 내려가시오 */
         badfile 'empxt.bad'          /* 수동으로 badfile 생성 */
         logfile 'empxt.log'          /* 성공하면 logfile 생성 */
         fields terminated by ','      
         missing field values are null /* 내가 가져온 row하고 맞지않으면 null로 넣어 */  
         (
          employee_id, first_name, last_name, email, phone_number, 
          hire_date char date_format date mask "RR/MM/DD", /* 데이터 모양에 맞게 설정 */    
          job_id, salary, commission_pct, manager_id, department_id      
         )      
      )      
       LOCATION ('emp.csv')      
     )      
       reject limit unlimited /* 오류나는 것 때문에 멈추는 경우를 방지 */
/
 
drop table hr.empxt purge;          
desc empxt;

select * from hr.empxt;

select * from USER_EXTERNAL_TABLES ;      
     	
select * from USER_EXTERNAL_LOCATIONS;
	
select * from  all_directories; /* 논리적인 디렉터리 권한은 dba에게 */

delete from empxt; 		-- 오류(external table 은 dml 조작 안됨. index 생성 안됨.)