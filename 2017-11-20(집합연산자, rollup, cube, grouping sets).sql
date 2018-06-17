[문제62] 1500 부서 위치에 근무하는 사원들중에 2007년도에 입사한 사원들의 근무 도시, 부서 이름, 사원번호, 입사일을 출력하세요.

select l.city, d.department_name, e.employee_id, e.hire_date
from employees e, departments d, locations l
where e.department_id = d.department_id
and d.location_id = l.location_id
and (e.hire_date >= to_date('20070101','yyyymmdd') and e.hire_date < to_date('20080101','yyyymmdd'))
and l.location_id = 1500;
-- inline view 굳이 하지 않아도 이 경우에는 괜찮음(오라클이 크게 보고 해결한다는...??)
/*
select (select city
        from locations
        where , department_name, employee_id, hire_date
from 

with
l_1500 as (select city, department_name, employee_id, hire_date 
           from 
h_2007 as (select hire_date from employees where hire_date >= to_date('20070101','yyyymmdd') and hire_date < to_date('20080101','yyyymmdd'))

select city, department_name, employee_id, hire_date
from l_1500
where h_2007
*/

[문제63] job_history 테이블은 job_id를 한번이라도 바꾼사원들의 정보가 저장되어 있습니다.
         사원테이블에서 두번이상 job_id를 바꾼 사원정보를 출력하세요.(correlated subquery)

select employee_id
from job_history
group by employee_id
having count(*) >1;

-- 선생님 풀이
select e.*
from employees e
where 2 <= (select count(*)
            from job_history
            where employee_id = e.employee_id); 
            -- 문제될수 있는 부분(건수로 비교해야 되면 조인으로)

select * from user_ind_columns; /*index 확인*/

[문제64] job_history 테이블은 job_id를 한번이라도 바꾼사원들의 정보가 저장되어 있습니다.
         사원테이블에서 두번이상 job_id를 바꾼 사원정보를 출력하세요.(조인&inline view)
         
select e.*
from employees e,
     (select employee_id, count(*)
      from job_history
      group by employee_id
      having count(*) > 1) h
where e.employee_id = h.employee_id;

[문제65] 사원테이블에서 각 부서마다 인원수를 출력주세요.

<화면결과>

    10부서     20부서     30부서     40부서     50부서     60부서
---------- ---------- ---------- ---------- ---------- ----------
         1          2          6          1         45          5

select department_id, count(*) 
from employees
where department_id between 10 and 60
group by department_id;

select max(decode(dep_id, 10, cnt)) "10부서",
       max(decode(dep_id, 20, cnt)) "20부서",
       max(decode(dep_id, 30, cnt)) "30부서",
       max(decode(dep_id, 40, cnt)) "40부서",
       max(decode(dep_id, 50, cnt)) "50부서",
       max(decode(dep_id, 60, cnt)) "60부서"
from (select department_id dep_id, count(*) cnt
      from employees
      where department_id between 10 and 60 
      group by department_id); 
      
================================================================================

-- 11g부터 지원 pivot : row의 data를 column으로 변경하는 함수
ex. 
dept_id  cn
10       1
20       2
30       10

10 20 30
-- -- --
1  2  10

/* 부서별 사원수 */
select *
from (select department_id from employees) --inline view로 열이 표현되어야 함
pivot(count(*) for department_id in (10 "10부서",20 "20부서",30 "30부서",40 "40부서",50 "50부서",60 "60부서")); --pivot으로 옆으로 표시

/* 부서별 급여총합 */
select *
from (select department_id, salary from employees) --inline view로 열이 표현되어야 함
pivot(sum(salary) for department_id in (10 "10부서",20 "20부서",30 "30부서",40 "40부서",50 "50부서",60 "60부서"));

/* 부서별 급여평균 */
select *
from (select department_id, salary from employees) --inline view로 열이 표현되어야 함
pivot(avg(salary) for department_id in (10 "10부서",20 "20부서",30 "30부서",40 "40부서",50 "50부서",60 "60부서"));

/* 부서별 급여표준편차 */
select *
from (select department_id, salary from employees) --inline view로 열이 표현되어야 함
pivot(stddev(salary) for department_id in (10 "10부서",20 "20부서",30 "30부서",40 "40부서",50 "50부서",60 "60부서"));

