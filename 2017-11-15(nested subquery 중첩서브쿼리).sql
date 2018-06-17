[문제38] 사원들의 사번, 급여, 급여등급, 부서이름을 출력하세요.
         부서배치를 받지 않는 사원은 제외시켜주세요.(오라클전용, ANSI표준)
-- oracle
select e.employee_id, e.salary, j.grade_level, d.department_name
from employees e, departments d, job_grades j
where (e.salary between j.lowest_sal and j.highest_sal)
and e.department_id = d.department_id;

-- ansi
select e.employee_id, e.salary, j.grade_level, d.department_name
from employees e join job_grades j
on e.salary between j.lowest_sal and j.highest_sal
join departments d
on e.department_id = d.department_id;

[문제39] 사원들의 사번, 급여, 급여등급, 부서이름, 근무 도시 정보를 출력하세요.
         부서배치를 받지 않는 사원도 포함시켜주세요.(오라클전용, ANSI표준)
         
-- oracle
select e.employee_id, e.salary, j.grade_level, d.department_name, l.city
from employees e, departments d, job_grades j, locations l
where e.department_id = d.department_id(+)
and d.location_id = l.location_id(+)
and e.salary between j.lowest_sal and j.highest_sal;

-- ansi
select e.employee_id, e.salary, j.grade_level, d.department_name, l.city
from employees e left join departments d
on e.department_id = d.department_id
left join locations l
on d.location_id = l.location_id
join job_grades j
on e.salary between j.lowest_sal and j.highest_sal;

[문제40] 사원들의 사번, 급여, 급여등급, 부서이름을 출력하세요.
         부서배치를 받지 않는 사원은 제외시켜주세요. 단, last_name에 a가 들어간 사원만(오라클전용, ANSI표준)
select count(*) 
from employees 
where last_name like '%a%' 
and department_id is not null; /* 51명 */

-- oracle
select e.employee_id, e.salary, j.grade_level, d.department_name
from employees e, departments d, job_grades j
where (e.salary between j.lowest_sal and j.highest_sal)
and e.department_id = d.department_id
and e.last_name like '%a%';

-- ansi
select e.employee_id, e.salary, j.grade_level, d.department_name
from employees e join job_grades j
on e.salary between j.lowest_sal and j.highest_sal
join departments d
on e.department_id = d.department_id
where e.last_name like '%a%';

[문제41] 사원들의 사번, 급여, 급여등급, 부서이름을 출력하세요.
         부서배치를 받지 않는 사원은 제외시켜주세요. 단, last_name에 a가 2개 이상 들어간 사원만(오라클전용, ANSI표준)
select *
from employees 
where last_name like '%a%a%'
and department_id is not null;      

-- oracle
select e.employee_id, e.salary, j.grade_level, d.department_name
from employees e, departments d, job_grades j
where (e.salary between j.lowest_sal and j.highest_sal)
and e.department_id = d.department_id
and e.last_name like '%a%a%'; 
/* instr(e.last_name,'a',1,2) > 0 (last_name 2번째 'a' 위치값 ~ 'a' 2개 존재) : index 스캔 가능 */

-- ansi
select e.employee_id, e.salary, j.grade_level, d.department_name
from employees e join job_grades j
on e.salary between j.lowest_sal and j.highest_sal
join departments d
on e.department_id = d.department_id
where instr(e.last_name,'a',1,2) > 0;

사원들의 employee_id, name, region_name 

select e.employee_id, e.first_name || ' ' || e.last_name name, r.region_name
from employees e, departments d, locations l, countries c, regions r
where e.department_id = d.department_id
and d.location_id = l.location_id
and l.country_id = c.country_id
and c.region_id = r.region_id;

select r.region_name, count(*), avg(salary), min(salary), max(salary)
from employees e, departments d, locations l, countries c, regions r
where e.department_id = d.department_id
and d.location_id = l.location_id
and l.country_id = c.country_id
and c.region_id = r.region_id
group by r.region_name;

================================================================================

-- subquery : SQL문 안에 SELECT문이 있는 쿼리(main + sub)

110번 사원의 급여보다 더 많이(초과) 받는 사원은?

select salary from employees where employee_id = 110; /* 110번 사원 급여 : 8200 */

select *
from employees
where salary > 8200; /* 상수를 고정 시켰다(변화가 없는 경우) */

/* 개선방법(변화가 있는 경우) */
select *
from employees 
where salary > (select salary from employees where employee_id = 110);

