[문제79] 오라클 DB에 유저가 접속해서 작업해야 합니다.
         새로운 user를 생성하세요.
         
	 유저이름 : insa
         default tablespace : users
	 temporary tablespace : temp
	 users tablespace 사용량 : unlimited

create user insa
identified by insa 
default tablespace users 
temporary tablespace temp
quota unlimited on users;

/*
# DML~DDL (~DCL) 같은창 작업 위험
# transantion 단위 : 논리적으로 select 제외한 dml을  ← 읽기 일관성, 작업시 부담감 감소
                     하나로 묶어서 처리하는 작업단위
  - 그래서 중간중간 commit 또는 rollback을 안하다가 나중에 하면 한방에 훅 간다
# auto commit : ddl, dcl 문장 및 exit, conn을 수행하면 발생됨
# auto rollback : 시스템장애, 네트워크장애, 창닫기 클릭
*/
select * from dba_tablespaces; 
-- view로 제공, system : 오라클 입장에서 자신을 관리하기 위한 정보, sysaux : 10g부터 제공 machine learning, 
-- undotbs1 : 작업시 임시저장소(부족하면 dml 추가입력 불가)
-- users : 샘플계정들 저장
select * from dba_data_files;
select * from dba_temp_files;
select * from dba_users;
select * from ts$; -- 실제 테이블

[문제80] insa 유저에게 create session, create table 시스템 권한을 부여해주세요.
	
grant create session to insa;
grant create table to insa;

select * from user_sys_privs;
select * from user_tab_privs;
select * from user_users;
select * from user_views;

[문제81] insa 유저는 사원정보를 저장하기위해 emp 테이블을 생성하세요.
	컬럼 이름   	컬럼 타입
	  id		number(3)
	  name		varchar2(20)
	  day		date

create table insa.emp
(id number(3), name varchar2(20), day date) -- date 7byte 고정
tablespace users;

[문제82] emp 타입의 신규데이터를 입력해주세요.
	100,홍길동,시스템시간정보
  
insert into insa.emp(id,name,day) -- block에 저장
values(100,'홍길동',sysdate);
commit;

select * from insa.emp;
commit;
================================================================================
/* insa계정 */
select * from emp;
select * from hr.employees; -- hr에 대한 조회권한 못받아서 오류발생

/* hr계정 */
grant select, insert, update, delete on hr.employees to insa; -- 이렇게 부여는 가능하지만 현장은 흔치않음
grant select on hr.employees to insa; 

select * from user_tab_privs; -- 권한준 것 확인

/* insa계정 */
select * from user_tab_privs; -- 권한받은 것 확인

select * from hr.employees;

/* hr계정 */
grant select on hr.departments to insa; 
-- insa계정에 hr계정의 departments 테이블을 select할 수 있는 권한을 부여

/* insa계정 */
-- 테이블과 테이블을 복제 가능

-- c.t.a.s : 테이블 복제 (create table + tablespace + object 권한 필요(select))
create table copy_emp -- 복제본 담을 테이블 생성
tablespace users -- 이게 없으면 defualt에 저장됨
as select * from hr.employees; -- 분석할 테이블

desc copy_emp;
select * from copy_emp;

create table copy_dept
tablespace users
as select department_id, department_name from hr.departments;

desc copy_dept;
select * from copy_dept;

delete from copy_emp; -- 전체 row만 삭제, undotbs1에 임시저장
select * from copy_emp;
rollback;

truncate table copy_emp; -- 전체 row만 삭제, 영구히 삭제됨(주의해야 한다)
rollback;
select * from copy_emp;

insert into copy_emp
select * from hr.employees; -- row만 다시 복제
commit;
select * from copy_emp;

create table temp_emp
as select * from hr.employees where 1 = 2; -- 테이블 뼈대만 가져오려면 where에 false 조건

-- add : column 추가하는 방법(무조건 제일 마지막에 들어가짐)
desc emp;

alter table emp add(sal number(10));

create table emp1
(id number(3), name varchar2(20), sal number(10), day date)
tablespace users;

insert into emp1(id, name, day)
select id, name, day from emp;

select * from emp1;

-- modify : column 타입 수정
alter table emp modify(name varchar2(30));

-- column 삭제
alter table emp drop column sal;
select * from emp;

================================================================================

/* hr계정 */

-- 다중테이블 insert : 데이터마트 작업
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

/* 무조건 insert all : 많이 사용됨 */
insert all 
into sal_history(employee_id, hire_date, salary) values(empid, hiredate, sal) 
into mgr_history(employee_id, manager_id, salary) values(empid, mgr, sal)
select employee_id empid, hire_date hiredate, manager_id mgr, salary sal /*별칭 쓰면 values에도 별칭으로 아니면 원래이름*/
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

/* 조건 insert all : oracle 전용, 조건이 공통되면 둘다 넣을수 있음 */
insert all
when hire < to_date('20050101', 'yyyymmdd') then -- 조건절1
 into emp_history(employee_id, hire_date,salary)
  values(id, hire, sal)
when comm is not null then -- 조건절2
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
/* 조건 first insert : 조건제어문 스타일로 조건에 맞는 것만 들어감 */
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
when sal < 5000 then -- select에 있는 salary임
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

-- merge : 병합(insert, delete, update)
create table oltp_emp
as select employee_id, last_name, salary, department_id
   from employees;
   
