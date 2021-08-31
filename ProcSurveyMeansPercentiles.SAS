
/*********************************************************************************
ProcSurveyMeansPercentiles.SAS
Topic: Generate descriptive statistics using PROC SURVEYMEANS 
 Wtitten by Pradip Muhuri
 Use the program at your own risk (no warranties).
**********************************************************************************/
LIBNAME pufmeps 'C:\Data';
Options nocenter nodate nonumber ls=132; 
proc format;
value povcat_fmt 
    1 = 'Poor'
    2,3 = 'Near Poor/Low Income'
	4 = 'Middle Income'
    5 = 'High Income';

Value inscov_fmt 
    1 = 'ANY PRIVATE'
    2 = 'PUBLIC ONLY'
	3 = 'UNINSURED';
run;

Data work.h209;
  set pufmeps.h209;
  if INSCOV18=3 then Unsinsured_d=1; else Unsinsured_d=0;
  if INSCOV18=3 then Unsinsured_s='Uninsured'; else Unsinsured_s='Insured';
  Label Unsinsured_d = 'Whether uninsured (1/0 variable)'
        Unsinsured_s = 'Whether uninsured (String variable)';
run;
ods graphics off;
PROC SURVEYMEANS DATA=work.h209 ;
    VAR totexp18  Unsinsured_d Unsinsured_s INSCOV18;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT18F;
	CLASS INSCOV18;
    FORMAT INSCOV18 INSCOV18_fmt.;
RUN;

PROC SURVEYMEANS DATA=pufmeps.h209 ;
    VAR totexp18;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT18F;
	DOMAIN POVCAT18;
    FORMAT POVCAT18 povcat_fmt.;
RUN;

ODS SELECT DOMAIN;
PROC SURVEYMEANS DATA=pufmeps.h209 ;
    VAR totexp18;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT18F;
	DOMAIN POVCAT18('High Income')*INSCOV18('ANY PRIVATE');    
	FORMAT POVCAT18 povcat_fmt.
           INSCOV18 inscov_fmt.;
 RUN;
ODS SELECT ALL;



PROC SURVEYMEANS DATA=pufmeps.h209 percentile=(25,50,75,90,95);
    VAR totexp18;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT18F;
	DOMAIN POVCAT18;
    FORMAT POVCAT18 povcat_fmt.;
RUN;

PROC SURVEYMEANS DATA=pufmeps.h209 percentile=(25,50,75,90,95);
    VAR totexp18;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT18F;
	DOMAIN POVCAT18;
    FORMAT POVCAT18 povcat_fmt.;
RUN;



ods select domainquantiles;
PROC SURVEYMEANS DATA=pufmeps.h209 nobs q1 median q3;
    VAR totexp18;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT18F;
	DOMAIN POVCAT18;
    FORMAT POVCAT18 povcat_fmt.;
	
RUN;

ods exclude all; /* To suppress the printed output */
PROC SURVEYMEANS DATA=pufmeps.h209 nobs mean stderr q1 median q3;
    VAR totexp18;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT18F;
	DOMAIN POVCAT18;
    FORMAT POVCAT18 povcat_fmt.;
	*Specify multiple ODS table names and SAS data sets names;
	ods output domain=mean_est domainquantiles=med_est;
   RUN;
ods select all; /* To restore the default printed output */
title 'Mean estimates';
proc print data=WORK.mean_est; 
 var POVCAT18   N  Mean  StdErr;
run;
title 'Percentile estimates';
proc print data=WORK.med_est; 
 var  POVCAT18 Percentile Estimate StdErr  LowerCL  UpperCL;
run;


ODS EXCLUDE ALL;
PROC SURVEYMEANS DATA=PUFMEPS.H209 NOBS SUMWGT SUM MEAN STDERR;
    VAR TOTEXP18 TOTSLF18 OBTOTV18;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT18F;
	DOMAIN POVCAT18;
    FORMAT POVCAT18 POVCAT_FMT.;
	ODS OUTPUT DOMAIN=WORK.DOMAIN_RESULTS;
RUN;
ODS SELECT ALL;
PROC PRINT DATA=WORK.DOMAIN_RESULTS (DROP=DOMAINLABEL)  
               NOOBS LABEL BLANKLINE=3 SPLIT='*';
LABEL POVCAT18 = 'FAMILY INCOME LEVEL'
      SUMWGT = 'SUM OF*THE WEIGHTS'
      SUM = 'ESTIMATED*POPULATION*TOTAL*VARIABLE*Y';
VAR POVCAT18 VARNAME N SUMWGT SUM STDDEV MEAN STDERR;
FORMAT N                      COMMA6.0
       SUMWGT   SUM    STDDEV COMMA17.0
       MEAN     STDERR        COMMA9.2
       POVCAT18               POVCAT_FMT. ;
RUN;


