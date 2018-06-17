[문제78] 각 부서 인원수가 전체 인원 대비 차지하는 비율을 계산하세요.;

select department_id dept_id, round((count(*)/(sum(count(*)) over()+1))*100, 2) per
from employees
where department_id is not null
group by department_id;

-- 선생님 풀이 : ratio_to_report() 함수
select department_id, cn, cn/107, ratio_to_report(cn) over() /* 비율구하는 분석함수 */
from (select department_id, count(*) cn
      from employees
      group by department_id)
order by 1;

-- 개선방안
select department_id dept_id, round((cn/(sum(cn) over()))*100, 2) per
from (select department_id, count(*) cn
      from employees
      group by department_id)
order by 1;

-- 분석함수 옵션
SELECT employee_id, salary,
sum(salary) over (ORDER BY employee_id ) sum_sal1, /* 누적 */
sum(salary) over (ORDER BY employee_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) sum_sal2, /* 누적 */
sum(salary) over ( ) sum_sal3, /* 전체합 */
sum(salary) over (ORDER BY employee_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) sum_sal4 /* 전체합 */
FROM employees;


- ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING : 정렬결과의 처음과 끝을 대상
- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW : 정렬결과 처음부터 현재 행까지를 대상

select department_id, salary, 
first_value(salary) over (partition by department_id order by salary rows between unbounded preceding and unbounded following) first,
/* 오름차순 : 첫번째, 내림차순 : 마지막값 */
last_value(salary) over (partition by department_id order by salary rows between unbounded preceding and unbounded following) last
/* 오름차순 : 마지막값, 내림차순 : 첫번째 */
from employees;

select department_id, salary, 
first_value(salary) over (partition by department_id order by salary) first,
/* 오름차순 : 첫번째, 내림차순 : 마지막값 */
last_value(salary) over (partition by department_id) last
/* 오름차순 : 마지막값, 내림차순 : 첫번째 */
from employees;

================================================================================

select employee_id, last_name, manager_id
from employees
order by 1;

/*
조직도?? 생각해보자~  계층검색쿼리!! 게시판이 바로 테이블이다. 댓글에 댓글이 그 예
*/

select employee_id, last_name, manager_id
from employees
start with employee_id = 101 -- 시작점
connect by prior employee_id = manager_id; -- connect by : 연결고리

select employee_id, last_name, manager_id
from employees
start with employee_id = 206 -- 시작점
connect by employee_id = prior manager_id; -- prior 위치에 따라 올라갈수도 내려갈수도 있다
                                           -- 인덱스 걸려있으면 인덱스 풀스캔해서 더 빠르다

-- 계급별 들여쓰기
select level, lpad('┗ ',level*2-2,' ')||last_name
from employees        /*공란길이*/
start with employee_id = 100
connect by prior employee_id = manager_id;

select level, lpad(last_name,length(last_name)+level*2-2)
from employees                                /*공란길이*/
start with employee_id = 101
connect by prior employee_id = manager_id;

-- 제한하기
select employee_id, last_name, manager_id
from employees
where employee_id <> 101 -- 101번 행만 제한
start with employee_id = 100
connect by prior employee_id = manager_id;

select employee_id, last_name, manager_id
from employees
start with employee_id = 100
connect by prior employee_id = manager_id
and employee_id <> 101; -- 101번 포함 부하직원들 제한(101번 조직도 제한)

-- sys_connect_by_path(개별열,'구분기호') : 1개의 필드에 계층순서 표현하는 함수
select sys_connect_by_path(last_name,'/') path_1,
       ltrim(sys_connect_by_path(last_name,'/'), '/') path_2 /*ltrim : 연속되는 접두(/)만 문자 제거*/
from employees
start with employee_id = 100
connect by prior employee_id = manager_id;

================================================================================

select department_id, last_name
from employees
order by 1;

-- 위의 내용을 부서별 이름으로 나타내기(가로로 출력) : listagg(개별열,'구분') within group(order by 기준)
select department_id, listagg(last_name,',') within group(order by last_name)/*가로로 출력하는 방법*/
from employees
group by department_id;

================================================================================
/*
database(데이터가 저장되는 공간(논리적))                       OS(물리적)
   ↓                                                          ↓
tablespace(업무별로)                                         datafile
   ↓                                                          ↓
segment = object 중 저장공간이 필요한 것(table, index)            
   ↓
extent
   ↓
block(오라클 최소 I/O단위)                                    os block 

권한 : 어떤 SQL 문장을 수행할 수 있는 권리
*/
-- DBA의 권한 조회 : 실제로 HR에 다 주지 않음, 데이터 관리차원
select * from session_privs; /* 시스템권한 확인 */
select * from user_sys_privs; 
select * from dba_sys_privs;
select * from user_tab_privs;

소유자로 부터 object 권한 받아야 책을 펼쳐볼수있다.


-- 유저생성
create user 권한이 필요(DBA DB관리자);
/* 
권한 : 특정한 SQL문을 수행할 수 있는 권리 
- 시스템권한(데이터베이스에 영향을 줄수 있는/DBA가 준다), 
- 객체권한(타인이 가지고 있는 다른 유저가 소유하고 있는 곳에 엑세스 할려면/다른유저가 준다)

롤 : 권한 덩어리(모음집)
*/
-- 롤 조회
select * from session_roles;

-- 롤 안에 시스템 권한 조회
select * from role_sys_privs;

-- 롤 안에 오브젝 권한 조회
select * from role_tab_privs;
