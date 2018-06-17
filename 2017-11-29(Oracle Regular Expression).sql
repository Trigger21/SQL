[문제92] 사원의 last_name중에 B, M, A 로 시작되는 사원정보를 출력하세요. 

select *
from employees
where last_name like 'B%' or last_name like 'M%' or last_name like 'A%';

select *
from employees
where instr(last_name,'B') = 1 or instr(last_name,'M') = 1 or instr(last_name,'A') = 1;

select *
from employees
where substr(last_name,1,1) in ('B','M','A');

[문제93] 사원의 first_name이 'Steven','Stephen' 사원정보를 출력하세요.

select *
from employees
where first_name in ('Steven','Stephen');

[문제94] 사원의 job_id중에 _MAN, _MGR 문자가 있는 사원정보를 출력하세요.

select *
from employees
where job_id like '%_MAN' or job_id like '%_MGR';

select *
from employees
where job_id like '%\_MAN' escape '\' 
or job_id like '%\_MGR' escape '\';

[문제95] 알파벳 대소문자 구분하지 않고 어느위치에 있든 o 가 있는 last_name을 출력하세요.

select last_name
from employees
where instr(last_name,'o')>0 or instr(last_name,'O')>0; 

[문제96] 연속되는  o가있는 last_name 검색 가 있는 last_name을 출력하세요.
-- 컬럼의 형(또는 대소문자) 이 바뀌면 index 스캔을 못함(substr, instr은 인덱스스캔 가능)

select last_name
from employees
where last_name like '%oo%' 
or last_name like '%OO%'
or last_name like '%Oo%'
or last_name like '%oO%';

select last_name, instr(last_name,'o'), instr(last_name,'o',1,2)
from employees
where instr(last_name,'o',1,2)-instr(last_name,'o') = 1;

================================================================================
☆ Oracle Regular Expression(정규표현식)

-- regexp_like(index scan 유지) : 문자검색용 함수

[문제92] 사원의 last_name중에 B, M, A 로 시작되는 사원정보를 출력하세요.

select *
from employees
where regexp_like(last_name,'^(B|M|A)');
/* 메타문자
 ^ : 시작,  ^(A) A로 시작되는 거 찾아
 | : or
*/
 

[문제93] 사원의 first_name이 'Steven','Stephen' 사원정보를 출력하세요.

select * 
from employees
where regexp_like(first_name, '^Ste(v|ph)en$');
/* 
 ^Ste : Ste로 시작
 (v|ph) : v or ph (공통되지 않은 부분)
 en$ : en으로 끝
*/


[문제94] 사원의 job_id중에 _MAN, _MGR 문자가 있는 사원정보를 출력하세요.

select *
from employees
where regexp_like(job_id, '(_m(an|gr))','i');
/*
 i : 대소문자 구분하지 않고 검색
 c : 내가 입력한 대로 검색(기본값)
*/

select * 
from employees
where regexp_like(job_id, '[a-z]{2}_m[an|gr]','i');
/*
 [a-z]{2} : a ~ z로 2글자만 
*/


[문제95] 알파벳 대소문자 구분하지 않고 어느위치에 있든 o 가 있는 last_name을 출력하세요.

select *
from employees
where regexp_like(last_name, '(o)', 'i');


[문제96] 연속되는  o가있는 last_name 검색 가 있는 last_name을 출력하세요.

select * 
from employees
where regexp_like(last_name, '(oo)', 'i');

select * 
from employees
where regexp_like(last_name, '(o)\1', 'i');

/*
 \1 : 연속의 개념,  (o)\1 = (oo)
*/

--------------------------------------------------------------------------------

create table cust(name varchar2(30));

insert into cust(name) values('oracle');
insert into cust(name) values('ORACLE');
insert into cust(name) values('오라클');
insert into cust(name) values('0racle');
insert into cust(name) values('히나라');
insert into cust(name) values('그나라');
insert into cust(name) values('통나라');
insert into cust(name) values('오racle');
insert into cust(name) values('5racle');
commit;

select * from cust;

알파벳 대소문자 구분하지 않고 이름 검색
select * from cust where regexp_like(name, '^[a-z]','i');
/* [a-z] : a ~ z */

알파벳 대소문자 구분해서 이름 검색
select * from cust where regexp_like(name, '^[A-Z]','c');
/* [A-Z] : A ~ Z */

숫자로 시작대는 이름 검색
select * from cust where regexp_like(name, '^[0-9]');
/* [0-9] : 0 ~ 9 */

한글이 들어 있는 이름 검색
select * from cust where regexp_like(name, '^[가-히]','i');
/* [가-히] : 가 ~ 히 */

select * from cust where regexp_like(name, '^(히|그|통)나라$');

--------------------------------------------------------------------------------

select postal_code from locations;

/* 대문자 검색*/
select postal_code from locations where regexp_like(postal_code,'[[:upper:]]');

/* 소문자 검색 */
select postal_code from locations where regexp_like(postal_code,'[[:lower:]]');

/* 숫자 검색 */
select postal_code from locations where regexp_like(postal_code,'[[:digit:]]');

/* 띄어쓰기 검색*/
select postal_code from locations where regexp_like(postal_code,'[[:blank:]]');
select postal_code from locations where regexp_like(postal_code,'[[:space:]]');

/* 특수문자 검색 */
select street_address
from locations
where regexp_like(street_address,'[[:punct:]]');

================================================================================

[문제97] 사원테이블에 phone_number 값이 화면과 같은 패턴의 번호만 검색(35개 나옴)
        < 화면 >
        011.44.1344.429268
        
select phone_number from employees;

select phone_number 
from employees 
where regexp_like(phone_number, '[0-9]{3}.(4)\1.[0-9]{4}.[0-9]{6}'); 
      
