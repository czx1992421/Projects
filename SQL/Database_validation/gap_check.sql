-- check gap in capiq
select a.*
from
(
select b.*, a.gap_check
from 
(
select a.*, ((a.adj_price2*a.open_price2/a.close_price2)/a.adjusted_all_close-1) as gap_check
from 
(
select a.*, b.adjusted_dividend_open as open_price2, b.adjusted_dividend_close as close_price2, b.adjusted_all_close as adj_price2
from capiq a, capiq b
where a.issuerCik=b.issuerCik
and a.issuerCik = '72205'
and datediff(b.`date`,a.`date`)>0
group by a.issuerCik, a.`date`
) a
-- where issuerCik = '72205'
order by a.`date`
) a, capiq b
where a.issuerCik=b.issuerCik
and datediff(b.`date`,a.`date`)>0
group by a.issuerCIk, a.`date`
) a
where abs(a.gap-a.gap_check)>0.0001
;

-- check gap in yahoo
select a.*
from
(
select b.*, a.gap_check
from 
(
select a.*, ((a.adj_price2*a.open_price2/a.close_price2)/a.adj-1) as gap_check
from 
(
select a.*, b.open as open_price2, b.close as close_price2, b.adj as adj_price2
from yahoo_price a, yahoo_price b
where a.issuerCik=b.issuerCik
and a.issuerCik = '72205'
and datediff(b.`date`,a.`date`)>0
group by a.issuerCik, a.`date`
) a
-- where issuerCik = '72205'
order by a.`date`
) a, yahoo_pricec b
where a.issuerCik=b.issuerCik
and datediff(b.`date`,a.`date`)>0
group by a.issuerCIk, a.`date`
) a
where abs(a.gap-a.gap_check)>0.0001
;
