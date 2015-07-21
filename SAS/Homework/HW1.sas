/************************************************************************************
 *                       Statistical Computing with SAS - Homework 1                *
 *                                   Author: Zhuxi Cai                              *
 ************************************************************************************/

/************************************************************************************
 *                                        Problem 1                                 *
 ************************************************************************************/ 
*Create a permanent SAS data set called Bobsled2014 
data Bobsled2014;
input Lastname $9. Firstname $8. Status $1. +1 Time1 Time2 Time3 Time4 Date MMDDYY10.;
datalines;
Jones    Joseph  P 87 63 55 58 01-01-2014
Robinson Kristin A 89 72 91 71 01-11-2014
Coggins  Daniel  A 77 78 86 74 02-13-2014
Lappi    John    P 67 56 61 59 02-09-2014
Giavardi Nicole  A 88 99 78 97 01-10-2014
Rainey   Samuel  A 78 78 92 85 01-05-2014
Smith    Jacob   P 64 52 49 62 01-11-2014
;
run;
proc print data=Bobsled2014;
format Date MMDDYY10.;
run;
libname Jovial'C:\Users\Jovial\Desktop\Jovial';
data Jovial.Bobsled2014;
set Bobsled2014;
run;
*Create a format for 'Status'
proc format;
value $Status 'A'='Amateur'
              'P'='Professional';
run;
*Sort the data by 'Status' and 'Last Name'
proc sort data=Bobsled2014;
by Status;
run;
proc sort data=Bobsled2014;
by Lastname;
run;
*Create a new variable called 'Ave_run'
data Bobsled2014_1;
set Bobsled2014;
if Status eq 'A' then Avg_run=(Time2+Time3+Time4)/3 ;
else if Status eq 'P' then Avg_run=(Time1+Time2+Time3+Time4)/4;
Avg_run=round(Avg_run,0.01);
run;
*Print the dataset
data Bobsled2014_2;
set Bobsled2014_1 (KEEP = Lastname Firstname Status Avg_run);
run;
proc print data=Bobsled2014_2;
title 'Bobsled2014';
run;
proc format;
value $Status 'A'='Amateur'
              'P'='Professional';
run;

/************************************************************************************
 *                                        Problem 2                                 *
 ************************************************************************************/
*Input two data sets and merge them 
data BP_Values;
infile 'C:\Users\Jovial\Desktop\BP_Values.csv' dsd;
input Id Sys1 Dias1 Sys2 Dias2 Sys3 Dias3;
run;
data BP_Trt;
infile 'C:\Users\Jovial\Desktop\BP_Trt.csv' dsd;
input Id Trtgrp;
run;
data combine;
merge BP_Values Bp_Trt;
by Id;
run;
*Check the contents 
proc contents data=combine;
run;
*Create 'AVG_SYS' and 'AVG_DIA' variables
data combine_1;
set combine;
AVG_SYS=(Sys1+Sys2+Sys3)/3;
AVG_DIA=(Dias1+Dias2+Dias3)/3;
AVG_SYS=round(AVG_SYS,0.01);
AVG_DIA=round(AVG_DIA,0.01);
run;
*Create 'AVG_BP' variable
data combine_2;
set combine_1;
AVG_BP=AVG_DIA+(AVG_SYS-AVG_DIA)/3;
AVG_BP=round(AVG_BP,0.01);
run;
*Create a subset containing only the patients that have an average blood pressure greater than or equal to 85
data combine_3;
set combine_2;
if AVG_BP<85 then delete;
run;
data combine_4;
set combine_3 (KEEP = Id AVG_BP);
run;
proc print data=combine_4
    style(data)={background=yellow};
	var Id;                                               
	var AVG_BP/style(data)={font_style=italic font_weight=bold};
	title 'IDs and average blood pressure';
run;
