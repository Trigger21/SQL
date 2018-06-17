[문제20] 일요일에 입사한 사원의 정보를 조회하세요.
select employee_id, 
       first_name || ' ' || last_name "NAME", 
       to_char(hire_date, 'day') "HIRE DAY"
from employees
where to_char(hire_date, 'd') = 1;

[문제21] 짝수달에 입사한 사원의 정보를 조회하세요.
select employee_id,
       first_name || ' ' || last_name "NAME",
       to_char(hire_date, 'month') "HIRE MONTH"
from employees
where mod(to_char(hire_date, 'mm'), 2) = 0
order by to_char(hire_date, 'mm');

[문제22] 사원테이블(employees)에 last_name, salary, commission_pct, commission_pct 값이 
null 아니면 (salary*12) + (salary*12*commission_pct) 이값이 수행되고
null 이면 salary * 12 가 수행할 수있도록 ann_sal 생성하세요.
(nvl, coalesce, nvl2 함수를 사용하여 각각으로 수행해서 보고서 작성해 주세요)

select last_name, salary, commission_pct,
       (salary*12) + (salary*12*nvl(commission_pct,0)) "ann_sal"
from employees;

select last_name, salary, commission_pct,
       coalesce((salary*12) + (salary*12*commission_pct), salary*12) "ann_sal"
from employees; 

select last_name, salary, commission_pct,
       nvl2(commission_pct, (salary*12) + (salary*12*commission_pct), salary*12)
       "ann_sal"
from employees;

================================================================================

select * from nls_session_parameters; /* 지역, 언어에 종속되는 단위값 목록 */

ALTER SESSION SET NLS_TERRITORY = KOREA;
ALTER SESSION SET NLS_LANGUAGE = KOREAN;

ALTER SESSION SET NLS_TERRITORY = GERMANY;
ALTER SESSION SET NLS_LANGUAGE = GERMAN;

ALTER SESSION SET NLS_LANGUAGE = JAPANESE;
ALTER SESSION SET NLS_TERRITORY = JAPAN;

ALTER SESSION SET NLS_LANGUAGE = FRENCH;
ALTER SESSION SET NLS_TERRITORY= FRANCE;

ALTER SESSION SET NLS_TERRITORY= AMERICA;
ALTER SESSION SET NLS_LANGUAGE = AMERICAN;

ALTER SESSION SET NLS_TERRITORY = china;
ALTER SESSION SET NLS_LANGUAGE = 'simplified chinese';

ALTER SESSION SET NLS_TERRITORY = 'United Kingdom';
ALTER SESSION SET NLS_LANGUAGE = ENGLISH;


select employee_id, 
      to_char(salary,'l999g999d00'), /* g : 1000단위 구분자 지역에 맞게, d : 소수점 자리 지역에 맞게 */
      to_char(hire_date, 'YYYY-MONTH-DD DAY') /* MONTH, DAY : 언어에 종속 */
from employees;

/* 지역과 언어 분리해도 상관없음, 대소문자 구분없음 */

================================================================================

-- 조건제어문 : decode, case 함수

if 조건 then 참값
else 거짓값
end if;

- decode(기준값, 비교값1, 참값1, 비교값2, 참값2, ... , 기본값)
※ 기준값과 = 로만 비교!!, row 단위 수행
/*
if 기준값 = 비교1 then 참값1
else if 기준값 = 비교2 then 참값2
else if 기준값 = 비교3 then 참값3
      ...................
else 
        기본값
end if;
*/
select last_name, job_id, salary,
       decode(job_id, 'IT_PROG', salary * 1.10,
                      'ST_CLERK', salary * 1.15,
                      'SA_REP', salary * 1.20,
              salary)
from employees;

- case 기준값 when 비교1 then 참1  /* 기준값 = 비교 1 */
             when 비교2 then 참2
             when 비교3 then 참3
             else 기본값
  end
 = case      when 기준값 = 비교 then 참1
   ...
   
- case       when 기준값 >= 비교1 then 참1
             when 기준값 <> 비교2 then 참2
             when 기준값 in(비교3,비교4,비교5) then 참3
             else 기본값
  end
