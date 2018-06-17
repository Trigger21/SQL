[문제30] 모든 사원의 last_name, department_id, department_name을 표시하기 위한 query 를 작성합니다.
/* oracle */
select e.last_name, e.department_id, d.department_name
from employees e, departments d
where e.department_id = d.department_id(+);

/* ansi */      
select e.last_name, e.department_id, d.department_name
from employees e left outer join departments d
on e.department_id = d.department_id;

[문제31] 부서 80에 속하는 last_name, job_id, department_name,location_id 을 표시하기 위한 query 를 작성합니다.
/* oracle */
select e.last_name, e.job_id, d.department_name, d.location_id
from employees e, departments d
where (e.department_id = d.department_id)
and e.department_id = 80; -- d.department = 80; /* 단일행술어 index가 있어야 한다 */

/* 재구성(오라클 머신러닝) : 의도적 카테시안 곱 유도 */
select e.last_name, e.job_id, d.department_name, d.location_id
from employees e, departments d
where d.department_id = 80 -- 1족
and e.department_id = 80; -- M족 

/* ansi */ 
select last_name, job_id, department_name, location_id
from employees cross join departments
where departments.department_id = 80
and employees.department_id = 80;

select last_name, job_id, department_name, location_id
from employees join departments
using(department_id)
where department_id = 80; -- where을 써야지 데이터 문제없다

select e.last_name, e.job_id, d.department_name, d.location_id
from employees e join departments d
on e.department_id = d.department_id 
and d.department_id = 80;

[문제32] commission_pct 에 null이 아닌 모든 사원의 last_name, department_name, location_id, city를 표시하기 위한 query 를 작성합니다.
/* oracle */
select e.last_name, d.department_name, d.location_id, l.city 
from employees e, departments d, locations l
where e.department_id = d.department_id(+)
and d.location_id = l.location_id(+)
and e.commission_pct is not null;

/* ansi */
select e.last_name, d.department_name, d.location_id, l.city 
from employees e left outer join departments d
on e.department_id = d.department_id
left outer join locations l
on d.location_id = l.location_id
where e.commission_pct is not null;

select * from employees where commission_pct is not null;

[문제33] last_name에 a(소문자)가 포함된 모든 사원의 last_name, department_name 을 표시하기 위한 query 를 작성합니다.
/* oracle */
select e.last_name, d.department_name
from employees e, departments d
where (e.department_id = d.department_id(+))
and e.last_name like '%a%';

select e.last_name, d.department_name
from employees e, departments d
where (e.department_id = d.department_id(+))
and instr(e.last_name,'a') > 0;

/* ansi */
select e.last_name, d.department_name
from employees e left outer join departments d
on e.department_id = d.department_id
where instr(last_name,'a') > 0; 

[문제34] locations 테이블에 있는 city컬럼에  Toronto도시에서 근무하는 모든 사원의 last_name, job_id, department_id, department_name 을 표시하기 위한 query 를 작성합니다.
/* oracle */
select e.last_name, e.job_id, d.department_id, d.department_name
from employees e, departments d, locations l
where e.department_id = d.department_id
and d.location_id = l.location_id
and l.city = 'Toronto'; --l.location_id = 1800;

/* ansi */
select last_name, job_id, department_id, department_name
from employees join departments
using(department_id) join locations
using(location_id)
where city = 'Toronto';

select e.last_name, e.job_id, d.department_id, d.department_name
from employees e join departments d
on e.department_id = d.department_id
join locations l
on d.location_id = l.location_id
where city = 'Toronto'; -- where city = 'Toronto';

=================================================================================
drop table job_grades purge; -- 영구삭제

CREATE TABLE job_grades -- F5 누르면 한방에 단 1번만
( grade_level varchar2(3),
  lowest_sal  number,
  highest_sal number);

INSERT INTO job_grades VALUES ('A',1000,2999);
INSERT INTO job_grades VALUES ('B',3000,5999);
INSERT INTO job_grades VALUES ('C',6000,9999);
INSERT INTO job_grades VALUES ('D',10000,14999);
INSERT INTO job_grades VALUES ('E',15000,24999);
INSERT INTO job_grades VALUES ('F',25000,40000);
commit;

select * from job_grades;

select * from employees;
/* salary 별 등급 알려줘 */

4. non equi join : 키값이 일치되는 것이 없고 범위내에 속하는 상황에 사용
select e.last_name, e.salary, j.grade_level
from employees e, job_grades j
where e.salary = j.lowest_sal;

select e.last_name, e.salary, j.grade_level
from employees e, job_grades j
where e.salary = j.lowest_sal(+);

/* between */
select e.last_name, e.salary, j.grade_level
from employees e, job_grades j
where e.salary between j.lowest_sal and j.highest_sal; /* 조인조건술어 */

=================================================================================

-- ansi 

/* cross join : cartesian product */
select employee_id, department_name
from employees cross join departments; 

/* 오라클에서 카테시안을 미발생하는 방법 : join */
select employee_id, department_name
from employees, departments;

select e.employee_id, d.department_name
from employees e, departments d
where e.department_id = d.department_id;

/* natural join */
select department_id, department_name, city
from departments natural join locations; 

