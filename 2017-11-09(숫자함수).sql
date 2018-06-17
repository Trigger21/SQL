<문제15>
last_name의 "J" 또는 "A" 또는 "M"으로 시작하는 이름을 가진 모든 사원의 last_name(첫번째 문자는
대문자, 나머지는 모두 소문자)과 last_name의 길이를 표시하는 query 를 작성합니다.
각 에 적절한 열별칭을 지정합니다. 사원의 성(last_name)을 기준으로 결과를 오름차순 정렬합니다.
select initcap(last_name) as "last name", length(last_name) as "length" 
from employees 
where substr(last_name, 1, 1) in('J','A','M') /* substr : 문자 추출 */
order by 1;

select initcap(last_name) as "last name", length(last_name) as "length" 
from employees 
where last_name like 'J%' or last_name like 'A%' or last_name like 'M%' 
order by 1;

select initcap(last_name) as "last name", length(last_name) as "length" 
from employees 
where instr(last_name, 'J') = 1 or instr(last_name, 'A') = 1 or instr(last_name, 'M') =1 
order by 1; /* instr : 글자의 위치정보(숫자) 제공 */

<문제16>
department_id(부서코드)가 50번 사원들 중에 last_name에 두번째 위치에 "a"글자가 있는 사원들을 조회하세요.
select * from employees where department_id = 50 and substr(last_name, 2, 1) = 'a';
select * from employees where department_id = 50 and last_name like '_a%';
select * from employees where department_id = 50 and instr(last_name, 'a', 1, 1) = 2;

-- index는 형이 바뀌는 함수, 대소문자 바뀌는 함수는 기능상실 하지만 substr, instr은 기능유지(함수를 적용한다고 다 상실되는 것 아님)
-- select 사용시 필요한 열만 찾아라(성능)

select * from user_ind_columns;
-- view 임
select * from ind$;
-- 오라클 인덱스 정보 다가진 진짜 테이블(sys에서만 보임)

======================================================================================================================

-- 숫자함수
- round : 반올림 함수, round(숫자, 여기까지 반올림)
select 45.926, round(45.926, 0), round(45.926, 1), round(45.926, 2), round(45.926, 3), round(45.926, -1), round(45.926, -2) from dual;

 4 5.9 2 6
-1 0 1 2 3

- trunc : 버림함수, trunc(숫자, 여기까지만 남김)
select 45.926, trunc(45.926, 0), trunc(45.926, 1), trunc(45.926, 2), trunc(45.926, 3), trunc(45.926, -1), trunc(45.926, -2) from dual;

- mod : 몫이 아닌 나머지 값을 출력하는 함수 /* 짝수, 홀수 판별시 유용하게 사용됨 */
select mod(10, 3) from dual;

<문제17> employees 테이블에 있는 employee_id, last_name, salary, salary는 10% 인상된 급여를 계산하면서 계산된 급여는 
        소수점은 반올림해서 정수값으로 표현하고 열별칭은 New Salary로 표시하세요.
select employee_id, last_name, round(salary * 1.10, 0) "New Salary" from employees;        

-- 날짜함수
date : 세기년월일시분초 5자리
select * from nls_session_parameters; /* 각종 단위값 확인(접속한 나라에 종속) */

- sysdate : 서버의 시간정보를 출력하는 함수
select sysdate from dual;
→ 서버의 날짜시간정보를 출력하는 쿼리문
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss.sssss') from dual; /* 24시간 형태 */
select to_char(sysdate,'yyyy-mm-dd hh:mi:ss.sssss am') from dual; /* 12시간 형태 */

alter session set nls_date_format = 'yyyy-mm-dd hh24:mi:ss.sssss';
→ 내가 원하는 날짜모델로 변환(내 session에서만 열려있는 동안만 적용)
select sysdate from dual;
select employee_id, hire_date from employees;
→ 설정한데로 바뀜

- current_date : client에 대한 시간정보를 출력하는 함수
alter session set time_zone = '+08:00'; /* 싱가포르 기준 */
select sysdate "korea", current_date "singapore" from dual;

alter session set time_zone = '-05:00'; /* 뉴욕 기준 */
select sysdate "korea", current_date "new york" from dual;

※ os에 설정된 시간대를 보여줄 뿐, 오라클이 시간정보를 가지고 있는 것은 아님

- 날짜계산
날짜(DATE) + 숫자(NUM) = 날짜(DATE)
날짜(DATE) - 숫자(NUM) = 날짜(DATE)
select sysdate + 100, sysdate - 100 from dual;

날짜(DATE) - 날짜(DATE) = 숫자(NUM)
select sysdate - hire_date from employees;

※ 날짜(DATE) + 날짜(DATE) = 오류
select sysdate + hire_date from employees;

날짜(DATE) ± 시간/24 = 날짜(DATE)
날짜(DATE) ± 분/(24*60) = 날짜(DATE)
날짜(DATE) ± 초/(24*60*60) = 날짜(DATE)
select sysdate + 3/24, sysdate + 10/(24*60), sysdate + 30/(24*60*60) from dual;
/* 3시간 증가, 10분 증가, 30초 증가 */

ex) 사원들의 입사일로 부터 현재까지 근무기간을 주단위 출력
select trunc((sysdate - hire_date)/7) from employees;

