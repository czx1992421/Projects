-- Check eps_info
select count(*) from eps_info
where `date` >= '2015-05-01'
;

select *, earnings_1D_yahoo(issuerCik, date, earnings_date), earnings_1w_yahoo(issuerCik, date, earnings_date), earnings_1D(issuerCik, date, earnings_date), earnings_1w(issuerCik, date, earnings_date)
from eps_info
where (abs(eps1D-earnings_1D_yahoo(issuerCik, date, earnings_date))>0.001
or abs(eps1Week-earnings_1w_yahoo(issuerCik, date, earnings_date))>0.001
)
and `date` >= '2015-05-01'
order by `date`
;