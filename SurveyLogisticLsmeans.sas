
/*********************************************************************************
* Topic: Generating LSMEANS estimates using PROC SURVEYLOGITIC 
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/



/* Clear log, output, and ODSRESULTS from the previous run automatically */
DM "Log; clear; output; clear; odsresults; clear";
proc datasets lib=work nolist kill; quit; /* Delete  all files in the WORK library */

OPTIONS NOCENTER LS=155 PS=79 NODATE FORMCHAR="|----|+|---+=|-/\<>*" PAGENO=1;

/* Create use-defined formats and store them in a catalog called FORMATS 
   in the work folder. They will be deleted at the end of the SAS session.
*/

PROC FORMAT;

value age18p_f 
    18-high = '18+'
    other = '0-17';

value age_f 
    18-34 = '18-49'
    35-64 = '50-64'
	65-High ='65+';

value ADFLST42_fmt
    -15 = "Cann't be computed"
	-1 = 'Inapplicable'
    1  = 'Yes'
	0,2  ='No';


value sex_fmt   1 = 'Male'
                2 = 'Female'; 
			

VALUE Racethx_fmt
  1 = 'Hispanic'
  2 = 'NH White only'
  3 = 'NH Black only'
  4 = 'NH Asian only'
  5 = 'NH Other etc';

 value INSCOV18_fmt
   1 = 'Any Private'
   2 = 'Public Only'
   3 = 'Uninsured';
run;

%LET DataFolder = C:\DATA\MySDS;  /* Adjust the folder name, if needed */
libname CDATA "&DataFolder"; 
%let kept_vars_2018 =  VARSTR VARPSU perwt18f saqwt18f ADFLST42  AGELAST RACETHX POVCAT18 INSCOV18 SEX;
data meps_2018;
 set CDATA.h209 (keep= &kept_vars_2018);
 
if ADFLST42 = 1 then flushot =1;
else if ADFLST42 = 2 then flushot =0;
else flushot =.;
run;

title " 2018 MEPS";

ods graphics off;
ods select domain;
PROC SURVEYMEANS DATA=meps_2018 nobs mean stderr ;
    VAR flushot;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT saqwt18f;
    DOMAIN agelast('18+')  agelast('18+')*INSCOV18;
	format agelast age18p_f. INSCOV18 INSCOV18_fmt.;
RUN;




/* The following code snippet is optional with the param=glm option on the CLASS statement
and a LSMEANS statement with oddsratio diff ilink options */

title 'Logistic Regression Model 1 Unadjusted';
	PROC SURVEYLOGISTIC DATA=meps_2018 ;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT saqwt18f;
    CLASS  INSCOV18 (ref='Any Private')/param=glm;
         model flushot(Event='1')=  INSCOV18;
	lsmeans INSCOV18 /oddsratio diff ilink;
	      format agelast age18p_f. INSCOV18 INSCOV18_fmt.;
    RUN;
ods trace on;	
title 'Logistic Regression Model 2 Adjusted';
ods select all;
	PROC SURVEYLOGISTIC DATA=meps_2018 ;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT saqwt18f;
    CLASS  agelast(ref='18-49') sex(ref='Male') RACETHX(ref='NH White only') 
           INSCOV18 (ref='Any Private') /param=glm;
         model flushot(Event= '1')= agelast sex RACETHX  INSCOV18;
	lsmeans INSCOV18 /oddsratio diff ilink;
      format agelast age_f. 
      sex sex_fmt. 
      RACETHX racethx_fmt. 
      INSCOV18 INSCOV18_fmt.;
    RUN;
ods trace off;