→ 양쪽 테이블 똑같은 이름의 컬럼을 모두 찾아서 조인조건 만든다. (오라클에게 짬 시키기)
   그래서 엉뚱한 결과를 초래할 수 있다. (예 : manager_id) 
   그리고 컬럼의 타입이 다르면 오류발생(형변환 안함) 

select d.department_id, d.department_name, l.city
from departments d, locations l
where d.location_id = l.location_id;

/* join using : natural join 단점보완 */
select e.last_name, department_id, d.department_name -- using절 사용된 열은 별칭 접두어 사용금지
from employees e join departments d
using(department_id) -- 기준열에 테이블 별칭 접두어로 사용금지
where department_id = 50;

select e.last_name, d.department_name
from employees e, departments d
where d.department_id = e.department_id;

/* join on : equi, non, self */
select e.last_name, d.department_id, d.department_name
from employees e join departments d 
on e.department_id = d.department_id; -- 조인조건술어

select e.last_name, d.department_id, d.department_name, l.city
from employees e join departments d 
on e.department_id = d.department_id
join locations l -- 3개 테이블 조인
on d.location_id = l.location_id; 

/* left outer join */
select e.last_name, d.department_id, d.department_name
from employees e, departments d 
where e.department_id = d.department_id(+);

select e.last_name, d.department_id, d.department_name
from employees e left outer join departments d 
on e.department_id = d.department_id;

/* right outer join */

select e.last_name, d.department_id, d.department_name
from employees e, departments d 
where e.department_id(+) = d.department_id;

select e.last_name, d.department_id, d.department_name
from employees e right outer join departments d 
on e.department_id = d.department_id;

/* full outer join */

select e.last_name, d.department_id, d.department_name
from employees e, departments d 
where e.department_id(+) = d.department_id
union
select e.last_name, d.department_id, d.department_name
from employees e, departments d 
where e.department_id = d.department_id(+); -- 데이터량이 많아지면 부하가 심해지는 문장

select e.last_name, d.department_id, d.department_name
from employees e full outer join departments d 
on e.department_id = d.department_id; -- 이 것을 사용하라(중요)

/* 연습 : 위 문제를 ansi 표준으로 풀어보기 */

=================================================================================

[문제35] 2006년도에 입사한 사원들의 부서이름별로 급여의 총액, 평균을 출력하세요.
select * from employees where to_date('20060101','yyyymmdd') <= hire_date and to_date('20070101','yyyymmdd') > hire_date;

select d.department_name, sum(e.salary), round(avg(e.salary),1)
from employees e, departments d
where e.department_id = d.department_id
and (to_date('20060101','yyyymmdd') <= e.hire_date and to_date('20070101','yyyymmdd') > e.hire_date)
group by d.department_name;

select department_name, sum(salary), round(avg(salary),1)
from employees join departments
using(department_id)
where to_date('20060101','yyyymmdd') <= hire_date and to_date('20070101','yyyymmdd') > hire_date
group by d.department_name;

select d.department_name, sum(e.salary), round(avg(e.salary),1)
from employees e join departments d
on e.department_id = d.department_id
and to_date('20060101','yyyymmdd') <= e.hire_date and to_date('20070101','yyyymmdd') > e.hire_date
group by d.department_name;

[문제36] 2006년도에 입사한 사원들의 도시이름별로 급여의 총액, 평균을 출력하세요.

select l.city, sum(e.salary), round(avg(e.salary),1) 
from employees e, departments d, locations l
where (to_date('20060101','yyyymmdd') <= e.hire_date and to_date('20070101','yyyymmdd') > e.hire_date) and
e.department_id = d.department_id
and d.location_id = l.location_id
group by l.city;

select city, sum(salary), round(avg(salary),1)
from employees join departments
using(department_id)
join locations
using(location_id)
where to_date('20060101','yyyymmdd') <= hire_date and to_date('20070101','yyyymmdd') > hire_date
group by l.city;

select l.city, sum(e.salary), round(avg(e.salary),1) 
from employees e join departments d
on e.department_id = d.department_id
join locations l
on d.location_id = l.location_id
where (to_date('20060101','yyyymmdd') <= e.hire_date and to_date('20070101','yyyymmdd') > e.hire_date)
group by l.city;

[문제37] 2007년도에 입사한 사원들의 도시이름별로 급여의 총액, 평균을 출력하세요.
       단 부서 배치를 받지 않는 사람들의 급여의 총액, 평균도 구하세요.
       
select * from employees where to_date('20070101','yyyymmdd') <= hire_date and to_date('20080101','yyyymmdd') > hire_date;       
       
select l.city, sum(e.salary), round(avg(e.salary),1)
from employees e, departments d, locations l
where (to_date('20070101','yyyymmdd') <= e.hire_date and to_date('20080101','yyyymmdd') > e.hire_date)
and e.department_id = d.department_id(+)
and d.location_id = l.location_id(+)
group by l.city;
       
select l.city, sum(e.salary), round(avg(e.salary),1)
from employees e left outer join departments d
on e.department_id = d.department_id
left outer join locations l
on d.location_id = l.location_id
where to_date('20070101','yyyymmdd') <= e.hire_date and to_date('20080101','yyyymmdd') > e.hire_date
group by l.city;       
       
       