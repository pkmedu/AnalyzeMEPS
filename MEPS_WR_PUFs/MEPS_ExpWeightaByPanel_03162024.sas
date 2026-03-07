
dm "log; clear; output; clear; odsresults; clear;";
proc datasets library=work kill nolist;
%let path = S:\CFACT\Shared\MEPS_HC_QC;
libname new "&path";
libname library "&path";
proc format LIBRARY=library;
value race_fmt 1 = 'Hispanic'
			   3 = 'Non-Hispanic Black'
			   4 = 'Asian'
               2,5  = 'Other races'
			   0='All';

value age_fmt 0 ='Under 1 year'
              1-4 = '1 to 4 years old'
			  5-9 = '5 to 9 years old'
			  10-14 = '10 to 14 years old'
			  15-17 = '15 to 17 years old'
			  18    = '18 years old'
			  19-25 = '19 to 25 years old'
			  26-29 = '26 to 29 years old'
			  30-34 = '30 to 34 years old'
			  35-44 = '35 to 44 years old'
			  45-54 = '45 to 54 years old'
			  55-59 = '55 to 59 years old'
			  60-64 = '60 to 64 years old'
			  65-69 = '65 to 69 years old'
			  70-74 = '70 to 74 years old'
			  75-79 = '75 to 79 years old'
			  80-HIGH = '80 years old and older';

value xfmt 1 = 1
           3 = 2
	       4 = 3
		   2,5 = 4
           0 = 5;

value $stat 'N' = 'Unweighted MEPS count'
        'Mean', 'MEAN' = 'Mean'
		'Min', 'MIN' = 'Minimum'
		'Max', 'MAX' = 'Maximum'
		'CV', 'cv' = 'Coefficent of variation (%)'
        'Sum','SUM' = 'Weighted MEPS count';

invalue $yfmt 'N' = 1
        'Mean', 'MEAN' = 2
		'Min', 'MIN' = 3
		'Max', 'MAX' = 4
		'CV', 'cv' = 5
        'Sum','SUM' = 6;

value mixedvalue
		low-<100 = [4.1]
		100-999 = [3.]
		1000-high = [comma12.];

value group_fmt 1 = 'Dec 31 respondents only'
			    2 = 'All respondents';

invalue $n_age_race  '1 to 4 years old' = '03' 
                    '5 to 9 years old' = '04' 
					'10 to 14 years old'    = '05'       
					'15 to 17 years old'    = '06'        
					'18 years old'  = '07'                
					'19 to 25 years old'  = '08'         
					'26 to 29 years old'  = '09'       
					'30 to 34 years old' = '10'          
					'35 to 44 years old'   = '11'        
					'45 to 54 years old'  = '12'         
					'55 to 59 years old'  = '13'          
					'60 to 64 years old'   = '14'         
					'65 to 69 years old'   = '15'        
					'70 to 74 years old'    = '16'       
					'75 to 79 years old'    = '17'        
					'80 years old and old'   = '18'     
					'Asian'  = '21'                      
					'Hispanic'    = '19'                 
					'Non-Hispanic Black' = '20'         
					'Other'   = '22'                      
					'Overall'   = '01'                     
					'Under 1 year' = '02';
run;
%macro loops(list) / mindelimiter=',' minoperator;                                                                                      
%local xcount i yr;                                                                                                                     
%let xcount=%sysfunc(countw(&list, %STR(|))); /* Count the number of data sets*/                                                        
%do i = 1 %to &xcount; /* Loop through the total # of data sets */                                                                      
	%let yr=%sysfunc(putn(%eval(&i+17),z2.)); /* Generate values from 18 to 21 */                                                           
                                                                                                                                        
	 %do j=1 %to 2;                                                                                                                         
		  %if &j=1 %then %do;                                                                                                                   
		   %let filter=INSC1231 = 1 &;                                                                                                          
		   %let outd=Stat&yr;                                                                                                                   
		  %end;                                                                                                                                 
		  %else %do;                                                                                                                            
		   %let filter=%str();                                                                                                                  
		   %let outd=xStat&yr;                                                                                                                  
		  %end;                                                                                                                                 
		                                                                                                                                        
		 proc means data=pufmeps.%scan(&list,&i,%str(|)) noprint;                                                                               
		  class agelast racethx;                                                                                                                
		  var PERWT&YR.F FAMWT&YR.F FAMWT&YR.C SAQWT&YR.F;                                                                                      
		  format agelast age_fmt. racethx race_fmt.;                                                                                            
		  where perwt&yr.f>0;                                                                                                                   
		  output out=&outd N= sum= mean= min= max= cv= / autoname;                                                                          
		 run;     

         data Final_&outd (drop= _: agelast: racethx:);
			 set &outd;
			 length agelast_c racethx_c age_race_c $20;
			 agelast_c = put(agelast, age_fmt.);
			 racethx_c = put(racethx, race_fmt.);
			 age_race_c = coalescec(agelast_c, racethx_c);
			 if index(age_race_c, '.') then age_race_c = 'Overall';
			 where _type_ in (0,1,2);
			run; 
	     proc sort data=Final_&outd;   by age_race_c; run;
                                                                                                                              
	 %end;                                                                                                                    
