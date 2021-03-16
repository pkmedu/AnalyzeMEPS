
/*********************************************************************************
* Topic: How to create and print ODS tables from PPROC SURVEYMEANS 
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

%LET DataFolder = C:\DATA\MySDS;  /* Adjust the folder name, if needed */
libname CDATA "&DataFolder"; 

/* READ IN DATA FROM 2018 CONSOLIDATED DATA FILE (HC-209) */

/* The LIBNAME statement that assigns a libref to the input SAS data set
   is in the AUTOEXEC.SAS, not included here */

DATA WORK.PUF209;
  SET PUFMEPS.H209 (KEEP = TOTEXP18 AGELAST   VARSTR  VARPSU  PERWT18F panel);
     WITH_AN_EXPENSE = TOTEXP18;
	 AGELAST_X = AGELAST;
  RUN;
ods graphics off;
ODS  EXCLUDE ALL;  /* Suppress SAS Output */
PROC SURVEYMEANS DATA=WORK.PUF209 NOBS SUMWGT MEAN SUM ;
    VAR  WITH_AN_EXPENSE TOTEXP18 ;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT18F;
	CLASS WITH_AN_EXPENSE;
	FORMAT WITH_AN_EXPENSE TOTEXP18_CATE. ;
	ods output Statistics=work.Overall_MEAN;  /* Create ODS Output */          
RUN;

ODS SELECT ALL;

TITLE 'MEAN OVERALL EXPENSES';
proc print data=work.Overall_MEAN (firstobs=3) noobs split='*'; 
var   VARNAME mean StdErr  Sum stddev;
 label mean = 'Proportion with an Expense'
       StdErr = 'SE of Proportion'
       Sum = 'Persons*with Any*Expense'
       Stddev = 'STD of*Number*Persons*with*Any Expense';
       format mean Percent7.2 stderr Percent7.5
              sum Stddev comma19.;
run;

TITLE 'MEAN OVERALL EXPENSES';
proc print data=work.Overall_MEAN (obs=1) noobs split='*'; 
var   varname mean StdErr  Sum stddev;
 label  mean = 'Mean($)'
       StdErr = 'SE of Mean($)'
       Sum = 'Total*Expense ($)'
       Stddev = 'STD of*Total Expense($)';
       format mean stderr comma9. 
              sum Stddev comma19.;
run;
title;
