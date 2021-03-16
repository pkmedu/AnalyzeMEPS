

	 proc sql;
         select name, type, length, label
         from
             sashelp.vcolumn
         where
             libname="SASHELP" and
             memname = "HEART"
      ;quit;

	
proc print data=sashelp.vcolumn label;
  var name type format length label;
  where libname='SASHELP' and memname='HEART';
run;

	   proc sql;
         select name, type, length, label
         from dictionary.columns
         where libname="SASHELP" and
             memname = "HEART"
      ;quit;

	  options label;
      proc sql;
       describe table sashelp.heart
      ;quit;
      options label;

	 proc contents data=sashelp.heart position;
	 ods select variables;
     run;
	 

	  proc contents data=sashelp.heart;
	  ods select variables;
	  run;

	  proc contents data=sashelp.heart varnum;
	  run;


	 proc datasets lib=sashelp;
     contents data=heart position;
     quit;

	
