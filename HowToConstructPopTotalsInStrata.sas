

/*********************************************************************************
* Topic: How to create a file with population totals in the strata 
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/

options nocenter nodate nonumber ls=155 ps=72; 

/* The LIBNAME statement that assigns a libref to the input SAS data set
   is in the AUTOEXEC.SAS, not included here */

*** How to constuct the data set containing the population totals in the strata;

* Code snippet 1;
proc summary data=PUFMEPS.H209 nway;
class varstr;
OUTPUT OUT=WORK.PROC_SUMMARY_Totals (drop=_TYPE_ rename=(_freq_=_Total_));
run;

* Code snippet 2;
proc sql;
create table WORK.SQL_Totals as
     select varstr, count (dupersid) AS _Total_
     from PUFMEPS.H209
 group by varstr;
quit;

* Code snippet to compare the population control totals in strata from two data sets;
PROC COMPARE BASE=WORK.PROC_SUMMARY_Totals COMPARE=WORK.SQL_Totals ;
TITLE1 'PROC COMPARE with no options or extra statements';
RUN; 
