libname pufmeps 'C:\Data';

proc format;
VALUE insu
1='1 <65, ANY PRI'
2='2 <65, PUB ONLY'
3='3 <65, UNINSURED'
4='4 65+, MEDICARE ONLY'
5='5 65+, MEDICARE AND PRI'
6='6 65+, MEDICARE AND OTHER PUB'
7='7 65+, NO MEDICARE/OTHER';

VALUE insu_x
1='65+, MEDICARE ONLY'
2='65+, MEDICARE AND PRI'
3='65+, MEDICARE AND OTHER PUB'
4='65+, NO MEDICARE/OTHER';

run;
%let yr=17;

Data D2017;
  set  pufmeps.h201;

   ** New variable for age group;
          if agelast lt 18 then AGE_GRP= 1;
		  else if 18<=AGELAST<=64 then AGE_GRP=2;
		  else if AGELAST>=65 then AGE_GRP=3;

*** New insurance variable for all ages;
 INSU=INSURC&YR;
  IF INSURC&YR=8 THEN INSU=7;
  
**** New insurance variable for ages 65 and older;
 if insu >=4 then INSU_x = insu - 3;
 else INSU_x = .;
run;

proc freq data=D2017;
tables insu insu_x;
format insu insu. insu_x insu_x.;
run;

ods graphics off;
PROC SURVEYMEANS DATA=D2017 nobs mean stderr sum;
    VAR  insu ;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT17F;
	class insu ;
	format insu insu. ;
RUN;

ods graphics off;
ods exclude statistics;
PROC SURVEYMEANS DATA=D2017 nobs mean stderr sum;
    VAR  insu_x;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT17F;
	class insu_x;
	domain age_grp('3');
	format insu_x insu_x.;
RUN;
