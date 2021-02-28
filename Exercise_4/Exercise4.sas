
%LET RootFolder= C:\Mar2021\sas_exercises\Exercise_4;
FILENAME MYLOG "&RootFolder\Exercise4_log.TXT";
FILENAME MYPRINT "&RootFolder\Exercise4_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;
options obs=max nocenter nodate nonumber formchar="|----|+|---+=|-/\<>*" ;

/*******************************************************************
* RUN logistic regression model (PROC SURVEYLOGISTIC) Predictors of the receipt of flu shot
********************************************************************/

PROC FORMAT;

value age18p_f 
    18-high = '18+'
    other = '0-17';


value age_f 
    18-34 = '18-34'
    35-64 = '35-64'
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

 
		   
value povcat_fmt
   1 = 'POOR' 
   2 = 'NEAR POOR'
   3 = 'LOW INCOME'
   4 = 'MIDDLE INCOME'  
   5 = 'HIGH INCOME' ;
 
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
    DOMAIN  agelast('18+')*POVCAT18;
	format agelast age18p_f. flushot  POVCAT18  POVCAT_fmt.;
RUN;

PROC SURVEYLOGISTIC DATA=meps_2018;
    STRATUM VARSTR;
     CLUSTER VARPSU;
   WEIGHT saqwt18f;
    CLASS sex(ref='Male')
               RACETHX  (ref='NH White only')
               POVCAT18 (ref='HIGH INCOME')
			   INSCOV18 (ref='Any Private') /param=glm;
         model flushot(ref= '0')= sex RACETHX  POVCAT18 INSCOV18;
     lsmeans povcat18 /diff ilink; 
	 format agelast age18p_f. 
      sex sex_fmt. 
      RACETHX racethx_fmt. 
      INSCOV18 INSCOV18_fmt.
      POVCAT18  POVCAT_fmt.;
    RUN;

	
   
	********************* reproduce Emily's results ;
	PROC SURVEYLOGISTIC DATA=meps_2018;
    STRATUM VARSTR;
     CLUSTER VARPSU;
   WEIGHT saqwt18f;
    CLASS sex(ref='Male')
               RACETHX  (ref='Hispanic')
               INSCOV18 (ref='Any Private') ;
         model flushot(ref= '0')= agelast sex RACETHX  INSCOV18;
      format agelast age18p_f. 
      sex sex_fmt. 
      RACETHX racethx_fmt. 
      INSCOV18 INSCOV18_fmt.;
    RUN;

proc printto;
run;
