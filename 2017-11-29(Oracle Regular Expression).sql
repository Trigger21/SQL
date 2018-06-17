[����92] ����� last_name�߿� B, M, A �� ���۵Ǵ� ��������� ����ϼ���. 

select *
from employees
where last_name like 'B%' or last_name like 'M%' or last_name like 'A%';

select *
from employees
where instr(last_name,'B') = 1 or instr(last_name,'M') = 1 or instr(last_name,'A') = 1;

select *
from employees
where substr(last_name,1,1) in ('B','M','A');

[����93] ����� first_name�� 'Steven','Stephen' ��������� ����ϼ���.

select *
from employees
where first_name in ('Steven','Stephen');

[����94] ����� job_id�߿� _MAN, _MGR ���ڰ� �ִ� ��������� ����ϼ���.

select *
from employees
where job_id like '%_MAN' or job_id like '%_MGR';

select *
from employees
where job_id like '%\_MAN' escape '\' 
or job_id like '%\_MGR' escape '\';

[����95] ���ĺ� ��ҹ��� �������� �ʰ� �����ġ�� �ֵ� o �� �ִ� last_name�� ����ϼ���.

select last_name
from employees
where instr(last_name,'o')>0 or instr(last_name,'O')>0; 

[����96] ���ӵǴ�  o���ִ� last_name �˻� �� �ִ� last_name�� ����ϼ���.
-- �÷��� ��(�Ǵ� ��ҹ���) �� �ٲ�� index ��ĵ�� ����(substr, instr�� �ε�����ĵ ����)

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
�� Oracle Regular Expression(����ǥ����)

-- regexp_like(index scan ����) : ���ڰ˻��� �Լ�

[����92] ����� last_name�߿� B, M, A �� ���۵Ǵ� ��������� ����ϼ���.

select *
from employees
where regexp_like(last_name,'^(B|M|A)');
/* ��Ÿ����
 ^ : ����,  ^(A) A�� ���۵Ǵ� �� ã��
 | : or
*/
 

[����93] ����� first_name�� 'Steven','Stephen' ��������� ����ϼ���.

select * 
from employees
where regexp_like(first_name, '^Ste(v|ph)en$');
/* 
 ^Ste : Ste�� ����
 (v|ph) : v or ph (������� ���� �κ�)
 en$ : en���� ��
*/


[����94] ����� job_id�߿� _MAN, _MGR ���ڰ� �ִ� ��������� ����ϼ���.

select *
from employees
where regexp_like(job_id, '(_m(an|gr))','i');
/*
 i : ��ҹ��� �������� �ʰ� �˻�
 c : ���� �Է��� ��� �˻�(�⺻��)
*/

select * 
from employees
where regexp_like(job_id, '[a-z]{2}_m[an|gr]','i');
/*
 [a-z]{2} : a ~ z�� 2���ڸ� 
*/


[����95] ���ĺ� ��ҹ��� �������� �ʰ� �����ġ�� �ֵ� o �� �ִ� last_name�� ����ϼ���.

select *
from employees
where regexp_like(last_name, '(o)', 'i');


[����96] ���ӵǴ�  o���ִ� last_name �˻� �� �ִ� last_name�� ����ϼ���.

select * 
from employees
where regexp_like(last_name, '(oo)', 'i');

select * 
from employees
where regexp_like(last_name, '(o)\1', 'i');

/*
 \1 : ������ ����,  (o)\1 = (oo)
*/

--------------------------------------------------------------------------------

create table cust(name varchar2(30));

insert into cust(name) values('oracle');
insert into cust(name) values('ORACLE');
insert into cust(name) values('����Ŭ');
insert into cust(name) values('0racle');
insert into cust(name) values('������');
insert into cust(name) values('�׳���');
insert into cust(name) values('�볪��');
insert into cust(name) values('��racle');
insert into cust(name) values('5racle');
commit;

select * from cust;

���ĺ� ��ҹ��� �������� �ʰ� �̸� �˻�
select * from cust where regexp_like(name, '^[a-z]','i');
/* [a-z] : a ~ z */

