/************************************************************************************
 *                       Statistical Computing with SAS - Homework 2                *
 *                                   Author: Zhuxi Cai                              *
 ************************************************************************************/

/************************************************************************************
 *                                        Problem 1                                 *
 ************************************************************************************/
data FEV;
infile 'C:\Users\Jovial\Desktop\FEV.csv' dsd;
input Id Age FEV Hgt Sex Smoke;
run;
data FEV_new;
set FEV;
log_FEV=log(FEV);
format log_FEV 6.3;
run;
proc sgplot data=FEV_new;
vbox log_FEV;
keylegend / title="log_FEV";
run;
proc sgplot data=FEV_new;
vbox FEV;
keylegend / title="FEV";
run;
proc sgplot data=FEV_new;
histogram log_FEV;
density log_FEV;
density log_FEV / type=kernel;
run;
proc sgplot data=FEV_new;
histogram FEV;
density FEV;
density FEV / type=kernel;
run;
proc univariate data=FEV_new;
var log_FEV;
histogram log_FEV;
inset n normal(ksdpval) / pos = ne;
run;
proc univariate data=FEV_new;
var FEV;
histogram FEV;
inset n normal(ksdpval) / pos = ne;
run;
proc means data=FEV_new mean std median qrange min max;
class Sex;                         
var Age log_FEV;
run;
proc freq data=FEV_new;
tables Sex*Smoke / norow nocol nocum;
run;
data FEV_new0;
set FEV_new;
if Age ge 3 and Age le 4 then Age0='Preschool Aged';
else if Age ge 5 and Age le 13 then Age0='School Aged';
else if Age gt 13 and Age lt 18 then Age0='Teen';
else Age0='Adult';
run;
proc format;
value Sexf 1='Male'
           0='Female';
value Smokef 1='Current Smoker'
             0='Non-Smoker';
run;
ods html file='C:\Users\Jovial\Desktop\HW2\HW2.html';
proc tabulate data=FEV_new0 missing noseps;
class Age0 Sex Smoke;
var FEV;
table (Age0='' ALL),(Sex='')*(Smoke='')*(FEV='')*(n*f=4. median*f=5.2) / RTS=25 
      box='Effect of Smoking on FEV';
format Sex Sexf. Smoke Smokef.;
run; 
ods html close;

/************************************************************************************
 *                                        Problem 2                                 *
 ************************************************************************************/

data Temp;
input City $10. temp1-temp6 3.;
cards;
New York  75 72 78 73 68 75
Tokyo     65 76 70 64 86 76
London    56 64 76 72 65 66
Melbourne 71 84 82 75 82 74
;
run;
proc print data=Temp;
run;
data Temp_new;
set Temp;
array temp{6} temp1-temp6;
array celsius_temp{6} Celsius_temp1-Celsius_temp6;
do i=1 to 6;
   celsius_temp{i}=round((temp{i}-32)/1.8);
end;
drop i;
run;
proc print data=Temp_new;
run;
proc report data=Temp_new windows headline ls=80;
column City temp1-temp6 tempave Celsius_temp1-Celsius_temp6 Ctempave;
define City / descending order group;
define tempave / computed "Average Fahrenheit" width=10 format=4.1;
compute tempave;
   tempave=(temp1+temp2+temp3+temp4+temp5+temp6)/6;
endcomp;
define Ctempave / computed "Average Celsius" width=7 format=4.1;
compute Ctempave;
   Ctempave=(Celsius_temp1+Celsius_temp2+Celsius_temp3+Celsius_temp4+Celsius_temp5+Celsius_temp6)/6;
endcomp;
define temp1-temp6 / display noprint;
define Celsius_temp1-Celsius_temp6 / display noprint;
break after City / dol;
title 'September temperature report';
run;
%macro STATS(dataset,vargroup1,vargroup2);
  proc means data=&dataset n mean stddev min max maxdec=1;
  var &vargroup1 &vargroup2;
  run;
%mend STATS;
%STATS(Temp_new,temp1-temp6,celsius_temp1-celsius_temp6);