create table dw_emp
as select employee_id, last_name, salary, department_id
   from employees
   where department_id = 20;

select * from oltp_emp;

alter table oltp_emp add flag char(1); -- flag라는 열을 추가

desc oltp_emp;

update oltp_emp
set flag = 'd'
where employee_id = 202; -- merge 의 delete 확인용

update oltp_emp
set salary = '20000'
where employee_id = 201; -- merge 의 update 확인용

commit;

select * from oltp_emp where employee_id between 201 and 202;
select * from oltp_emp where department_id = 20;

select * from dw_emp; -- 여기에다 일치되는 키값 데이터를 update or delete


merge into dw_emp d -- target table, 여기로 insert, delete, update
using oltp_emp o /* 쿼리문이 들어갈 땐 (select * from oltp_emp) o */
on (d.employee_id = o.employee_id) 
when matched then -- merge keyword / 키값이 일치되는 놈들은 ...
      update set -- 필수
        d.last_name = o.last_name,
        d.salary = o.salary * 1.1,
        d.department_id = o.department_id
      delete where o.flag = 'd' -- 옵션
when not matched then  -- merge keyword /  키값이 안 일치되는 놈들은 ... / 옵션
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

/* merge 별도의 권한은 없고, 위의 경우에 dw_emp는 insert, delete, update 권한
   oltp_emp는 select 권한이 있어야 한다(다른 계정에서 사용할 때)*/

================================================================================

create table copy_emp
as select * from employees;

-- 키값이 틀리면 update
update copy_emp
set job_id = (select job_id
              from copy_emp
              where employee_id = 200),
    salary = (select salary
              from copy_emp
              where employee_id = 202)
where employee_id = 113;

select employee_id, job_id, salary from copy_emp where employee_id in(200,113);

-- 키값이 같으면 update
update copy_emp
set(job_id, salary) = (select job_id, salary
                       from copy_emp
                       where employee_id = 200)
where employee_id = 113;

================================================================================
-- delete에서 서브쿼리 활용
delete from copy_emp 
where department_id in(select department_id
                       from departments
                       where department_name like '%Public%');
select * from copy_emp where department_id = 70;
commit;
================================================================================
-- 제약 조건 : dml 작업시 데이터 품질유지를 위한 방안

- NOT NULL : null만 체크해서 불허하는 조건(중복 허용)
- UNIQUE : 중복성만 체크해서 불허나는 조건(null 허용 / unique index 자동생성)
- PRIMARY KEY : null & unique 둘다 체크해서 불허나는 조건(테이블의 대표성을 띄는 열 / unique index 자동생성)
- FOREIGN KEY : primary key 또는 unique 제약조건을 참조해서 불허하는 조건(primary key에 없는 것을 거르기)(null, 중복 허용) 참조무결성
- CHECK : 조건식이 true인 경우에만 입력과 수정이 가능(null, 중복 허용)


CREATE TABLE copy_emp
( employee_id NUMBER(6) CONSTRAINT copy_emp_employee_id PRIMARY KEY
, first_name VARCHAR2(20)
, last_name VARCHAR2(25)  CONSTRAINT copy_emp_last_name_nn NOT NULL
, email VARCHAR2(25)
CONSTRAINT copy_emp_email_nn NOT NULL /* CONSTRAINT 이름(30자) 타입 */
CONSTRAINT copy_emp_email_uk UNIQUE
, phone_number VARCHAR2(20)
, hire_date DATE CONSTRAINT copy_emp_hire_date_nn NOT NULL
, job_id VARCHAR2(10)
CONSTRAINT copy_emp_job_nn NOT NULL
, salary NUMBER(8,2) CONSTRAINT copy_emp_salary_ck CHECK (salary>0)
, commission_pct NUMBER(2,2)
, manager_id NUMBER(6) CONSTRAINT copy_emp_manager_fk REFERENCES copy_emp (employee_id) /* REFERENCES : foreign key 제약 */
, department_id NUMBER(4) CONSTRAINT copy_emp_dept_fk REFERENCES departments (department_id)); 
  /* foreign key 제약조건을 걸어야지 pk 삭제가 방지(종속관계), 품질유지 */

select * from user_tables;
select * from user_constraints where table_name = 'COPY_EMP'; -- 테이블에 걸린 제약조건 목록조회 
/* 그냥 복제한 테이블은 not null 제약조건만 자동으로 포함이 되고 나머지는 사용자가 설정을 해야함 */
select * from user_cons_columns; -- 컬럼에 걸린 제약조건 목록조회

select * from copy_emp;

================================================================================
-- 제약조건 테스트
create table copy_dept
(dept_id number(2) unique,
dept_name varchar2(20) );

insert into copy_dept values(10,'인사팀');
insert into copy_dept values(null,'영업팀');
commit;

select * from copy_dept;

select * from user_cons_columns where table_name = 'COPY_DEPT';

create table copy_emp
(id number(2),
name varchar2(20),
dept_id number(20) references copy_dept(dept_id));

insert into copy_emp values(1,'홍길동',10);
insert into copy_emp values(2,'박찬호',null);
commit;

select * from copy_emp;

select e.*, d.*
from copy_emp e, copy_dept d
where e.dept_id = d.dept_id;

-- fk제약조건 없애면서 삭제하는 쿼리문
drop table copy_dept cascade constraints purge;