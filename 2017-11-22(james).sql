select * from user_sys_privs; -- ���� ���� �ý��۱��� Ȯ��
select * from user_tab_privs; -- ���� ���� �Ǵ� �ο��� ��ü���� Ȯ��
select * from user_users; -- ������
select * from user_ts_quotas; -- ���� ����� �� �ִ� tablespace �������� Ȯ��
/* -1 �������� �޾Ҵ� */

create table test
(id number(4), name varchar2(20), day date)
tablespace users; -- �̰� �� ���� default�� �����

drop table test1;

-- table �����Ϸ��� ���� üũ�� ����
1. create table ������ �޾Ҵ��� Ȯ��
2. ����� �� �ִ� tablespace Ȯ�� : user_ts_quotas
-- check!!
desc insa;

-- insert : ������ ������ �ƴ϶� cmd���� �� ���ϼ� �ִ�.
insert into test(id, name, day)--�ɼ������� �� �ִ� ����
values(1, 'ȫ�浿',to_date('20171122','yyyymmdd'));

insert into test(id, name, day)--�ɼ������� �� �ִ� ����
values(2, '������',to_date('20171122','yyyymmdd'));

insert into test(id, name, day)
values(3, '�Ӳ���', to_date('20171121','yyyymmdd'));

insert into test(id, name, day)
values(4, user, sysdate);

commit; -- ������ DB�� ����
rollback; -- ������ ���

select * from test; 

-- rename : ddl / rename test to insa;

update test
set name = '������', day = null
where id = 2; -- ������ �� ��ġ

delete from test -- ���� rollback
where id = 2;

-- test ��������
drop table test purge;

create table insa
(id number(2), name varchar2(20), sal number(10), day date)
tablespace users;
/*
# DML~DDL (~DCL) ����â �۾� ����
# transantion ���� : �������� select ������ dml�� 
                     �ϳ��� ��� ó���ϴ� �۾�����
  - �׷��� �߰��߰� commit �Ǵ� rollback�� ���ϴٰ� ���߿� �ϸ� �ѹ濡 �� ����
# auto commit : ddl, dcl ���� �� exit, conn�� �����ϸ� �߻���
# auto rollback : �ý������, ��Ʈ��ũ���, â�ݱ� Ŭ��
*/

select * from insa;
delete from insa where rowid <> 'AAAE/0AAEAAAAFXAAB' ;
select rowid, id from insa;
select * from insa;
rollback;