/*DM 'Clear Log; Clear Output;';*/
options nocenter nodate nonumber ls=132;
proc datasets lib=work nolist kill; 
quit; /* delete  all files in the WORK library */
libname CDATA "C:\DATA";

PROC FORMAT;
  VALUE AGECAT
        0-64 = '0-64'
       65-high = '65+';

   VALUE totexp17_x
       0-high     = 'Any Expense'
       other      = 'None';
RUN;
TITLE "MEPS FULL-YEAR CONSOLIDATED FILE, 2017";

/* READ IN DATA FROM 2017 CONSOLIDATED DATA FILE (HC-201) */
DATA WORK.PUF201;
  SET CDATA.H201 (KEEP = TOTEXP17 AGELAST VARSTR  VARPSU  PERWT17F);
       /* Create a new TOTEXP17_X variable */
       TOTEXP17_x = TOTEXP17; 
run;
ODS HTML CLOSE; /* This will make the default HTML output no longer active,
                  and the output will not be displayed in the Results Viewer.*/
ods graphics off; /*Suppress the graphics */
ods listing; /* Open the listing destination*/
TITLE2 'PERCENTAGE OF PERSONS WITH AN EXPENSE & OVERALL EXPENSES';
PROC SURVEYMEANS DATA=WORK.PUF201 NOBS SUMWGT MEAN STDERR SUM;
    VAR  TOTEXP17;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT17F;
RUN;

TITLE2 'MEAN EXPENSE PER PERSON WITH AN EXPENSE, FOR OVERALL, AGE 0-64, AND AGE 65+';
ODS EXCLUDE STATISTICS; /* Not to generate output for the overall population */
PROC SURVEYMEANS DATA= WORK.PUF201 NOBS SUMWGT MEAN STDERR SUM ;
    VAR  TOTEXP17;
    STRATUM VARSTR ;
    CLUSTER VARPSU ;
    WEIGHT  PERWT17F ;
    DOMAIN TOTEXP17_X('Any Expense')  TOTEXP17_X('Any Expense')*AGELAST ;
    FORMAT TOTEXP17_X TOTEXP17_X. AGELAST agecat. ;
RUN;
