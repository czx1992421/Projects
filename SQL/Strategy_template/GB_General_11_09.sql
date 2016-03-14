-- @GB_min<GB<@GB_max, @dollarvalue_min<dollarvalue<@dollarvalue_max, num(CEO CFO COO)>@num_insider, @dollarvolume_min<dollarvolume<@dollarvolume_max or null, same_period=@same_period, transactionPrice>@transactionPrice, @var20_min<var20<@var20_max, @var90_min<var90<@var90_max, @var180_min<var180<@var180_max, last_buy>@last_buy, @mktcap_avg_min<mktcap<@mktcap_avg_max or null, @beg_date<time_restriction<@end_date, 
-- no_duplicate=1 means no duplicate, no_duplicate=100 means duplicate
-- investorType can be ajusted
-- date difference between acceptedDate and transactionDate should be less than 90, or there must be something wrong in our database

set 
@GB_min = 3, @GB_max = 100,			     			      # The minimum mount of people in a group you are willing to consider
@dollarvalue_min = 10000, @dollarvalue_max = 1E+9,        # the minimum transactionvalue of insider you are willing to consider
@num_insider = 1,									 	  # represent the # of insiders  
@dollarvolume_min = 2, @dollarvolume_max = 1E+9,	      # represents minimum dollarvolume (in millions) including nulls by default, this is calculated from capiq table which has data up to may 2015
@same_period = 1, 									      # '1' indicated that the entire group transactions are between 430pm in day 1 and before 930am in day 2, (day 1= accepted date), '0' indicated that Group buys are limited to 30 days which is default value calculated in 'GT' column.
@transactionPrice_min = 1, @transactionPrice_max = 2000,  #The minimum transaction price (this restriction is used so we don't consider penny/small cap stocks)
@var20_min = -100, @var20_max = 1000,
@var90_min = -100, @var90_max = 1000,
@var180_min = -100, @var180_max = 1000,  		          #varX indicated the change in price of the companys (Issuers) in the previous X days from transaction date,  the variable is set to the lower limit, by default Null fields are included to change this go down in the query
@beg_date = '2004-01-01', @end_date = '2015-05-13',       #Range of Databse that you would like to use
@no_duplicate = 1,									      #two opitons--> '1' inducates duplicate companys (Issuers) in same group are only shown once,  '100' indicated duplicate companys (Issuers) in same group are only shown each time
@last_buy_min = 0, @last_buy_max = 1000,			      #Days since the previous buy
@mktcap_avg_min = 30, @mktcap_avg_max = 1E+12;            #take average of 30 day market cap in million


CREATE TABLE test AS SELECT a.* FROM
    form_info_new a,
    form_info_new b
