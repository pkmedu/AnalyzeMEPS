/*********************************************************************************
* Topic: How to find new SAS variables from the 2018 MEPS (not in the 2017 file) 
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/

*** Read data from an external file;
options nocenter nodate nonumber;
libname new 'C:\Data\MySDS';
data new.V_added;
  infile 'C:\Data\Variables_Added_2018.txt' missover;
  input Name :$32.;
run;
proc sort data=new.V_added; by Name; run;

*** Create a macro variable containing a list of values;
proc sql noprint;
    select quote(strip(Name)) into :vars_added_18 
        separated by ' ' 
        from new.V_added; 
        %let num_vars_added_18=&sqlobs;
quit;
%put &=num_vars_added_18;


proc sql noprint;
select quote(strip(name)) into :var_list2 separated by ' '
from dictionary.columns 
where libname='NEW' and memname='H209';
%let num_vars_added_18_2=&sqlobs;
quit;
%put &=num_vars_added_18_2;

proc sql;
select Name from new.V_added
where Name not in (&var_list2);
quit;



proc sql;
  
   select name label='Variable', 
          label label='Description'
   from dictionary.columns 
    where libname='NEW' and memname='H209' and
	name not in (&vars_added_18)
	order by name;
   quit;
*** Filter the dictionary.table (dictionary.columns) based 
    on the macro variable created above;

title;
ods excel file = 'c:\Data\2018_Added_Vars_rev.xlsx'
  options(row_heights="0,0,0,14,0,0" sheet_interval='PROC'
                  sheet_name="Added" 
                  embedded_titles="yes");
proc sql;
   title "New variables added to MEPS 2018 (Expected # %sysfunc(left(&num_vars_added_18)))";
    create table added_vars as
   select name label='Variable', 
          label label='Description'
   from dictionary.columns 
    where libname='NEW' and memname='H209' and
	name in (&vars_added_18)
	order by name;
  select monotonic() as Number, name, label
     from added_vars;
 quit;
ods excel close;
