options center nonumber nodate;
title "MEPS Full Year Consolidated File";
proc sql ;
   select count(distinct varstr) as count_varstr, 
         count(distinct varpsu) as count_varpsu,
		 count(distinct cats(varstr,varpsu)) as count_str_psu
		 from pufmeps.h209;
quit;

proc sql ;
   select count(*) as N_obs format=comma.,
		  sum(perwt18f=0) as num_zero_weights format=comma.,
		  sum(perwt18f>0) as num_positive_weights format=comma.,
		  count(distinct int(perwt18f)) as distinct_Int_weight_values format=comma.
		 from pufmeps.h209;
	quit;

run;
