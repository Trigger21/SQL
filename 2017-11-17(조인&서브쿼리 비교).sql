[문제60] 같은 부서에서 자신보다 입사한 날짜가 늦은 사원보다 급여가 낮은 받는 사원을 표시하는 query 를 작성합니다.(exists 대표적 문제)
-- 내 풀이(exists 연산자를 사용한 correlated subquery)
select *
from employees e
where exists
(select 1
 from employees 
 where department_id = e.department_id /* 같은 부서에서 */
 and hire_date > e.hire_date           /* 나보다 늦게 입사했는데 */
 and salary > e.salary);               /* 나보다 더 많이 받네 */

select employee_id, hire_date, salary from employees e where department_id = 90;

-- 선생님 풀이
select *
from employees o
where exists(select 1
            from employees i -- i : 별칭 안해도 됨
            where i.department_id = o.department_id
            and i.hire_date > o.hire_date
            and i.salary > o.salary);
            
================================================================================            

-- 자신의 부서 평균급여보다 많이 받는 사원(correlated subquery)

select department_id, last_name, salary, (select avg(salary)
                from employees
                where department_id = e.department_id) avg_dep -- cache기능
from employees e
where salary > (select avg(salary) /* 함수 많이 사용하면 cpu 부하 */
                from employees
                where department_id = e.department_id);

-- 관리자 사원들의 정보를 출력하라

select *
from employees
where employee_id in (select manager_id from employees); -- emp_id : 1족, man_id : M족(중복이 포함)

select *
from employees e
where exists (select 1 from employees where manager_id = e.employee_id);
/* in 과 exists 어느것을 사용할지 고민해 보라 */

/* order by절에도 subquery 사용가능(group by 는 불가) */
select *
from employees o
order by (select department_name 
          from departments
          where department_id = o.department_id);
          
/* inline view */
select e2.*
from (select department_id, avg(salary) avg_sal -- e1 : 필요한 컬럼으로만 재구성한 가상 테이블
      from employees
      group by department_id) e1, employees e2 -- e2 : 원판 테이블
where e1.department_id = e2.department_id
and e2.salary > e1.avg_sal;

-- 부서이름별 총액급여를 구하세요
/* join */
select d.department_name, sum(e.salary)  -- 4.함수계산
from employees e, departments d          -- 1.원본 테이블
where e.department_id = d.department_id  -- 2.join 실시(row 107번 실행)
group by d.department_name;              -- 3.그룹화 작업

/* inline view : 개선 */
select d.department_name, e.sum_sal
from (select department_id, sum(salary) sum_sal
      from employees
      group by department_id) e, departments d
where e.department_id = d.department_id;

================================================================================

/* join */
select e.last_name, d.department_name
from employees e, departments d          
where e.department_id = d.department_id;  

/* scalar subquery : 개선(불필요한 반복방지, null도 출력 */
select e.last_name,
       (select department_name
        from departments
        where department_id = e.department_id) -- cache
from employees e;

-- 부서이름별로 총액급여를 구하세요.(단, skalar subquery 사용)
select d.department_name,
       (select sum(salary) from employees where department_id = d.department_id)
from departments d; -- 큰 테이블 group 안해도 되자나, outer join을 안해도 동일한 효과!

select d.department_name, e.sumsal
from (select department_id, sum(salary) sumsal -- group by로 인해 full scan 하게됨
      from employees
      group by department_id) e, departments d 
where e.department_id = d.department_id;

-- 평균급여도 보고싶어요
select d.department_name,
       (select sum(salary) from employees where department_id = d.department_id),
       (select avg(salary) from employees where department_id = d.department_id)  
from departments d;
/* 위 쿼리문은 총 3번의 IO 발생 : 문제점 */

-- 개선방법
select d.department_name,
       (select 'sumsal:'||sum(salary)||', avgsal:' || avg(salary) 
        from employees 
        where department_id = d.department_id)
from departments d;

select d.department_name, 
       (select sum(salary) || avg(salary) from employees where department_id = d.department_id)
from departments d;

/* 새로운 문자함수 : lpad, rpad */
select last_name, lpad(last_name,20,'*'), -- 20자리는 고정으로 잡겠어, 왼쪽공백은 * 채워줘
       rpad(last_name,20,'*'),-- 20자리는 고정으로 잡겠어, 오른쪽공백은 * 채워줘
       lpad(salary,10,'*') -- 장난치는거 방지
from employees;

[문제61] salary값을 1000당 * 출력하세요
sal   star
5000  *****
4000  ****

