/*********************************************************************************
* Topic: How to test differrences in means for continuous variables 
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/


DM "Log; clear; output; clear; odsresults; clear";
proc datasets lib=work nolist kill; quit; /* Delete  all files in the WORK library */
OPTIONS NOCENTER LS=155 PS=79 NODATE NONUMBER FORMCHAR="|----|+|---+=|-/\<>*" PAGENO=1;


proc format;
value sex_fmt 1 = 'Male'
              2 = 'Female';
value povcat_fmt 
    1 = 'Poor'
    2,3 = 'Near Poor/Low Income'
	4 = 'Middle Income'
    5 = 'High Income';
run;

/* The LIBNAME statement that assigns a libref to the input SAS data set
   is in the AUTOEXEC.SAS, not included here */
Data work.h209;
  set pufmeps.h209 (keep= dupersid sex POVCAT18 totexp18 varstr varpsu PERWT18F);
run;

ods html close;
ods listing;
**** Generating and directly printing results including statistical tests;
ods graphics off; /*Suppress the graphics */
PROC SURVEYMEANS DATA=work.h209;
    VAR  totexp18;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT18F;
	domain sex/diffmeans;
	format sex sex_fmt.;
 RUN;

ods graphics off; /*Suppress the graphics */
ods exclude summary statistics; /* Suppress printed output for Summary ;*/
PROC SURVEYMEANS DATA=work.h209;
    VAR  totexp18;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT18F;
	domain sex*POVCAT18('High Income')/diffmeans;
	format sex sex_fmt. POVCAT18 povcat_fmt.;
 RUN;


* ADJUST=BON also automatically invokes DIFFMEANS;

 PROC SURVEYMEANS DATA=work.h209 ;
    VAR totexp18;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT18F;
    DOMAIN POVCAT18 / adjust=bon ;
    FORMAT POVCAT18 povcat_fmt.;
 run;


/* SAS Documentation
CLDIFF requests t type confidence limits for each difference of domain means. You can specify the confidence
level ? in the ALPHA= option in the PROC SURVEYMEANS statement. By default, ? D 0:05,
which produces 95% confidence limits. If you specify the ADJUST=BON option, then the adjusted
confidence limits for Bonferroni multiplicity are also displayed.
This option also invokes the DIFFMEANS option.
 */

ods graphics off;
ods exclude summary statistics;
ods select domaindiffs; /*to disply printed output for Domaindiffs/CLDIFF;*/
 PROC SURVEYMEANS DATA=work.h209 ;
    VAR totexp18;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT18F;
    DOMAIN POVCAT18 / adjust=bon CLDIFF;
    FORMAT POVCAT18 povcat_fmt.;
 run;


