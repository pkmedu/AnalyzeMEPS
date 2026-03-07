
dm "log; clear; output; clear; odsresults; clear;";
options nocenter nodate ps = 80;
data puf2024_list;
input month :8. schedule :$14. file_name :$60.;
infile datalines dlm=',' truncover;
datalines;
2, February 2024, 2022 Jobs File
2, February 2024, 2022 Full Year Population Characteristics File
5, May 2024,1996-2022 MEPS-NHIS Link Files
5, May 2024,2022 Other Medical Expenses File
5, May 2024,2022 Dental Visits File
5, May 2024,2022 Home Health File
6, June 2024, 2022 Hospital Inpatient Stays File
6, June 2024,2022 Emergency Room Visits File
6, June 2024,2022 Office-Based Medical Provider Visits File
6, June 2024,2022 Outpatient Visits File
7, July 2024, 2022 Prescribed Medicines File
7, July 2024, 2022 Food Security File
7, July 2024, 2023 MEPS-IC Private Sector Tables
8, August 2024, 1996-2022 Pooled Linkage File for Common Variance Structure
8, August 2024, 1996-2022 Replicate File for BRR Variance Estimation
8, August 2024, Appendix to MEPS 2022 Event Files
8, August 2024, 2022 Medical Conditions File
8, August 2024, 2022 Full Year Consolidated Data File
8, August 2024,2022 Person Round Plan File
9, September 2024, 2021-2022 MEPS Panel 26 Longitudinal Data File
10, October 2024, MEPS Insurance Component Chartbook 2023
11, November 2024, 2023 MEPS-IC Public Sector Tables
11, November 2024, 2023 MEPS-IC Civilian Tables
11, November 2024, 2019-2022 MEPS Panel 24 Longitudinal Data File
;
/* proc sort data=puf2024_list out=sorted_puf2024_list; by month; run;*/
proc print data= sorted_puf2024_list; run;
ods excel file = 'c:\Data\MEPS_2024_PUF_release.xlsx'
options(row_heights="0,0,0,14,0,0" sheet_interval='none'  embedded_titles="yes");
title '2024 MEPS Data Release Schedule';
proc report data=sorted_puf2024_list nowd; 
  column month schedule schedule2 file_name;
  define month /order width=15 noprint;
  define schedule /order width=15 noprint;
  break after schedule / summarize style=[font_weight=bold] suppress;
  compute schedule2 /character length=15;
    schedule2 = schedule;
  endcomp;
  define schedule2 /computed 'File Release Schedule';
  define file_name / display width=40 'File Description';
run;
ods excel close;
title;


 
