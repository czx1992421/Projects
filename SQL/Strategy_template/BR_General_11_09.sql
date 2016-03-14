-- BR, @dollarvalue_min<dollarvalue<@dollarvalue_max, @dollarvolume_min<dollarvolume<@dollarvolume_max or null, @mktcap_avg_min<mktcap<@mktcap_avg_max or null, CEO CFO COO, @reversal_min<reversal<@reversal_max, transactionPrice>@transactionPrice, @var20_min<var20<@var20_max, @var90_min<var90<@var90_max, @var180_min<var180<@var180_max, @beg_date<time_restriction<@end_date
-- investorType can be ajusted
-- date difference between acceptedDate and transactionDate should be less than 90, or there must be something wrong in our database

set 
@dollarvalue_min = 10000, @dollarvalue_max = 1E+9,        # the minimum transactionvalue of insider you are willing to consider
@dollarvolume_min = 2, @dollarvolume_max = 1E+9,          # represents minimum dollarvolume (in millions) including nulls by default, this is calculated from capiq table which has data up to may 2015 
@reversal_min = 20, @reversal_max = 1E+9,
@transactionPrice_min = 1, @transactionPrice_max = 2000,  #The minimum transaction price (this restriction is used so we don't consider penny/small cap stocks)
@beg_date = '2004-01-01', @end_date = '2015-05-13',       #Range of Databse that you would like to use
@mktcap_avg_min = 30, @mktcap_avg_max = 1E+12,            #take average of 30 day market cap in million
@var20_min = -100, @var20_max = 1000,
@var90_min = -100, @var90_max = 1000,
@var180_min = -100, @var180_max = 1000;  		          #varX indicated the change in price of the companys (Issuers) in the previous X days from transaction date,  the variable is set to the lower limit, by default Null fields are included to change this go down in the query

CREATE TABLE test AS SELECT p.*,
    EARNINGS_RETURN(p.form_id),
    EARNINGS_RETURN_2(p.form_id),
    EARNINGS_RETURN_1W(p.form_id),
    EARNINGS_RETURN_1W_2(p.form_id),
    MORNING(p.form_id),
    FRIDAY(p.form_id) FROM
    form_info_new p
WHERE
        p.dollarValue between @dollarvalue_min and @dollarvalue_max
        AND p.issuerTradingSymbol NOT IN ('NONE','None','none','N/A','N/a','n/a','NA')
        AND (p.investorType = 1 OR p.investorType = 2 OR p.investorType = 3)
        AND (DOLLARVOLUME(p.form_id, 30) between @dollarvolume_min and @dollarvolume_max
        OR DOLLARVOLUME(p.form_id, 30) IS NULL)
        AND (mktcap_avg(form_id, 30) between @mktcap_avg_min and @mktcap_avg_max
		OR mktcap_avg(form_id, 30) IS NULL)
        AND reversal between @reversal_min and @reversal_max
        AND (transactionPrice between @transactionPrice_min and @transactionPrice_max)
        AND p.acceptedDate > @beg_date
        AND p.acceptedDate < @end_date
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
WHERE p.var20 between @var20_min and @var20_max
AND p.var90 between @var90_min and @var90_max
AND p.var180 between @var180_min and @var180_max
AND (datediff(p.acceptedDate,p.transactionDate) between 0 and 90)
;

drop table test;
