<문제 9> 급여(salary)가 5000 ~ 12000의 범위에 속하지 않는 모든 사원의 성(last_name) 및 급여(salary)를 조회하세요.
select last_name, salary from employees where salary not between 5000 and 12000;

<문제 10> Matos 및 Taylor라는 성(last_name)을 가진 사원의 성(last_name), 직무 ID(job_id), 채용 날짜(hire_date)를 조회하세요.
select last_name, job_id, hire_date from employees where last_name = 'Matos' or last_name = 'Taylor';

<문제 11> job_id에 SA로 시작하고 10000 이상의 급여를 받는 사원검색을 조회하세요.(employees)
select * from employees where job_id like 'SA%' and salary >= 10000;

<문제 12> last_name의 세번째 문자가 'a' 또는 'e'가 포함된 모든 사원의 성(last_name)을 조회하세요.
select last_name from employees where last_name like '__a%' or last_name like '__e%';
select last_name from employees where substr(last_name, 3, 1) in('a', 'e');

<문제 13> 2006년도 입사한 사원의 사원번호(employee_id), 성(last_name), 입사한 날짜(hire_date)를 조회하세요.
select employee_id, last_name, hire_date from employees where hire_date >= to_date('20060101','yyyymmdd') and hire_date < to_date('20070101','yyyymmdd');
※ to_date : 문자 → 날짜 형변환 함
-- select * from nls_session_parameters; 참조해서 해당지역 날짜 포멧에 맞게 작성해야지 오라클이 내부적으로 to_date 사용
-- 년도만 뽑아내려면 to_char(hire_date,'yyyy') = '2006' 형변환으로 인해 full scan 될 가능성이 있음
-- sysdate : 시분초 도 볼수있는

<문제 14> 80번 부서(department_id) 사원중에 commission_pct 값이 0.2 이고 job_id는 SA_MAN인 사원의 employee_id, last_name, salary를 조회하세요.
select employee_id, last_name, salary from employees where department_id = 80 and commission_pct = 0.2 and job_id = 'SA_MAN';

=========================================================================================================================================================

-- in 연산자에 null 적용
select * from employees where employee_id in(100, 200, null);
select * from employees where employee_id = 100 or employee_id = 200 or employee_id = null;
→ 조회가능

-- in 연산자에 not 적용 (not in)
select * from employees where employee_id not in(100, 200, null);
select * from employees where employee_id <> 100 and employee_id <> 200 and employee_id <> null;
→ 조회불가(null 값이 있으면 주의)

-- 현재 사원들의 관리자 번호
select manager_id from employees;
→ null값은 ceo(즉, ceo를 누가 관리한다는 말인가? 당연히 없지)

-- 관리자 사원정보 검색(서브쿼리 사용)
select * from employees where employee_id in(select manager_id from employees);
→ 서브쿼리 ( )안 쿼리문장, null 값을 포함하고 있으므로 in 연산자 사용

-- null 비교 연산자(is null / is not null)
select * from employees where manager_id is null;
select * from employees where department_id is null;
select * from employees where manager_id is not null;

※ 주의사항
select * from employees where employee_id is null
→ employee_id는 primary key 이기때문에 null 존재불가 

-- 관리자가 아닌 사원 검색
select * from employees where employee_id not in(select manager_id from employees where manager_id is not null);

-- 논리연산자 우선순위(and > or > not)
select * from employees where employee_id = 100 or employee_id = 200 and salary > 10000;
→ employee_id = 200 and salary > 10000 부터 수행됨

select * from employees where (employee_id = 100 or employee_id = 200) and salary > 10000;
→ ( ) 먼저 수행됨

-- 정렬하기(order by)
※ select 검색할 컬럼 from 테이블명 where 검색조건 order by 정령할 컬럼(컬럼이름, 별칭, 표현식, 위치표기법) asc(오름차순, 기본값) desc(내림차순)

select employee_id, last_name, salary from employees order by salary;
→ order by 제일 마지막에 처리, 기본은 오름차순
→ ... order by salary asc;(오름차순) / ... order by salary desc;(내림차순)

select employee_id, last_name, salary * 12 from employees order by salary * 12;
→ 표현식
select employee_id, last_name, salary * 12 ann_sal from employees order by salary * 12;
→ 별칭(ann_sal)
select employee_id, last_name, salary * 12 ann_sal from employees order by ann_sal;
→ 열별칭(ann_sal)

※ 주의사항
select employee_id, last_name, salary * 12 "ann_sal" from employees order by "ann_sal";
→ " " 일치
select employee_id, last_name, salary * 12 "ann_sal" from employees order by 3;
→ 위치표기법(3은 salary * 12)

select department_id, last_name, salary * 12 "ann_sal" from employees order by 1 asc, 3 desc;
→ 위치표기법 응용(부서는 오름차순, 부서별 급여 내림차순)

