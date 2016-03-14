-- Run very quickly
-- WA, @dollarvalue_min<dollarvalue<@dollarvalue_max, @dollarvolume_min<dollarvolume<@dollarvolume_max or null, @mktcap_avg_min<mktcap<@mktcap_avg_max or null, @return2w_min<return2w<@return2w_max, @winrate2w_min<winrate2w<@winrate2w_max, n2w_min<n2w<n2w_max, transactionPrice>@transactionPrice, no duplicate, last_buy>@last_buy, @beg_date<time_restriction<@end_date
-- investorType can be ajusted
-- date difference between acceptedDate and transactionDate should be less than 90, or there must be something wrong in our database

set 
@dollarvalue_min = 10000, @dollarvalue_max = 1E+9,        # the minimum transactionvalue of insider you are willing to consider
@dollarvolume_min = 2, @dollarvolume_max = 1E+9,          # represents minimum dollarvolume (in millions) including nulls by default, this is calculated from capiq table which has data up to may 2015
@rtn_min = 0.05, @rtn_max = 1000,               
@winrate_min = 0.8, @winrate_max = 1,
@n_min = 3, @n_max = 1000, 
@transactionPrice_min = 1, @transactionPrice_max = 2000,  #The minimum transaction price (this restriction is used so we don't consider penny/small cap stocks)
@beg_date = '2004-01-01', @end_date = '2015-05-13',       #Range of Databse that you would like to use
@last_buy_min = 0, @last_buy_max = 1000,				  #two opitons--> '1' inducates duplicate companys (Issuers) in same group are only shown once,  '100' indicated duplicate companys (Issuers) in same group are only shown each time
@mktcap_avg_min = 30, @mktcap_avg_max = 1E+12;            #take average of 30 day market cap in million

CREATE TABLE test AS SELECT *,
    EARNINGS_RETURN(form_id),
    EARNINGS_RETURN_2(form_id),
    EARNINGS_RETURN_1W(form_id),
    EARNINGS_RETURN_1W_2(form_id),
    MORNING(form_id),
    FRIDAY(form_id) FROM
    form_info_new
WHERE
    form_id IN (SELECT 
            form_id
        FROM
            tmpResults
        WHERE
			    (transactionCode LIKE '%BUY%' OR transactionCode = 'EX-B')
                AND return3MonthWA between @rtn_min and @rtn_max
                AND win3Month between @winrate_min and @winrate_max
                AND n3Month between @n_min and @n_max)
		AND (investorType = 1 OR investorType = 2 OR investorType = 3)
        AND dollarValue between @dollarvalue_min and @dollarvalue_max
        AND (DOLLARVOLUME(form_id, 30) between @dollarvolume_min and @dollarvolume_max
        OR DOLLARVOLUME(form_id, 30) IS NULL)
        AND (mktcap_avg(form_id, 30) between @mktcap_avg_min and @mktcap_avg_max
		OR mktcap_avg(form_id, 30) IS NULL)
        AND (transactionPrice between @transactionPrice_min and @transactionPrice_max)
GROUP BY issuerCik
HAVING COUNT(issuerCik) = 1
    AND acceptedDate > @beg_date
	AND acceptedDate < @end_date
;

-- Add new columns from capiq and tmpResults
SELECT 
    p.*,
    cap.adjusted_all_close AS adjusted_all_close_ciq,
    cap.Volume AS Volume_ciq,
    cap.market_cap AS market_cap_ciq,
    tmp.return1DayWA,
    tmp.return1weekWA,
    tmp.return2weekWA,
    tmp.return3weekWA,
    tmp.return1MonthWA,
    tmp.return2MonthWA,
    tmp.return3MonthWA,
    tmp.return6MonthWA,
    tmp.return1YearWA,
    tmp.alpha1DayWA,
    tmp.alpha1weekWA,
    tmp.alpha2weekWA,
    tmp.alpha3weekWA,
    tmp.alpha1MonthWA,
    tmp.alpha2MonthWA,
    tmp.alpha3MonthWA,
    tmp.alpha6MonthWA,
    tmp.alpha1YearWA,
    tmp.win1Day,
    tmp.win1week,
    tmp.win2week,
    tmp.win3week,
    tmp.win1Month,
    tmp.win2Month,
    tmp.win3Month,
    tmp.win6Month,
    tmp.win1Year,
    tmp.n1Day,
    tmp.n1week,
    tmp.n2week,
    tmp.n3week,
    tmp.n1Month,
    tmp.n2Month,
    tmp.n3Month,
    tmp.n6Month,
    tmp.n1Year
FROM
	test p
        LEFT JOIN
    tmpResults tmp ON p.form_id = tmp.form_id
        LEFT JOIN
    capiq cap ON p.issuerCik = cap.issuerCik
        AND p.acceptedDate = cap.date
	where (Last_Buy(p.form_id) between @last_buy_min and @last_buy_max)
    AND (datediff(p.acceptedDate,p.transactionDate) between 0 and 90)
;

drop table test;