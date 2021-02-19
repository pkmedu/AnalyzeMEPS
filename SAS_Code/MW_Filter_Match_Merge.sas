
/*********************************************************************************************
LEDARNING TOPICS: Filtering and Match-Merging SAS Data Sets 

Goal: Add PSAQ frame variables to the PSAQ study respondents
- Filter the PSAQ frame data set (H163 - 2013 MEPS Full Year Consolidated File) based on the following criteria (conditions)
         (1) MEPS Panel 18 (Round 1-3 by default) 
         (2) 34 years of age or older as of December 31
         (3) in-scope as of December 31
         (4) received a full year person-level weight
- Sort both data sets by DUPERSID  
- Use the MERGE statement with a BY statement to match-merge observations from both SAS data sets 
  into a single obdervation in a new SAS data set based on DUPERSID

- Ensure that all observations (n = 2,185) in the PSAQ data set are kept in the PSAQ analytic data file

**********************************************************************************************/
%LET RootFolder= C:\Data;
FILENAME MYLOG "&RootFolder\Filter_Match_Merge_Data_log.TXT";
FILENAME MYPRINT "&RootFolder\Filter_Match_Merge_Data_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;


/* Clear log, output, and ODSRESULTS from the previous run automatically */
DM "Log; clear; output; clear; odsresults; clear";

/* Delete all files in the WORK library */
proc datasets lib=work nolist kill; quit; 

options nocenter nodate nonumber obs=max formchar="|----|+|---+=|-/\<>*";
libname library 'C:\Data';
libname sds 'C:\Data';    /* Assign libref to the output SAS data set */

/* Use LIBRARY= option only specifies libref to store formats
   permanently in libref.formats */

proc format LIBRARY=library;

value age_f 
    35-64 = 'Ages 35-64'
	65-High ='Ages 65+';

value resp53_fmt 1 = 'Self-Respondent'
                  2 = 'Household Proxy'; 

value sex_fmt   1 = 'Male'
                2 = 'Female'; 
			

VALUE Racethx2_fmt
  1 = 'NH White Only'
  2 = 'Racial/Ethnic Minority' ;

 value edu2_fmt 
	       1 = 'Up to High School'
		   2 = 'Some College';
		   
value povcat_fmt
   1 = 'P/NPR/LOW INCOME' 
   2 = 'MIDDLE INCOME'  
   3 = 'HIGH INCOME' 
   4 = 'Missing';

 
  VALUE HEALTH_fmt
      1='EXCELLENT/VERY GOOD' 
      2 ='GOOD' 
      3='FAIR/POOR' 
      4='MISSING';


  value Marital_fmt
	    1 = 'Currently Married'
		2 = 'Wid-Div-Sep'
		3 = 'Never married';

  value emp_fmt 1 = 'Employed'
              2 = 'Not Employed';

  value fms_fmt 1 = '1 Person'
                2 =  '2 Persons'
				3 =  '3 Persons'
				4 =  '4+ Persons';

  VALUE inscov_fmt
        1='ANY PRIVATE'
        2='PUBLIC ONLY'
        3='UNINSURED';

  value obv10_p_fmt 1 = '10+ Office-based visits'
            2 = '0-9 Office-based visits';

  value region_fmt
      1 = 'Northeast'
	  2 = 'Midwest'
	  3 = 'South'
	  4 = 'West';

  
run;


*** Create a macro variable that holds variable names from the 20113 MEPS;

%let kept_vars = dupersid resp53 perwt13f varstr varpsu agelast sex INSURC13
                 edrecode povcat13 racethx resp53 RTHLTH53 totexp13
				 OBVEXP13 OPTEXP13 ERTEXP13  IPTEXP13 RXEXP13
				 MARRY53X FAMSZE53 EMPST53 REGION53
				 inscov13 obtotv13 IPNGTD13
                 panel insc1231;

**** Create a temporary SAS data file (PSAQ Frame) with source and derived variables 
				 from the 2013 MEPS Full Year File based on certain conditions;

 /* PUFMEPS below is the iibref to the input data set, which is assigned in the AUTOEXEC.SAS file */
 /*%put %str(%sysfunc(getoption(autoexec))); */