select employee_id from employees order by 1;
select employee_id from employees order by 1 desc;
→ 이미 index는 정렬되었으므로 leaf에서 full scan 한다.

-- 최소(대)값 구하기(min/max 알고리즘)
select min(employee_id) from employees;
select max(employee_id) from employees;
→ index는 정렬되어서 최소(대)값 빨리 찾음(최소값 : 좌측, 최대값 : 우측)

-- select * from user_ind_columns; index 여부확인

/* 
- 중복제거 키워드 : distinct
- 연결연산자 : ||
 문자 || 문자 → 문자
 문자 || 숫자 → 문자 || to_char(숫자) → 문자
 문자 || 날짜 → 문자
 문자 || NULL → 문자
- 산술연산자 : * / + - (우선순위 1 : * /, 2 : + -)
- 비교연산자 : =, <, >, <=, >=, <>, !=, ^=
- 논리연산자 : and, or, not
- 기타비교연산자
   between 작은값 and 큰값 ( >= and <= )
   in ( ~ or ~ )
   like (wild card : %, _ )
   is null
*/

-- 함수 : 기능의 프로그램
1. 단일행함수(하나씩 집어넣어서 하나씩 처리하는), 그룹함수(여러개 집어넣어서 하나로 나옴)
ex)
select lower(last_name) from employees;
→ 단일행함수
select min(salary) from employees;
→ 그룹함수

2. 문자함수
-- 대소문자 변환함수
lower(last_name) : 소문자, upper(last_name) : 대문자, initcap(last_name) : 첫글자만 대문자

-- 문자를 조작하는 문자함수
concat(last_name, first_name) : last_name || first_name 같은 결과로 문자를 연결하는 함수(인수값 두개만 가능)
select concat(last_name, first_name) from employees;

substr(last_name, 1, 2) : 문자를 추출하는 함수(스타트 지점, 뽑을 수)
substr(last_name, -2, 2) : 문자를 추출하는 함수(스타트 지점, 뽑을 수)
  k i n g
  1 2 3 4
 -4-3-2-1
select last_name, substr(last_name, 1, 1) from employees;
→ 추출되는 순서는 좌에서 우로

select * from nls_database_parameters;
→ XE는 미국을 기준으로 나옴

select substr('hong', 1, 2), substr('홍길동', 1, 2) from dual;
select substrb('hong', 1, 2), substrb('홍길동', 1, 3) from dual;
→ b = byte 를 기준으로 문자 추출(한글자당 3byte)
select substrc('hong', 1, 2), substrc('홍길동', 1, 2) from dual;

-- 문자타입
/* NLS_CHARACTERSET AL32UTF8(영어 1byte, 한글 3byte) */
varchar2 : 가변, 입력한 크기 사용한 만큼만 가지게 됨(빈공간 없게)
char : 고정, 빈공간 그래도 둠(업데이트성이 빈번하게 발생되는 문자열은 이걸로)

NLS_NCHAR_CHARACTERSET AL16UTF16
nvarchar2 : national 용
nchar
한글, 한자, 일어, 영어만 넣는 MS 언어체계 NLS_CHARACTERSET = KO16MSWIN949(영어 1byte, 한글 2byte)

select * from user_objects where object_name = 'EMPLOYEES';
→ object_id 처음 만들때 생성
→ data_object_id이 다르면 재구성된 것

-- length(글자의 길이 및 크기)
select last_name, length(last_name) from employees;
select length('hong'), length('홍길동') from dual;
select lengthb('hong'), lengthb('홍길동') from dual;
→ b = byte 를 기준으로 크기 측정(한글자당 3byte)

-- instr(글자의 위치정보)
select instr('aabbcc', 'b') from dual;
→ 첫번째 b 위치

select instr('aabbcc', 'b', 1, 1) from dual;
→ 첫번째 b 위치

select instr('aabbcc', 'b', 1, 2) from dual;
→ 두번째 b 위치

-- replace(치환함수)
select replace('100-001', '-', '%') from dual;
→ - 를 % 로
select replace('  100  001  ', ' ', '') from dual;
→ 빈공간 제거

-- trim(연속되는 접두 및 접미만 문자 제거)
select trim('a' from 'aabbcaa') from dual;
→ 둘다

select ltrim('aabbcaa', 'a') from dual;
→ 앞쪽만

select rtrim('aabbcaa', 'a') from dual;
→ 뒷쪽만

select replace('aabbcaa', 'b') from dual;
/*
※ 가운데는 지울수 없음, 지우려면 replace 활용
※ dual : 함수 및 계산식을 테이블 생성 없이 수행하기 위한 'dummy' 테이블
          값이 들어있지 않은 임시의 공간
          1. 오라클에 의해서 자동으로 생성되는 테이블
          2. sys스키마에 있지만 모든 사용자가 엑세스 가능
          3. VARCHAR2(1)로 정의된 dummy라고 하는 하나의 컬럼
          4. 함수 및 계산을 실행할 때 임시사용에 적합
*/