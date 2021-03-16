/*********************************************************************************
* Topics: Pool MEPS data for 19 years using a Macro 
          Estimate health care expenses by year using a seprate macro
* Variables of interest: Health care expenditures, analysis weight and design variables
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/
OPTIONS nocenter nodate nonumber nosymbolgen;
libname new 'C:\Data\MySDS'  access=readonly;
libname xnew 'C:\Data\MEPS';
proc datasets nolist kill; quit;

* DATA step;
%macro loops(list) / mindelimiter=',' minoperator;
     %local xcount i yr;                                             
     %let xcount=%sysfunc(countw(&list, %STR(|))); /* Count the number of data sets*/
     %do i = 1 %to &xcount; /* Loop through the total # of data sets */   
	     %let yr=%sysfunc(putn(%eval(&i-1),z2.)); /* Generate values from 00 to 18*/
            data xnew.FY_&yr;
               set new.%scan(&list,&i,%str(|)) 
                  (keep= totexp: perwt:
						%if %scan(&list,&i,%str(|)) in (h50, h60) %then %do;
						      varstr&yr varpsu&yr
		                %end;
						%else %do;
						   varstr varpsu
		                %end;
				
                       rename=(
 				               %if %scan(&list,&i,%str(|)) in (h50, h60) %then %do;
				                  varpsu&yr=varpsu
		                          varstr&yr=varstr
                               %end;
                               )
                  );
		             year=20&yr.;
		             if totexp&yr >0 then any_exp=1;
             run;
    %end;
  %mend loops;
%loops(h50|h60|h70|h79|h89|h97|h105|h113|h121|h129|h138|h147|h155|h163|h171|h181|h192|h201|h209)

* PROC SURVEYMEANS step;
%macro runit (first=, last=);
%do yr=&first %to &last;
 title ;
 ods graphics off;
 ods exclude summary statistics;
          proc surveymeans data=xnew.FY_%sysfunc(putn(&yr,z2.)) nobs sumwgt mean stderr sum ;
          stratum varstr;
          cluster varpsu;
          weight perwt%sysfunc(putn(&yr,z2.))f;
          var  totexp%sysfunc(putn(&yr,z2.));
          domain any_exp('1') ;
          ods output domain=_domain_%sysfunc(putn(&yr,z2.));
          run;
  %end ;
%mend runit;
%runit(first=00, last=18)
* Generate customized output;
data domain_HD (drop= domainlabel varname);   
  set  _domain: indsname=source;
  Year = cats('20',scan(source, -1, '_'));
run;

proc format;   
   picture bigmoney (fuzz=0)
      1E06-<1000000000='0000.99 M' (prefix='$' mult=.0001)
      1E09-<1000000000000='0000.99 B' (prefix='$' mult=1E-07)
      1E12-<1000000000000000='0000.99 T' (prefix='$' mult=1E-010);
run;
title 'Health care expenditures among persons with an expense in';
title2 'the civillian noninstitutionalized population,';
title3 'United States, MEPS 2000-2018';
proc print data=domain_HD noobs label; 
var year N mean stderr sum stddev ;
label N= 'Number of sampled persons'
      mean = 'Mean HC expenditure per person with an expense'
      stderr = 'SE'
      sum= 'Total HC expenditures'
	  stddev 'STD';
format N comma9. mean stderr dollar7. sum stddev bigmoney.;
run;
