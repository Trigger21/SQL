select * from user_sys_privs; -- 내가 받은 시스템권한 확인
select * from user_tab_privs; -- 내가 받은 또는 부여한 객체권한 확인
select * from user_users; -- 내정보
select * from user_ts_quotas; -- 내가 사용할 수 있는 tablespace 권한정보 확인
/* -1 무한으로 받았다 */

create table test
(id number(4), name varchar2(20), day date)
tablespace users; -- 이거 안 쓰면 default에 저장됨

drop table test1;

-- table 생성하려면 먼저 체크할 사항
1. create table 권한을 받았는지 확인
2. 사용할 수 있는 tablespace 확인 : user_ts_quotas
-- check!!
desc insa;

-- insert : 영구히 저장은 아니라서 cmd에서 안 보일수 있다.
insert into test(id, name, day)--옵션이지만 꼭 넣는 습관
values(1, '홍길동',to_date('20171122','yyyymmdd'));

insert into test(id, name, day)--옵션이지만 꼭 넣는 습관
values(2, '춘향이',to_date('20171122','yyyymmdd'));

insert into test(id, name, day)
values(3, '임꺽정', to_date('20171121','yyyymmdd'));

insert into test(id, name, day)
values(4, user, sysdate);

commit; -- 영구히 DB에 저장
rollback; -- 영구히 취소

select * from test; 

-- rename : ddl / rename test to insa;

update test
set name = '차정훈', day = null
where id = 2; -- 수정할 행 위치

delete from test -- 주의 rollback
where id = 2;

-- test 완전삭제
drop table test purge;

create table insa
(id number(2), name varchar2(20), sal number(10), day date)
tablespace users;
/*
# DML~DDL (~DCL) 같은창 작업 위험
# transantion 단위 : 논리적으로 select 제외한 dml을 
                     하나로 묶어서 처리하는 작업단위
  - 그래서 중간중간 commit 또는 rollback을 안하다가 나중에 하면 한방에 훅 간다
# auto commit : ddl, dcl 문장 및 exit, conn을 수행하면 발생됨
# auto rollback : 시스템장애, 네트워크장애, 창닫기 클릭
*/

select * from insa;
delete from insa where rowid <> 'AAAE/0AAEAAAAFXAAB' ;
select rowid, id from insa;
select * from insa;
rollback;