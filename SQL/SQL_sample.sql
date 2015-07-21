#This is a sample including all the basic commands in MySQL

#Create database
create database columbia;
use columbia;
drop database columbia;

#Create tables
use test;
create table employee
(
id int primary key,
name varchar(30),
dob datetime,
email varchar(40)
);
desc employee;

#Create tables from other tables
create table emp_info as
select id,name,dob,email
from employee;
desc emp_info;

#Remove tables from database
drop table emp_info;
desc emp_info;

#Insert data into tables
desc employee;
insert into employee (id,name,dob,email)
values (1901,'Jovial','1992-04-21 12:00:00','zc2270@columbia.edu');
select * from employee;
insert into employee
values (2000,'ABC','1992-08-30 12:00:00','ABC@columbia.edu');
select * from employee;

#Insert data into a table from another table
show tables;
desc employee;
desc emp_info;
select * from emp_info;
select * from employee;
insert into emp_info (id,name,dob,email)
select id,name,dob,email
from employee;
select * from emp_info;

#Select query
select name,email
from employee;
select *
from employee;

#Arithmetic operators
select 5+10;
select 10-5;
select 10*5;
select 10/5;
select 10%3;

#Comparison operators
create table employee
(
id int primary key,
name varchar(30),
age int,
email varchar(40),
salary decimal(10,2)
);
desc employee;
insert into employee
values (1900,'John',22,'john@gmail.com',12500.00);
insert into employee
values (1901,'Peter',24,'peter@gmail.com',13800.00);
insert into employee
values (1902,'Howard',29,'howard@gmail.com',25000.00);
select * from employee;
select * from employee where salary<15000;
select * from employee where salary>15000;
select * from employee where salary=25000;
select * from employee where salary<>25000;
select * from employee where salary<=15000;
select salary from employee where name='John';
select salary from employee where age>=24;

#Logical operators
select * from employee where age>=24 and salary<=25000;
select * from employee where age>=24 or salary<=25000;
insert into employee
values (1903,'Kurt',34,'kurt@gmail.com',null);
select * from employee where salary is null;
select * from employee where name like 'p%';
select * from employee where age in (24,30,34);
select * from employee where age between 24 and 34;
select * from employee where age < all(select age from employee where salary>20000);

#WHERE clause
select * from employee where age>24;
select * from employee where name='Kurt';

#AND and OR operators
select * from employee where salary>15000 and age<30;
select * from employee where salary>15000 or age<30;

#Update query
select * from employee;
update employee
set age=26 where id=1900;

#Delete query
select * from employee;
delete from employee
where id=1904;

#Like operator
select * from employee;
select * from employee where email like '%hotmail%';
select * from employee where age like '2_';
select * from employee where name like '_o%';

#TOP and LIMIT clauses
select * from employee limit 3;

#ORDER BY clause
select * from employee order by name;
select * from employee order by age;
select * from employee order by age desc;
select * from employee order by salary desc;

#GROUP BY clause
create table tutorial
(
id int primary key,
title varchar(30),
subject varchar(30),
duration decimal(4,2),
upload_date date
);
desc tutorial;
select * from tutorial;
select subject, count(*)
from tutorial group by subject;
select subject, sum(duration)
from tutorial group by subject;

#Distinct keyword
select salary from employee order by salary;
select distinct salary from employee order by salary;

#Aliasing through AS clause
select title as Title,upload_date as 'Upload Date',duration as Length
from tutorial;

#JOIN
select * from tutorial;
create table tutorial_info
(
tutorial_id int primary key,
views int,
likes int,
dislikes int,
shares int
);
select * from tutorial_info;
select t.id, t.title, t.duration,
ti.views, ti.likes, ti.shares 
from tutorial as t
join tutorial_info as ti
on t.id=ti.tutorial_id;
select t.id, t.title, t.duration,
ti.views, ti.likes, ti.shares 
from tutorial as t, tutorial_info as ti
where t.id=ti.tutorial_id;

#Using GROUP BY clause with JOIN
select t.subject, sum(ti.views) as 'Total Views', sum(ti.likes) as 'Total Likes'
from tutorial as t 
join tutorial_info as ti
on t.id=ti.tutorial_id
group by t.subject;

