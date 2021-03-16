
libname work list;
proc options option=work;
run;


%put %sysfunc(getoption(work));
%put %sysfunc(getoption(sasuser));

%put %sysfunc(pathname(work));
%put %sysfunc(pathname(sasuser));
