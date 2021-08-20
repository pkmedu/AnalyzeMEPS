
/*********************************************************************************
* Topic: Extracting and dumping variables of interest 
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/
options nocenter nodate nonumber;

*Task Variant 1: Retrieve attributes of variables (common prefix)
    by listing them as values of the NAME column through DICTIONARY.COLUMN;

libname PUFMEPS 'c:\Data\MySDS';
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

*Task Variant 2: Retrieve attributes of variables by listing them as values of the NAME column through DICTIONARY.COLUMN;

proc sql noprint;
select quote(strip(Name))
  into :varlist separated by ' '
  from dictionary.columns
 where libname= "PUFMEPS" and memname = upcase("h209")
    and name in ('DUPERSID', 'VARSTR', 'VARPSU');
 %let num_vars=&sqlobs;
quit;
proc sql;
title "Displaying attributes of %sysfunc(left(&num_vars)) variables fron MEPS-SAQ, 2018";
create table SAQ_vars as
select name, type, label
  from dictionary.columns
 where libname= "PUFMEPS" and memname = upcase("h209")
    and name in (&varlist)
		order by name;
  select monotonic() as Number, name, label
     from SAQ_vars;
quit;
%put sqlobs = &SQLOBS;


*Task Variant 3: Retrieve attributes of variables by listing them as values of the NAME column through DICTIONARY.COLUMN
       where the values are the value of a macro variable;

%let mv=  VARSTR VARPSU perwt18f saqwt18f ADFLST42  AGELAST SEX RACETHX POVCAT18 INSCOV18 
                       ADOFTB42 ADKALC42 ADHOPE42 ADINTR42 ADREST42 ADSAD42 ADMOOD42 ADNERV42 ADPRST42;
%let q_mv=%unquote(%str(%')%qsysfunc(tranwrd(%sysfunc(compbl(&mv)),%str( ),' '))%str(%'));
%put &q_mv;

proc sql noprint;
select quote(strip(Name))
  into :varlist separated by ' '
  from dictionary.columns
 where libname= "PUFMEPS" and memname = upcase("h209")
    and name in (&q_mv);
%let num_vars = &sqlobs;
quit;
%put &varlist;
%PUT &SQLOBS;

%put _user_;


*Dump the the attributes of the variables of interest into a spreadsheet (from Task 2);
ods excel file = 'c:\Data\Selected_SAQ_vars.xlsx'
options(row_heights="0,0,0,14,0,0" sheet_interval='PROC'
                  sheet_name="SAQ" 
                  embedded_titles="yes");
proc sql;
title "Displaying attributes of %sysfunc(left(&num_vars)) variables fron MEPS-SAQ, 2018";
create table SAQ_vars as
select name, type, label
  from dictionary.columns
 where libname= "PUFMEPS" and memname = upcase("h209")
    and name in (&varlist)
		order by name;
  select monotonic() as Number, name, label
     from SAQ_vars;
quit;
ods excel close;




