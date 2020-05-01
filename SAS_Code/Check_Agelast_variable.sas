
/***************************************************************************
* Goal: Check the construction of the AGELAST variable
* based on (Person’s Age Last Time Eligible) AGE17X, AGE42X, and AGE31X
* MEPS Documentation: - D. Variable-Source Crosswalk
****************************************************************************/

PROC FORMAT;
  VALUE AGECAT_F
	   low-64 = '0-64'
	   65-high = '65+'  ;
run;

DATA PUF201;
  set pufmeps.h201 (keep=age:);

 /* Create a new age variable (AGELAST_NEW) from AGE17X, AGE42X and  AGE31X variables */
       IF AGE17X >= 0 THEN AGELAST_NEW = AGE17X ; /*Age as of 12/31/2017 */
  ELSE IF AGE42X >= 0 THEN AGELAST_NEW = AGE42X ; /*Age as of Round 4/2 */
  ELSE IF AGE31X >= 0 THEN AGELAST_NEW = AGE31X ; /*Age as Round 3/1 */

RUN;
options nocenter nodate nonumber ps=100 orientation=landscape;

proc freq data=PUF201 noprint;
tables age17x*age42x*age31x*agelast*agelast_new /out=freq_count;
run;

proc sort data=freq_count; by descending count descending age17x;
proc print data=freq_count;
run;

proc freq data=PUF201 ;
tables agelast*agelast_new /list missing;
format agelast agelast_new agecat_f.;
run;



