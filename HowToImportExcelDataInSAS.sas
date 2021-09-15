
/*********************************************************************************
* Topic: How to import Excel data into SAS 
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/
options validvarname=any nocenter nodate number ls=255
 obs=max  orientation=landscape;
%let path=C:\AnalyzeMEPS\qc_2019cond1.xlsx;
proc import datafile="&path" 
  dbms=xlsx replace out=cond_16_19;
  sheet="Sheet1";
  getnames=YES;
 run;
/* proc contents data=work.cond_16_19; run; */
proc sort data=work.cond_16_19;    
  by descending exp19;; run;
proc print data=work.cond_16_19 (drop=DIFF:);
var condition pop19 exp19 Mean19 Event19;
*format N: exp: Event: comma16.;
where condition = 'Mental disorders';
run;
