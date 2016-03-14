-- create test table using new form_info_new
create table test_new as
select * 
from form_info_new
where acceptedDate <= '2015-05-30'
order by rand()
limit 10000;

-- create test table using old form_info_new
create table test_old as
select * 
from form_info_old
where acceptedDate <= '2015-05-30'
order by rand()
limit 10000;

-- check startprice using new form_info_new
create table startprice_difference_capiq as
select form_id, issuerName, issuerTradingSymbol, rptOwnerName, officertitle, acceptedDate, acceptedTime, transactionCode, issuerCik, rptOwnerCik, investorType, accessionNumber, startPrice, startprice_capiq(form_id) as startprice_capiq
from test_new
where (transactionCode = 'BUY' OR transactionCode = 'EX-B' OR transactionCode = '10b5-1-BUY') 
and startPrice != startprice_capiq(form_id)
and abs(startPrice-startprice_capiq(form_id)) > startPrice*0.001
;
select * from startprice_difference_capiq;
drop table startprice_difference_capiq;

create table startprice_difference_yahoo as
select form_id, issuerName, issuerTradingSymbol, rptOwnerName, officertitle, acceptedDate, acceptedTime, transactionCode, issuerCik, rptOwnerCik, investorType, accessionNumber, startPrice, startprice_yahoo(form_id) as startprice_yahoo
from test_new
where (transactionCode = 'BUY' OR transactionCode = 'EX-B' OR transactionCode = '10b5-1-BUY') 
and startPrice != startprice_yahoo(form_id)
and abs(startPrice-startprice_yahoo(form_id)) > startPrice*0.001
;
select * from startprice_difference_yahoo;
drop table startprice_difference_yahoo;

-- Check startprice using old form_info_new
create table startprice_difference_capiq_old as
select form_id, issuerName, issuerTradingSymbol, rptOwnerName, officertitle, acceptedDate, acceptedTime, transactionCode, issuerCik, rptOwnerCik, accessionNumber, startPrice, startprice_capiq(form_id) as startprice_capiq
from test_old
where (transactionCode = 'BUY' OR transactionCode = 'EX-B' OR transactionCode = '10b5-1-BUY') 
and startPrice != startprice_capiq(form_id)
and abs(startPrice-startprice_capiq(form_id)) > startPrice*0.001
;
select * from startprice_difference_capiq_old;
drop table startprice_difference_capiq;

create table startprice_difference_yahoo_old as
select form_id, issuerName, issuerTradingSymbol, rptOwnerName, officertitle, acceptedDate, acceptedTime, transactionCode, issuerCik, rptOwnerCik, accessionNumber, startPrice, startprice_yahoo(form_id) as startprice_yahoo
from test_old
where (transactionCode = 'BUY' OR transactionCode = 'EX-B' OR transactionCode = '10b5-1-BUY') 
and startPrice != startprice_yahoo(form_id)
and abs(startPrice-startprice_yahoo(form_id)) > startPrice*0.001
;
select * from startprice_difference_yahoo_old;
drop table startprice_difference_yahoo;