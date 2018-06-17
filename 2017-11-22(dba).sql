select * from session_privs where privilege = 'CREATE USER';

-- user ������
create user james 
identified by oracle /* pw */
default tablespace users /* ���̺� �����Ϸ��� �⺻���� ���̺����̽� */ 
temporary tablespace temp /* ��Ʈ �۾��� temp(�ӽ� ���������)�� ������ */
quota 10m on users; /* ���̺����̽� ������ ���� �޴� �۾� */

select * from dba_tablespaces;
select * from dba_data_files;
select * from dba_temp_files;
select * from dba_users;

-- james ������ �α��� ���� ���Ѻο� �ؾ��� conn james/oracle ��(sql cmd)
grant create session to james;

-- james ������ �α��� ���� ��������
revoke create session from james;

-- ���� ������ �� alter
alter user james identified by james; /* pw */
alter user james quota ... ;

select * from dba_ts_quotas;

alter user james quota unlimited on users; /* unlimited : ���� */

-- james ������ ���̺� ����� �ִ� ���� �ο�
grant create table to james;