%end;                                                                                                                               
%mend loops;                                                                                                                            
%loops(h209|h216|h224|h233) 

%macro run_my_steps(d);
 data m_&d ;
 merge final_&d.18 final_&d.19 final_&d.20 final_&d.21;
 by age_race_c;
 run;

proc transpose data=m_&d  out=t_m_&d;
by age_race_c;
run;

data x_t_m_&d (rename=(COL1=value));
  set t_m_&d;
  length stat $4 keyvar $12;
  if prxmatch('/N$/', strip(_name_)) then stat='N';
  if prxmatch('/Mean$/', strip(_name_)) then stat='Mean';
  if prxmatch('/Sum$/', strip(_name_)) then stat='Sum';
  if prxmatch('/CV$/', strip(_name_)) then stat='CV';
  if prxmatch('/Min$/', strip(_name_)) then stat='Min';
  if prxmatch('/Max$/', strip(_name_)) then stat='Max';

  retain r;
  if _N_ = 1 then r = prxparse('/.+(\d{2})[A-Z]\_[a-zA-Z]/');
  if prxmatch(r,_NAME_) then yr = prxposn(r,1,_NAME_);
  year = '20'||yr;

  retain r2;
  if _N_ = 1 then r2 = prxparse('/(.+)\d{2}([A-Z])\_[a-zA-Z]/');
  if prxmatch(r2,_NAME_) then 
     do;
       first = prxposn(r2,1,_NAME_);
	   last = prxposn(r2,2,_NAME_);
     end;
  keyvar = cats(first, last);
drop _: yr r: first last ;
run;
%mend ;
%run_my_steps(stat)
%run_my_steps(xstat)

data comb ;
 set x_t_m_stat (in=a1) x_t_m_xstat (in=a2);
 if a1=1 then group_cat = 1 ;
else if a2=1 then group_cat = 2;
run;

proc sort data=comb; 
 by age_race_c stat keyvar group_cat;
run;

proc transpose data=comb  out=t_comb (drop=_NAME_) prefix=Year;
id year;
var value;
by age_race_c stat keyvar group_cat;
run;

data xt_comb;
 set t_comb;
 length n_age_race_c $ 2;
 n_age_race_c = input(age_race_c, $n_age_race.);
 n_stat = input(stat, $yfmt.);
run;
proc sort data= xt_comb; by n_age_race_c n_stat; run;

* direct the PROC REPORT output to an Excel workbook using a macro;

ods listing close;
/* Format the current date as "YYYY-MM-DD" */
%let current_date = %sysfunc(today());
%let formatted_date = %sysfunc(putn(&current_date., yymmdd10.));
%macro printit (text);
ods excel options(sheet_name="&text" embedded_titles="yes");
title "%sysfunc(date(),worddate.)";
title2 "MEPS Expenditure Weights (&text), 2018-2021";
proc report data=xt_comb (where=(keyvar= "&text")); 
  column group_cat n_age_race_c age_race_c age_race_c2 stat n_stat year2018 year2019 year2020 year2021;
  define group_cat / order descending format = group_fmt. "MEPS respondent type" width=25;
  define age_race_c / order "Age and Race"  width=25 noprint;
  define age_race_c2 / computed "Age and Race"  width=25;
  define n_age_race_c / order "Age and Race" width=25 noprint;
  define n_stat / order "Statistic"  width=25 noprint;
  define stat / format= $stat. "Statistic"  width=25 ;
  define year2018 / display  width=9 "2018" format =  mixedvalue.;
  define year2019 / display  width=9 "2019" format =  mixedvalue.;
  define year2020 / display  width=9 "2020" format =  mixedvalue.;
  define year2021 / display  width=9 "2021" format =  mixedvalue.;
  compute age_race_c2 /character length=25;
     age_race_c2 = age_race_c;
  endcomp;
run;
%mend printit;
ods excel file="&path\MEPS_Expenditure_Weights_&formatted_date..xlsx" options(sheet_interval='PROC');
%printit(PERWTF)
%printit(SAQWTF)
%printit(FAMWTC)
%printit(FAMWTF)
     
ods excel close;
ods listing;



