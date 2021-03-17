
/*********************************************************************************
* Topic: How to find Strata with lonely PSUs 
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/

proc freq data=pufmeps.h209;
tables varstr*varpsu /out=outdata(where=(count=0))
sparse norow nocol nopct;
where perwt18f>0;
run;

proc sql noprint;
 select distinct varstr
   into  :singlestr separated by  ','
    from outdata;
quit;
%put SQLOBS=*&sqlobs*;
