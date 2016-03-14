-- Check GT
select form_id, issuerName, issuerTradingSymbol, rptOwnerName, officertitle, acceptedDate, acceptedTime, transactionCode, issuerCik, rptOwnerCik, investorType, GT, GB30D(form_id) as GT30D
from form_info_new
where (transactionCode = 'BUY' OR transactionCode = 'EX-B' OR transactionCode = '10b5-1-BUY') 
and GT != GB30D(form_id)
and GT > 0
-- and issuerCik > 1323715
;

select form_id, issuerName, issuerTradingSymbol, rptOwnerName, officertitle, acceptedDate, acceptedTime, transactionCode, issuerCik, rptOwnerCik, investorType, GT, GS30D(form_id) as GT30D
from form_info_new
where (transactionCode LIKE 'SELL%' OR transactionCode LIKE 'EX-S%')  
and GT != GS30D(form_id)
and GT < 0
-- and issuerCik > 1323715
;

-- Check GT1D
select form_id, issuerName, issuerTradingSymbol, rptOwnerName, officertitle, acceptedDate, acceptedTime, transactionCode, issuerCik, rptOwnerCik, investorType, GT1D, GB1D(form_id)
from form_info_new
where (transactionCode = 'BUY' OR transactionCode = 'EX-B' OR transactionCode = '10b5-1-BUY') 
and GT1D != GB1D(form_id)
and GT > 0
-- and issuerCik > 1323715
;


select form_id, issuerName, issuerTradingSymbol, rptOwnerName, officertitle, acceptedDate, acceptedTime, transactionCode, issuerCik, rptOwnerCik, investorType, GT1D, GS1D(form_id)
from form_info_new
where (transactionCode LIKE 'SELL%' OR transactionCode LIKE 'EX-S%') 
and GT != GS30D(form_id)
and GT < 0
-- and issuerCik > 1323715
;

-- Check GTSP
create table GTSP_test as
select * from form_info_new
order by rand()
limit 100000;

select form_id, issuerName, issuerTradingSymbol, rptOwnerName, officertitle, acceptedDate, acceptedTime, transactionCode, issuerCik, rptOwnerCik, investorType, GTSP, GB_same_period(form_id,1)
from GTSP_test
where (transactionCode = 'BUY' OR transactionCode = 'EX-B' OR transactionCode = '10b5-1-BUY') 
and GTSP != GB_same_period(form_id,1)
and GT > 0
-- and issuerCik > 1323715
;

select form_id, issuerName, issuerTradingSymbol, rptOwnerName, officertitle, acceptedDate, acceptedTime, transactionCode, issuerCik, rptOwnerCik, investorType, GTSP, GS_same_period(form_id,1)
from GTSP_test
where (transactionCode LIKE 'SELL%' OR transactionCode LIKE 'EX-S%') 
and GTSP != GS_same_period(form_id,1)
and GT < 0
-- and issuerCik > 1323715
;

drop table GTSP_test;



