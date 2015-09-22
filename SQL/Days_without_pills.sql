#Quiz: Calculating days a patient did not have any pills
#We want to calculate as efficiently as possible how many days in a period a patient did not have any pills, based on data of when a patient has bought how many pills.
#Assume the following:
#The period starts at the day of the first fill and ends on the day of the last fill.
#A patient takes 1 pill per day, starting at the day he/she bought the pills.
#If a patient buys more pills before his/her supply runs out, the newly bought pills get added to the already existing supply.
#Please describe (or code!) how you would calculate the amount of days in a period a patient did not have any pills. 

#Create new database
create database AllazoHealth;
use AllazoHealth;

#Input original values
create table pill
(
id int primary key,
day int,
amount int
);
desc pill;
insert into pill (id,day,amount)
values (1,0,30),(2,40,30),(3,65,30),(4,110,30);
select * from pill;

#Calculate remaining pills each fill day
create table pill_
(
id int primary key,
day int,
amount int,
remain int
);
insert into pill_ (id,day,amount,remain)
select id,day,amount,
(case when remain is null then 0 else remain end) as remain
from
(select b.id,b.day,b.amount,(select (a.amount+a.day-b.day) from pill a where a.id = (b.id-1)) as remain
from pill b) x;
select * from pill_;

#Calculate days without pills according to two conditions
set @remain=(select remain from pill_ where id=(select max(id) from pill_));
set @t1=ifnull((select abs(sum(remain)-@remain) from pill_ where @remain>0),0);
set @t2=ifnull((select abs(sum(remain)) from pill_ where @remain<0),0);
select convert(greatest(@t1,@t2),signed) as t;





