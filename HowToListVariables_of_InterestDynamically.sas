/*********************************************************************************
* Topic: How to list variables of interest (Flu Variabls) from various NEPS files  
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/

options nocenter nodate ps = 80;
proc sql;
create table Panels_1_20 as 
select memname, case
      when memname ='H193' then  '2015-2016'
      when memname ='H183' then  '2014-2015'
      when memname ='H172' then  '2013-2014'
      when memname ='H164' then  '2012-2013'
      when memname ='H156' then  '2011-2012'
      when memname ='H148' then  '2010-2011'
      when memname ='H139' then  '2009-2010'
      when memname ='H130' then  '2008-2009'
      when memname ='H122' then  '2007-2008'
      when memname ='H114' then  '2006-2007'
      when memname ='H106' then  '2005-2006'
      when memname ='H98' then  '2004-2005'
      when memname ='H86' then  '2003-2004'
      when memname ='H80' then  '2002-2003'
      when memname ='H71' then  '2001-2002'
      when memname ='H65' then  '2000-2001'
      when memname ='H58' then  '1999-2000'
      when memname ='H48' then  '1998-1999'
      when memname ='H35' then  '1997-1998'
      when memname ='H23' then  '1996-1997'
      else 'None'
      end as Year, name, label
 from dictionary.columns
 where libname= "PUFMEPS"  
 and name like "FLUSHT%" or name like "FLSHOT%" 
                or name like "DSFLT%"  
                or name like "DSVBY%"  
				or name like "DSFLNV%" 
 and memname in ('H23', 'H35','H48','H58', 'H65', 'H71', 'H80', 'H86',
                 'H98', 'H106','H114', 'H122', 'H130', 'H139', 'H148', 'H156',
                 'H164', 'H172', 'H183', 'H193');
 quit;
proc sort data=Panels_1_20; by year memname; run;
proc print data=Panels_1_20; by year memname;
id  year memname;
where year ne 'None';
run;
proc format;
value age_fmt -1 = 'Inapplicable'
      0-17 = '0-17 Yrs'
	  other = '18+ Yrs';
value flu_fmt 
-8, -7 = 'DK/REFUSED'	
-1 = 'INAPPLICABLE'	
1 ='WITHIN PAST YEAR'	
2 ='WITHIN PAST 2 YEARS'	
3 ='WITHIN PAST 3 YEARS'	
4 ='WITHIN PAST 5 YEARS'	
5 ='MORE THAN 5 YEARS'	
6 ='NEVER';
run;



options center;
title 'MEPS Panel 20 Longitudinal Data File, 2015-2016';
proc freq data=pufmeps.h193;
tables age3x*FLUSHT3 /list missing;
format age3x age_fmt. FLUSHT3 flu_fmt.;
run;

/*
proc sql noprint;
select name
  into :varlist_x separated by ' ' 
 from dictionary.columns
 where libname= "PUFMEPS" and memname = upcase("h202")
    and name like "FLU%";
quit;
proc freq data=pufmeps.h202;
tables age3x*FLUSHT3 /listing missing;
run;
*/