/* 부서별 급여분산 */
select *
from (select department_id, salary from employees) --inline view로 열이 표현되어야 함
pivot(variance(salary) for department_id in (10 "10부서",20 "20부서",30 "30부서",40 "40부서",50 "50부서",60 "60부서"));

-- unpivot 함수 : pivot함수의 반대개념으로 column을 rowdata로 변경하는 함수

select *
from (
      select *
      from (select department_id from employees)
      pivot(count(*) for department_id in(10,20,30,40,50,60))
      )
unpivot(cnt for dept_id in("10","20","30","40","50","60")); -- 다시변형

select *
from (
      select *
      from (select department_id from employees)
      pivot(count(*) for department_id in(10 "10부서",20 "20부서",30 "30부서",40 "40부서",50 "50부서",60 "60부서"))
      )
unpivot(cnt for dept_id in("10부서","20부서","30부서","40부서","50부서","60부서"));

[문제66] 사원테이블에서 요일별 입사한 인원수를 출력해주세요.

<화면결과>

   일요일     월요일     화요일     수요일     목요일     금요일     토요일
--------- ---------- ---------- ---------- ---------- ---------- ----------
       15         10         13         15         16         19         19

select to_char(hire_date,'dy'), count(*)
from employees
group by to_char(hire_date,'dy');

select *
from (select to_char(hire_date,'day') day from employees) -- 여기서는 그냥 각 사원별 입사한 요일 컬럼 생성 
pivot(count(*) for day in('일요일','월요일','화요일','수요일','목요일','금요일','토요일')); 
-- in 연산자 값에서 같은 것(형 및 이름 일치)끼리 카운트 되면서 정리가 되는듯

select *
from (
     select *
     from (select to_char(hire_date,'day') day from employees) -- 여기서는 그냥 각 사원별 입사한 요일 컬럼 생성 
     pivot(count(*) for day in('일요일' "일",'월요일' "월",'화요일' "화",'수요일' "수",'목요일' "목",'금요일' "금",'토요일' "토"))
     ) /* unpivot을 하려면 문자의 경우 별칭을 지정해야 되는 것 같다 */
unpivot(cnt for day in("일","월","화","수","목","금","토"));


select *
from (select to_char(hire_date,'d') day from employees)
pivot(count(*) for day in(1 "일요일",2 "월요일",3 "화요일",4 "수요일",5 "목요일", 6 "금요일", 7"토요일"));

select *
from (
     select *
from (select to_char(hire_date,'d') day from employees)
pivot(count(*) for day in(1 "일요일",2 "월요일",3 "화요일",4 "수요일",5 "목요일", 6 "금요일", 7"토요일"))
     )
unpivot(cnt for day in("일요일","월요일","화요일","수요일","목요일","금요일","토요일"));

================================================================================

-- 집합연산자 : 선두 후미 쿼리문의 열 및 타입 일치 필수

/* 합집합(union, union all : all을 써라) */
select employee_id, job_id
from employees
union -- 중복을 제거(소트 알고리즘)한 후 합함 : 데이터 양이 많으면 별로 좋지 않다.
select employee_id, job_id
from job_history;

select employee_id, job_id
from employees
union all -- 중복을 포함한 후 합함
select employee_id, job_id
from job_history;

/* 교집합(intersect) : 쌍비교, 'join' 이나 'exists' 써라 */
select employee_id, job_id
from employees
intersect -- 공통된 데이터만 출력 : 과거 영업팀 이었다가 총무 했다가 다시 영업팀으로 오면 나옴
select employee_id, job_id
from job_history;

/* 차집합(minus) : 'not exists' 써라 */
select employee_id, job_id
from employees
minus -- 한번도 job_id 변동 안함
select employee_id, job_id
from job_history
order by 1,2; -- 내부적으로 이렇게 된다고 함. 첫번째 쿼리의 컬럼을 기준으로 생각해야함.

-- ※ 주의사항 : 소트라는 오퍼레이터가 돌아간다. 현장에서 쓰면 부하 폭발

select employee_id, job_id, salary sal -- 첫번째 쿼리문에 별칭설정
from employees
union 
select employee_id, job_id, to_number(null) -- 위의 salary 땜 
from job_history
order by 1,2,3;

select employee_id, job_id, salary
from employees
union 
select employee_id, job_id, to_number(0) -- 위의 salary 땜 
from job_history;

select employee_id, job_id, salary
from employees
union 
select employee_id, job_id, null -- 위의 salary 땜 
from job_history;

