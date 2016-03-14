select count(distinct issuerCik) from
(
select *, count(earnings_date) as frequence
from capiq
where earnings_date > 0
group by issuerCik, year(`date`)
) a
where frequence > 4
;

select * from
(
select *, count(earnings_date) as frequence
from capiq
where earnings_date > 0
group by issuerCik, year(`date`)
) a
where frequence > 4
;

select count(distinct issuerCik) 
from capiq;

select 3021/12730;

select distinct a.* from
(
select distinct a.* from
(
select * from
(
select *, sum(earnings_date) as frequence
from capiq
group by issuerCik, year(`date`)
-- having sum(earnings_date) = 0
) a
group by issuerCik
having sum(frequence) = 0
) a, form_info_new b
where a.issuerCik = b.issuerCik
and a.market_cap > 50
and b.issuerTradingSymbol NOT IN ('NONE','None','none','N/A','N/a','n/a','NA')
) a, form_info_new b
where a.issuerCik = b.issuerCik
and b.transactionPrice is not null
and b.acceptedDate = '2015-04-30'
;