select phone_number 
from employees 
where regexp_like(phone_number, '\d{3}.\d{2}.\d{4}.\d{6}'); 

select phone_number 
from employees 
where regexp_like(phone_number, '^\d{3}.\d{3,4}.\d{4}$'); 

[문제98] locations 테이블에 postal_code 값이 영문자로 끝나는 정보들 출력하세요.

select postal_code from locations;

select *
from locations
where regexp_like(postal_code, '[a-z]$','i');

================================================================================
-- regexp_substr

select REGEXP_SUBSTR('abc@dream.com', '[^@]+',1,1) from dual;
/*
 [^ : not의 의미
 + : 첫번째 여러글자(abc), 표시 안하면 첫글자만 뽑음
*/

SELECT REGEXP_INSTR ('0123456789', '(123)(4(56)(78))', 1, 1, 0, 'i', 1) "Position"
FROM dual;
/*
 (123)(4(56)(78)) : 123, 45678, 56, 78(하위식) / 4개를 1개로 만듬
 첫번째 하위식(123)이 '0123456789'에서 어디서 나오나?
 (1, n, 0,... : 처음부터 시작해 n번째 나오는 (0은 의미없음)
  ..., n) : n번째 하일식을 찾아라
*/

select regexp_instr('78123456789', '(4(56)(78))', 1, 1, 0, 'i', 3) "position"
from dual; /* 9 */
select regexp_instr('45678123456789', '(4(56)(78))', 1, 1, 0, 'i', 3) "position"
from dual; /* 4 */
select regexp_instr('45678456789', '(4(56)(78))', 1, 2, 0, 'i', 3) "position"
from dual; /* 9 */


/* 쥐의 DNA */
SELECT
REGEXP_INSTR('ccacctttccctccactcctcacgttctcacctgtaaagcgtccctc
cctcatccccatgcccccttaccctgcagggtagagtaggctagaaaccagagagctccaagc
tccatctgtggagaggtgccatccttgggctgcagagagaggagaatttgccccaaagctgcc
tgcagagcttcaccacccttagtctcacaaagccttgagttcatagcatttcttgagttttca
ccctgcccagcaggacactgcagcacccaaagggcttcccaggagtagggttgccctcaagag
gctcttgggtctgatggccacatcctggaattgttttcaagttgatggtcacagccctgaggc
atgtaggggcgtggggatgcgctctgctctgctctcctctcctgaacccctgaaccctctggc
taccccagagcacttagagccag',
'(gtc(tcac)(aaag))',
1, 1, 0, 'i',1) "Position"
FROM dual;



SELECT REGEXP_COUNT(
'ccacctttccctccactcctcacgttctcacctgtaaagcgtccctccctcatccccatgcccccttaccctgcag
ggtagagtaggctagaaaccagagagctccaagctccatctgtggagaggtgccatccttgggctgcagagagaggag
aatttgccccaaagctgcctgcagagcttcaccacccttagtctcacaaagccttgagttcatagcatttcttgagtt
ttcaccctgcccagcaggacactgcagcacccaaagggcttcccaggagtagggttgccctcaagaggctcttgggtc
tgatggccacatcctggaattgttttcaagttgatggtcacagccctgaggcatgtaggggcgtggggatgcgctctg
ctctgctctcctctcctgaacccctgaaccctctggctaccccagagcacttagagccag',
'gtc') AS Count
FROM dual;
/*
 'gtc'라는 글자가 몇번 나오는지
*/

[응용] phone_number 중 첫번째 . , 앞에 있는 숫자는?

select phone_number from employees;

select regexp_substr(phone_number, '[^.]+', 1, 1) f_num, 
       count(*) cnt
from employees
group by regexp_substr(phone_number, '[^.]+', 1, 1);

================================================================================

[문제99] '010-1234-5678', '010-123-5678' 번호를 가지고 앞번호 010 중간번호 1234 끝번호 5678를 분리해서
	출력하세요.(기존의 substr 이용)

select substr('010-1234-5678', 1, 3) f_num,
       substr('010-1234-5678', 5, 4) m_num,
       substr('010-1234-5678', 10, 4) l_num,
       substr('010-123-5678', 1, 3) f_num,
       substr('010-123-5678', 5, 3) m_num,
       substr('010-123-5678', 10, 4) l_num
from dual;

select substr('010-1234-5678', 1, instr('010-1234-5678','-')-1) f_num,
       substr('010-1234-5678', instr('010-1234-5678','-')+1, instr('010-1234-5678','-',1,2)-instr('010-1234-5678','-')-1) m_num,
       substr('010-1234-5678', instr('010-1234-5678','-',1,2)+1) l_num
from dual;

select substr('010-123-5678', 1, instr('010-123-5678','-')-1) f_num,
       substr('010-123-5678', instr('010-123-5678','-')+1, instr('010-123-5678','-',1,2)-instr('010-123-5678','-')-1) m_num,
       substr('010-123-5678', instr('010-123-5678','-',1,2)+1) l_num
from dual;

[문제100] '010-1234-5678' 번호를 가지고 앞번호 010 중간번호 1234 끝번호 5678를 분리해서
	출력하세요.(기존의 regexp_substr 이용)
  
select regexp_substr('010-1234-5678', '[^-]+', 1, 1) f_num,
       regexp_substr('010-1234-5678', '[^-]+', 1, 2) m_num,
       regexp_substr('010-1234-5678', '[^-]+', 1, 3) l_num
from dual;

================================================================================

-- 튜닝
/*
ocp는 오라클 관리자(엔지니어) 관련 라이센스 / 굳이 딸 필요는 없음(차라리 정보처리기사를 따라)
*/