select salary, lpad('*',(salary/1000),'*'), lpad(' ',salary/1000+1,'*')
from employees;

-- 아래 쿼리문(부서이름 별 급여합 및 급여평균)을 inline 으로 바꾸고 lpad 사용해서

select d.department_name, 
       (select sum(salary) || avg(salary) from employees where department_id = d.department_id) sal
from departments d;

select *
from (
select d.department_name, 
       (select rpad(substr(sum(salary) || avg(salary), 0, length(sum(salary))),20)
        from employees 
        where department_id = d.department_id) sal
from departments d);

substr(sum(salary))

-- 선생님 풀이
select department_name, substr(sal, 1, 10) sumsal, -- 합 추출
                        substr(sal, 11) avgsal -- 평균 추출
from (
       select d.department_name, 
              (select lpad(sum(salary),10) || lpad(avg(salary),10) -- 각각 10칸 만들고 합 또는 평균값이 일력, 좌측빈칸은 공백 
               from employees 
               where department_id = d.department_id) sal
       from departments d
      )
where sal is not null;
/*
※ inline view는 object가 아님으로 사용만 가능, 다른 from 절 넣을순 없다.
select
from (select ... ) e, (select ... from e) e1
*/
-- 연도별 입사한 사원 수 (1행 테이블로)
select count(decode(to_char(hire_date,'yyyy')/*기준값*/ , '2001' , 1 )) "2001", -- 107개 row가 전체를 다 비교하게 된다(악성코드)
       count(decode(to_char(hire_date,'yyyy')/*기준값*/ , '2002' , 1 )) "2002",
       count(decode(to_char(hire_date,'yyyy')/*기준값*/ , '2003' , 1 )) "2003",
       count(decode(to_char(hire_date,'yyyy')/*기준값*/ , '2004' , 1 )) "2004",
       count(decode(to_char(hire_date,'yyyy')/*기준값*/ , '2005' , 1 )) "2005",
       count(decode(to_char(hire_date,'yyyy')/*기준값*/ , '2006' , 1 )) "2006",
       count(decode(to_char(hire_date,'yyyy')/*기준값*/ , '2007' , 1 )) "2007",
       count(decode(to_char(hire_date,'yyyy')/*기준값*/ , '2008' , 1 )) "2008"
from employees;

select count(decode((select to_char(hire_date,'yyyy')
                     from (
                           select to_char(hire_date,'yyyy') year , 
                                  count(*) cnt
                           from employees
                           group by to_char(hire_date,'yyyy')
                           )
                      group by to_char(hire_date,'yyyy')) , '2001'  , 1 )) "2001" 
from employees;

select to_char(hire_date,'yyyy'), count(*)
from employees
group by to_char(hire_date,'yyyy');

-- 선생님 풀이

select max(decode(year,'2001',cnt)) "2001", -- max(다른 그룹함수도 ok)를 통해서 null 값 제거후 1행 표현하려고
       max(decode(year,'2002',cnt)) "2002",
       max(decode(year,'2003',cnt)) "2003",
       max(decode(year,'2004',cnt)) "2004",
       max(decode(year,'2005',cnt)) "2005",
       max(decode(year,'2006',cnt)) "2006",
       max(decode(year,'2007',cnt)) "2007",
       max(decode(year,'2008',cnt)) "2008"      
from (
      select to_char(hire_date,'yyyy') year , count(*) cnt
      from employees
      group by to_char(hire_date,'yyyy') -- 107열에서 8열로 대폭 줄인 가상테이블
      );

================================================================================
/* 부서별 급여 총합의 평균은 어떻게 구할까? 그 평균보다 급여총합이 더 큰 부서는? */
select *
from (select d.department_name, 
            (select sum(salary) 
             from employees 
             where department_id = d.department_id) dept_total
      from departments d) dept_cost, -- 가상테이블
     (select sum(dept_total)/count(*) from dept_cost); -- 오류 : table or view does not exist

/* 위 해결방법 : with문 */
with
dept_cost as (select d.department_name, 
                    (select sum(salary) 
                     from employees 
                     where department_id = d.department_id) dept_total -- 부서별 사원들의 급여총합
              from departments d), -- dept_cost : 가상테이블 됨
avg_cost as (select sum(dept_total)/count(*) dept_avg/*25348.7*/ from dept_cost) -- 이제 호출됨
select *
from dept_cost
where dept_total > (select dept_avg
                    from avg_cost);


select (select sum(salary) 
        from employees 
        where department_id = d.department_id) dept_avg,
        sum(dept_total)/count(*)    
from departments d;