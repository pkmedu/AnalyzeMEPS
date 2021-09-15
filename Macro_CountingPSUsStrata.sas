options center nonumber nodate options formchar="|----|+|---+=|-/\<>*";
%macro printit (year, ds);
title "MEPS Full Year Consolidated File, &year";
proc sql ;
   select count(distinct varstr) as count_varstr, 
         count(distinct varpsu) as count_varpsu,
		 count(distinct cats(varstr,varpsu)) as count_str_psu
		 from pufmeps.&ds;
quit;
%mend printit;
%printit (2015, h181)
%printit (2016, h192)
%printit (2017, h201)
%printit (2018, h209)
%printit (2019, h216)
