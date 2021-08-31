
/*********************************************************************************
ProcSurveyMeansPercentiles.SAS
Topic: Generate percentage distribution using PROC SURVEYFREQ 
 Wtitten by Pradip Muhuri
 Use the program at your own risk (no warranties).
**********************************************************************************/
LIBNAME pufmeps 'C:\Data';
Options nocenter nodate nonumber ls=132; 
proc format;
Value inscov_fmt 
    1 = 'ANY PRIVATE'
    2 = 'PUBLIC ONLY'
	3 = 'UNINSURED';
run;

ods graphics off;
PROC SURVEYFREQ DATA=pufmeps.h209 ;
    TABLES INSCOV18;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT18F;
	FORMAT INSCOV18 INSCOV18_fmt.;
RUN;