ex) 사원들의 입사일로 부터 현재까지 근무기간을 월단위 출력
???
- months_between : 두 날짜간의 달수를 출력해주는 함수
select months_between(sysdate, hire_date) from employees;
select months_between(hire_date, sysdate) from employees;

- add_months : 달수을 더하는 함수, (날짜,숫자)→ 날짜
select add_months(sysdate, 6) from dual;

- next_day : 기준일로 부터 제일 가까운 요일(미래시점)에 해당하는 날짜정보 출력하는 함수(session 언어에 종속)
select next_day(sysdate, '금요일') from dual;

- last_day : 그 달의 마지막 날짜정보
select last_day(sysdate) from dual;

<문제18> 사원의 last_name,hire_date 및 근무 6 개월 후 첫번째 월요일에 해당하는 날짜를 조회하세요.
        열별칭은 REVIEW 로 지정합니다.
select last_name, hire_date, next_day(add_months(hire_date, 6), '월요일') "REVIEW" from employees; 

<문제19> 15년 이상 근무한 사원들의 사원번호, 입사날짜, 근무개월수를 조회하세요.
select employee_id, hire_date, trunc(months_between(sysdate, hire_date), 0) 
from employees 
where trunc((sysdate - hire_date)/365)>= 15;

select employee_id, hire_date, trunc(months_between(sysdate, hire_date), 0) 
from employees 
where  trunc((months_between(sysdate, hire_date))/12, 0)>= 15;

-- ★ 객체지향 오버로드(같은 이름, 다른 기능 함수) : round에 인수값의 형에 따라 2개 이상의 기능가짐
select round(to_date('20171116','yyyymmdd'),'month') from dual;
→ 달을 기준(16일)으로 반올림(다음달 1일로)
select round(to_date('20171116','yyyymmdd'),'year') from dual;
→ 년을 기준(7월)으로 반올림(다음해 1월 1일로)

95-10-27 1995 ? 2095 ?
기존의 yy타입은 21세기 부터 문제가 발생 → RR타입
                                     데이터 입력연도
                            00~49                   50~99
현재연도 00~49        반환날짜는 현재세기를 반영   반환날짜는 이전세기의 날짜
        50~99        반환날짜는 이후세기를 반영   반환날짜는 현재세기의 날짜
  -------------------------------------------------------------------
현재연도   데이터입력날짜             RR                YY(현재연도의 세기를 반영)
1994      95-10-27               1995                   1995
1994      17-10-27               2017                   1917
2001      17-10-27               2017                   2017
2048      52-10-27               1952                   2052
2051      47-10-27               2147                   2047
  -------------------------------------------------------------------
  
-- 형변환 함수
- to_char : 보고서 용
  NUM → Char
  DATE → Char
select to_char(sysdate, 'yyyymmdd'), 
       to_char(sysdate, 'year'), /* 연도를 스펠링으로 */
       to_char(sysdate, 'mm month mon'), 
       to_char(sysdate, 'ddd dd d'), /* ddd : 년 기준 일, dd : 월 기준 일, d : 주 기준 일 */
       to_char(sysdate, 'day, dy'), /* 요일, 요일약어 */
       to_char(sysdate, 'ww w iw'), /* ww : 년 기준 주, w : 월 기준 주, iw : iso기준 */
       to_char(sysdate, 'ddspth'), /* 월 기준 일, 스펠링 서수단위 */
       to_char(sysdate, 'hh24:mi:ss.sssss am'),
       to_char(sysdate, 'fmdd "of" month') /* 날짜 중간에 문자열 삽입은 " ", fm : 앞에 0 제거 */
from dual;  
  
select employee_id, to_char(hire_date, 'day') 
from employees 
order by to_char(hire_date, 'd'); /* 일 : 1, 월 :2, ... , 토 : 7 */
  
select salary, to_char(salary, 'l999,999.00'), to_char(salary, 'l099,999.00') 
from employees;    /* l : 현재 위치 통화가치, 999.999.00 : 자리수 표현 */
  
- to_number : 문자(숫자모양) → 숫자
select to_number('1', '9'), to_number('1') from dual;
select to_number('one') from dual; /* 오류 */

- to_date : 문자(날짜) → 날짜

- nvl : null값을 실제값으로 치환하는 함수
nvl(모든 타입인수 , 치환할 값)
select salary, commission_pct, salary * 12 + nvl(commission_pct, 0),
       nvl(to_char(commission_pct), 'no comm') /* commission_pct 숫자형 */
from employees;
  
nvl2( , , ) 
select nvl2(commission_pct, 'salary * 12 + commission_pct', salary * 12)
from employees;
/* 첫번째 인수가 null이 아니면 두번째 인수를 수행, null이면 세번째 인수를 수행 */  
/* 2, 3번째 인수의 형 일치되야 됨 */

- coalesce( , , , , ) : null이 아닌 값을 찾는 함수(인수값 제한 없음)
select commission_pct, salary, coalesce(salary * 12 + commission_pct, salary * 12, 10000)
from employees;

- nullif(a,b) : 인수값 두개로 제한, null을 만드는 함수(단, 인수의 형은 일치)
/* 
if a = b then
       null;
else
       a;
end if;
*/
select last_name, first_name, nullif(length(last_name), length(first_name))
from employees;