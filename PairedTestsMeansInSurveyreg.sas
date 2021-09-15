
/*********************************************************************************
PairedTestsMeansInSurveyreg.sas
Topic: Compare the mean of totexp18 for domains   
Wtitten by Pradip Muhuri
Use the program at your own risk (no warranties).
**********************************************************************************/

LIBNAME pufmeps 'C:\Data';
Options nocenter nodate nonumber ls=132; 
proc format;
value povcat_fmt 
    1,2,3 = 'Poor-Low Income'
    4 = 'Middle Income'
    5 = 'High Income';
run;

ods graphics off; /* To suppress the graphics */
ods select ParameterEstimates Estimates;
PROC SURVEYREG DATA=pufmeps.h209;
   	class POVCAT18  ;
    model totexp18= POVCAT18 / noint solution vadjust=none;
	STRATUM VARSTR;
	CLUSTER VARPSU;
	WEIGHT PERWT18F;
	estimate 'POVCAT18: High Income vs Middle Income' POVCAT18 1 -1 0;
	estimate 'POVCAT18: Middle Income vs Low/Poor Income' POVCAT18 0 1 -1;
    estimate 'POVCAT18: High Income vs Low/Poor Income' POVCAT18 1 0 -1;
	FORMAT POVCAT18 povcat_fmt.;
RUN;
ODS SELECT ALL;

