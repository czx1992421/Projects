select b.issuerCik，b.accessionNumber from
(
select b.* from
(
select *
from form_info_new
where (transactionCode = '10b5-1-BUY' or transactionCode = 'BUY' or transactionCode = 'EX-B'
or transactionCode = '10b5-1-SELL' or transactionCode = '10b5-1-EX-S' or transactionCode LIKE 'SELL%' OR transactionCode LIKE 'EX-S%')
group by accessionNumber
having count(form_id) = 2
) a, form_info_new b
where a.accessionNumber = b.accessionNumber
and b.form_id like '%0'
and (b.transactionCode = '10b5-1-BUY' or b.transactionCode = 'BUY' or b.transactionCode = 'EX-B')
) a, form_info_new b
where a.accessionNumber = b.accessionNumber
;