
libname pufmeps 'C:\Data';

proc format;
VALUE 	No_usc_F
1 =  'Yes'
2 =  'No';

run;

data h224;
 set pufmeps.h224 (keep = haveus42 varstr varpsu perwt20f;
 no_usc = haveus42;
 if haveus42 < 0 then no_usc = .;
run;

ods graphics off;
PROC SURVEYMEANS DATA=h224 nobs mean stderr sum;
    VAR  no_usc;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT PERWT20F;
	class 	no_usc;
	format 	no_usc no_usc_f. ;
RUN;
