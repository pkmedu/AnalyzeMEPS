/**********************************************************************************
PROGRAM:      EXERCISE1.SAS

DESCRIPTION:  THIS PROGRAM GENERATES THE FOLLOWING ESTIMATES ON NATIONAL HEALTH CARE EXPENSES, 2018:


               (1) MEAN AND MEDIAN EXPENSES, OVERALL
	           (2) PERCENTAGE OF PERSONS WITH AN EXPENSE, OVERALL AND BY AGE GROUP
	           (3) MEAN AND MEDIAN EXPENSE PER PERSON WITH AN EXPENSE, OVERALL AND BY AGE GROUP

	        
INPUT FILE:   C:\DATA\MySDS\H209.SAS7BDAT (2018 FULL-YEAR FILE)
*******************************************************************************************************/


proc datasets lib=work nolist kill; quit; /* Delete  all files in the WORK library */
OPTIONS nocenter LS=132 PS=79 NODATE FORMCHAR="|----|+|---+=|-/\<>*" PAGENO=1;

/*********************************************************************************
 IMPORTANT NOTE:  Use the next 5 lines of code, only if you want SAS to create 
    separate files for SAS log and output.  Otherwise comment  out these lines.
***********************************************************************************/

%LET RootFolder= C:\Mar2021\sas_exercises\Exercise_1;
FILENAME MYLOG "&RootFolder\Exercise1_log.TXT";
FILENAME MYPRINT "&RootFolder\Exercise1_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;

PROC FORMAT;
  VALUE AGECAT
       low-64 = '0-64'
	   65-high = '65+';

   VALUE totexp18_cate
      0         = 'No Expense'
      Other     = 'Any Expense';
RUN;
TITLE "MEPS FULL-YEAR CONSOLIDATED FILE, 2018";

%LET DataFolder = C:\DATA\MySDS;  /* Adjust the folder name, if needed */
libname CDATA "&DataFolder"; 
/* READ IN DATA FROM 2018 CONSOLIDATED DATA FILE (HC-209) */
DATA WORK.PUF209;
  SET CDATA.H209 (KEEP = TOTEXP18 AGELAST   VARSTR  VARPSU  PERWT18F panel);
     WITH_AN_EXPENSE= TOTEXP18;
	 AGELAST_X = AGELAST;
  RUN;
ODS HTML CLOSE; /* This will make the default HTML output no longer active,
                  and the output will not be displayed in the Results Viewer.*/

ods graphics off; /*Suppress the graphics */
ods listing; /* Open the listing destination*/
TITLE2 'PERCENTAGE OF PERSONS WITH AN EXPENSE and OVERALL HEALTH CARE EXPENSES, 2018';
PROC SURVEYMEANS DATA=WORK.PUF209 NOBS MEAN STDERR sum median ;
    VAR  WITH_AN_EXPENSE  ;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT18F;
	class WITH_AN_EXPENSE;
	FORMAT WITH_AN_EXPENSE TOTEXP18_CATE. ;
RUN;

TITLE2 'MEAN AND MEDIAN EXPENSE PER PERSON WITH AN EXPENSE, OVEALL and FOR AGES 0-64, AND 65+, 2018';
PROC SURVEYMEANS DATA= WORK.PUF209 NOBS MEAN STDERR sum median  ;
    VAR  totexp18;
	STRATUM VARSTR ;
	CLUSTER VARPSU ;
	WEIGHT  PERWT18F ;	
	DOMAIN WITH_AN_EXPENSE('Any Expense')*AGELAST;
	FORMAT WITH_AN_EXPENSE TOTEXP18_CATE. AGELAST agecat.;
RUN;

/* THE PROC PRINTTO null step is required to close the PROC PRINTTO,  only if used earlier.
   Otherswise. please comment out the next two lines */
PROC PRINTTO;
RUN;