※ 다른 연산자도 사용가능, 다른 SQL에도 사용가능

select last_name, job_id, salary,
       case job_id when 'IT_PROG' then salary * 1.10
                   when 'ST_CLERK' then salary * 1.15
                   when 'SA_REP' then salary * 1.20
                   else salary
       end
from employees;

[문제22] 사원테이블(employees)에 last_name, salary, commission_pct, commission_pct 값이 
null 아니면 (salary*12) + (salary*12*commission_pct) 이값이 수행되고
null 이면 salary * 12 가 수행할 수있도록 ann_sal 생성하세요.

select last_name, salary, commission_pct,
       decode(commission_pct, null, salary * 12, 
              (salary*12) + (salary*12*commission_pct)) "ann_sal"
from employees;

select last_name, salary, commission_pct,
       case nvl(commission_pct,0) when 0 then salary * 12
                                  else (salary*12) + (salary*12*commission_pct)
       end "ann_sal"
from employees;

select last_name, salary, commission_pct,
       case  when commission_pct is null then salary * 12
                                  else (salary*12) + (salary*12*commission_pct)
       end "ann_sal"
from employees;

[문제23] JOB_ID 열의 값을 기반으로 모든 사원의 등급을 표시하는 query 를 작성합니다.

<화면예>
JOB_ID	 	GRADE
------		----	
AD_PRES 	A
ST_MAN 		B
IT_PROG 	C
SA_REP 		D
ST_CLERK 	E
		      Z

select distinct job_id,
       decode(JOB_ID, 'AD_PRES', 'A', 
                      'ST_MAN', 'B', 
                      'IT_PROG', 'C', 
                      'SA_REP', 'D', 
                      'ST_CLERK', 'E', 
                      'Z') "GRADE"
from employees
order by grade;

SELECT DISTINCT job_id,
       CASE job_id WHEN 'AD_PRES' THEN 'A'
                   WHEN 'ST_MAN' THEN 'B'
                   WHEN 'IT_PROG' THEN 'C'
                   WHEN 'SA_REP' THEN 'D'
                   WHEN 'ST_CLERK' THEN 'E'
                   ELSE 'Z'
        END GRADE
FROM EMPLOYEES
ORDER BY GRADE;

[문제24] 사원의 last_name, salary,  급여가 5000 미만이면 'Low', 10000 미만이면 'Medium', 
20000미만이면 'Good', 20000 이상이면 'Excellent' 를 출력하세요.
select last_name, salary,
       case when salary < 5000 then 'Low'
            when salary < 10000 then 'Medium'
            when salary < 20000 then 'Good'
            when salary >= 20000 then 'Excellent' /* 또는 else 'Excellent' */
       end
from employees;

-- 단일행함수 : 문자, 숫자, 날짜, 형변환, 조건제어문, NULL
-- 그룹함수 : count(행수), max(최대값), min(최소값), sum(합), avg(평균), variance(분산), stddev(표준편차)
   /* 주의 1. null값 포함하지 않음 : 문제점은 평균, 분산, 표준편차 구할 때 주의해야 함(nvl함수 써야함)
      주의 2. sum(합), avg(평균), variance(분산), stddev(표준편차) : 숫자만 인수값으로 사용 */

select count(*) from employees; /* count(*) : null을 포함한 전체 row 수 */
select count(department_id) from employees; /* column값은 null 제외 */
select count(distinct department_id) from employees;

select count(*) from employees where department_id = 50;
select count(commission_pct) from employees where department_id = 50; /* 50번 부서 commission_pct null */

select count(*) from employees where commission_pct is not null;

select count(salary), count(last_name), count(hire_date)
from employees;

select max(salary), max(last_name), max(hire_date)
from employees;

select min(salary), min(last_name), min(hire_date)
from employees;

select sum(salary) from employees where department_id = 50; /* 숫자만 */
select sum(salary) from employees where last_name like '%i%';

select avg(commission_pct) from employees; /* 잘못됨 null 미포함 */
select avg(nvl(commission_pct,0)) from employees;

select variance(nvl(commission_pct,0)) from employees;

- 전체사원들의 총액금액
select sum(salary) from employees;

