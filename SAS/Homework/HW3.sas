/************************************************************************************
 *                       Statistical Computing with SAS - Homework 3                *
 *                                   Author: Zhuxi Cai                              *
 ************************************************************************************/

/************************************************************************************
 *                                        Problem 1                                 *
 ************************************************************************************/
ODS RTF File='C:\Users\Jovial\Desktop\HW3.rtf';
data asthma;
      infile 'C:\Users\Jovial\Desktop\asthma.txt' missover;
      input ID trtmnt $ FEV_1 FEV_2 FEV_3 FEV_4;
run;
data asthma1;
	set asthma;
	if FEV_1=. or FEV_2=. or FEV_4=. or FEV_4=. then delete;
run;
data asthma2;
	set asthma1;
	if trtmnt='A' then delete;
run;
proc univariate data=asthma2 normal;
var FEV_1 FEV_4;
histogram FEV_1 FEV_4;
qqplot FEV_1 FEV_4;
run;
 proc ttest data=asthma2; 
 paired FEV_1*FEV_4;
 run;
proc univariate data=asthma1 normal;
histogram FEV_4;
qqplot FEV_4;
class trtmnt;
run;
proc ttest data=asthma1;
class trtmnt;
var FEV_4;
run;

/************************************************************************************
 *                                        Problem 2                                 *
 ************************************************************************************/
proc sgplot data=Sicklecell;
vbox Hglevel / group=Type;
xaxis label="Type";
run; 
proc glm data = Sicklecell;
class Type;
model Hglevel=Type;
output out=new p=pred r=resid;
run;
proc univariate data=new normal;
var resid;
QQplot resid;
run;
proc glm data = Sicklecell;
class Type;
model Hglevel=Type;
means Type/ HOVTEST=BF; 
run;
proc glm data = Sicklecell;
class Type;
model Hglevel=Type;
means Type/ tukey; 
run;
proc glm data = Sicklecell;
class Type;
model Hglevel=Type;
contrast '3 vs 1 & 2' Type 1 1 -2;
estimate '3 vs 1 & 2' Type 1 1 -2;
run;

/************************************************************************************
 *                                        Problem 3                                 *
 ************************************************************************************/
proc sgplot data=Health;
scatter x=X y=Y;
run;
proc reg data=Health;
model Y = X / clb; * change the alpha=0.10;
output out=lin p=pred r=res;
run;
proc univariate data=lin normal;
var res;
qqplot res;
run;
ODS RTF CLOSE;
