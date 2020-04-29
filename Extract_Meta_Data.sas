
options nocenter nonumber nodate;
options formchar="|----|+|---+=|-/\<>*";
LIBNAME pufmeps  'C:\Data' access=readonly;

* Generate output on the number of observations and variables;
proc sql;
select nobs format=comma7.
       ,nvar 
    from dictionary.tables
    where libname = 'PUFMEPS' and memname = 'H201';
 quit;

 
options nonotes;
data _NULL_;
set PUFMEPS.H201;
array char[*} $ _CHAR_;
array num[*} _NUMERIC_;
nCharVar  = dim(char);
nNumerVar = dim(num);
put "Item # 1d new.TITANIC: " nCharVar= nNumerVar= ;
stop;   /* stop processing after first observation */
run;

* Generate a list of all variables and their attributes in the data set;
proc contents data=pufmeps.H201 varnum;
ods select position;
run;


* Create a macro variable that holds a horizontal list of variables of interest;
proc sql noprint;
select name
  into :varlist separated by ' ' 
 from dictionary.columns
 where libname= "PUFMEPS" and memname = "H201"
 and (name like "INSCOP%" or name like "KEY%" or name like "PERWT%");
quit;
%put &=varlist;

* Print the meta data for the variables of interest;
proc sql ;
select name, type, label
  from dictionary.columns
 where libname= "PUFMEPS" and memname = "H201"
 and (name like "INSCOP%" or name like "KEY%" or name like "PERWT%");
quit;

* Generate a listing of MEPS data files dynamically;
ods excel file = 'C:\Data\List_MEPS_Datasets.xlsx'
   options (embedded_titles='on'  sheet_name='List'); 
title "Listing of MEPS Data Files (SAS Data Sets) from  CFACT's Shared Drive";
libname pufmeps  'C:\Data' access=readonly;
proc sql number;
  select memname 
         ,nobs format=comma10.
         ,nvar format=comma7.
         ,DATEPART(crdate) format date9. as Date_created label='Creation Date'
		 ,TIMEPART(crdate) format timeampm. as Time_created label='Creation Time'
     from dictionary.tables
       where libname = 'PUFMEPS' 
        and memtype = 'DATA'
   order by Date_created desc;
  quit;
ods excel close;
  ods listing;

* Create temporary formats;
proc format;
value inscope_fmt(max=50)
  0 = '0 NOT RECORDED AS BEING INSCOPE'	
  1 = '1 INSCOPE AT SOME TIME DURING 2017'	
  2 = '2 OUT-OF-SCOPE FOR ALL OF 2017';

value keyness_fmt
  1 = '1 KEY'
  2 = '2 NON-KEY';
run;

* Display the frequesncy disgtribution for variables of interest;
title 'MEPS 2017 - PERWT17F value of 0';
proc freq data=pufmeps.h201 (keep=&varlist);
    tables perwt17f*keyness*inscope /list missing nopercent sparse;
   format inscope inscope_fmt. keyness keyness_fmt.;
  where PERWT17F=0;
run;

