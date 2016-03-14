select b.* from 
(
select * from issuerInfo
where YHOO_ticker is not null
group by YHOO_ticker
having count(distinct issuerCik) > 1
order by YHOO_ticker
) a, issuerInfo b
where a.YHOO_ticker = b.YHOO_ticker
order by YHOO_ticker
;

select count(distinct issuerCik) from issuerInfo
where YHOO_ticker = 'ACN';