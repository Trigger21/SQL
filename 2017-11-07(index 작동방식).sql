[ INDEX �۵���� ]

<����3> 90�� department_id�� �ٹ��ϴ� ����� ��ȸ�ϼ���.

�� : select * from employees where department_id = 90; 

- ���� ����Ŭ������ select * from employees where to_number(department_id) = 90; (�̰� ������ �ȴ� index �ɸ� ���� �Լ��� ���� full scan)
 : char �� number(���ڰ� �� �����) 

�� ���� �ٸ����(�ǵ�ġ �ʰ� ���� �ٲ�� �� ��Ȳ�� �̸� �ľ��ؾ� �Ѵ�)
number ~ char
select * from employees where department_id = '90'; �� select * from employees where department_id = to_number('90'); (������ ���� ����)


* ��� : ������ ������ �ض�

================================================================================================================================

select rowid, employee_id from employees;

rowid : ���� colume (~ ���ּҿ� ���� �ߺ����� 18�ڸ� ���ĺ����� ����)

ex)
AAAEAbAAEAAAADNAAA = AAAEAb(#data object_id)AAE(#file num)AAAADN(#block num)AAA(#row slot)
 : �������� �ּ�

select * from user_objects; -- (���� ������ object ����)

- ����
select * from employees where rowid = 'AAAEAbAAEAAAADNABa'; (rowid�� ã��) <-optimizer�� ���� ���� ã�¹��(IO �ּ�)

- optimizer�� �����ȹ �ۼ�
 1. ������ ó�����
   a. full table scan(��ü�� �� �����ϴ� �ʿ�ÿ��� / �ϰ��� / �ٷ��� ������ ó��)
   b. rowid  scan(���� ó�� / �ϰ��� / �Ҽ��� ������ ó��)
      - by user rowid(���� ���)
      - by index rowid (ex. select * from employees where employee_id = 190;)

ex) id = 100�� ����� ã�ƺ���

select * from hr.emp where id = 100; 

�� 1. 100�� ���� rowid ã�ƾ� �Ѵ�
�� 2. optimizer ������ ��� � ����� ����� ���� ����(id�� primary key, unique �� full table scan ����)

(rowid scan)
create unigue index emp.idx on hr.emp(id) tablespace users; (unigue : �ߺ��� ����(����) ��� ���, emp.idx : segment or object name)
�̶� oracle���� ���� SQL���� �۵���Ų��. 
�� select id from hr.emp order by id; (order by id : ����) id ���� �����ͼ� ���Ľ�Ŵ 

index : �� ��� rowid�� ������ִ� �༮      

pinned : ���� �� leaf �� �ٽ� ���ƿü� �ֵ��� ���

 non unigue �� buffer pinning(�޸� ���) = block pinning(���丮�� ���) : IO�� ���̴� �۾�(���� ã�ư��� �� block ����ϰ� �־�)

===============================================================================================================================

select * from hr.emp where name = 'King';
create index emp.name.idx on hr.emp(name) tablespace users;
select name from hr.emp order by name;

select * from user_ind_columns; (index name ��� ����)

===============================================================================================================================

select * from hr.emp where dept_id = 10; (�μ��ڵ� 10���� ��� �̾ƶ�)
�� index �������� check!!

select * from user_ind_columns; (index �������� Ȯ���۾�)

create index emp.dept.idx on hr.emp(dept.id) tablespace users; 
�� emp.dept.idx : object, segment(��������� �ʿ��� object)

�� �������ÿ� �Ʒ� select�� ���ư���
select dept.id from hr.emp order by dept.id;

===============================================================================================================================

- in ������ ������

select * from employees where employee_id in(100,101,102); (select ... 100, select ... 101, select ... 102 �̷��� unigue scan 3�� �ǽ�)
�� �߸��� ��� IO ����(IO : 12)
�� in �Լ��� ������ �ִ� �� ã����

select * from employees where employee_id between 100 and 102; (�̷��� �籸�� �ؾ���!!)

===============================================================================================================================

- like ������ : ���������� ã�� ������

select * from employees where last_name like 'K%';  (% : wild card, �ޱ��� �ƹ��ų�)
select * from employees where last_name like 'K___'; (_ ������ ���� ���ڰ��� ������)

�� ������ %, _ ���ڿ� �տ� ������� 
select * from employees where last_name like '_ing'; (index full table scan)

select * from employees where jod_id like 'SA\_%' escape '\';  (^�� ����)
�� _�� ���ڷ� ǥ���ؾ� �Ҷ�

select * from employees where jod_id not like 'SA^_%' escape '^'; (index scan ���� ����)

- �Ǽ����(�������ϸ� ����ؾ� ��)

select * from employees where hire_date like '02%'; (�Ǽ��ڵ�)
�� ����Ŭ�� �����Լ� ����Կ� ���� �Ǽ�

�����δ� �Ʒ��� ���� �ٲ� ����
select * from employees where to_char(hire_date) like '02%'; (full scan)

select * from employees where employee_id = 100;
select * from employees where to_number(employee_id) = 100 ;
�� index �ɷ��� �ִ� ���� �Լ��� ���� �Ǽ����α׷� ��. (index�� Ÿ���ʰ� full scan)

===============================================================================================================================

<����5> ����߿� 2001/01/13�� �Ի��� ����� ��ȸ�ϼ���.

�� : select * from employees where hire_date = to_date('20010113','yyyymmdd'); 

�� ���������δ� ...to_date('20010113 00:00:00', 'yyyymmdd hh24:mi:ss');

�� �� �� ���� ������ �ִٸ� �̷��� �ϸ� �ȵ�! 

���� where hire_date >= to_date('20010113', 'yyyymmdd') and hire_date < to_date('20010114', 'yyyymmdd'); �� ����

===============================================================================================================================