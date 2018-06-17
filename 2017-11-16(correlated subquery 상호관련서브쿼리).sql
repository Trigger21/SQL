[문제53] department_name이 IT 부서의 모든 사원에 대한 employee_id, last_name, job_id 출력하세요(서브쿼리, 조인)

/* subquery */
select employee_id, last_name, job_id
from employees
where department_id 
      = (select department_id from departments where department_name = 'IT');

/* join */
select e.employee_id, e.last_name, e.job_id
from employees e, departments d
where e.department_id = d.department_id
and d.department_name = 'IT';

select employee_id, last_name, job_id
from employees join departments
using(department_id)
where department_name = 'IT';

[문제54] 전체 평균 급여보다 많은 급여를 받고 last_name에 "u"가 포함된 사원이 있는 부서에서 근무하는 
모든 사원의 employee_id, last_name, salary 출력하세요

select employee_id, last_name, salary
from employees
where salary > (select avg(salary) from employees)
and department_id in (select distinct department_id from employees where instr(last_name,'u') > 0);

/* M족 과 1족(서브쿼리) 간의 경우에만 JOIN을 실시, 그 외에는 X */

[문제55] 관리자 사원들의 정보를 출력해주세요.
/* subquery */
select *
from employees
where employee_id in (select /*+ no_unnest */ manager_id from employees);

/*+ no_unnest */ : semi 쓰지마 필터술어로 풀어죠~ 힌트문(실행계획 제어)

/* self join */
select distinct m.* -- distinct 데이터양이 많아질 경우 문제가 된다(위험부담) 
from employees e, employees m
where e.manager_id = m.employee_id;

-- 위험부담 예
select w.*e.ma
from (select distinct manager_id
      from employees) m, employees w
where m.manager_id = w.employee_id;

-- 개선 : inline view(from에 subquery)

select w.*
from (select manager_id
      from employees) m, employees w
where m.manager_id = w.employee_id; 

[문제56] 관리자가 아닌 사원들의 정보를 출력해주세요.

select *
from employees
where employee_id not in (select manager_id from employees where manager_id is not null);
/* not in 은 <> all 같다. */

================================================================================

-- 쌍비교(다중열 다중행 서브쿼리)
select *
from employees
where (manager_id, department_id) in (select manager_id, department_id
                                      from employees
                                      where first_name = 'John');
                                      
/* 서브쿼리 값이 쌍으로 가서 메인쿼리 값과 비교 */
ex. 
100 10 ← 100 10
200 20 ← 200 20
300 30 ← 300 30
300 10
                                      
-- 비쌍비교
select *
from employees
where manager_id in (select manager_id
                     from employees
                     where first_name = 'John')
and department_id in (select department_id
                      from employees
                      where first_name = 'John');

/* 서브쿼리 값이 각각 가서 메인쿼리 값과 비교(쌍비교랑 결과값 다름) */

[문제57] 자신의 부서 평균급여보다 더 많이 받는 사원 출력해주세요(힌트 : 메인쿼리 먼저 수행, 서브 쿼리에 적용)
/* 상호관련 서브쿼리(상관 서브쿼리) : 중첩서브쿼리와 순서반대 */
select e.*
from employees e
where e.salary > (select avg(salary) 
                  from employees 
                  where department_id = e.department_id/*변수*/);

1. 메인쿼리절을 먼저 수행(결과 테이블 생성)
2. 첫번째 행을 후보행으로 잡는다(비교하기 위해 고정)
3. 후보행 값을 서브쿼리 절에 전달
4. 후보행 값을 가지고 서브쿼리 절 수행
5. 후보행을 잡고 있는 행하고만 비교
6. N행으로 계속 반복 (만약 후보행 값이 동일하다면 불필요한 반복수행으로 부하가 발생)

-- 용어정리
nested subquery(중첩서브쿼리) : 서브쿼리를 먼저 수행한 값을 메인쿼리 사용
correlated subquery(상호관련서브쿼리) : 메인쿼리의 컬럼이 서브쿼리 안에 있는 경우

-- 가상집합(부서별 평균급여)을 이용해서 해결 : 위의 쿼리문을 써도 오라클이 자동으로 아래로 변환시킴(머신러닝)

