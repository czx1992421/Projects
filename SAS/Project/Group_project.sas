/*******************************************************
*             P6110 - Final Group Project              *
********************************************************/

********************************************************
*                    Problem 1                         *
********************************************************;
data Forecast1;
set Forecast;
if forecast_error =. then delete;
run;
proc univariate data=Forecast1 normal;
var forecast_error;
histogram forecast_error;
qqplot forecast_error;
run;
proc means data=Forecast1 noprint;
var forecast_error;
output out=error mean=error_mean std=error_std n=n;
run;
proc surveyselect data=Forecast1 out=error_samples seed=45921 rep=500 sampsize=211 method=urs outhits;
run;
proc means data=error_samples noprint;
var forecast_error;
by Replicate;
output out=bootout mean=mean stderr=stderr;
run;
data error;
set error;
one=1;
keep one error_mean error_std n;
run;
data bootout;
set bootout;
one=1;
run;
data bootout;
merge error bootout;
by one;
zb=(mean-error_mean)/stderr;
run;
proc univariate data=bootout noprint;
var zb;
output out=outpct1 pctlpre=P_ pctlpts=2.5 97.5;
run;
data outpct1;
set outpct1;
one=1;
run;
data outpct1;
merge error outpct1;
by one;
run;
data outpct1;
set outpct1;
lower=error_mean-P_97_5*error_std/sqrt(n);
upper=error_mean-P_2_5*error_std/sqrt(n);
run;
proc print data=outpct1;
var lower upper;
run;
proc univariate data=bootout normal;
var mean;
histogram mean;
qqplot mean;
run;