- 부서별 총액급여
select department_id, sum(salary), count(*) from employees
group by department_id; /* group by : 그룹별 지정 */

select job_id, sum(salary), count(*) from employees
group by job_id; 

select department_id, job_id, manager_id, sum(salary) /* department_id, job_id, manager_id 일치한 사원의 salary 합 */
from employees
group by department_id, job_id, manager_id; /* 주의 3 : select에 개별열 그룹절에 그대로 복사*/

select department_id dept_id, sum(salary)
from employees
group by department_id; /* 주의 4 : group by절 별칭사용 안됨 */

select department_id dept_id, sum(salary)
from employees
where department_id in(10, 20, 30) /* 주의 5 : where 위치 group by 이전 */
group by department_id;

select department_id dept_id, sum(salary)
from employees
where sum(salary) >= 10000 /* 주의 6 : 그룹함수는 where에 제한하면 안됨(오류남) */
group by department_id;

select department_id dept_id, sum(salary)
from employees
group by department_id
having sum(salary) >= 10000; /* having : 그룹함수의 결과를 제한하는 절 */

select max(avg(salary)), department_id /* 그룹함수 두번 중첩되면 개별열 사용금지 */
from employees
group by department_id;

select department_id, sum(salary)
from employees
where job_id not like '%REP%' /* 행을 제한하는 절로 그룹핑 전에 제거하고 싶은거 설정 */
group by department_id
having sum(salary) > 10000
order by 1;
→ 처리순서 1.from 2.where 3.group by(소그룹 나눔) 4.select 5.having 6.order by 

select max(avg(salary)) /* 그룹함수 2번까지 중첩 가능, 단 개별열 못씀 */
from employees
group by department_id;

[문제25] 모든 사원의 최고급여, 최저급여, 합계 및 평균 급여를 찾습니다. 
열 레이블을 각각 Maximum, Minimum, Sum 및 Average 로 지정합니다. 
결과를 소수점은 반올림해서 정수값으로 출력하세요.

   Maximum    Minimum        Sum    Average
---------- ---------- ---------- ----------
     24000       2100     691416       6462

select max(salary) "Maximum",
       min(salary) "Minimum",
       sum(salary) "Sum",
       round(avg(salary),0) "Average"
from employees;

[문제26] 2008년도에 입사한 사원들의 job_id별 인원수를 구하고 인원수가 많은 순으로 출력하세요. 

JOB_ID     COUNT(*)
---------- --------
SA_REP            6 
SH_CLERK          2 
ST_CLERK          2 
SA_MAN            1 

select distinct job_id, count(*)
from employees
where to_char(hire_date,'yyyy') = '2008'
group by job_id
order by 2 desc;

select job_id, count(*)
from employees
where hire_date >= to_date('20080101','yyyymmdd')
and hire_date < to_date('20090101','yyyymmdd') /* to_date('hire_date', 'yyyymmdd') 범위로 사용하는게 index활용해서 더 좋다. */
group by job_id
order by 2 desc;

[문제27] 사원의 총수와 2005년, 2006년, 2007년, 2008년에 입사한 사원의 수 출력하세요.

   TOTAL       2005       2006       2007       2008
-------- ---------- ---------- ---------- ----------
     107         29         24         19         11
/*     
select to_char(hire_date,'yyyy'), count(*)
from employees
group by to_char(hire_date,'yyyy')/*                → 다음주 가로형으로 바꾸는 걸 배운다
having to_char(hire_date,'yyyy') >= 2005
order by 1;
*/
-- 27번 정답 중 하나, 이딴 건 악성이다. 왜냐하면 전체 row가 4번의 반복행위를 당한다. 데이터 크기가 커지면 부하 증가
select count(*) "TOTAL", 
       count(decode(to_char(hire_date,'yyyy'),'2005',1)) "2005",
       count(decode(to_char(hire_date,'yyyy'),'2006',1)) "2006",
       count(decode(to_char(hire_date,'yyyy'),'2007',1)) "2007",
       count(decode(to_char(hire_date,'yyyy'),'2008',1)) "2008" /* decode, case 안에 그룹함수 사용하면 안됨 */
from employees;

