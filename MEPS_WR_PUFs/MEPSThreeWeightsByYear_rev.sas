
dm "log; clear; output; clear; odsresults; clear;";

FILENAME MYLOG 'S:\CFACT\Shared\PMuhuri\MEPS_HC_QC\SASPrograms\MEPSThreeWeights_log.TXT';
FILENAME MYPRINT 'S:\CFACT\Shared\PMuhuri\MEPS_HC_QC\SASPrograms\MEPSThreeWeights_OUTPUT.TXT';
PROC PRINTTO LOG=MYLOG PRINT=MYPRINT NEW;
RUN;

proc datasets library=work kill nolist; run; quit;
%let path = S:\CFACT\Shared\PMuhuri\MEPS_HC_QC;
libname new "&path\ProcMeansOutput";
libname newx "&path\ProcMeansAnalytics";
libname library "&path\ProcMeansAnalytics";

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
%macro vlist (ana_var=, s=, where = 1) ;                                                                                      
%local ds1 ds2 ds3 ds4 dscount j yr ;                                                                                                                     
%let ds1 = h209;
%let ds2 = h216;
%let ds3 = h224;
%let ds4 = h233;
%let dscount = 4; 
%do j = 1 %to &dscount; /* Loop through number of data sets */                                                                      
	%let yr=%sysfunc(putn(%eval(&j+17),z2.)); /* Generate values from 18 to 21 */
   		 proc means data=pufmeps.&&ds&j (where =(&where))
                             noprint;                                                                               
		  class agelast racethx;                                                                                                                
		  var &ana_var.&yr&s;            ; 
		  where &ana_var.&yr&s>0;
		  format agelast age_fmt. racethx race_fmt.;                                                                    
		  output out=new.&ana_var&yr.&s.%scan(&where,1, ' ') 
                     N= sum= mean= min= max= cv= / autoname;                                                                          
		 run;                                                                                                      
%end;                                                                                                                               
%mend vlist;                                                                                                                            
%vlist(ana_var=perwt, s=F) 
%vlist(ana_var=SAQWT, s=F)
%vlist(ana_var=DIABW, s=F)
%vlist(ana_var=perwt, s=F, where=insc1231 eq 1) 
%vlist(ana_var=SAQWT, s=F, where=insc1231 eq 1)
%vlist(ana_var=DIABW, s=F, where=insc1231 eq 1)

dm "log; clear; output; clear; odsresults; clear;";

* Get the datasets names into a macro variable;
libname LIB 'C:\Data';
proc sql noprint;
 select memname into :ds1 -
 from dictionary.tables
 where libname="NEW";
 %let dscount = &sqlobs;
quit; 
%put &=dscount;
%macro ref;
 %DO i = 1 %TO &dscount;
     %put  &&ds&i; 
 %END; 
%mend ref;
%ref

%macro vlist ;                                                                                      
%do j = 1 %to &dscount; /* Loop through all  datasets */ 
 Data newx.&&ds&j (drop =agelast: racethx:  _: );
   set new.&&ds&j indsname= source;
   length resp_type $14 year $4 keyvar $8;

   agelast_c = put(agelast, age_fmt.);
   racethx_c = put(racethx, race_fmt.);

   if strip(agelast_c)='.' then agelast_c= ' ';
   if strip(racethx_c)='.' then racethx_c= ' ';

   age_race_c = coalescec(agelast_c, racethx_c);
   if age_race_c= ' ' then age_race_c= 'Overall';

   retain _r1;
   if _N_ = 1 then _r1 = prxparse('/.+(\d{2})[C|F].+/');
   if prxmatch(_r1, source) then _yr = prxposn(_r1,1, source);
   year = '20'||_yr;

    retain _r2;
    if _N_ = 1 then _r2 = prxparse('/NEW\.(.+)\d{2}([C|F]).+/');
    if prxmatch(_r2,source) then 
     do;
       _first = prxposn(_r2,1, source);
	   _last = prxposn(_r2,2, source);
     end;
    keyvar = cats(_first, _last);

	if prxmatch('/[C|F]1$/', strip(source))  then resp_type = 'All';
	else if prxmatch('/1231$/', strip(source))  then resp_type = 'InScope Only';
	where _type_ in (0,1,2);
  run;
  proc sql noprint;
		 select strip(name) into :var1-
		 from dictionary.columns
		 where libname="NEWX" and memname="&&ds&j" and (name like '%WT%' or name like '%BW%');
		 %let num_vars=&sqlobs;
  quit;

	proc datasets library=newx;
	modify &&ds&j;
	rename
		%do i = 1 %to &num_vars;
		 &&var&i = %scan(&&var&i,-1,'_')
		%end; 
        ;
	quit;
%end;
%mend vlist;                                                                                                                            
%vlist

data newx.comb ;
 set newx.Perwt: newx.saqwt: newx.diabw:;
run;

proc sort data=newx.comb; 
 by year resp_type age_race_c keyvar ;
run;

proc transpose data=newx.comb  out=t_comb (drop=_LABEL_ rename=(_NAME_=stat col1=value));
by year resp_type age_race_c keyvar;
run;

proc sort data=t_comb; 
 by resp_type age_race_c keyvar stat ;
run;

proc transpose data=t_comb  out=tt_comb  prefix=Year;
id year;
var value;
by resp_type age_race_c keyvar stat;
run;

data newx.xt_comb;
 set tt_comb;
 length n_age_race_c $ 2;
 n_age_race_c = input(age_race_c, $n_age_race.);
 n_stat = input(stat, $yfmt.);
run;
proc sort data= newx.xt_comb; by n_age_race_c n_stat; run;


* direct the PROC REPORT output to an Excel workbook using a macro;

ods listing close;
/* Format the current date as "YYYY-MM-DD" */
%let current_date = %sysfunc(today());
%let formatted_date = %sysfunc(putn(&current_date., yymmdd10.));
%macro printit (text);
ods excel options(sheet_name="&text" embedded_titles="yes");
title "%sysfunc(date(),worddate.)";
title2 "MEPS Expenditure Weights (&text), 2018-2021";
proc report data=newx.xt_comb (where=(keyvar= "&text")); 
  column resp_type n_age_race_c age_race_c age_race_c2 stat n_stat year2018 year2019 year2020 year2021;
  define resp_type / order descending  "MEPS respondent type" width=25;
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
ods excel file="&path\MEPS_Three_Weights_2018To2022_&formatted_date..xlsx" options(sheet_interval='PROC');
%printit(PERWTF)
%printit(SAQWTF)
%printit(DIABWF)
     
ods excel close;
ods listing;

proc printto;
run;


