[문제28] 사원의 department_id가 60 또는 80이며 사원이 10000이 넘는 급여를 받는 사원을 조회하세요.
SELECT * FROM employees WHERE salary > 10000 AND (department_id IN(60,80));

[문제29] job_id를 기준으로 총액급여를 구합니다. 단 CLERK글자가 있는 job_id는 제외하고 총액급여는 
        13000가 넘는 정보를 출력하면서 총액 급여를 기준으로 내림차순 정렬하세요.
SELECT job_id,
  SUM(salary)
FROM employees
WHERE job_id NOT LIKE '%CLERK%'
GROUP BY job_id -- 10g 부터 hash 알고리즘으로 처리, 그래서 정렬이 안 되어서 나옴
HAVING SUM(salary) > 13000 
ORDER BY 2 DESC; 

=====================================================================================

select department_id, sum(salary)
from employees 
where department_id in(20,30)
group by department_id;

select department_id, sum(salary)
from employees
group by department_id
having department_id in(20,30); /* 잘못된 예 : 처리순서를 고려해야 함 */

======================================================================================

/* 왜 사원, 부서 테이블 분리를 했을까? */
select employee_id, department_id from employees;
select department_id, department_name from departments; 

→ 테이블 구성 : 유지관리를 위해서 1. UPDATE 2. DELETE 3. 스토리지 낭비 4. block 초과방지
→ 테이블 분리 : 정규화 작업
desc employees;

-- JOIN : 두개 이상의 테이블에서 데이터를 가져오는 방법
→ 서로의 테이블에서 일치되는 키 값(연결통로)을 통해서 연결
1. 동일한 이름의 컬럼 찾아라(단, dep에서 manager_id는 부서장, emp에서는 사수)
2. 업무요건, 테이블구조 파악 잘하라

select * from departments where department_id = 50; /* 부서장은 121 */
select * from employees where department_id = 50;


select employee_id, department_name 
from employees, departments /* 오류 : emp_id는 107개, dep_id는 27개 */
order by 1; 
/* cartesion product */
- 조인조건이 생략이 되었을 경우
- 조인조건이 부적합하게 만든 경우
결과 : 첫번째 테이블 행 * 두번째 테이블 행 → 발생시키면 안됨

## 조인유형
1. equi join(simple join, inner join, 등가조인) : 키값이 일치되는 데이터 뽑아내기 위해

select employee_id, department_name
from employees, departments
where department_id = department_id; /* 조인조건술어 */

- parse : 컴파일
 ① sysntax : select, from, where check!! (키워드 확인)
 ② semantic : 테이블 존재여부, 열의 존재여부(테이블,열 1:1 비교), 의미분석

select employees.employee_id, departments.department_name /* 테이블 별 구분필수 */
from employees, departments
where employees.department_id = departments.department_id; /* 테이블 별 구분필수 */

→ semantic 성능 빨라짐, column 정의모호 오류 방지
→ 하지만 위 문장을 오라클이 기억하기 위해 메모리 사용량이 증가됨

select e.employee_id, d.department_name 
from employees e, departments d /* 테이블 별칭 정의(가독성 증가) */
where e.department_id = d.department_id /* M족 집합처럼 나와라 */
      /* M족 집합 */      /* 1족 집합 */
      and e.employee_id = 100; /* 비조인조건술어(단일행술어) */

select e.employee_id, d.department_name 
from employees e, departments d
where e.department_id = d.department_id /* M족 집합처럼 나와라 */
      /* M족 집합 */      /* 1족 집합 */
      and e.last_name = 'King'; /* 비조인조건술어(단일행술어:X) */
      
→ 동일한 성능을 내면서 메모리 사용량을 줄일 수 있는 테이블 별칭 사용
→ 키값이 일치되는 데이터만 나옴, 결과를 검증할 필요있음

select * from locations; /* 부서별 주소값 */

select e.employee_id, l.street_address
from employees e, departments d, locations l
where e.department_id = d.department_id
and d.location_id = l.location_id; /* 징검다리(d를 경유) */

select e.employee_id, d.department_name 
from employees e, departments d
where e.department_id = d.department_id;

2. outer join : 키값이 없는 데이터까지 뽑아내는 JOIN

select e.employee_id, d.department_name 
from employees e, departments d
where e.department_id = d.department_id(+); /* 키값 미일치는 + 없는 쪽 데이터 다 뽑아달라 */

select e.employee_id, d.department_name 
from employees e, departments d
where e.department_id(+) = d.department_id; /* 소속사원이 없는 부서까지 뽑아달라 */

→ 기존데이터에 NULL이 추가되서 나오는 곳에 (+)라고 생각하자(내 생각)

ex) 
       사원 테이블                            부서 테이블                      부서위치 테이블
사번  이름    부서코드                  부서코드   부서이름    부서위치            부서위치   주소
100  홍길동    10                       10      총무팀      1000               1000   서울시                  
101  박찬호    20                       20      개발팀      2000               2000   경기도
102  손흥민                             30      영업팀      3000               3000   강원도

/* null, 미일치는 equi 누락 */

select e.employee_id, l.street_address
from employees e, departments d, locations l
where e.department_id = d.department_id(+) -- ① : emp ~ dep
and d.location_id = l.location_id(+); -- ② : ①_결과집합 ~ loc
/*
① 결과집합      ② 결과집합
100  1000       100  서울시
101  2000       101  경기도
102  null       102  null
*/
① 수행이유 및 결과집합에 생성되어야할 정보는? 부서위치 아이디 파악
② 수행이유? select 결과 값

아무개 학교에는 홍길동, 박찬호, 손흥민 이라는 같은 반 학우들이 있습니다. 저는 오늘 막 아무개 학교로 전학를 왔습니다.
오늘 수업도 무사히 마치고 집으로 돌아가려고 하는데, 선생님이 같자기 저를 불러서 홍길동, 박찬호, 손흥민이 못 받아간 
간식을 나눠주라고 했습니다. 그런데 그 3명은 종이 치자마자 바로 가버려서 직접 친구들 집으로 찾아가서 줘야될 것 같아요.

3. self join 

ex) 
         사원 테이블(사원)                                 사원 테이블(관리자)
사번  이름    관리자번호  부서코드                   사번  이름    관리자번호  부서코드  
100  홍길동     null     10                      100  홍길동     null     10             
101  박찬호     100      20                      101  박찬호     100      20
102  손흥민     101     null                     102  손흥민     101     null

사원들의 관리자 이름 파악 : 사원 이름 관리자번호 관리자이름
                       100 홍길동 null    null
                       101 박찬호 100     홍길동
                       102 손흥민 101     박찬호

select 사원.사번, 사원.이름, 관리자.사번, 관리자.이름
from 사원테이블 사원, 사원테이블 관리자
where 사원.관리자번호 = 관리자.사번;

select e1.employee_id, e1.last_name, e2.employee_id, e2.last_name
from employees e1, employees e2
where e1.manager_id = e2.employee_id;

select e1.employee_id, e1.last_name, e2.employee_id, e2.last_name
from employees e1, employees e2
where e1.manager_id = e2.employee_id(+);

