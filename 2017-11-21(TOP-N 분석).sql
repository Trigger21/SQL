[문제70] 년도별 입사한 인원수를 pivot을 이용해서 출력해주세요.

      2001       2002       2003       2004       2005       2006       2007       2008
---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
         1          7          6         10         29         24         19         11
         
select *
from (select to_char(hire_date,'yyyy') year from employees)
pivot (count(*) for year in('2001' "2001",'2002' "2002",'2003' "2003",'2004' 
"2004",'2005' "2005",'2006' "2006",'2007' "2007",'2008' "2008")); 

select *
from (select to_char(hire_date,'yyyy') year, nvl(null,1) num from employees)
pivot (sum(num) for year in('2001' "2001",'2002' "2002",'2003' "2003",'2004' 
"2004",'2005' "2005",'2006' "2006",'2007' "2007",'2008' "2008"));

[문제71] 전체 사원의 수, 년도별 입사한 인원수를 pivot을 이용해서 출려해주세요.

select *
from (select to_char(hire_date,'yyyy') year, count(*) cnt 
      from employees 
      group by rollup(to_char(hire_date,'yyyy')))
pivot (max(cnt) for year in(null "total",'2001' "2001",'2002' "2002",'2003' 
"2003",'2004' "2004",'2005' "2005",'2006' "2006",'2007' "2007",'2008' "2008"));

select *
from(select to_char(hire_date,'yyyy') -- 별칭을 지정해 주지않으면 외부에서 사용불가
     from employees)
where to_char(hire_date,'yyyy') = '2001';

select *
from(select to_char(hire_date,'yyyy') year
     from employees)
where year = '2001';

[문제72] 20번 부서에 사원들의 급여의 누적 합계를 구하세요.(self join, >= 써야함)

EMPLOYEE_ID     SALARY DEPARTMENT_ID      TOTAL
----------- ---------- ------------- ----------
        201      13000            20      13000
        202       6000            20      19000
        
select e1.employee_id, e1.salary, e1.department_id, sum(e2.salary) total
from (select employee_id, salary, department_id from employees where department_id = 20) e1,
     (select employee_id, salary from employees where department_id = 20) e2
where e1.employee_id >= e2.employee_id -- >= 이 핵심
group by e1.employee_id, e1.salary, e1.department_id;

================================================================================
-- 누적값을 구하는 분석함수 : over(order by 기준)
select employee_id, salary, department_id, 
       sum(salary) over(order by employee_id)
from employees
where department_id = 20;

-- 전체값을 구하는 분석함수 : over()
select employee_id, salary, department_id, sum(salary) over()/*전체합*/, avg(salary) over()/*전체평균*/
from employees
where department_id = 20;

select employee_id, salary, department_id,
sum(salary) over(partition by department_id) as dept_total,/*부서별 총합*/
sum(salary) over(partition by department_id order by employee_id) as running_total, /*부서별 누적합*/
sum(salary) over() as total /*전체 총합*/
from employees;

select employee_id, salary, job_id,
sum(salary) over(partition by job_id order by employee_id) as running
from employees;

================================================================================
-- rownum : fetch(화면상 출력) 번호 (n명 출력시 사용)
-- rowid : 물리적인 row 주소값
select rownum, rowid, employee_id
from employees;

-- TOP-N 분석

select last_name, salary
from employees
order by salary desc;

/* 오개념(잘못된 방법) : 동일한 급여를 받는 사원이 누락할 가능성 있음 */
select rownum, last_name, salary
from (
      select last_name, salary
      from employees
      order by salary desc
      )
where rownum <= 2; -- fetch number라서 = , >, >= 는 안됨

/* rank(), dense_rank() */
select employee_id, last_name, salary,
       rank() over(order by salary desc) rank, -- 2등 2명이면 3등은 없다
       dense_rank() over(order by salary desc) dense_rank -- 연이은 순위
from employees;

select rank, last_name, salary
from (select dense_rank() over(order by salary desc) rank,
             last_name, salary
      from employees)
where rank <= 10; 

select department_id, employee_id, last_name, salary,
       rank() over(partition by department_id order by salary desc) rank, -- 부서별 사원 급여순위
       dense_rank() over(partition by department_id order by salary desc) dense_rank -- 부서별 사원 급여순위
from employees;

================================================================================

[문제73] 사원수가 3명 미만인 부서번호, 부서이름, 인원수를 출력

select department_id, (select department_name
                       from departments
                       where department_id = e.department_id)
       , count(*) cnt
from employees e
where department_id is not null
group by department_id
having count(*) < 3;

-- 선생님 풀이
select d.department_id, d.department_name, e.cnt
from(select department_id, count(*) cnt
     from employees
     group by department_id
     having count(*)<3) e, departments d
where d.department_id = e.department_id;

select department_id, count(*)
from employees
group by rollup(department_id)
order by 2;

[문제74] 사원 수가 가장 많은 부서번호, 부서이름, 인원수를 출력

select department_id, (select department_name
                       from departments
                       where department_id = b.department_id) dept_name
       , cnt
from (select dense_rank() over(order by  count(*) desc) rank, department_id, count(*) cnt
      from employees
      group by department_id) b
where rank = 1
group by department_id, cnt;

-- 선생님 풀이
select d.department_id, d.department_name, e.cnt
from (select department_id, count(*) cnt
      from employees
      group by department_id
      having count(*) = (select max(count(*))
                         from employees
                         group by department_id)) e, 
      departments d
where d.department_id = e.department_id;

[문제75] 자신의 부서 평균급여 보다 더 많이 받는 사원의 사번, 급여, 부서이름을 출력해주세요.(테이블 3개)
         (join, correlated subquery); -- 부하유발자

select e.employee_id, e.salary, d.department_name -- f10 window buffer : 오라클이 분석함수를 이용했다는...
from employees e, departments d
where e.department_id = d.department_id
and e.salary > (select avg(salary)
                from employees
                where department_id = d.department_id);

[문제76] 자신의 부서 평균급여 보다 더 많이 받는 사원의 사번, 급여, 부서이름을 출력해주세요.(테이블 3개)
         (inline view, join);

select e.employee_id, e.salary, d.department_name
from (select department_id, employee_id, salary
      from employees) e,
     (select department_id, department_name
      from departments) d,
     (select department_id, avg(salary) avg_sal
      from employees
      group by department_id) av  
where e.department_id = d.department_id
and d.department_id = av.department_id
and e.salary > av.avg_sal;

[문제77] 자신의 부서 평균급여 보다 더 많이 받는 사원의 사번, 급여, 부서이름을 출력해주세요.(테이블 2개)
         (inline view, join, 분석함수);
         
select e.employee_id, e.salary, d.department_name
from (select avg(salary) over(partition by department_id) avg_sal, department_id, employee_id, salary
      from employees) e,
     (select department_id, department_name
      from departments) d
where e.department_id = d.department_id
and e.salary > e.avg_sal;

select e.*
from employees e
where e.salary > any 
(select avg(salary) over(partition by department_id) from employees where department_id = e.department_id) ;

-- 선생님 풀이
/*
inline view 안에서 조인을 통해 원하는 테이블을 생성하고 case when문을 응용해서 
부서별 평균값보다 높은 급여를 받는 사원들의 rowid들로 구성된 열을 생성
*/
select employee_id, salary, department_name
from (select e.employee_id, e.salary, d.department_name,
      case when e.salary > avg(salary) over(partition by e.department_id)
      then e.rowid end VW_COL_4 /*column name*/
      from employees e, departments d
      where e.department_id = d.department_id) 
where VW_COL_4 is not null;









