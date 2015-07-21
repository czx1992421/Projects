/************************************************************************************
 *                       Statistical Computing with SAS - Homework 3                *
 *                                   Author: Zhuxi Cai                              *
 ************************************************************************************/

/************************************************************************************
 *                                        Problem 1                                 *
 ************************************************************************************/
ODS RTF File='C:\Users\Jovial\Desktop\HW3.rtf';
/*Read the dataset and exclude the missing observations*/
data asthma;
      infile 'C:\Users\Jovial\Desktop\asthma.txt' missover;
      input ID trtmnt $ FEV_1 FEV_2 FEV_3 FEV_4;
run;
/*Test the normality assumption and perform significant test on the mean of first and fourth FEV*/
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
/*Create side-by-side boxplots for the three types of disease*/
proc sgplot data=Sicklecell;
vbox Hglevel / group=Type;
xaxis label="Type";
run; 
/*Test the model assumptions to check whether the hemoglobin levels differ significantly between patients with different types of disease*/ 
proc glm data = Sicklecell;
class Type;
model Hglevel=Type;
output out=new p=pred r=resid;
run;
proc univariate data=new normal;
var resid;
QQplot resid;
run;
/*Check which two groups are significantly different by using pairwise comparisons*/
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
/*Create a contrast to compare the hemoglobin levels of the HB SC group with the average hemoglobin levels of the other two types*/
proc glm data = Sicklecell;
class Type;
model Hglevel=Type;
contrast '3 vs 1 & 2' Type 1 1 -2;
estimate '3 vs 1 & 2' Type 1 1 -2;
run;

/************************************************************************************
 *                                        Problem 3                                 *
 ************************************************************************************/
/*Graphical explorations*/
proc sgplot data=Health;
scatter x=X y=Y;
run;
/*Model fitting and checking the model assumptions*/
proc reg data=Health;
model Y = X / clb; * change the alpha=0.10;
output out=lin p=pred r=res;
run;
/*Goodness of fit*/
proc univariate data=lin normal;
var res;
qqplot res;
run;
ODS RTF CLOSE;
