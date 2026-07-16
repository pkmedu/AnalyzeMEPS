/* cap input rows for the captured run */
options obs=100;

/* Mock replacement for the author's LIBNAME pufmeps 'C:\Data'; pointing at the
   restricted-access MEPS full-year consolidated file (HC-209). Columns mirror
   the design variables and the poverty-category domain the script tests across:
   VARSTR/VARPSU (stratum/cluster), PERWT18F (weight), TOTEXP18 (total
   expenses), POVCAT18 (1=Poor .. 5=High Income). */
libname pufmeps (work);

data pufmeps.h209;
  length varstr varpsu perwt18f totexp18 povcat18 8;
  input varstr varpsu perwt18f totexp18 povcat18;
  datalines;
1 1 1050.3 3200 1
1 1  980.1 1500 2
1 2 1102.6 8200 4
1 2  875.4  600 3
2 1  990.8 4200 5
2 1 1044.2 2100 1
2 2 1120.9 9100 4
2 2  860.7  400 2
3 1  975.5 3600 3
3 1 1010.3 1800 1
3 2 1085.7 7600 5
3 2  900.2  700 2
4 1 1035.9 3900 4
4 1  965.6 1600 1
4 2 1099.4 8800 5
4 2  915.8  550 3
5 1 1005.1 3300 2
5 1  950.7 1400 1
5 2 1120.3 8900 4
5 2  890.5  650 3
;
run;
