
OPTIONS nocenter nodate nonumber symbolgen;
libname new 'U:\A_DataRequest\sds';
  
%macro runit (first=, last=);
%do yr=&first %to &last;
 title "MEPS, 20%sysfunc(putn(&yr,z2.))";
 ods graphics off;
 ods exclude statistics;
          proc surveymeans data=new.FY_%sysfunc(putn(&yr,z2.)) nobs sumwgt mean stderr sum ;
          stratum varstr;
          cluster varpsu;
          weight perwt%sysfunc(putn(&yr,z2.))f;
          var  totexp%sysfunc(putn(&yr,z2.));
          domain nmiss_exp('1') ;
          ods output domain=_overall_%sysfunc(putn(&yr,z2.));
          run;
  %end ;
%mend runit;
%runit(first=00, last=15)
*******;
data new.overall_HD (drop= domainlabel varname);   
  set  _overall: indsname=source;
  Year = cats('20',scan(source, -1, '_'));
run;

proc format;   
   picture bigmoney (fuzz=0)
      1E06-<1000000000='0000.99 M' (prefix='$' mult=.0001)
      1E09-<1000000000000='0000.99 B' (prefix='$' mult=1E-07)
      1E12-<1000000000000000='0000.99 T' (prefix='$' mult=1E-010);
run;
title 'Health care expenditures, United States (civillian noninstitutionalized population), MEPS 2000-2015';

proc print data=new.overall_HD noobs label; 
var year N mean sum ;
label N= 'Number of sample persons'
      mean = 'Mean expenditure per person ($)'

sum= 'Total expenditures ($)';
format mean dollar7. sum bigmoney.;
run;

