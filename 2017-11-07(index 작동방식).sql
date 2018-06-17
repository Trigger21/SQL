[ INDEX 작동방식 ]

<문제3> 90번 department_id에 근무하는 사원을 조회하세요.

답 : select * from employees where department_id = 90; 

- 실제 오라클에서는 select * from employees where to_number(department_id) = 90; (이게 문제가 된다 index 걸린 곳에 함수를 쓰면 full scan)
 : char → number(숫자가 더 힘쎄다) 

※ 형이 다를경우(의도치 않게 형이 바뀌게 될 상황을 미리 파악해야 한다)
number ~ char
select * from employees where department_id = '90'; → select * from employees where department_id = to_number('90'); (문제가 되지 않음)


* 결론 : 동일한 형으로 해라

================================================================================================================================

select rowid, employee_id from employees;

rowid : 가상 colume (~ 집주소와 같고 중복없고 18자리 알파벳으로 구성)

ex)
AAAEAbAAEAAAADNAAA = AAAEAb(#data object_id)AAE(#file num)AAAADN(#block num)AAA(#row slot)
 : 물리적인 주소

select * from user_objects; -- (내가 생성한 object 보기)

- 응용
select * from employees where rowid = 'AAAEAbAAEAAAADNABa'; (rowid로 찾기) <-optimizer가 가장 빨리 찾는방법(IO 최소)

- optimizer는 실행계획 작성
 1. 데이터 처리방법
   a. full table scan(전체를 다 봐야하는 필요시에만 / 일과후 / 다량의 데이터 처리)
   b. rowid  scan(빠른 처리 / 일과중 / 소수의 데이터 처리)
      - by user rowid(직접 명시)
      - by index rowid (ex. select * from employees where employee_id = 190;)

ex) id = 100인 사원을 찾아보자

select * from hr.emp where id = 100; 

→ 1. 100에 대한 rowid 찾아야 한다
→ 2. optimizer 가성비 고려 어떤 방법을 사용할 건지 선택(id는 primary key, unique 라서 full table scan 안함)

(rowid scan)
create unigue index emp.idx on hr.emp(id) tablespace users; (unigue : 중복성 적은(없을) 경우 사용, emp.idx : segment or object name)
이때 oracle에서 별도 SQL문을 작동시킨다. 
→ select id from hr.emp order by id; (order by id : 정렬) id 값만 가져와서 정렬시킴 

index : 나 대신 rowid를 기억해주는 녀석      

pinned : 핀을 찍어서 leaf 로 다시 돌아올수 있도록 기억

 non unigue → buffer pinning(메모리 용어) = block pinning(스토리지 용어) : IO를 줄이는 작업(내가 찾아가야 할 block 기억하고 있어)

===============================================================================================================================

select * from hr.emp where name = 'King';
create index emp.name.idx on hr.emp(name) tablespace users;
select name from hr.emp order by name;

select * from user_ind_columns; (index name 목록 보기)

===============================================================================================================================

select * from hr.emp where dept_id = 10; (부서코드 10번인 놈들 뽑아라)
→ index 생성여부 check!!

select * from user_ind_columns; (index 생성여부 확인작업)

create index emp.dept.idx on hr.emp(dept.id) tablespace users; 
→ emp.dept.idx : object, segment(저장공간이 필요한 object)

※ 순간동시에 아래 select이 돌아간다
select dept.id from hr.emp order by dept.id;

===============================================================================================================================

- in 연산자 주의점

select * from employees where employee_id in(100,101,102); (select ... 100, select ... 101, select ... 102 이렇게 unigue scan 3번 실시)
→ 잘못된 방법 IO 증폭(IO : 12)
→ in 함수는 떨어져 있는 거 찾을때

select * from employees where employee_id between 100 and 102; (이렇게 재구성 해야함!!)

===============================================================================================================================

- like 연산자 : 문자패턴을 찾는 연산자

select * from employees where last_name like 'K%';  (% : wild card, 뒷글자 아무거나)
select * from employees where last_name like 'K___'; (_ 갯수에 따른 글자개수 정해짐)

※ 주의점 %, _ 문자열 앞에 사용자제 
select * from employees where last_name like '_ing'; (index full table scan)

select * from employees where jod_id like 'SA\_%' escape '\';  (^도 가능)
→ _을 문자로 표현해야 할때

select * from employees where jod_id not like 'SA^_%' escape '^'; (index scan 유도 안함)

- 실수사례(문자패턴만 사용해야 됨)

select * from employees where hire_date like '02%'; (악성코드)
→ 오라클이 내부함수 사용함에 따라 악성

실제로는 아래와 같이 바꿔 수행
select * from employees where to_char(hire_date) like '02%'; (full scan)

select * from employees where employee_id = 100;
select * from employees where to_number(employee_id) = 100 ;
→ index 걸려져 있는 곳에 함수를 쓰면 악성프로그램 됨. (index를 타지않고 full scan)

===============================================================================================================================

<문제5> 사원중에 2001/01/13에 입사한 사원을 조회하세요.

답 : select * from employees where hire_date = to_date('20010113','yyyymmdd'); 

→ 내부적으로는 ...to_date('20010113 00:00:00', 'yyyymmdd hh24:mi:ss');

시 분 초 까지 가지고 있다면 이렇게 하면 안됨! 

따라서 where hire_date >= to_date('20010113', 'yyyymmdd') and hire_date < to_date('20010114', 'yyyymmdd'); 로 수정

===============================================================================================================================