중첩서브쿼리 : 서브쿼리 먼저 수행한 결과값을 가지고 메인쿼리절이 사용한다.

1. 단일행 서브쿼리(single row subquery) : 서브쿼리에서 수행한 결과값이 1개로 고정
 - 비교연산자(= , > , >= , < , <= , <>)
 
2. 다중행 서브쿼리(multiple row subquery) : 서브쿼리에서 수행한 결과값이 다수
 - 비교연산자(IN , ALL , ANY)
 
select *
from employees
where salary > (select salary from employees where last_name like '%a%'); /* 오류 */

ex. 141번 job_id랑 동일한 사원의 정보를 조회하시오.

select *
from employees
where job_id = (select job_id from employees where employee_id = 141);

[문제42] 사원 141의 job_id 와 동일한 job_id 가진 사원들 중에 141 사원의 급여보다 많이 받는 사원을 출력하세요.
         단 141번 사원은 제외시켜서 출력하세요.

select *
from employees
where salary > (select salary from employees where employee_id = 141)
and job_id = (select job_id from employees where employee_id = 141);

[문제43] 회사에서 최고 급여를 받는 사원들의 정보를 출력하세요.
/* 범위(등급)으로 요청 */
select *
from employees e, job_grades j
where (e.salary between j.lowest_sal and j.highest_sal)
and j.grade_level = 'E';

select *
from employees e join job_grades j
on (e.salary between j.lowest_sal and j.highest_sal)
where j.grade_level = 'E';

/* 최고만 요청 */
select *
from employees
where salary = (select max(salary) from employees);

[문제44] 회사에서 최저 급여를 받는 사원들의 정보를 출력하세요.
/* 범위(등급)으로 요청 */
select * 
from employees e, job_grades j
where (e.salary between j.lowest_sal and j.highest_sal)
and j.grade_level = 'A';

select *
from employees e join job_grades j
on (e.salary between j.lowest_sal and j.highest_sal)
where j.grade_level = 'A';

/* 최저만 요청 */
select *
from employees
where salary = (select min(salary) from employees);

[문제45] 회사에서 최고 급여를 받는 사원들의 사번, 급여, 부서이름 정보를 출력하세요.

select e.employee_id, e.salary, d.department_name
from employees e, job_grades j, departments d
where (e.salary between j.lowest_sal and j.highest_sal)
and j.grade_level = 'E'
and e.department_id = d.department_id;

select e.employee_id, e.salary, d.department_name
from employees e, departments d
where e.salary = (select max(salary) from employees)
and e.department_id = d.department_id;

[문제46] 회사에서 최저 급여를 받는 사원들의 사번, 급여, 부서이름 정보를 출력하세요.

select e.employee_id, e.salary, d.department_name
from employees e, job_grades j, departments d
where (e.salary between j.lowest_sal and j.highest_sal)
and j.grade_level = 'A'
and e.department_id = d.department_id;

select e.employee_id, e.salary, d.department_name
from employees e, departments d
where e.salary = (select min(salary) from employees)
and e.department_id = d.department_id;

================================================================================

select job_id, avg(salary)
from employees
group by job_id;

select job_id, max(avg(salary)) /* 오류 : 그룹함수 중첩시 개별열 사용불가 */
from employees
group by job_id; /* 1열 인지 2열인지?? */

select job_id, avg(salary)
from employees
group by job_id
having avg(salary) = (select max(avg(salary)) from employees group by job_id); /* 서브쿼리문 */

================================================================================

/* in : 각각에 일치하는 것들 뿌려 */
select *
from employees
where salary in (select min(salary) from employees group by department_id);

select *
from employees
where salary in (select salary from employees where job_id = 'IT_PROG');
-- in는 = or의 범주

/* any */
select *
from employees
where salary > any (select salary from employees where job_id = 'IT_PROG');
-- > any : > or의 범주, 서브쿼리 결과값 중 최소값보다 큼의 역활

select *
from employees
where salary > (select min(salary) from employees where job_id = 'IT_PROG');
-- min(salary) : 4200

select *
from employees
where salary < any (select salary from employees where job_id = 'IT_PROG');
-- < any : < or의 범주, 서브쿼리 결과값 중 최대값보다 작음의 역활

select *
from employees
where salary < (select max(salary) from employees where job_id = 'IT_PROG');
-- max(salary) : 9000

= any : in 과 동일

/* all */
select *
from employees
where salary > all (select salary from employees where job_id = 'IT_PROG');
-- > all : > and의 범주, 서브쿼리 결과값 중 최대값보다 큼의 역활