WHERE
    a.form_id IN (SELECT 
            a.form_id
        FROM
            form_info_new a,
            form_info_new b
        WHERE
            a.form_id NOT IN (SELECT 
                    a.form_id
                FROM
                    form_info_new a,
                    form_info_new b
                WHERE
                    a.form_id IN (SELECT 
                            a.form_id
                        FROM
                            form_info_new a,
                            form_info_new b
                        WHERE
                            a.issuerTradingSymbol NOT IN ('NONE','None','none','N/A','N/a','n/a','NA')
                                AND a.GT between @GB_min and @GB_max
                                AND a.dollarValue between @dollarvalue_min and @dollarvalue_max
                                AND a.investorType > 0
                                AND a.issuerCik = b.issuerCik
								AND a.acceptedDate > @beg_date
                                AND a.acceptedDate < @end_date
                                AND (b.transactionCode = 'BUY' OR b.transactionCode = 'EX-B' OR b.transactionCode = '10b5-1-BUY')
                                AND b.investorType > 0
                                AND b.dollarValue between @dollarvalue_min and @dollarvalue_max
                                AND b.acceptedDate > @beg_date
                                AND b.acceptedDate < @end_date
                                AND SAME_PERIOD(a.form_id, b.form_id) >= @same_period
                        GROUP BY a.form_id
                        HAVING COUNT(DISTINCT b.rptOwnerCik) between @GB_min and @GB_max)
                        AND a.issuerCik = b.issuerCik
                        AND (b.transactionCode LIKE 'SELL%' OR b.transactionCode LIKE 'EX-S%')
                        AND SAME_PERIOD(a.form_id, b.form_id) >= @same_period
                GROUP BY a.form_id
                HAVING COUNT(b.form_id) > 0)
                
                
                AND a.form_id IN (SELECT 
                    a.form_id
                FROM
                    form_info_new a,
                    form_info_new b
                WHERE
                    a.issuerTradingSymbol NOT IN ('NONE','None','none','N/A','N/a','n/a','NA')
                        AND a.GT between @GB_min and @GB_max
                        AND a.dollarValue between @dollarvalue_min and @dollarvalue_max
                        AND a.investorType > 0
                        AND a.issuerCik = b.issuerCik
                        AND (b.transactionCode = 'BUY' OR b.transactionCode = 'EX-B' OR b.transactionCode = '10b5-1-BUY')
                        AND b.investorType > 0
                        AND b.dollarValue between @dollarvalue_min and @dollarvalue_max
                        AND SAME_PERIOD(a.form_id, b.form_id) >= @same_period
						AND a.acceptedDate > @beg_date
				        AND a.acceptedDate < @end_date
                        AND b.acceptedDate > @beg_date
				        AND b.acceptedDate < @end_date
                GROUP BY a.form_id
                HAVING COUNT(DISTINCT b.rptOwnerCik) between @GB_min and @GB_max)
                AND a.issuerCik = b.issuerCik
                AND (b.transactionCode = 'BUY' OR b.transactionCode = 'EX-B' OR b.transactionCode = '10b5-1-BUY')
                AND b.dollarValue between @dollarvalue_min and @dollarvalue_max
                AND (b.investorType = 1 OR b.investorType = 2
                OR b.investorType = 3)
                AND SAME_PERIOD(a.form_id, b.form_id) >= @same_period
				AND b.acceptedDate > @beg_date
				AND b.acceptedDate < @end_date
        GROUP BY a.form_id
        HAVING COUNT(DISTINCT b.rptOwnerCik) >= @num_insider)
        AND a.issuerCik = b.issuerCik
        AND (b.transactionCode = 'BUY' OR b.transactionCode = 'EX-B' OR b.transactionCode = '10b5-1-BUY')
        AND b.investorType > 0
        AND b.dollarValue between @dollarvalue_min and @dollarvalue_max
        AND SAME_PERIOD(a.form_id, b.form_id) >= @same_period
GROUP BY a.form_id
HAVING COUNT(DISTINCT b.transactionDate, b.transactionPrice) >= COUNT(DISTINCT b.rptOwnerCik)
    OR COUNT(DISTINCT b.transactionDate, b.transactionPrice) between @GB_min and @GB_max
;


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
    (SELECT 
        *,
            EARNINGS_RETURN(form_id),
            EARNINGS_RETURN_2(form_id),
            EARNINGS_RETURN_1W(form_id),
            EARNINGS_RETURN_1W_2(form_id),
            MORNING(form_id),
            FRIDAY(form_id),
            count_insider(form_id)
    FROM
        test
    WHERE
        form_id IN (SELECT 
                a.form_id
            FROM
                test a, test b
            WHERE
                a.issuerCik = b.issuerCik
                    AND SAME_PERIOD(a.form_id, b.form_id) >= @same_period
            GROUP BY a.form_id
            HAVING COUNT(b.form_id) <= @no_duplicate)
            AND 
            (DOLLARVOLUME(form_id, 30) between @dollarvolume_min and @dollarvolume_max
            OR DOLLARVOLUME(form_id, 30) IS NULL)
            AND (transactionPrice between @transactionPrice_min and @transactionPrice_max)
			AND var20 between @var20_min and @var20_max
            AND var90 between @var90_min and @var90_max
            AND var180 between @var180_min and @var180_max
            AND (Last_Buy(form_id) between @last_buy_min and @last_buy_max)
            AND (mktcap_avg(form_id, 30) between @mktcap_avg_min and @mktcap_avg_max
            OR mktcap_avg(form_id, 30) IS NULL)) AS p
        LEFT JOIN
    tmpResults tmp ON p.form_id = tmp.form_id
        LEFT JOIN
    capiq cap ON p.issuerCik = cap.issuerCik
        AND p.acceptedDate = cap.date
	where (datediff(p.acceptedDate,p.transactionDate) between 0 and 90)
;

drop table test;