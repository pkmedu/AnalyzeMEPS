data test;
  w=1;
  do i=1 to 50;
    y=rannor(3420);
    gender=scan('male,female', rantbl(0, .55, .45));
    output;
  end;
run;
ods exclude all; *to suppress the printed output;
proc surveymeans data=test;
  var y;
  weight w;
  domain gender/diffmeans;
  ods output domain=domain domaindiffs=diffs;
run;
ods select all; *restore the default printed output;

proc print data=domain;

proc print data=diffs;

run;

 

/* one way to combine the two output data sets */

data all;

  set domain diffs;

run;

proc print data=all;

run;
