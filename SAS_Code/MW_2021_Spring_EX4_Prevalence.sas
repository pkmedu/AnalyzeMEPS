
%LET RootFolder= C:\Data;
FILENAME MYLOG "&RootFolder\Exercise4_Prevalence_log.TXT";
FILENAME MYPRINT "&RootFolder\Exercise4_Prevalence_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;

/* Clears log, output, and ODSRESULTS from the previous run automatically */
DM "Log; clear; output; clear; odsresults; clear"; 
OPTIONS nocenter ps=58 ls=132 obs=max nodate nonumber varlenchk=nowarn ;

libname library 'C:\Data';
libname sds 'C:\Data';
%macro runit (ana_var, t);
title " 2014 PSAQ Survey, Analysis Variable: &t";
ods graphics off;
PROC SURVEYMEANS DATA=sds.MEPS_WShop_PSAQ nobs mean stderr sum ;
    VAR &ana_var;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT psaqwt;
	domain x_psaqage sex x_psaqage*r_edrecode2('Some College');
	format x_psaqage age_f. sex sex_fmt. r_edrecode2 edu2_fmt. ;
	ods select all ;
RUN;
%mend runit;
%runit (x_flushot, FluShotPastYear)
%runit (x_ofttobac, SmokeDailyPastYear)

proc printto;
run;





