-- reversal between 7 and 540 is reversal = 0
-- reversal != 0

select b.*,a.datediff from form_info_new b,
(
select b.*, max(datediff(a.acceptedDate,b.acceptedDate)) as datediff from 
form_info_new a, form_info_new b
where a.issuerCik = b.issuerCik
and a.rptOwnerCik = b.rptOwnerCik
and a.acceptedDate < b.acceptedDate
and (a.transactionCode = '10b5-1-BUY' or a.transactionCode = 'BUY' or a.transactionCode = 'EX-B') 
and (b.reversal<0)
-- and (b.transactionCode = '10b5-1-SELL' or b.transactionCode = 'SELL' or b.transactionCode = '10b5-1-EX-S' or b.transactionCode = 'EX-S')
group by b.issuerCik, b.rptOwnerCik, b.form_id
) a
where b.form_id = a.form_id
and b.reversal-a.datediff != 0
and a.datediff > -540
;

select b.*,a.datediff from form_info_new b,
(
select b.*, min(datediff(b.acceptedDate,a.acceptedDate)) as datediff from 
form_info_new a, form_info_new b
where a.issuerCik = b.issuerCik
and a.rptOwnerCik = b.rptOwnerCik
and a.acceptedDate < b.acceptedDate
-- and (b.transactionCode = '10b5-1-BUY' or b.transactionCode = 'BUY' or b.transactionCode = 'EX-B') 
and (b.reversal>0)
and (a.transactionCode = '10b5-1-SELL' or a.transactionCode = '10b5-1-EX-S' or a.transactionCode LIKE 'SELL%' OR a.transactionCode LIKE 'EX-S%')
group by b.issuerCik, b.rptOwnerCik, b.form_id
) a
where b.form_id = a.form_id
and b.reversal-a.datediff != 0
-- and b.transactionCode = 'BUY'
and a.datediff between 7 and 540
;

-- reversal = 0

select * from
(
select a.form_id, a.issuerName, a.issuerTradingSymbol, a.rptOwnerName, a.officertitle, a.acceptedDate, a.acceptedTime, a.transactionCode, a.issuerCik, a.rptOwnerCik, a.reversal, a.accessionnumber, b.lastbuy, b.lastsell
from form_info_new a, add_form_info b
where a.form_id = b.form_id
and a.reversal = 0
and (a.transactionCode = '10b5-1-BUY' or a.transactionCode = 'BUY' or a.transactionCode = 'EX-B'
or a.transactionCode = '10b5-1-SELL' or a.transactionCode = '10b5-1-EX-S' or a.transactionCode LIKE 'SELL%' OR a.transactionCode LIKE 'EX-S%')
-- and b.lastbuy > 0
-- and b.lastsell > 0
) a
where (a.transactionCode = '10b5-1-SELL' or a.transactionCode = '10b5-1-EX-S' or a.transactionCode LIKE 'SELL%' OR a.transactionCode LIKE 'EX-S%')
and lastsell < 0
and lastbuy between 8 and 540
;

select * from
(
select a.form_id, a.issuerName, a.issuerTradingSymbol, a.rptOwnerName, a.officertitle, a.acceptedDate, a.acceptedTime, a.transactionCode, a.issuerCik, a.rptOwnerCik, a.reversal, a.accessionnumber, b.lastbuy, b.lastsell
from form_info_new a, add_form_info b
where a.form_id = b.form_id
and a.reversal = 0
and (a.transactionCode = '10b5-1-BUY' or a.transactionCode = 'BUY' or a.transactionCode = 'EX-B'
or a.transactionCode = '10b5-1-SELL' or a.transactionCode = '10b5-1-EX-S' or a.transactionCode LIKE 'SELL%' OR a.transactionCode LIKE 'EX-S%')
-- and b.lastbuy > 0
-- and b.lastsell > 0
) a
where (a.transactionCode = '10b5-1-BUY' or a.transactionCode = 'BUY' or a.transactionCode = 'EX-B')
and lastbuy < 0
and lastsell between 8 and 540
;