
/*********************************************************************************
* Topic: Finding variables of interest in MEPS 2018 (Alcohol Use)
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/
libname PUFMEPS 'c:\Data\MySDS';
proc sql noprint;
select quote(strip(Name))
  into :varlist separated by ' '
  from dictionary.columns
 where libname= "PUFMEPS" and memname = "H209"
 and prxmatch ("/ALC|DRNK/oi", name) > 0;
   /* and name like "_%DRNK%";*/
 %let num_vars_ALC_DRNK=&sqlobs;
quit;
%put &=num_vars_ALC_DRNK;

* Dump the the attributes of the variables of interest into a spreadsheet;
ods excel file = 'c:\Data\MEPS_ALC_DRNK_variables.xlsx'
options(row_heights="0,0,0,14,0,0" sheet_interval='PROC'
                  sheet_name="ALC_DRNK" 
                  embedded_titles="yes");
proc sql;
title "Displaying attributes of %sysfunc(left(&num_vars_ALC_DRNK)) variables for Alcol/Drink variables";
create table ALC_DRNK_vars as
select memname, name, type, label
  from dictionary.columns
 where libname= "PUFMEPS" and memname = "H209"
  and name in (&varlist)
		order by name;
  select monotonic() as Number, memname, name, label
     from ALC_DRNK_vars;
quit;
ods excel close;
