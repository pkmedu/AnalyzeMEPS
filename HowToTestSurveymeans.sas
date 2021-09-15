
/*********************************************************************************
HowToTestSurveyMeans.SAS
Topic: Perform statistical tests with PROC SURVEYMEANS 
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
run;

ods graphics off; /* To suppress the graphics */
PROC SURVEYMEANS DATA=pufmeps.h209;
    VAR  totexp18;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT18F;
	DOMAIN POVCAT18 / diffmeans ;
    FORMAT POVCAT18 povcat_fmt.;
RUN;

ods exclude summary statistics;
 PROC SURVEYMEANS DATA=pufmeps.h209 ;
    VAR totexp18;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT18F;
    DOMAIN POVCAT18 / adjust=bon ;
    FORMAT POVCAT18 povcat_fmt.;
 run;
ods exclude none;

/* SAS Documentation
CLDIFF requests t type confidence limits for each difference of domain means. You can specify the confidence
level alpha in the ALPHA= option in the PROC SURVEYMEANS statement. By default, alpha = D 0:05,
which produces 95% confidence limits. If you specify the ADJUST=BON option, then the adjusted
confidence limits for Bonferroni multiplicity are also displayed.
This option also invokes the DIFFMEANS option.
 */

 /* To suppress printed output for Summary and Statistics*/
ods select domaindiffs; /* To disply printed output for CLDIFF */
 PROC SURVEYMEANS DATA=pufmeps.h209 ;
    VAR totexp18;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT18F;
    DOMAIN POVCAT18 / CLDIFF;
    FORMAT POVCAT18 povcat_fmt.;
 run;

ods select domaindiffs; /* To disply printed output for Domaindiffs/CLDIFF */
 PROC SURVEYMEANS DATA=pufmeps.h209 ;
    VAR totexp18;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT18F;
    DOMAIN POVCAT18 / ADJUST=BON CLDIFF;
    FORMAT POVCAT18 povcat_fmt.;
 run;
ods select all;
