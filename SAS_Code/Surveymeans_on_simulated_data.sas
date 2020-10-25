ods graphics off;
proc surveymeans data=person_x nobs mean ;
  stratum varstr;
  cluster varpsu;
  weight perwtf ;
  var TOTEXP;
 domain sex age_grp age_grp*sex('Male');
  ods output Statistics=ALL domain=Male;
run;
