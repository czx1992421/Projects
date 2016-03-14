-- Check dollarvolume
select a.form_id, a.issuerName, a.issuerTradingSymbol, a.rptOwnerName, a.officertitle, a.acceptedDate, a.acceptedTime, a.transactionCode, a.issuerCik, a.rptOwnerCik, a.investorType, a.accessionNumber, b.dollarvolume, dollarvolume(b.form_id,30) as dollarvolume_check
from form_info_new a, add_form_info b
where a.form_id = b.form_id
and b.dollarvolume = dollarvolume(b.form_id,30)
;