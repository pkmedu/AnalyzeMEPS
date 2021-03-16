
/*********************************************************************************
* Topic: How to do finite population correction in PROC SURVEYMEANS ESTIMATES 
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/

options nocenter nodate nonumber ls=155 ps=72; 
PROC FORMAT;
  VALUE AGECAT_fmt
       low-64 = '0-64'
	   65-high = '65+';

   VALUE totexp18_cate
      0         = 'No Expense'
      Other     = 'Any Expense';
RUN;
TITLE1 "NATIONAL HEALTH CARE EXPENSES, 2018";
%LET DataFolder = C:\DATA\MySDS;  /* Adjust the folder name, if needed */
libname CDATA "&DataFolder"; 


/* READ IN DATA FROM 2018 CONSOLIDATED DATA FILE (HC-209) */
DATA WORK.PUF209;
  SET CDATA.H209 (KEEP = TOTEXP18 AGELAST   VARSTR  VARPSU  PERWT18F panel);
     WITH_AN_EXPENSE = TOTEXP18;
	 AGELAST_X = AGELAST;
  RUN;

  *** How to constuct the data set containing the population totals in the strata;
proc summary data=WORK.PUF209 nway;
class varstr;
OUTPUT OUT=WORK.Totals (drop=_TYPE_ rename=(_freq_=_Total_));
run;

* Generate estimates without finite population correction;
ods graphics off;
title 'MEPS 2018, Without finite population correction';
PROC SURVEYMEANS DATA=WORK.PUF209 NOBS MEAN STDERR SUM;
    VAR  WITH_AN_EXPENSE TOTEXP18 ;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT18F;
	CLASS WITH_AN_EXPENSE;
	FORMAT WITH_AN_EXPENSE TOTEXP18_CATE. ;
 RUN;

* Generate estimates with finite population correction;
* Option total= added;

title 'MEPS 2018, With finite population correction';
PROC SURVEYMEANS DATA=WORK.PUF209 NOBS MEAN STDERR SUM total=Totals;
    VAR  WITH_AN_EXPENSE TOTEXP18 ;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT18F;
	CLASS WITH_AN_EXPENSE;
	FORMAT WITH_AN_EXPENSE TOTEXP18_CATE. ;
 RUN;



