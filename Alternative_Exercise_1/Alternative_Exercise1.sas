
/**********************************************************************************
PROGRAM:      ALTERNATIVE_EXERCISE1.SAS

DESCRIPTION:  THIS PROGRAM GENERATES THE FOLLOWING ESTIMATES ON NATIONAL HEALTH CARE EXPENSES, 2018:

	           (1) MEAN AND MEDIAN EXPENSES, OVERALL
	           (2) PERCENTAGE OF PERSONS WITH AN EXPENSE, OVERALL AND BY AGE GROUP
	           (3) MEAN AND MEDIAN EXPENSE PER PERSON WITH AN EXPENSE, OVERALL AND BY AGE GROUP

INPUT FILE:   C:\DATA\H209.SAS7BDAT (2018 FULL-YEAR FILE)
*********************************************************************************/;
/* IMPORTANT NOTES: Use the next 6 lines of code, if you want to specify an alternative destination for SAS log and 
SAS procedure output.*/

%LET MyFolder=C:\Mar2021\sas_exercises\Alternative_Exercise_1;
OPTIONS LS=132 PS=79 NODATE FORMCHAR="|----|+|---+=|-/\<>*" PAGENO=1;
FILENAME MYLOG "&MyFolder\Alternative_Exercise1_log.TXT";
FILENAME MYPRINT "&MyFolder\Alternative_Exercise1_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;

proc datasets lib=work nolist kill; quit; /* delete  all files in the WORK library */

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
ods graphics off;
ODS  SELECT NONE;
PROC SURVEYMEANS DATA=WORK.PUF209 NOBS SUMWGT MEAN MEDIAN  SUM ;
    VAR  WITH_AN_EXPENSE TOTEXP18 ;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT18F;
	CLASS WITH_AN_EXPENSE;
	FORMAT WITH_AN_EXPENSE TOTEXP18_CATE. ;
	ods output Statistics=work.Overall_MEAN
               QUANTILES=WORK.MEDIAN;
RUN;
proc print data=work.Overall_MEAN;
run;

ODS SELECT ALL; 
TITLE2 'PERCENTAGE OF PERSONS WITH AN EXPENSE';
proc print data=work.Overall_MEAN (firstobs=3) noobs split='*'; 
var   VARNAME mean StdErr  Sum stddev;
 label mean = 'Proportion with an Expense'
       StdErr = 'SE of Proportion'
       Sum = 'Persons*with Any*Expense'
       Stddev = 'STD of*Number*Persons*with*Any Expense';
       format mean Percent7.2 stderr Percent7.5
              sum Stddev comma19.;
run;
PROC PRINT DATA=MEDIAN; RUN;

TITLE2 'MEAN OVERALL EXPENSES';
proc print data=work.Overall_MEAN (obs=1) noobs split='*'; 
var   varname mean StdErr  Sum stddev;
 label  mean = 'Mean($)'
       StdErr = 'SE of Mean($)'
       Sum = 'Total*Expense ($)'
       Stddev = 'STD of*Total Expense($)';
       format mean stderr comma9. 
              sum Stddev comma19.;
run;

TITLE2 'MEDIAN OVERALL EXPENSES';
proc print data=work.median (obs=1) noobs split='*'; 
var varname Estimate StdErr;
 label Estimate = 'Median($)'
       StdErr = 'SE of Median($)';
       format Estimate stderr comma9. ;
run;

ODS GRAPHICS OFF;
ODS SELECT NONE; 
PROC SURVEYMEANS DATA=WORK.PUF209 NOBS SUMWGT MEAN MEDIAN  SUM ;
    VAR  WITH_AN_EXPENSE TOTEXP18 ;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT18F;
	DOMAIN AGELAST ;
	CLASS WITH_AN_EXPENSE;
	FORMAT WITH_AN_EXPENSE TOTEXP18_CATE. AGELAST AGECAT_fmt.;
	ods output Domain=work.Domain_MEAN
               DomainQuantiles=WORK.Domain_Median;
RUN;

PROC SORT DATA=work.DOMAIN_MEAN; BY VARNAME AGELAST; RUN;
ODS SELECT ALL; 
TITLE2 'PERCENTAGE OF PERSONS WITH AN EXPENSE BY AGE GROUP';
proc print data=work.DOMAIN_MEAN (obs=2)  noobs split='*';
var   AGELAST VARNAME mean StdErr  Sum stddev;
 label mean = 'Mean($)'
       StdErr = 'SE of Mean($)'
       Sum = 'SUM'
       Stddev = 'STD of*SUM';
       format mean dollar12. stderr 7.5
              sum Stddev dollar18.;
run;

PROC SORT DATA=work.DOMAIN_MEAN; BY VARNAME AGELAST; RUN;
ODS SELECT ALL; 
TITLE2 'MEAN HEALTH CARE EXPENSES BY AGE GROUP';
proc print data=work.DOMAIN_MEAN (obs=2)  noobs split='*';
var   AGELAST VARNAME mean StdErr  Sum stddev;
 label mean = 'Mean($)'
       StdErr = 'SE of Mean($)'
       Sum = 'SUM of Expenses'
       Stddev = 'STD of*SUM';
       format mean dollar12. stderr 7.5
              sum Stddev dollar18.;
run;

TITLE2 'PERCENTAGE OF PERSONS WITH AN EXPENSE BY AGE GROUP';
proc print data=work.DOMAIN_MEAN (firstobs=3)  noobs split='*';
var   AGELAST varlevel Mean StdErr  Sum stddev;
 label mean = 'Proportion'
       StdErr = 'SE of Proportion'
       Sum = 'SUM'
       Stddev = 'STD of*SUM';
       format mean percent7.1 stderr Percent7.3
              sum Stddev comma12. ;
run;

TITLE2 'MEDIAN HEALTH CARE EXPENSES BY AGE GROUP';
proc print data=work.DOMAIN_MEDIAN (obs=2)  noobs split='*';
var   AGELAST VARNAME Estimate StdErr;
 label Estimate = 'Median($)'
       StdErr = 'SE of Median($)';
          format Estimate stderr dollar12.;
run;

/* THE PROC PRINTTO null step is required to close the PROC PRINTTO */
PROC PRINTTO;
RUN;
