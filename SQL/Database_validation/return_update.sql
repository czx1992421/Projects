create table return_capiq_yahoo as
select a.*, ret_yahoo_month(a.form_id,12) as return_yahoo
from
(
select form_id, issuerName, issuerTradingSymbol, issuerCik, rptOwnerName, rptOwnerCik, officertitle, acceptedDate, acceptedTime, transactionCode, investorType, accessionNumber, return1Year, ret_capiq_month(form_id,12) as return_capiq
from form_info_new
where (transactionCode = 'BUY' OR transactionCode = 'EX-B' OR transactionCode = '10b5-1-BUY') 
and abs(return1Year-ret_capiq_month(form_id,12))>0.0001
) a, form_info_new b
where a.form_id = b.form_id
and abs(a.return1Year-ret_yahoo_month(a.form_id,12))>0.0001
and a.acceptedDate <= '2015-05-13'
order by issuerCik, acceptedDate, acceptedTime
;

select * from return_capiq_yahoo;

drop table return_capiq_yahoo;

SET SQL_SAFE_UPDATES = 0;

update form_info_new, return_capiq_yahoo 
set form_info_new.return1Year= return_capiq_yahoo.return_capiq
where form_info_new.form_id = return_capiq_yahoo.form_id
;