Data work.PSAQ_Frame_2013;
  set pufmeps.h163 (keep=&kept_vars
                     where = (panel = 18 
                              & insc1231=1
                              & agelast >=34 
                              & perwt13f>0 )
                    ); 

		  *** Racethx_x variable (Dichotomous);
		  if racethx =2 then r_racethx2 = 1;
		  else if racethx in (1,3,4,5) then r_racethx2 = 2;
		  else if racethx in (-7,-8,-9) then r_racethx2 = .;
		  

         *** New education variable (dichotomous);
		  if edrecode in (1,2,13) then r_edrecode2=1; /* up to high school */
          else if edrecode in (14,15,16) then r_edrecode2=2;   /* Some College  */
          else if edrecode in (-1,-7,-8,-9) then r_edrecode2 = .; /* Missing/NA */

         
         *** Marital Status;
		  if MARRY53X in (-7,-8,-9,6) then marital_s = .;
		  else if MARRY53X in (1,7) then marital_s = 1;
		  else if MARRY53X in (2,3,4,8,9,10) then marital_s = 2;
		  else if MARRY53X = 5 then marital_s = 3;


         	  
         *** Family size;
         if FAMSZE53 = 1 then d_famscat=1;
		 else if FAMSZE53  = 2 then d_famscat=2;
         else if FAMSZE53  = 3 then d_famscat=3;
		 else if FAMSZE53 >=4 then d_famscat=4;

         *** Employment status;
		 if EMPST53 =1 then empstat13=1;
		 else if EMPST53 in (2,3,4) then empstat13=2;  /*Need to check */

		     *** New POVCAT variable;
		  if povcat13 in (1,2,3 ) then r_povcat = 1;
		  else if povcat13 =4 then r_povcat = 2;
		  else if povcat13 =5 then r_povcat = 3;
          else if povcat13 in (-7,-8,-9) then r_povcat = 4;

       
         *** Region;
		 r_region = region53;
		 if region53 = -1 then r_region = .;

		 * New Perceived health status variable;

		  if RTHLTH53 in (1,2) then health = 1;
		  else if RTHLTH53 = 3 then health = 2;
		  else if RTHLTH53 in (4,5) then health = 3;
		  else if RTHLTH53 in (-7,-8,-9) then health = 4;

         *** office-based provider visits;
         	if obtotv13 >=10 then obv10_plus=1;
           else obv10_plus = 2;

         
  run;

* Sort the data files before merging them in a DATA step;
proc sort data=PSAQ_Frame_2013; by dupersid; 
run;
proc sort data=pufmeps.h173 out=work.PSAQ_data;  /* Create a temporary sorted data set */
   by dupersid; 
run;

* Create a PSAQ analytic data file by mergeing the PSAQ data file with the FRAME data file;

data sds.MEPS_WShop_PSAQ;
  merge work.psaq_data (in=a)
        work.PSAQ_Frame_2013; by dupersid;

		* Create a new PSAQ age  variable replacing -9 with a value from age53x;		 
  x_psaqage = psaqage;
  if psaqage = -9 then x_psaqage=age53x;

  * Create a new flushot variable ;		 
  if flushot = 1 then x_flushot = 1;
  else if flushot = 2 then x_flushot = 0;
  else if flushot = -9 then x_flushot = .;

  * Create a Smoke_Every_day variable;
  
  if ofttobac = -9 then x_ofttobac = .;
  else if ofttobac = 1 then x_ofttobac = 1;
  else if ofttobac in (2,3) then x_ofttobac = 0;



  if a;     /* uniquely identifies the source data set and keeps the same number 
               of observations in the output data set */
run;

title '2014 PSAQ Analytic File - Frequency Tables for Selected Variables';
proc freq data=sds.MEPS_WShop_PSAQ;
tables resp53 sex r_racethx2 r_edrecode2 marital_s d_famscat empstat13 r_povcat r_region health inscov13 obv10_plus;
format 
	resp53 resp53_fmt.
	sex sex_fmt.
	r_racethx2 Racethx2_fmt.
	r_edrecode2 edu2_fmt.
	marital_s marital_fmt.
	d_famscat fms_fmt.
	empstat13 emp_fmt.
	r_povcat povcat_fmt.
	r_region region_fmt.
	health  health_fmt.
	inscov13 inscov_fmt.
	obv10_plus obv10_p_fmt.;
run;


*** Check the range of variables in the data set create;
*proc means data=sds.MEPS_WShop_PSAQ; 
*run;

proc printto;
run;