select employee_id, job_id, salary
from employees
union 
select employee_id, job_id, 0 -- 위의 salary 땜 
from job_history;

================================================================================
[문제67] 아래와 같은 SQL문을 정렬이 수행되지 않게 튜닝하세요.
/*
select employee_id, job_id
from employees
intersect
select employee_id, job_id
from job_history;
*/
select e.employee_id, e.job_id
from employees e
where exists (select 1 
              from job_history 
              where employee_id = e.employee_id 
              and job_id = e.job_id); 

select e.employee_id, e.job_id
from employees e, job_history h
where e.employee_id = h.employee_id
and e.job_id = h.job_id;

/* ※ intersect → exists (or join) */

[문제68] 아래와 같은 SQL문을 정렬이 수행되지 않게 튜닝하세요.
/*
select employee_id, job_id
from employees
minus
select employee_id, job_id
from job_history
*/

select e.employee_id, e.job_id
from employees e
where not exists (select 1 
                  from job_history 
                  where employee_id = e.employee_id 
                  and job_id = e.job_id); 

/* ※ minus → not exists */
                
================================================================================

[문제69] 아래와 같은 SQL문을 정렬이 수행되지 않게 튜닝하세요.(union → union all 중복성 없게)
/*
select e.employee_id, d.department_name
from employees e, departments d
where e.department_id = d.department_id(+)
union
select e.employee_id, d.department_name
from employees e, departments d
where e.department_id(+) = d.department_id;
*/
select e.employee_id, d.department_name
from employees e, departments d
where e.department_id = d.department_id(+)
union all
select null, d.department_name -- employee_id 자리를 null(핵심)
from departments d
where not exists (select 1 
                  from employees -- 사원이 없는 부서명 뽑는 쿼리문
                  where department_id = d.department_id);

/* ※ union → union all + not exists */
================================================================================
sum(salary)={department_id, job_id, manager_id} -- 3개 열을 기준 급여총합
sum(salary)={department_id, job_id} -- 2개 열을 기준 급여총합
sum(salary)={department_id} -- 1개 열을 기준 급여총합
sum(salary)={} -- 전체 급여총합 

select department_id, job_id, manager_id, sum(salary)
from employees
group by department_id, job_id, manager_id
union all
select department_id, job_id, null, sum(salary)
from employees
group by department_id, job_id
union all
select department_id, null, null, sum(salary)
from employees
group by department_id
union all
select null,null,null,sum(salary)
from employees;

/* 숙제 : 독서(데이터웨어하우징(하우스) : 남산도서관) */

sum(salary)={department_id, job_id, manager_id} 
sum(salary)={department_id, job_id} 
sum(salary)={department_id}
sum(salary)={} 

/* rollup : 개별 컬럼을 오른쪽을 기준으로 해서 왼쪽으로 하나씩 지우면서 집계값 구함 */
select department_id, job_id, manager_id, sum(salary)
from employees
group by rollup(department_id, job_id, manager_id);

================================================================================

sum(salary)={department_id, job_id, manager_id} 
sum(salary)={department_id, job_id} 
sum(salary)={department_id, manager_id}
sum(salary)={job_id, manager_id} 
sum(salary)={department_id}
sum(salary)={job_id} 
sum(salary)={manager_id}
sum(salary)={} 

/* cube : rollup 기능 포함하고 조합가능한 경우를 전부 집계함 */
select department_id, job_id, manager_id, sum(salary)
from employees
group by cube(department_id, job_id, manager_id);

================================================================================

-- 내가 원하는 집계값만 구하려면 어쩔까?
sum(salary)={department_id, job_id} 
sum(salary)={department_id, manager_id}

select department_id, job_id, null, sum(salary)
from employees
group by department_id, job_id
union all
select department_id, null, manager_id, sum(salary)
from employees
group by department_id, manager_id;

/* grouping sets : 내가 원하는 그룹 만듬 */
select department_id, job_id, manager_id, sum(salary) -- 개별열은 그룹바이에 1번 이상 써야함
from employees
group by grouping sets((department_id, job_id), (department_id, manager_id));

sum(salary)={department_id, job_id} 
sum(salary)={department_id, manager_id}
sum(salary)={} 

select department_id, job_id, manager_id, sum(salary)
from employees
group by grouping sets((department_id, job_id), (department_id, manager_id), ()); -- () : 전체합

================================================================================

