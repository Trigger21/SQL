select * from session_privs where privilege = 'CREATE USER';

-- user 생성문
create user james 
identified by oracle /* pw */
default tablespace users /* 테이블 생성하려면 기본적인 테이블스페이스 */ 
temporary tablespace temp /* 소트 작업시 temp(임시 만들어지는)로 내려가 */
quota 10m on users; /* 테이블스페이스 쓰려면 권한 받는 작업 */

select * from dba_tablespaces;
select * from dba_data_files;
select * from dba_temp_files;
select * from dba_users;

-- james 계정에 로그인 가능 권한부여 해야지 conn james/oracle 됨(sql cmd)
grant create session to james;

-- james 계정에 로그인 가능 권한해제
revoke create session from james;

-- 추후 수정할 땐 alter
alter user james identified by james; /* pw */
alter user james quota ... ;

select * from dba_ts_quotas;

alter user james quota unlimited on users; /* unlimited : 무한 */

-- james 계정에 테이블 만들수 있는 권한 부여
grant create table to james;