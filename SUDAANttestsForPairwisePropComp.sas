
/*********************************************************************************
* Topic: t-test for pairwise comparison (propotions) using SUDAAN;
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/

options nocenter nonumber nodate nosymbolgen ls=132;;
options formchar="|----|+|---";
LIBNAME new "H:\_HeartDisease\SDS";

FILENAME MYLOG "H:\_HeartDisease\output\Figure_1_SUDAAN_Variant1_log.TXT";
FILENAME MYPRINT "H:\_HeartDisease\output\Figure_1_SUDAAN_Variant1_output.TXT";
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;
proc format ;
value ageF 
  . = 'Overall'
  1 = '<=17'
  2 = '18-44'
  3 = '45-64'
  4 = '65 and above'; 
            
 value sexF   1 = 'Male'
              2 = 'Female'; 
			
VALUE RacethxF  
  1 = 'Hispanic'
  2 = 'NH White Only'
  3 = 'NH Black Only'
  4 = "NH Aisan Only"
  5 = "NH Other/Multiple Race" ;
 
 run;

PROC SORT DATA=new.summary_person_17; BY varstr  varpsu; RUN;
title 'Figure 1, MEPS 2017 - Percentage with expenses for heart disease treatment by demigraphic characteristics';
title1 'Ages 18 or older';
%macro runit (by_var, lv, fmt);
proc descript data=new.summary_person_17 design=wr filetype=sas;
  nest varstr  varpsu;
  weight perwtf;
  var  hd;
  subgroup &by_var;
  levels &lv;
  TABLES &by_var;
subpopn age_18p=1;
format &by_var &fmt;
SETENV DECWIDTH=6 COLWIDTH=18;
PRINT NSUM MEAN SEMEAN  /style=NCHS;
run;
%mend runit;
%runit(age_grp, 4, ageF.)
%runit(racethx, 5, racethxF.)
%runit(sex, 2, sexF.)


title 'Figure 1, MEPS 2017 - Results from Pairwise Proportion Tests';
%macro runit (by_var, lv, fmt);
proc descript data=new.summary_person_17 design=wr filetype=sas;
  nest varstr  varpsu;
  weight perwtf;
  var  hd;
  subgroup &by_var;
  levels &lv;
pairwise &by_var /name = "Between categories";
subpopn age_18p=1;
format &by_var &fmt;
SETENV DECWIDTH=6 COLWIDTH=18;
PRINT NSUM WSUM MEAN SEMEAN T_MEAN P_MEAN TOTAL SETOTAL /REPLACE;
OUTPUT MEAN SEMEAN T_MEAN P_MEAN / REPLACE FILENAME=T1;
run;
%mend runit;
%runit(age_grp, 4, ageF.)
%runit(racethx, 4, racethxF.)
%runit(sex, 2, sexF.)


PROC PRINTTO;
run;
