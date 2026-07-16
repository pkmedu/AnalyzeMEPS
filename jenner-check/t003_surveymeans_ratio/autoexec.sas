/* cap input rows for the captured run */
options obs=100;

/* Mock replacement for the author's LIBNAME pufmeps 'C:\Data'; pointing at the
   restricted-access MEPS full-year consolidated file (HC-209). Columns mirror
   the design and expenditure variables the script actually reads: VARSTR/VARPSU
   (stratum/cluster), PERWT18F (person weight), TOTEXP18 (total expenses) and
   its component categories (office-based, outpatient, ER, inpatient, Rx, home
   health) used in the RATIO statement. */
libname pufmeps (work);

data pufmeps.h209;
  length varstr varpsu perwt18f totexp18 obvexp18 optexp18 ertexp18
         iptexp18 rxexp18 hhaexp18 8;
  input varstr varpsu perwt18f totexp18 obvexp18 optexp18 ertexp18 iptexp18 rxexp18 hhaexp18;
  datalines;
1 1 1050.3 3200 800 400 0    0    900  0
1 1  980.1 1500 500 200 0    0    600  0
1 2 1102.6 8200 900 300 2100 3200 1500 200
1 2  875.4  600 250   0 0    0    250  0
2 1  990.8 4200 700 500 0    0    2400 0
2 1 1044.2 2100 600 300 0    0    1000 0
2 2 1120.9 9100 850 400 1900 4200 1500 250
2 2  860.7  400 150   0 0    0    150  0
3 1  975.5 3600 750 350 0    0    1900 0
3 1 1010.3 1800 450 250 0    0    900  0
3 2 1085.7 7600 800 500 1700 2900 1400 300
3 2  900.2  700 300   0 0    0    300  0
4 1 1035.9 3900 780 420 0    0    2100 0
4 1  965.6 1600 400 200 0    0    800  0
4 2 1099.4 8800 900 450 2000 3600 1600 250
4 2  915.8  550 220   0 0    0    220  0
5 1 1005.1 3300 700 380 0    0    1700 0
5 1  950.7 1400 350 180 0    0    700  0
5 2 1120.3 8900 870 430 2050 3700 1550 300
5 2  890.5  650 280   0 0    0    280  0
;
run;
