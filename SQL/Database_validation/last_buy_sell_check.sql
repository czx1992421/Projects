-- Check Last_Buy
select a.form_id, a.issuerName, a.issuerTradingSymbol, a.rptOwnerName, a.officertitle, a.acceptedDate, a.acceptedTime, a.transactionCode, a.issuerCik, a.rptOwnerCik, a.investorType, a.accessionNumber, b.lastbuy, Last_Buy(b.form_id) as Last_buy
from form_info_new a, add_form_info b
where a.form_id = b.form_id
and (a.transactionCode = 'BUY' OR a.transactionCode = 'EX-B' OR a.transactionCode = '10b5-1-BUY') 
and b.lastbuy != Last_Buy(b.form_id)
-- and b.lastbuy != -1
;

-- Check Last_Sell
select a.form_id, a.issuerName, a.issuerTradingSymbol, a.rptOwnerName, a.officertitle, a.acceptedDate, a.acceptedTime, a.transactionCode, a.issuerCik, a.rptOwnerCik, a.investorType, a.accessionNumber, b.lastsell, Last_Sell(b.form_id) as Last_sell
from form_info_new a, add_form_info b
where a.form_id = b.form_id
and (a.transactionCode LIKE 'SELL%' OR a.transactionCode LIKE 'EX-S%' 
OR a.transactionCode = '10b5-1-EX-S' OR a.transactionCode like '10b5-1-SELL%'
)
and b.lastsell != Last_Sell(b.form_id)
-- and b.lastsell != -1
;