[문제85] EMPLOYEES 테이블을 복제 EMP_COPY 이름으로 복제하세요.

create table emp_copy
tablespace users
as select *
from hr.employees;

[문제86] EMP_COPY테이블에 employee_id에 primary key 제약조건을 추가하세요.

alter table emp_copy
add constraint emp_copy_empid_pk
primary key (employee_id);
commit;
desc emp_copy;
select * from user_constraints where table_name = 'EMP_COPY';

[문제87] EMP_COPY 테이블에 department_name varchar2(30) 컬럼을 추가하세요.

alter table emp_copy
add (department_name varchar2(30));

desc emp_copy;
select department_name from emp_copy;

[문제88] DEPARTMENTS 테이블에 있는 department_name을 기준으로 EMP_COPY 테이블에 department_name에 값을 수정하세요.(UPDATE)

update emp_copy ec
set department_name = (select department_name 
                       from hr.departments 
                       where department_id = ec.department_id);
commit; -- update는 transantion을 유발해서 마무리 해줘야 함.

[문제89] EMP_COPY 테이블에 department_name에 값을 NULL 값으로 수정하세요. (MERGE)

merge into emp_copy e
using hr.departments d
on (e.department_id = d.department_id)
when matched then
  update set e.department_name = null;

select department_name from emp_copy;
commit;

================================================================================

-- savepoint a, rollback to a (오라클 전용) ※ commit은 안됨

/* test 테이블 생성 */
drop table test purge;
create table test(id number);

/* row값 입력 */
insert into test (id) values(1);
savepoint a;

insert into test (id) values(2);
savepoint b;

insert into test (id) values(3);

/* savepoint b까지만 반영 */
rollback to b;

/* 결과확인 */
select * from test;
rollback;

================================================================================
drop table test purge;

-- default 값 : 입력 안되면 null 대신 지정된 값(함수)으로 자동입력(단, 형일치 필수)
create table test
(id number, name varchar2(20), sal number default 0, day date default sysdate)
tablespace users;

insert into test(id, name) values(1, 'james');

select * from test;

insert into test(id, name, sal, day)
values(2, 'harden', default, default);

insert into test(id, name, sal, day)
values(3, '이충희', null, null); /* null이 우선순위 더 높음 */

================================================================================

-- flashback query : dml 작업을 잘못 수생하고 commit까지 던졌다면... 
--                   특정시간에 값을 query를 통해 이전값을 확인가능 

/* dba 접속 */
show parameter undo;
/* 
undo : dml 작업시 이전값 저장해 놓은곳(스토리지 영역) why? 1.rollback, 2.읽기일관성

NAME                                               TYPE        VALUE                                                                                                
-------------------------------------------------- ----------- --------
undo_management                                    string      AUTO                                                                                                 
undo_retention                                     integer     900(초 동안만 보장) : 9i ver                                                                                                  
undo_tablespace                                    string      UNDOTBS1                                                                                             
*/

/* insa 접속 */
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

commit; /* 실수발생!! */

/* 삭제된 데이터 확인 */
select * from emp_20
as of timestamp to_timestamp('20171127 11:37:30', 'yyyymmdd hh24:mi:ss');

alter table emp_20 enable row movement;

/* XE는 안됨... */
flashback table emp_20 to timestamp to_timestamp('20171127 11:37:30', 'yyyymmdd hh24:mi:ss');

alter table emp_20 disable row movement;

================================================================================

-- flashback ~ drop (purge 란? 복원 안되는)
drop table emp_copy;

create table emp_copy
as select * from hr.employees;

/* 휴지통 */
show recyclebin;
select * from user_recyclebin;

/* 복원 */
flashback table emp_copy before drop;
flashback table emp_copy before drop rename to emp_new; /* 이름 같은것 있다면 */

/*purge 안해서 이름만 바꿨지 데이터는 건재*/
select * from "BIN$HLRpRexXTyCj/gtTQJc62A==$0"; 

/* 휴지통 비우기 */
purge recyclebin;

/* 연습장 그림 참조
drop/ truncate/ delete
drop table emp purge; -- 테이블 아예 없앰. (purge쓰지 않으면 bin$로 rename만 됨)
truncate table emp;   -- 첫번째 extent 만 놔두고 나머지 extent 모두 해지. rollback 안됨.
delete from emp;      -- extent는 놔두고 emp 테이블의 row 삭제. 잘못하면 rollback 가능.
(대상 row들이 undo tbs 안에 쌓여있음)
select * from v$option
> flashback table false.
*/
================================================================================
-- VIEW (※ view는 select문만 가지고 있는거라능~)
/*
1. 종류
- 단순view : 조인없음, dml 함
- 복합view : 조인조건, 그룹함수, group by, having / DML 작업 불가
2. 성질
view는 object가 아님. (마치 실제 있는 것처럼)select문장이 돌아갈 뿐
*/
select * from v$option; /* false는 추가비용 및 구입해야 사용가능 */

select * from session_privs; 
select * from role_sys_privs; /* role 안에 있는 시스템 권한 */
select * from role_tab_privs; /* 내가 받은 role 안에 어떤 object 권한이 들어있는지 확인 */
select * from user_sys_privs; /* dba한테 직접 받은 시스템권한 확인 */
select * from user_tab_privs; /* 내가 줬거나 받은 object 권한 */

select * from emp;

create table emp_30
as select * from hr.employees -- ctas : 스토리지 낭비, 유지관리 불편함
where department_id = 30;

select * from emp_30;
--------------------------------------------------------------------------------
/* hr 접속 */

create view emp_vw_30
as select * from employees
where department_id = 30;

select * from emp_vw_30;

