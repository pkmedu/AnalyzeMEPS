
dm "log; clear; output; clear; odsresults; clear;";
options nocenter nodate ps = 80;
%let path = S:\CFACT\Shared\MEPS_HC_QC;
%put &=path;
%let current_date = %sysfunc(date(), worddate.);
%let formatted_date = %sysfunc(putn(%sysfunc(today()), yymmdd10.));

proc sql;
create table YR2021 as 
select memname, name, label, case
      when memname ='H217' then  'MEPS HC-217: MEPS Panel 23 Longitudinal Data File (2018-2019)'
      when memname ='H225' then  'MEPS HC-225: MEPS Panel 24 Longitudinal Data File (2019-2020)'
	  when memname ='H226' then  'MEPS HC-226: MEPS Panel 23 Three-Year Longitudinal Data File (2018-2020)'
      when memname ='H236' then  'MEPS HC-236: MEPS Panel 23 Four-Year Longitudinal Data File (2018-2021)'
      when memname ='H235' then  'MEPS Panel 24 Three-Year Longitudinal Data File (2019-2021)'
      when memname ='H234' then  'MEPS Panel 25 Longitudinal Data File (2020-2021)'
      when memname ='H233' then  '2021 Full Year Consolidated Data File'
      when memname ='H232' then  '2021 Person Round Plan Public Use File'
      when memname ='H231' then  '2021 Medical Conditions File'
      when memname ='H230' then  '2021 Food Security File'
      when memname ='H229I' then 'Appendix to MEPS 2021 Event Files' 
      when memname ='H229H' then '2021 Home Health File' 
      when memname ='H229G' then  '2021 Office-Based Medical Provider Visits File'
      when memname ='H229F' then  '2021 Outpatient Visits File'
      when memname ='H229E' then '2021 Emergency Room Visits File' 
      when memname ='H229D' then  '2021 Hospital Inpatient Stays File'
	  when memname ='H229C' then  '2021 Other Medical Expenses File'
      when memname ='H229B' then '2021 Dental Visits File ' 
      when memname ='H229A' then  '2021 Prescribed Medicines File'
      when memname ='H228' then  '2021 Full Year Population Characteristics File'
      when memname ='H227' then  '2021 Jobs File'
      when memname ='H03BRR' then 'MEPS 1996-2021 Replicate File for BRR Variance Estimation'  
      when memname ='H36U21' then  'MEPS 1996-2021 Pooled Linkage File for Common Variance Structure'
	  else 'None'
      end as fname
 from dictionary.columns
 where libname= "PUFMEPS"  
 and   (name like '%WT%' and name like '%21%') |
       (name like 'LONGWT')| (name like 'LSAQWT')
 and memname in ('H217', 'H225','H226', 'H236', 'H235','H234','H233', 'H232', 'H231', 'H230', 'H229I', 
                 'H229H', 'H229G', 'H229F', 'H229E', 'H229D', 'H229C','H229B', 'H229A',
                 'H228', 'H227','H03BRR', 'H36U21')
 having calculated  fname not in ('', 'None');
 
 quit;

ods listing close;
title 'List of sampling weights for various  MEPS public use files, data year 2021 (for most files)';
options nocenter  ls=256; 
ods RTF file = "&path\List_MEPS_Weights_&formatted_date..xlsx"
          options(row_heights="0,0,0,14,0,0" sheet_interval='PROC' sheet_name='ByWeights'  embedded_titles="yes");

proc report data=YR2021 nowd; 
  column memname memname2  fname Name Label;
  define memname /order width=15 noprint;
  define fname / order 'Data file description' width=40 ;
  break after memname / summarize style=[font_weight=bold] suppress;
  compute memname2 /character length=15;
    memname2 = memname;
  endcomp;
  define memname2 /computed 'Data file number';
  break after fname /summarize 
                       style=[font_weight=bold]
					   suppress;
  define name / display width=40 'Variable';
  define label / display width=40 'Variable description';
run;


proc sort data=YR2021 out=sort_YR2021 (keep = name label) nodupkey; 
    by name label; 
run;

title 'List of unique sampling weights in MEPS public use files, 2021';
ods excel options(row_heights="0,0,0,14,0,0" sheet_interval='PROC' sheet_name='UniqueWGTs'  embedded_titles="yes");
Proc sql;
create table new_table as
select name "Variable", label "Variable description"
from sort_YR2021
where label not contains ('EXPENDITURE') ;
select monotonic() as Number, name length=12, label length=80
     from new_table;
quit;
ods RTF close;
title;



