-- create test table using new form_info_new
create table test_new as
select * 
from form_info_new
order by rand()
limit 50000;

create table test_new_edit as
select * 
from test_new
where dollarvolume(form_id,30) >= 2
and mktcap_avg(form_id,30) >= 30
and transactionPrice >= 1
and dollarvalue >= 10000
and acceptedDate <= '2015-05-13'
-- order by rand()
-- limit 10000
;

select * from test_new;
drop table test_new;

select * from test_new_edit;

-- create test table using old form_info_new
create table test_old as
select *
from form_info_old
order by rand()
limit 10000;

-- check return in capiq_new
create table return_difference_capiq_new as
select form_id, issuerName, issuerTradingSymbol, issuerCik, rptOwnerName, rptOwnerCik, officertitle, acceptedDate, acceptedTime, transactionCode, investorType, accessionNumber, transactionPrice, dollarvalue, dollarvolume(form_id,30), mktcap_avg(form_id,30), return1Day, ret_capiq(form_id,1) as return_capiq
from test_new
where (transactionCode = 'BUY' OR transactionCode = 'EX-B' OR transactionCode = '10b5-1-BUY') 
and return1Day != ret_capiq(form_id,1)
and abs(return1Day-ret_capiq(form_id,1))>0.0001
order by issuerCik, acceptedDate, acceptedTime;

select count(distinct issuerCik) from return_difference_capiq_new;

select *, (return1Day-return_capiq) as diff from return_difference_capiq_new;

select avg(abs(return1Day-return_capiq)) from return_difference_capiq_new;

drop table return_difference_capiq_new;

-- check return in yahoo_price_new
create table return_difference_yahoo_new as
select form_id, issuerName, issuerTradingSymbol, issuerCik, rptOwnerName, rptOwnerCik, officertitle, acceptedDate, acceptedTime, transactionCode, investorType, accessionNumber, transactionPrice, dollarvalue, dollarvolume(form_id,30), mktcap_avg(form_id,30), return1Day, ret_yahoo(form_id,1) as return_yahoo
from test_new
where (transactionCode = 'BUY' OR transactionCode = 'EX-B' OR transactionCode = '10b5-1-BUY') 
and return1Day != ret_yahoo(form_id,1)
and abs(return1Day-ret_yahoo(form_id,1))>0.0001;

drop table return_difference_yahoo_new;

-- check return difference new
create table return_difference_new as
select form_id, issuerName, issuerTradingSymbol, rptOwnerName, officertitle, acceptedDate, acceptedTime, transactionCode, issuerCik, rptOwnerCik, investorType, accessionNumber, return1Day, ret_capiq(form_id,1) as return_capiq, ret_yahoo(form_id,1) as return_yahoo
from test_new
where (transactionCode = 'BUY' OR transactionCode = 'EX-B' OR transactionCode = '10b5-1-BUY')
and return1Day != ret_capiq(form_id,1)
and return1Day != ret_yahoo(form_id,1)
and abs(return1Day-ret_capiq(form_id,1))>0.0001
and abs(return1Day-ret_yahoo(form_id,1))>0.0001;
select * from return_difference;

select a.*, b.return_yahoo
from return_difference_capiq_new a, return_difference_yahoo_new b
where a.form_id = b.form_id
;

-- return difference because of missing records in capiq
select form_id, issuerName, issuerTradingSymbol, rptOwnerName, officertitle, acceptedDate, acceptedTime, transactionCode, issuerCik, rptOwnerCik, investorType, accessionNumber, return1Day, ret_capiq(form_id,1) as return_capiq, ret_yahoo(form_id,1) as return_yahoo 
from test_new
where form_id not in
(
select a.form_id
from test_new a, capiq b
where a.issuerCik = b.issuerCik
and a.acceptedDate = b.`Date`
)
;

-- return difference because of next day is weekend in capiq
select a.* from 
(
select a.*
from return_difference_capiq_new a, capiq b
where a.issuerCik = b.issuerCik
and a.acceptedDate = b.`Date`
) a
where a.form_id not in
(
select a.form_id
from return_difference_capiq_new a, capiq b
where a.issuerCik = b.issuerCik
and adddate(a.acceptedDate, interval 1 day) = b.`Date` 
)
;

select a.* from 
(
select a.*
from return_difference_capiq_new a, capiq b
where a.issuerCik = b.issuerCik
and a.acceptedDate = b.`Date`
) a
where a.form_id in
(
select a.form_id
from return_difference_capiq_new a, capiq b
where a.issuerCik = b.issuerCik
and adddate(a.acceptedDate, interval 1 day) = b.`Date` 
)
;

-- check return in capiq_old
create table return_difference_capiq_old as
select form_id, issuerName, issuerTradingSymbol, rptOwnerName, officertitle, acceptedDate, acceptedTime, transactionCode, issuerCik, rptOwnerCik, accessionNumber, return1Day, ret_capiq(form_id,1) as return_capiq
from test_old
where (transactionCode = 'BUY' OR transactionCode = 'EX-B' OR transactionCode = '10b5-1-BUY') 
and return1Day != ret_capiq(form_id,1)
and abs(return1Day-ret_capiq(form_id,1))>0.0001;

-- check return in yahoo_price_old
create table return_difference_yahoo_old as
select form_id, issuerName, issuerTradingSymbol, rptOwnerName, officertitle, acceptedDate, acceptedTime, transactionCode, issuerCik, rptOwnerCik, accessionNumber, return1Day, ret_yahoo(form_id,1) as return_yahoo
from test_old
where (transactionCode = 'BUY' OR transactionCode = 'EX-B' OR transactionCode = '10b5-1-BUY') 
and return1Day != ret_yahoo(form_id,1)
and abs(return1Day-ret_yahoo(form_id,1))>0.0001;

select * from return_difference_capiq_new where acceptedDate < '2015-05-30';
select * from return_difference_yahoo_new where acceptedDate < '2015-05-30';
select * from return_difference_capiq_old where acceptedDate < '2015-05-30';
select * from return_difference_yahoo_old where acceptedDate < '2015-05-30';

drop table test_new;
drop table test_new_edit;

drop table test_old;

select a.*, b.return2week as return_old
from return_difference_capiq_new a, form_info_old b
where a.form_id = b.form_id
and b.return2week is not null;