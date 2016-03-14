-- Check num of insider in same period 
create table test as
select * 
from form_info_new
order by rand()
limit 10000;

select a.form_id, a.issuerName, a.issuerTradingSymbol, a.rptOwnerName, a.officertitle, a.acceptedDate, a.acceptedTime, a.transactionCode, a.issuerCik, a.rptOwnerCik, a.investorType, a.accessionNumber, b.num_insider_same_period, num_insider_same_period_buy(b.form_id) as numSP
from test a, add_form_info b
where a.form_id = b.form_id
and (a.transactionCode = 'BUY' OR a.transactionCode = 'EX-B' OR a.transactionCode = '10b5-1-BUY') 
and b.num_insider_same_period != num_insider_same_period_buy(b.form_id)
;

select a.form_id, a.issuerName, a.issuerTradingSymbol, a.rptOwnerName, a.officertitle, a.acceptedDate, a.acceptedTime, a.transactionCode, a.issuerCik, a.rptOwnerCik, a.investorType, a.accessionNumber, b.num_insider_same_period, num_insider_same_period_sell(b.form_id) as numSP
from form_info_new a, add_form_info b
where a.form_id = b.form_id
and (a.transactionCode LIKE 'SELL%' OR a.transactionCode LIKE 'EX-S%' 
OR a.transactionCode = '10b5-1-EX-S' OR a.transactionCode like '10b5-1-SELL%'
)
and b.num_insider_same_period != num_insider_same_period_sell(b.form_id)
;

-- Check num of insider in one day
select a.form_id, a.issuerName, a.issuerTradingSymbol, a.rptOwnerName, a.officertitle, a.acceptedDate, a.acceptedTime, a.transactionCode, a.issuerCik, a.rptOwnerCik, a.investorType, a.accessionNumber, b.num_insider_1D, num_insider_1D_buy(b.form_id) as numSP
from form_info_new a, add_form_info b
where a.form_id = b.form_id
and (a.transactionCode = 'BUY' OR a.transactionCode = 'EX-B' OR a.transactionCode = '10b5-1-BUY') 
and b.num_insider_1D != num_insider_1D_buy(b.form_id)
;

select a.form_id, a.issuerName, a.issuerTradingSymbol, a.rptOwnerName, a.officertitle, a.acceptedDate, a.acceptedTime, a.transactionCode, a.issuerCik, a.rptOwnerCik, a.investorType, a.accessionNumber, b.num_insider_1D, num_insider_1D_sell(b.form_id) as numSP
from form_info_new a, add_form_info b
where a.form_id = b.form_id
and (a.transactionCode LIKE 'SELL%' OR a.transactionCode LIKE 'EX-S%' 
OR a.transactionCode = '10b5-1-EX-S' OR a.transactionCode like '10b5-1-SELL%'
)
and b.num_insider_1D != num_insider_1D_sell(b.form_id)
;
