/*********************************************************************************
* Topic: How to get SAS variable attributed dynamically (Various)
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/

	 proc sql;
         select name, type, length, label
         from
             sashelp.vcolumn
         where
             libname="SASHELP" and
             memname = "HEART"
      ;quit;

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
