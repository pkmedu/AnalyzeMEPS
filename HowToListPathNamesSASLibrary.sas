
/*********************************************************************************
* Topic: How to create folders dynamically (Various) 
* Wtitten by Pradip Muhuri
* Acknowledgements: Online Sources, SAS Documentation
* Use the program at your own risk (no warranties).
**********************************************************************************/
libname work list;
proc options option=work;
run;


%put %sysfunc(getoption(work));
%put %sysfunc(getoption(sasuser));

%put %sysfunc(pathname(work));
%put %sysfunc(pathname(sasuser));