#Left outer JOIN
select t.subject, sum(ti.views) as 'Total Views', sum(ti.likes) as 'Total Likes'
from tutorial as t 
left join tutorial_info as ti
on t.id=ti.tutorial_id
group by t.subject;

#Right outer JOIN
select t.subject, sum(ti.views) as 'Total Views', sum(ti.likes) as 'Total Likes'
from tutorial as t 
right join tutorial_info as ti
on t.id=ti.tutorial_id
group by t.subject;

#ABS() function
select abs(-15);
select t.title,
abs(ti.likes-ti.dislikes) as 'Difference of Likes and Dislikes'
from tutorial as t 
join tutorial_info as ti
on t.id=ti.tutorial_id;

#ROUND() function
select round(54.783);
select round(54.783,1);
select round(54.783,2);
select round(-12.57,0);
select t.subject, round(avg(ti.likes)) as 'The Avaerage number of Likes rounded off to the nearest decimal point'
from tutorial as t
join tutorial_info as ti
on t.id=ti.tutorial_id
group by t.subject;

#DIV() and MOD() function
select 5 div 2;
select duration from tutorial;
select title, duration div 1 as minutes,
round(duration*60 mod 60) as seconds
from tutorial;

#Numeric function
select ceil(35.40);
select floor(35.40);
select exp(5);
select log(2);
select log10(2);
select pow(2,7);
select greatest(5,3,1,77,9,11,3,3,6,89);
select least(5,3,1,-77,9,11,3,3,6,89);
select radians(180);
select sqrt(196);
select truncate(225.6548,2);
select rand();

#CONCAT() function
select concat('Hello ','World!');
select concat(title,' belongs to ',subject) as tutorial
from tutorial;

#UPPER() and LOWER() function
select upper('Hey there!');
select lower('Hey there!');
select upper(title) from tutorial;

#TRIM() function
select trim('    I have got too much space on either side    ');

#SUBSTR(),RIGHT(),LEFT() function
select SUBSTR('I need a break',3,4);
select SUBSTR('I need a break',10,5);
select right('I need a break',5);
select left('I need a break',6);

#LENGTH() and INSERT() function
select length('Hello World!');
select char_length('Hello World!');
select insert('Hello Word',7,5,'World');

#REPEAT() and REPLACE() function
select repeat('Good Morning!',10);
select replace('Good Morning!','Morning','Night');

#REVERSE() and STRCMP() function
select reverse('See you later, Aligator!');
select strcmp('Day','Day');
select strcmp('Day','Night');
select strcmp('Night','Day');

#Date and Time functions
select adddate('1989-11-20',interval 25 day);
select adddate('1989-11-20',interval 25 month);
select adddate('1989-11-20',interval 25 year);
select subdate('1989-11-20',interval 25 day);
select subdate('1989-11-20',interval 25 month);
select curdate();
select curtime();
select dayname('2007-07-14');
select dayname(upload_date)
from tutorial;
select now();
select makedate(2003,231);
select monthname('2017-03-04');
select timediff('1976-10-11 17:50:28','1976-10-11 20:08:27');
select time_to_sec('23:15:26');
select unix_timestamp();

#Views in SQL
select * from employee;
create view emp_view as 
select id,name,email
from employee
where name is not null;
select * from emp_view;

insert into emp_view
values(1905,'Craig','craig@gmail.com');
insert into emp_view
values(1906,null,'notavailable@gmail.com');
select * from emp_view;
select * from employee;

create view emp_view_new as
select id,name,email
from employee
where name is not null
with check option;
insert into emp_view_new
values(1907,null,'trythis@gmail.com');

update emp_view
set name='Bond'
where id=1905;
select * from emp_view;
delete from emp_view 
where id=1905;
drop view emp_view;

#Aggregate functions
select count(*) from employee;
select count(*) from employee
where age<20;
select max(age) from employee;
select min(age) from employee;
select sum(salary) from employee;
select avg(age) from employee;

#TRUNCATE table 
truncate table tutorial;
select * from tutorial;

#Subqueries in SQL
select id,name from employee
where salary=(select max(salary) from employee);

#ALTER table 
alter table employee add city char(20);
select * from employee;
alter table employee drop city;
alter table employee modify name char(30) not null;
desc employee;