/* cap input rows for the captured run */
options obs=100;

/* Mock replacement for the author's %LET DataFolder=...; libname CDATA "&DataFolder";
   pointing at the restricted-access 2019 MEPS Full-Year Consolidated File (HC-216).
   Columns mirror what the script's SET statement keeps: TOTEXP19, AGELAST, VARSTR,
   VARPSU, PERWT19F, PANEL. AGECAT_LABEL is added here (pre-computed '0-64'/'65+')
   because Jenner's PROC SURVEYMEANS does not yet accept a FORMAT statement inside
   the PROC step (the author's `FORMAT AGELAST agecat.;` on the DOMAIN breakdown) --
   grouping on the pre-labeled character variable reproduces the same age-group
   breakdown the format would have produced. */
libname cdata "./cdata_lib";

data cdata.h216;
  length totexp19 agelast varstr varpsu perwt19f panel 8 agecat_label $5;
  input totexp19 agelast varstr varpsu perwt19f panel;
  if agelast le 64 then agecat_label = '0-64';
  else agecat_label = '65+';
  datalines;
3200 34 1 1 1050.3 1
0     8 1 1  980.1 1
8200 71 1 2 1102.6 1
0    45 1 2  875.4 1
4200 52 2 1  990.8 2
2100 29 2 1 1044.2 2
9100 68 2 2 1120.9 2
0    12 2 2  860.7 2
3600 41 3 1  975.5 1
0    19 3 1 1010.3 1
7600 77 3 2 1085.7 1
0    33 3 2  900.2 1
3900 58 4 1 1035.9 2
0     6 4 1  965.6 2
8800 82 4 2 1099.4 2
0    24 4 2  915.8 2
3300 47 5 1 1005.1 1
0    15 5 1  950.7 1
8900 66 5 2 1120.3 1
0    38 5 2  890.5 1
;
run;
