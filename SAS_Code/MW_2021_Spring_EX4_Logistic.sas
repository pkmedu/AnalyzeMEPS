
%LET RootFolder= C:\Data;
FILENAME MYLOG "&RootFolder\Exercise4_Logistic_log.TXT";
FILENAME MYPRINT "&RootFolder\Exercise4_Logistic_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;

/* Clear log, output, and ODSRESULTS from the previous run automatically */
DM "Log; clear; output; clear; odsresults; clear"; 
OPTIONS nocenter ps=58 ls=132 obs=max nodate nonumber varlenchk=nowarn ;

libname library 'C:\Data';
libname sds 'C:\Data';


%macro runit (depvar, t);
ods select NObs OddsRatios FitStatistics;
title "PSAQ Survey, 2014, Dependent Variable: &t";
PROC SURVEYLOGISTIC DATA=sds.MEPS_WShop_PSAQ ;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT psaqwt;
	CLASS  x_psaqage (ref='Ages 35-64') sex (reference='Male') 
           r_edrecode2(ref='Up to High School') 
           r_racethx2 (ref='NH White Only')
		   marital_s(ref='Currently Married')
		   obv10_plus(ref='0-9 Office-based visits') ;
	model &depvar(ref= '0')= x_psaqage sex r_edrecode2 r_racethx2 marital_s
         obv10_plus;
    format x_psaqage age_f. sex sex_fmt.
           r_edrecode2 edu2_fmt. 
           r_racethx2 Racethx2_fmt.
           marital_s marital_fmt. 
           obv10_plus obv10_p_fmt.;
  
	RUN;
%mend runit;
%runit(x_flushot, FluShotPastYear)
%runit(x_ofttobac, SmokeDailyPastYear)

PROC PRINTTO;
RUN;

