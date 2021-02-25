

%LET RootFolder= C:\Mar2021\sas_exercises\Exercise_3;
FILENAME MYLOG "&RootFolder\Exercise3_log.TXT";
FILENAME MYPRINT "&RootFolder\Exercise3_OUTPUT.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;


proc datasets lib=work nolist kill; quit; /* Delete  all files in the WORK library */
OPTIONS LS=132 PS=79 NODATE FORMCHAR="|----|+|---+=|-/\<>*"  VARLENCHK=NOWARN PAGENO=1;


PROC FORMAT;

  VALUE totexp_fmt
      0         = 'No Expense'
      Other     = 'Any Expense';

  VALUE agecat_fmt
       18-49 = '18-49'
       50-64 = '50-64'
       65-high= '65+';

   
     value yes_no_fmt
      1 = 'Yes'
      0,2 = 'No'; 

	
run;
***************  MEPS 2017;
%LET DataFolder = C:\DATA\MySDS;  /* Adjust the folder name, if needed */
libname CDATA "&DataFolder"; 

%let kept_vars_2017 =  VARSTR VARPSU perwt17f agelast ARTHDX JTPAIN31 totexp17 totslf17;
data meps_2017;
 set CDATA.h201 (keep= &kept_vars_2017
                 rename=(totexp17=totexp
                         totslf17=totslf));
  perwtf = perwt17f/2;;

  
   * Create a subpopulation indicator called SPOP
    and a new variable called JOINT_PAIN  based on ARTHDX and JTPAIN31;

   spop=0;
   if agelast>=18 and not (ARTHDX <=0 and JTPAIN31 <0) then do;
  	  SPOP=1; 
   	 if ARTHDX=1 | JTPAIN31=1 then joint_pain =1;
   	 else joint_pain=0;
   end;

   label totexp = 'TOTAL HEALTH CARE EXP'
         totslf = 'TOTAL AMOUNT PAID - SELF-FAMILY';
run;


*** 2018 MEPS ; 

%let kept_vars_2018 =  VARSTR VARPSU perwt18f agelast ARTHDX JTPAIN31_M18 totexp18 totslf18;
data meps_2018;
 set CDATA.h209 (keep= &kept_vars_2018
                 rename=(totexp18=totexp
                         totslf18=totslf));
  perwtf = perwt18f/2;

  * Create a subpopulation indicator called SPOP
    and a new variable called JOINT_PAIN  based on ARTHDX and JTPAIN31_M18;

   spop=0;
   if agelast>=18 and not (ARTHDX <=0 and JTPAIN31_M18 <0) then do;
  	  SPOP=1; 
   	 if ARTHDX=1 | JTPAIN31_M18=1 then joint_pain =1;
   	 else joint_pain=0;
   end;
run;


**** Concatenate 2017 and 2018 analytic data files;

data MEPS_1718;
  set meps_2017(rename=(JTPAIN31 = JTPAIN))
      meps_2018 (rename=(JTPAIN31_M18 = JTPAIN));
	   TOTEXP_X = TOTEXP;
run;



title 'MEPS 2017-18 combined';

proc freq data=MEPS_1718;
tables ARTHDX*JTPAIN*joint_pain
       ARTHDX*JTPAIN*spop 
       spop joint_pain /list missing;
run;

title 'MEPS 2017-18 combined';
ods exclude statistics;
PROC SURVEYMEANS DATA=meps_1718  nobs mean sum ;
    VAR joint_pain totexp totslf;
    STRATUM VARSTR ;
    CLUSTER VARPSU;
    WEIGHT perwtf;
	domain spop('1');
	class joint_pain;
  	format joint_pain yes_no_fmt. ;
RUN;

title 'MEPS 2017-18 combined';
ods exclude statistics;
PROC SURVEYMEANS DATA=meps_1718  nobs mean sum median;
    VAR totexp totslf;
    STRATUM VARSTR ;
    CLUSTER VARPSU;
    WEIGHT perwtf;
	domain spop('1')*joint_pain;
	format joint_pain yes_no_fmt.  ;
;
RUN;

title 'MEPS 2017-18 combined / with any expense';
ods exclude statistics;
PROC SURVEYMEANS DATA=meps_1718  nobs mean sum median;
    VAR totexp totslf;
    STRATUM VARSTR ;
    CLUSTER VARPSU;
    WEIGHT perwtf;
	domain spop('1')*totexp_x('Any Expense')*joint_pain;
	format joint_pain yes_no_fmt.   totexp_x totexp_fmt.;
;
RUN;

proc printto;
run;