grant select on emp_vw_30 to insa;
--------------------------------------------------------------------------------
/* insa 접속 */
select * from hr.emp_vw_30; /* 간접 엑세스 */
--------------------------------------------------------------------------------
/* hr 접속 */
/*
테이블이라면 문법체크, 시맨틱체크 실시되지만
뷰라면 아래 dictionary view에서 확인된 select문을 시행
*/

/* 내가 만든 object 확인 */
select * from user_objects where object_name = 'EMP_VW_30';

/* 진짜 테이블(dba) */
select * from obj$; 

/* dictionary view */
select * from user_views where view_name = 'EMP_VW_30';
--------------------------------------------------------------------------------
/* insa 접속 */
select * from user_views where view_name = 'EMP_VW_30'; /* null값(만든건 없으니) */
select * from all_views where view_name = 'EMP_VW_30'; /* insa 입장에서 확인 */

update hr.emp_vw_30
set salary = 1000;
/* 
오류 보고: 
SQL 오류: ORA-01031: insufficient privileges
*/

--------------------------------------------------------------------------------
/* hr 접속 */
grant select, insert, update, delete on emp_vw_30 to insa;
--------------------------------------------------------------------------------
/* insa */
-- 간접엑세스 : dml 작업가능
update hr.emp_vw_30
set salary = 1000;

select * from hr.emp_vw_30;

rollback;

================================================================================

[문제90] 부서이름별 총액급여, 평균급여, 최고급여, 최저급여률
      출력하는 query문을 작성한 후 dept_sal_vw를 생성하세요.

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

-- 선생님 풀이
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
/* 복합view 여도 DML작업 하려면 plsql로 트리거를 만들어야 함.
뷰 필요없어지면 드랍하면 됨. 뷰는 드랍 후 recyclebin 기능 없음. */

--------------------------------------------------------------------------------
-- create or replace view
/*
① CREATE VIEW는 뷰의 구조를 바꾸려면 뷰를 삭제하고 다시 만들어야 함.
② CREATE OR REPLACE VIEW는 새로운 뷰를 만들거나 기존의 뷰를 통해 새로운 구조의 뷰 생성가능

- VIEW에는 VIEW를 생성하는 SELECT 문만 저장(실제로 테이블은 존재하지 않음)
- VIEW를 SELECT 문으로 검색하는 순간 실제 테이블을 참조하여 보여준다.
- VIEW의 query문에는 ORDER BY 절을 사용할 수 없음
- WITH CHECK OPTION을 사용하면, 해당 VIEW를 통해서 볼 수 있는 범위 내에서만 UPDATE/INSERT 가능
ex)
CREATE OR REPLACE VIEW V_EMP_SKILL
        AS
        SELECT *
        FROM EMP_SKILL
        WHERE AVAILABLE = 'YES'
        WITH CHECK OPTION;

위와 같이 WITH CHECK OPTION을 사용하여 뷰를 만들면, 
AVAILABLE 컬럼이 'YES'가 아닌 데이터는 VIEW를 통해 입력불가
(즉, 아래와 같이 입력하는 것은 '불가능'하다)

INSERT INTO V_EMP_SKILL
VALUES('10002', 'C101', '01/11/02','NO');

- WITH READ ONLY을 사용하면 해당 VIEW를 통해서는 SELECT만 가능하며 
  INSERT/UPDATE/DELETE를 할 수 없게 됩니다. 만약 이것을 생략한다면, 
  뷰를 사용하여 Create, Update, Delete 등 모두 가능합니다.
*/

create or replace view emp_vw_30
as select employee_id, last_name || first_name name, salary*1.10 sal
from employees
where department_id = 30;
/*
1.view를 만들때 주의할 점 
  → column처럼 쓰일 곳에 표현식, * 등의 문자열이 있으면 안됨
    (별칭을 꼭 기술해 줘야함)
2.위의 view는 단순뷰(조인 X, 그룹 X)지만, 저렇게 표현식이 들어간 column이 있는 
  view는 insert/update 작업 불가함
  (논리적 접근 : sal도 계산되어있고 name도 2개 붙인거라서 update 불가
   employee_id만 update 가능, delete는 employee_id를 통해서 가능)
*/
select * from emp_vw_30;

grant select on emp_vw_30 to insa;

commit;
select * from user_objects where object_name = 'EMP_VW_30';
select * from obj$ where name = 'EMP_VW_30'; /* 실제위치 */
select * from user_views where view_name = 'EMP_VW_30';

================================================================================

-- sequence : 자동 일련번호 생성하는 object

create table emp_seq
(id number, name varchar2(20), day timestamp default systimestamp)
tablespace users;

create sequence emp_id_seq
increment by 1 /* 1씩 증가 */
start with 1 
maxvalue 50 /* 여기까지 */
cache 30 /* 옵션(기본값 20) */
nocycle; /* 51번째 오류 */
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
/* cache_size : 속도 향상을 위해 메모리 위해 미리 만들어서 올려둠(이 경우 20개) */

/* sequence name.nextval */
insert into emp_seq(id, name, day)
values(emp_id_seq.nextval, user, default); 

select * from emp_seq;

/* 현재 사용한 번호 */
select emp_id_seq.currval from dual; 

rollback; /* 영구 결번되어서 1에서 시작 안하고 입력된 max(id) 다음수부터 시작(감안하고 사용해야함) */

/* 쇼핑몰, 증권 등 sequence 사용, 일련번호 갭이 있으면 안 된다면 max 써야함. 
   다행히 index를 탄다면 제일 우측으로 찾아가면 됨 */
   
alter sequence emp_id_seq
maxvalue 100
cache 50;

/* 수정불가는 시작점 */

drop sequence emp_id_seq;

select emp_id_seq.currval from dual; /* 조회 : 사용한 번호 */
select emp_id_seq.nextval from dual; /* 생성 : 사용가능한 번호 */