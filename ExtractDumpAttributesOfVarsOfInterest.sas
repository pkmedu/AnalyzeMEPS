
/*********************************************************************************
* Topic: Extracting and dumping variables of interest 
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/
options nocenter nodate nonumber;

* Create two macro variables - one containing the list of variables for a given AHS measure
  and the number of macro variables;

/* The LIBNAME statement that assigns a libref to the input SAS data set
   is in the AUTOEXEC.SAS, not included here */

proc sql noprint;
select quote(strip(Name))
  into :varlist separated by ' '
  from dictionary.columns
 where libname= "PUFMEPS" and memname = upcase("h209")
    and name like "AD%";
 %let num_vars_AHS08=&sqlobs;
quit;

* Dump the the attributes of the variables of interest into a spreadsheet;
ods excel file = 'c:\Data\Var_Doc_Example.xlsx'
options(row_heights="0,0,0,14,0,0" sheet_interval='PROC'
                  sheet_name="AHS08" 
                  embedded_titles="yes");
proc sql;
title "Displaying attributes of %sysfunc(left(&num_vars_AHS08)) variables for Measure AHS08";
create table AHS08_vars as
select name, type, label
  from dictionary.columns
 where libname= "PUFMEPS" and memname = upcase("h209")
    and name in (&varlist)
		order by name;
  select monotonic() as Number, name, label
     from AHS08_vars;
quit;
ods excel close;