���ĺ� ��ҹ��� �����ؼ� �̸� �˻�
select * from cust where regexp_like(name, '^[A-Z]','c');
/* [A-Z] : A ~ Z */

���ڷ� ���۴�� �̸� �˻�
select * from cust where regexp_like(name, '^[0-9]');
/* [0-9] : 0 ~ 9 */

�ѱ��� ��� �ִ� �̸� �˻�
select * from cust where regexp_like(name, '^[��-��]','i');
/* [��-��] : �� ~ �� */

select * from cust where regexp_like(name, '^(��|��|��)����$');

--------------------------------------------------------------------------------

select postal_code from locations;

/* �빮�� �˻�*/
select postal_code from locations where regexp_like(postal_code,'[[:upper:]]');

/* �ҹ��� �˻� */
select postal_code from locations where regexp_like(postal_code,'[[:lower:]]');

/* ���� �˻� */
select postal_code from locations where regexp_like(postal_code,'[[:digit:]]');

/* ���� �˻�*/
select postal_code from locations where regexp_like(postal_code,'[[:blank:]]');
select postal_code from locations where regexp_like(postal_code,'[[:space:]]');

/* Ư������ �˻� */
select street_address
from locations
where regexp_like(street_address,'[[:punct:]]');

================================================================================

[����97] ������̺� phone_number ���� ȭ��� ���� ������ ��ȣ�� �˻�(35�� ����)
        < ȭ�� >
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

[����98] locations ���̺� postal_code ���� �����ڷ� ������ ������ ����ϼ���.

select postal_code from locations;

select *
from locations
where regexp_like(postal_code, '[a-z]$','i');

================================================================================
-- regexp_substr

select REGEXP_SUBSTR('abc@dream.com', '[^@]+',1,1) from dual;
/*
 [^ : not�� �ǹ�
 + : ù��° ��������(abc), ǥ�� ���ϸ� ù���ڸ� ����
*/

SELECT REGEXP_INSTR ('0123456789', '(123)(4(56)(78))', 1, 1, 0, 'i', 1) "Position"
FROM dual;
/*
 (123)(4(56)(78)) : 123, 45678, 56, 78(������) / 4���� 1���� ����
 ù��° ������(123)�� '0123456789'���� ��� ������?
 (1, n, 0,... : ó������ ������ n��° ������ (0�� �ǹ̾���)
  ..., n) : n��° ���Ͻ��� ã�ƶ�
*/

select regexp_instr('78123456789', '(4(56)(78))', 1, 1, 0, 'i', 3) "position"
from dual; /* 9 */
select regexp_instr('45678123456789', '(4(56)(78))', 1, 1, 0, 'i', 3) "position"
from dual; /* 4 */
select regexp_instr('45678456789', '(4(56)(78))', 1, 2, 0, 'i', 3) "position"
from dual; /* 9 */


/* ���� DNA */
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
 'gtc'��� ���ڰ� ��� ��������
*/

[����] phone_number �� ù��° . , �տ� �ִ� ���ڴ�?

select phone_number from employees;

select regexp_substr(phone_number, '[^.]+', 1, 1) f_num, 
       count(*) cnt
from employees
group by regexp_substr(phone_number, '[^.]+', 1, 1);

================================================================================

[����99] '010-1234-5678', '010-123-5678' ��ȣ�� ������ �չ�ȣ 010 �߰���ȣ 1234 ����ȣ 5678�� �и��ؼ�
	����ϼ���.(������ substr �̿�)

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

[����100] '010-1234-5678' ��ȣ�� ������ �չ�ȣ 010 �߰���ȣ 1234 ����ȣ 5678�� �и��ؼ�
	����ϼ���.(������ regexp_substr �̿�)
  
select regexp_substr('010-1234-5678', '[^-]+', 1, 1) f_num,
       regexp_substr('010-1234-5678', '[^-]+', 1, 2) m_num,
       regexp_substr('010-1234-5678', '[^-]+', 1, 3) l_num
from dual;

================================================================================

-- Ʃ��
/*
ocp�� ����Ŭ ������(�����Ͼ�) ���� ���̼��� / ���� �� �ʿ�� ����(���� ����ó����縦 ����)
*/