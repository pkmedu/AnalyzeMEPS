/* cap input rows for the captured run */
options obs=100;

/* The author's real autoexec assigns the LIBNAME pointing at the restricted
   MEPS full-year consolidated file (HC-209); this mock stands in for it with
   the two columns the script actually reads: VARSTR (stratum) and DUPERSID
   (person ID, used to count persons per stratum). */
libname pufmeps (work);

data pufmeps.h209;
  length varstr 8 dupersid $10;
  input varstr dupersid $;
  datalines;
1 P00001001
1 P00001002
1 P00001003
2 P00002001
2 P00002002
2 P00002003
2 P00002004
3 P00003001
3 P00003002
4 P00004001
4 P00004002
4 P00004003
4 P00004004
4 P00004005
5 P00005001
5 P00005002
5 P00005003
;
run;
