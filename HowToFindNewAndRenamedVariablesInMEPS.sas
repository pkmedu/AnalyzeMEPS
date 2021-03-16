/*********************************************************************************
* Topic: How to find new and renamed variables from the 2018 MEPS (not in the 2017 file) 
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/

options nocenter nodate nonumber;
libname new 'C:\Data\MySDS';
data new.V_added;
  infile 'C:\Data\Variables_Added_2018.txt' missover;
  input Name :$32.;
run;
proc sort data=new.V_added; by Name; run;

proc sql noprint;
    select quote(strip(Name)) into :vars_added_18 
        separated by ' ' 
        from new.V_added; 
        %let num_vars_added_18=&sqlobs;
quit;
%put &=num_vars_added_18;


proc sql noprint;
select quote(strip(name)) into :vars_added_18_2 separated by ' '
from dictionary.columns 
where libname='NEW' and memname='H209';
%let num_vars_added_18_2=&sqlobs;
quit;
%put &=num_vars_added_18_2;


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

ods excel file = 'c:\Data\2018_Not_Added_Vars_rev.xlsx'
  options(row_heights="0,0,0,14,0,0" sheet_interval='PROC'
                  sheet_name="Not_Added" 
                  embedded_titles="yes");
proc sql;
   title "New variables expected to be added, but not added to MEPS 2018";
   select Name from new.V_added
   where Name not in (&vars_added_18_2);
 quit;
ods excel close;


**************************;

data new.V_renamed;
  infile 'C:\Data\Variables_Renamed_2018.txt' missover;
  input Name :$32.;
run;
proc sort data=new.V_Renamed; by Name; run;

proc sql noprint;
    select quote(strip(Name)) into :vars_renamed_18 
        separated by ' ' 
        from new.V_renamed; 
        %let num_vars_renamed_18=&sqlobs;
quit;
%put &=num_vars_renamed_18;

ods excel file = 'c:\Data\2018_Renamed_Vars_rev.xlsx'
  options(row_heights="0,0,0,14,0,0" sheet_interval='PROC'
                  sheet_name="Renamed" 
                  embedded_titles="yes");
proc sql;
   title 'Renamed variables in MEPS 2018';
   create table renamed_vars as
   select name label='Variable', 
          label label='Description'
   from dictionary.columns 
    where libname='NEW' and memname='H209' and
	name in (&vars_renamed_18)
	order by name;
  select monotonic() as Number, name, label
     from renamed_vars;
 quit;
ods excel close;
******************************************;
data new.V_deleted;
  infile 'C:\Data\Variables_Deleted_2018.txt' missover;
  input Name :$32.;
run;
proc sort data=new.V_deleted; by Name; run;

proc sql noprint;
    select quote(strip(Name)) into :vars_deleted_18 
        separated by ' ' 
        from new.V_deleted; 
        %let num_vars_deleted_18=&sqlobs;
quit;
%put &=num_vars_deleted_18;

proc sql noprint;
select quote(strip(name)) into :vars_deleted_18_2 separated by ' '
from dictionary.columns 
where libname='NEW' and memname='H201';
%let num_vars_deleted_18_2=&sqlobs;
quit;
%put &=num_vars_deleted_18_2;


ods excel file = 'c:\Data\2018_Deleted_Vars_rev.xlsx'
  options(row_heights="0,0,0,14,0,0" sheet_interval='PROC'
                  sheet_name="Deleted" 
                  embedded_titles="yes");
proc sql;
   title "Deleted variables from MEPS 2018 (Expected # %sysfunc(left(&num_vars_deleted_18)))";
   create table deleted_vars as
   select name label='Variable', 
          label label='Description'
   from dictionary.columns 
    where libname='NEW' and memname='H201' and
	name in (&vars_deleted_18)
	order by name;
  select monotonic() as Number, name, label
     from deleted_vars;
 quit;
ods excel close;

 ods excel file = 'c:\Data\Not_found_2017_Vars_rev.xlsx'
  options(row_heights="0,0,0,14,0,0" sheet_interval='PROC'
                  sheet_name="Not_found" 
                  embedded_titles="yes");
proc sql;
   title "Expected to be deleted, but not found in MEPS 2017";
   select Name from new.V_deleted
   where Name not in (&vars_deleted_18_2);
 quit;
ods excel close;






