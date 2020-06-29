
OPTIONS nocenter ps=58 ls=132 obs=max nodate nonumber varlenchk=nowarn ;
libname new "C:\Data";
proc format;
value age_f 
    35-64 = 'Ages 36-64'
	65-High ='Ages 65+';
value sex_f
    1 = 'Male'
	2 = 'Female';
value flushot_f
    -9, . = 'Not Ascetained'
    1 = 'Yes'
	2 = 'No';
title "In the past 12 months Had a flu shot or flu vaccine sprayed in nose, 2014";
title 'Proportion women with flu shot by age group (-9 for FLUSHOT included in a seprate category)';
options nolabel;
ods graphics off;
PROC SURVEYMEANS DATA=new.h173 nobs mean stderr sum ;
    VAR flushot;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT psaqwt;
	domain age53x*sex('Female');
	format age53x age_f. sex sex_f. flushot flushot_f.  ;
	class flushot;
ods select domain;
RUN;

data h173;
  set new.h173;
  flushot_x = flushot;
  if flushot = -9 then flushot_x=.; /*-9 changed to missing*/
run;

title "In the past 12 months Had a flu shot or flu vaccine sprayed in nose, 2014";
title2 'Proportion women with flu shot by age group (-9 changed to missing for FLUSHOT)';

ods graphics off;
PROC SURVEYMEANS DATA=h173 nobs mean stderr sum ;
    VAR flushot_x;
    STRATUM VARSTR;
    CLUSTER VARPSU;
    WEIGHT psaqwt;
	domain age53x*sex('Female');
	format age53x age_f. sex sex_f. flushot_x flushot_f. ;
	class flushot_x;
ods select domain;
RUN;




