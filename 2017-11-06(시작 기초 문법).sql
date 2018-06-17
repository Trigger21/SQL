-- 오라클 다운 받은 후(암호 설정 : oracle)
cmd 창 접속
sqlplus sys/oracle as sysdba -- 시스템 계정(최상위)으로 접속

select * from dba_users; 
alter user hr identified by hr account unlock; (expired/locked 해제)
===================================================================
select * from tab;

desc employees

select * from employees;

-- select 문 기능 : projection(column), selection(row), join(서로 다른 테이블에서 가져옴)

=================================================================================================================================================

- 동일한 SQL문의 기준 : 

1. 대소문자, 공백, tab key, enter key 일치

2. 주석 -- /* */

3. 힌트 /*+  */ 실행계획을 제어하는 방법

4. 상수값, 리터럴값(문자값) 동일 (select first_name || ',' || last_name from employees; / select 'My name''s ' || first_name || ' ' || last_name from employees;)

|| : 사용시 타입 맞는걸로(문자+문자, 문자+숫자-> no)

==================================================================================================================================================

- 문자열 기입 방법

select department_name || ' Department is manager id:' || manager_id from departments;

select department_name || ' Department''s manager id:' || manager_id from departments;

select department_name || q'[ Department's manager id:]' || manager_id from departments;

select department_name || q'< Department's manager id:>' || manager_id from departments;

select department_name || q'! Department's manager id:!' || manager_id from departments;

select department_name || q'{ Department's manager id:}' || manager_id from departments;

select department_name || q'( Department's manager id:)' || manager_id from departments;

select department_name || q'+ Department's manager id:+' || manager_id from departments;

====================================================================================================================================================

last_name || first_name : 표현식

select last_name || first_name name from employees; 
SELECT last_name || first_name as name FROM employees;
: 열별칭(열 이름 NAME)

SELECT last_name || first_name as "name" FROM employees;
(열 이름 name)

select last_name || first_name "이름@" from employees;

====================================================================================================================================================

- 산술연산자 : * : 곱셈, / : 나눗셈, + : 덧셈, - : 뺄셈

number : 전부다 가능

date : +, -

char : 사용불가

select employee_id, last_name, salary, salary * 12 , salary / 2, salary + 100, salary - 100 from employees;

- 우선순위 

 1순위 : *, /
 2순위 : +, -

ex) (((a * b) / c) + d)

- 다른연산

select power(10,2)
from dual; -- 10^2 

====================================================================================================================================================

- nvl : Null 값을 실제 값으로 대체하는 함수 ex) nvl(x , y) 단 x, y 형 일치
select last_name, salary, commission_pct, salary * 12 + commission_pct from employees;
select last_name, salary, commission_pct, salary * 12 + nvl(commission_pct,0) from employees;
(Null → 0)

- to_char : 형변환 함수(숫자 → 문자)
select last_name, nvl(commission_pct, 'no comm') from employees; 
(X) : commission_pct 숫자

select last_name, nvl(to_char(commission_pct), 'no comm') from employees; 
(O)

- 숫자/모델 요소
select employee_id, salary, to_char(salary, '999,999.00') from employees; -- (세자리 씩 , / 소수점 표시하는 양식) - 9는 숫자 안나오게
select employee_id, salary, to_char(salary, '000,999.9') "SALARY" from employees; -- 0은 0이 공란채우도록

select employee_id, salary, to_char(salary * 12 + nvl(commission_pct,0), '000,999.9') "Salary" from employees; -- (연봉을 위의 양식대로)
select employee_id, salary, to_char(salary * 12 + nvl(commission_pct,0), 'l900,999.9') "Salary" from employees;-- (l : 어느지역에서 열었나에 따라 화폐부호 바뀜)

=====================================================================================================================================================

select department_id from employees;

-- 중복행 제거 방법
select distinct department_id from employees;(Hash 알고리즘 적용)

=====================================================================================================================================================

--행을 제한하는 방법(where 사용)
select * from employees where employee_id = 100; (비교연산자 = , > , >= , < , <= , <> , != , ^=)

select * from employees where last_name = 'King';(문자로 찾음, 대소문자 조심)

--lower / upper / initcap함수 사용(입력에 사용) ※대소문자 구분!!
select * from employees where last_name = 'king';(index 참조)

last_name 의 값을 우측 문자와 비교전에 먼저 대소문자 변환을 실시하고 전체비교(비효율적) → 입력시 일정한 패턴으로 기입될 수 있도록 설정
select * from employees where lower(last_name) = 'king';(전수)
select * from employees where upper(last_name) = 'KING';(전수)
select * from employees where initcap(last_name) = 'King';(전수)

=====================================================================================================================================================

-- 날짜는 「지역」과 「언어」에 종속됨, 민감하게 반응하라

select * from nls_session_parameters; --(nls 정보보기)

- to_date : char → date (oracle 내부적으로 수행)
select * from employees where hire_date = to_date('2002-06-07','yyyy-mm-dd');
select * from employees where hire_date = to_date('20020607','yyyymmdd'); (어느지역에서도 조회가능)
select * from employees where hire_date = to_date('06072002','mmddyyyy');

=====================================================================================================================================================

논리연산자 : and, or, not

and : 
select * from employees where salary >= 10000 and salary <= 20000; [10000, 20000]
select * from employees where salary between 10000 and 20000; 

or : 
select * from employees where employee_id = 100 or employee_id = 200; 
select * from employees where employee_id in(100,200);

not :
select * from employees where salary not between 10000 and 20000; (10000 미만, 20000 초과)
select * from employees where employee_id not in(100,200); (100, 200 제외)

=====================================================================================================================================================