select e2.*
from (select department_id, avg(salary) avgsal /* 가상테이블 컬럼은 꼭 별칭으로 표현 */
      from employees
      group by department_id) e1, employees e2
where e1.department_id = e2.department_id
and e2.salary > e1.avgsal;

[문제58] 부서이름별로 총액 금여를 구하세요.
/* inline view(좋은풀이) : 합 + 조인 */
select d.department_name, e.sum_salary
from (select department_id, sum(salary) sum_salary
      from employees
      group by department_id) e, departments d
where e.department_id = d.department_id;

/* inline view(나쁜풀이) */
select d.department_name, sum(e.salary)
from (select department_id, department_name
      from departments) d, employees e
where d.department_id = e.department_id
group by d.department_name; -- group by로 성능 나빠짐

/* join : 조인 + 그룹 + 합 */
select d.department_name, sum(e.salary)
from employees e, departments d
where e.department_id = d.department_id 
group by d.department_name; 

/* 결론 : 이 경우에 inline view 과 join에 비해 일량이 적다. 전체 테이블을 사용하기에
         부하가 예상되는 경우 축소해서 사용하고자 할 때 inline view */

================================================================================
/* 관리자인 사원 조회하는 문제 */
select *
from employees
where employee_id in (select /*+ no_unnest */ manager_id from employees);
-- 1족 → M족 비교해서 찾으면 break 기능을 줄 수 없을까? 아래가 답

/* 상호관련서브쿼리 : 나쁜것만은 아니다(exists를 사용한다면) */
select *
from employees e
where exists (select 'x'
              from employees
              where manager_id = e.employee_id);
              
★ exists : 존재여부만 확인하는 연산자(boolean) / 후보행 값이 서브쿼리절에서 찾아보고 있으면 TRUE 검색종료
            앞과 서브쿼리에 컬럼을 쓰면 안됨(단, 문법오류 방지하기 위해 무의미 값 적는다('x',1,...))

select *
from employees e
where not exists (select 'x'
                  from employees
                  where manager_id = e.employee_id);

================================================================================
/* 동일한 인수값이 반복되는 컬럼을 통해 join이 될 때 발생되는 문제점 */
select e.last_name, e.department_id, d.department_id, d.department_name
from employees e, departments d
where e.department_id = d.department_id /* 동일한 인수값이 오면 부서테이블 가지 않고 캐시에 있는 값을 주는 방법은 없나? */
order by 2, 3;
-- department_name을 찾았음에도 같은부서 사원은 또 찾아야 한다.(불필요한 IO 발생)

/* skalar subquery : query cache가 있는 subquery */
select e.last_name, e.department_id, (select department_name
                                      from departments
                                      where department_id = e.department_id) -- cache기능, e.department_id : 변수
from employees e
order by 2;


1. 단일열, 단일행 값만 나옴 / 다중행 다중열 return 안됨 → 그래도 해야된다면 ||으로 열을 하나로 만들자
2. 단일행함수처럼 동작해서 skalar 표현식 이라고도 한다
3. 중복성 있는 열에만 써야 한다. 아니면 캐시만 커져서 성능 나빠짐

/* DBA는 알아야 한다 */
scalar subquery 
- scalar subquery 표현식은 한 행에서 정확히 하나의 열 값을 반환하는 subquery
- 수행횟수를 최소화하려고 입력값과 출력값을 query execution cache에 저장
- 9i에서는 256개 cache, 10g "_query_execution_cache_max_size" parameter에 설정된 cache size 결정된다.(그 이상이면 밀어내기식 처리)
alter session set "_query_execution_cache_max_size"= 65536; -- 기본값
alter session set "_query_execution_cache_max_size"=131072;

사전판단
select count(distinct department_id) from employees;
select count(distinct department_name) from departments;

[문제59] 부서이름별로 총액급여, 평균급여를 구하세요.(단, skalar subquery 사용)
select d.department_name,
       (select sum(salary) from employees where department_id = d.department_id),
       (select avg(salary) from employees where department_id = d.department_id)
from departments d;
-- 비록 d.department_id가 1족이라서 cache효과는 못 보지만 join 보다 성능에서 좋은 방법이라는 점이 강점
-- group by를 사용하지 않아도 되서 좋음

select d.department_name,
       (select sum(salary) || ' ' || avg(salary) from employees where department_id = d.department_id)
from departments d;

select * from departments;