select *
from employees
where salary > (select max(salary) from employees where job_id = 'IT_PROG');
-- max(salary) : 9000

select *
from employees
where salary < all (select salary from employees where job_id = 'IT_PROG');
-- < all : < and의 범주, 서브쿼리 결과값 중 최소값보다 작음의 역활

select *
from employees
where salary < (select min(salary) from employees where job_id = 'IT_PROG');
-- min(salary) : 4200


※ 결론(여기서 1이 최소값, n을 최대값으로 가정한다)
 A in (1,2,3,...,n) : A = 1 or A = 2 or ... or A = n

 A > any (1,2,3,...,n) : A > 1 or A > 2 or ... or A > n → 『A > 1』 
 A >= any (1,2,3,...,n) : A >= 1 or A >= 2 or ... or A >= n → 『A >= 1』
 A < any (1,2,3,...,n) : A < 1 or A < 2 or ... or A < n → 『A < n』
 A <= any (1,2,3,...,n) : A <= 1 or A <= 2 or ... or A <= n → 『A <= n』
 A = any (1,2,3,...,n) : A = 1 or A = 2 or ... or A = n → 『A in (1,2,3,...,n)』

 A > all (1,2,3,...,n) : A > 1 and A > 2 and ... and A > n → 『A > n』 
 A >= all (1,2,3,...,n) : A >= 1 and A >= 2 and ... and A >= n → 『A >= n』
 A < all (1,2,3,...,n) : A < 1 and A < 2 and ... and A < n → 『A < 1』
 A <= all (1,2,3,...,n) : A <= 1 and A <= 2 and ... and A <= n → 『A <= 1』
 
[문제47] 전체 평균(avg) 급여(salary) 이상을 받는 모든 사원의 사원 employee_id, last_name, salary 를 출력하세요.

select employee_id, last_name, salary
from employees
where salary >= (select avg(salary) from employees);

[문제48] last_name 에 문자 "u"가 포함된 사원과 같은 부서에 근무하는 모든 사원의 employee_id, last_name 을 출력하세요.

select employee_id, last_name
from employees
where department_id in (select department_id from employees where instr(last_name, 'u') > 0);

[문제49] 부서 위치(location_id) ID 가 1700 인 모든 사원의 last_name, department_id, job_id 를 출력하세요.
/* equi join*/
select e.last_name, d.department_id, e.job_id 
from employees e, departments d
where e.department_id = d.department_id
and d.location_id = 1700;

select last_name, department_id, job_id
from employees join departments
using(department_id)
where location_id = 1700;

select e.last_name, d.department_id, e.job_id 
from employees e join departments d
on e.department_id = d.department_id
where d.location_id = 1700; 

/* subquery(in) */
select last_name, department_id, job_id
from employees
where department_id in (select department_id from departments where location_id = 1700);

[문제50] King 에게 보고하는 모든 사원의 last_name 및 salary 출력하세요. (e.mananger_id)
/* self join */
select e.last_name, e.salary
from employees e, employees m
where e.manager_id = m.employee_id
and m.last_name = 'King';

select e.last_name, e.salary
from employees e join employees m
on e.manager_id = m.employee_id
where m.last_name = 'King';

/* subquery(in) */
select last_name, salary
from employees
where manager_id in (select employee_id from employees where last_name = 'King'); 

[문제51] 부서 이름(department_name) 이 Executive 부서의 모든 사원에 대한 department_id, last_name, job_id  출력하세요.
/* equi join */
select d.department_id, e.last_name, e.job_id
from employees e, departments d
where e.department_id = d.department_id
and d.department_name = 'Executive';

/* subquery(in) */
select department_id, last_name, job_id
from employees
where department_id in (select department_id from departments where department_name = 'Executive');

[문제52] 부서 department_id 60에 소속된 모든 사원의 급여(salary)보다 높은(max) 급여를 받는 모든 사원 출력하세요.(★ 문제뜻 제대로 파악)
ex. '... 어떤 사원의 급여 ...' 이라면 any
/* equi join */
select *
from employees e, departments d
where e.department_id = d.department_id(+)
and e.salary > all (select salary from employees where department_id = 60);

select *
from employees e, departments d
where e.department_id = d.department_id(+)
and e.salary > (select max(salary) from employees where department_id = 60);

/* subquery(any) */
select *
from employees
where salary > all (select salary from employees where department_id = 60);

select *
from employees
where salary > (select max(salary) from employees where department_id = 60);