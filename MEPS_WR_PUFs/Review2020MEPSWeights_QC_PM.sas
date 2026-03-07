/******************************************************************************************
* Solution 2
* SAS program (Draft) that reproduces the Philippe's Visual Basic output 
* except for two (?) items (no data found or specs not given?)
* for MEPS weights-QC tables;
* Version: Sept 2023 
* Input data: SAS Output in Excel spreadsheet
* I have renamed the Excel spreadsheet 'Tab' as 'Tab1'.
* Written by Pradip Muhuri
*****************************************************************************************/
dm "log; clear; output; clear; odsresults; clear;"
%let path = C:\Data;
libname new "&path";

filename mylog "&path\Solution2_QC_log.txt";
filename myprint "&path\Solution2_output.txt";
proc printto log=mylog print=myprint new;
run;

options nodate nonumber nodate;
Libname new "&path\QC_Weights";
Libname xl xlsx "&path\QC_data.xlsx";

* Create user-defined formats;
proc format;
value race_fmt 1 = 'Hispanic'
			   2 = 'Non-Hispanic Black'
			   3 = 'Asian'
               4  = 'Other'
			   . ='All';
value pov_fmt 1 = 'Below poverty'
              2 = '100-124 percent'
              3 = '125-199 percent'
              4 = '200-399 percent'
              5 = '400 or more percent';

value age_fmt 1 = '<1 yr (Weighted count or WC)'
              2 = '1 to 4 yrs (WC)'
			  3 = '5 to 9 yrs (WC)'
			  4 = '10 to 14 yrs (WC)'
			  5 = '15 to 17 yrs (WC)'
			  6   = '18 yrs (WC)'
			  7 = '19 to 25 yrs  (WC)'
			  8 = '26 to 29 yrs (WC)'
			  9 = '30 to 34 yrs (WC))'
			  10 = '35 to 44 yrs (WC)'
			  11 = '45 to 54 yrs (WC)'
			  12 = '55 to 59 yrs (WC)'
			  13 = '60 to 64 yrs (WC)'
			  14 = '65 to 69 yrs (WC)'
			  15 = '70 to 74 yrs (WC)'
			  16 = '75 to 79 yrs  (WC)'
			  17 = '80 yrs or older (WC)'
              .  = 'All (WC)';

value xfmt 1 = 1
           2 = 2
	       3 = 3
		   4 = 4
           . = 5;

value $stat 'N' = 'Unweighted MEPS count'
        'Mean', 'MEAN' = 'Mean'
		'Min', 'MIN' = 'Minimum'
		'Max', 'MAX' = 'Maximum'
		'CV', 'cv' = 'Coefficent of variation (%)'
        'Sum','SUM' = 'Weighted MEPS count';

value $yfmt 'N' = '1'
        'Mean', 'MEAN' = '2'
		'Min', 'MIN' = '5'
		'Max', 'MAX' = '4'
		'CV', 'cv' = '3'
        'Sum','SUM' = '6';

value mixedvalue
		low-<100 = [4.1]
		100-999 = [3.]
		1000-high = [comma12.];

value $name_fmt 
               'COL1', '1' = 'Dec 31 respondents only'
			   'COL2', '2' = 'All respondents';	

/* We may not need this format but created it to mimic Philippe's Excel table format. */
value grp_step_fmt 
               1 = 'Initial Weight'
			   2 = 'Weight trimming by RACETHNX'
			   3 = 'Ratio MEPS-CPS estimates before raking'
			   4 = 'Final raked weighted - Dec 31 resp only'
			   5 = 'Final Weight'
			   6 = 'FY Final Weight Stats - Dec 31 resp only'
			   7 = 'FY Final Weight Stats - All resp';			  
run;

* Read the SAS output from 13 Excel spreadsheets directly into SAS;
%macro runit (tabnum=, v1=, v2=, part=);
data new.File&tabnum._&part;
 set xl."tab &tabnum.$&v1.:&v2."n;
run;
%mend runit;
%runit(tabnum=2, v1=A9, v2=G10, part=0)

%runit(tabnum=3, v1=A9, v2=G10, part=0)
%runit(tabnum=5, v1=A9, v2=G10, part=0)
%runit(tabnum=6, v1=A9, v2=I13, part=0)
%runit(tabnum=7, v1=A9, v2=G10, part=0)
%runit(tabnum=8, v1=A9, v2=G10, part=0)
%runit(tabnum=9, v1=A9, v2=I13, part=0)
%runit(tabnum=10, v1=A6, v2=C12, part=1)
%runit(tabnum=10, v1=A28, v2=C34, part=2)
%runit(tabnum=10, v1=A41, v2=C48, part=3)
%runit(tabnum=10, v1=A55, v2=C60, part=4)
%runit(tabnum=10, v1=A67, v2=C70, part=5)
%runit(tabnum=10, v1=A28, v2=C34, part=6)
%runit(tabnum=10, v1=A77, v2=C95, part=7)
%runit(tabnum=10, v1=A102, v2=C107, part=8)

%runit(tabnum=10, v1=A114, v2=C117, part=9)
%runit(tabnum=10, v1=A124, v2=C130, part=10)
%runit(tabnum=10, v1=A137, v2=C145, part=11)
%runit(tabnum=10, v1=A152, v2=C158, part=12)
%runit(tabnum=10, v1=A165, v2=C170, part=13)
%runit(tabnum=10, v1=A177, v2=C196, part=14)

%runit(tabnum=11, v1=A6, v2=I36, part=0)

%runit(tabnum=12, v1=A8, v2=I38, part=1)
%runit(tabnum=12, v1=A48, v2=I78, part=2)
%runit(tabnum=12, v1=A88, v2=I188, part=3)
%runit(tabnum=12, v1=A128 v2=I158, part=4)

%runit(tabnum=13, v1=A6, v2=I36, part=0)

%runit(tabnum=14, v1=A8, v2=I38, part=1)
%runit(tabnum=14, v1=A48, v2=I78, part=2)
%runit(tabnum=14, v1=A88, v2=I118, part=3)
%runit(tabnum=14, v1=A128, v2=I158, part=4)

/**********************************************
* Item 1
* Concatenate aggregate values of N SUM (PERWTF20)
* for 'Dec 31 respondents' vs.  'All respondents'. 	
**********************************************/

data File5_8;
 set new.File5_0 new.File8_0;
run;

/*********************************************
* Item 1 (Continued)
* Restructure the SAS data set (wide format to long format)
* for  'Dec 31 respondents' vs. 'All respondents'.
* Use double transposition.	
* Direct the PROC REPORT to an Excel sheet.
**********************************************/

/* Do simple row-column transposition for N and SUM */
proc transpose data=File5_8
    out=t_File5_8 (drop=_LABEL_) name=stat;
var N SUM;
run;

/* Do the second transposition - wide format to long format. */
proc transpose data=t_File5_8
    out=tt_File5_8;
by stat;
run;

/* You can change the sorting order if desired. */
proc sort data=tt_File5_8 out=Overall_by_rsep_type; 
by  _NAME_;
run;

/*************************************************
* Direct the PROC REPORT output to an Excel sheet.
**************************************************/
ods listing close;
Title "Table 1: N and weighted count (overall all) for PERWTyyF for two respondent types";
Title2 "using data from the SAS output in Excel sheets - Item 1 (Solution 2)";
ods excel file="&path\QC_MEPS_Weights_draft.xlsx"
  options(sheet_name="tab1" row_heights="0,0,0,14,0,0" sheet_interval='PROC'
  embedded_titles="yes" Title_footnote_width="80");
proc report data=Overall_by_rsep_type; 
  column   _NAME_   stat COL1;
  define stat / display  "Description" format= $stat. width=25;
  define _NAME_ /  "Respondent Type" order format= $name_fmt. width=25;
  define COL1 / display "FY20" Format =  mixedvalue. width=25;
 run;

/**********************************************
* Item 2
* Print the weighted count (PERWTF20) by age group 
* (17 categories)for  'Dec 31 respondents' vs.  'All respondents'.	
* We are not restructuring the data here.
**********************************************/
data File10_7x;
  set new.File10_7;
  _NAME_ = 'COL1';
run;
Title "Table 2: N and Weighted Count for PERWTyyF by age group";
Title2 "using data from the SAS output in Excel sheets - Item 2 (Solution 2)";;
ods excel options(sheet_name="tab2" row_heights="0,0,0,14,0,0" sheet_interval='PROC'
  embedded_titles="yes" Title_footnote_width="80");
proc report data=File10_7x; 
  column _NAME_ R_AGE17 WGT_CNT;
  define _NAME_ /  "Respondent Type" order format= $name_fmt. width=25;
  define R_AGE17 / display  "Description" format= age_fmt. width=25;
  define WGT_CNT / display "FY20" Format =  mixedvalue. width=25;
 run;

/**********************************************************
* Item 3
* Add the 'overall' row of  N SUM MEAN CV  MIN MAX (PERWTF20)
* to race/ethnicity-specific rows of the same six values.
* We concatenate the rows for  
* 'Dec 31 respondents' vs.  'All respondents'.	
************************************************************/

data new.File6x_0;
  set new.File5_0  new.File6_0;
  _name_='COL1';
run;
data new.File9x_0;
  set new.File8_0  new.File9_0;
  _name_='COL2';
run;

/***********************************************************
* Item 3 (Continued)
* Restructure the SAS data set (wide format to long format). 
* Direct the PROC REPORT to an Excel sheet
* for 'Dec 31 respondents' vs.  'All respondents' using a macro.	
***********************************************************/

%macro runit(n);
proc sort data= new.File&n.x_0(drop=N__obs sum median  
         rename=(Coeff_of__variation =cv))
out=File&n.x_0;
by racethnx ;
run;
proc transpose data=File&n.x_0 
    out=t_File&n.x_0 (drop=_LABEL_) name=stat;
by racethnx;
run;
proc sort data= t_File&n.x_0 ;
by stat;
run;
%mend runit;
%runit(6)
%runit(9)

/***********************************************************
* Item 3 (Continued)
* Concatenate observations for 'Dec 31 respondents' vs.  'All respondents'.	
***********************************************************/
data new.Review2020Data;
  set t_File6x_0 (in = a rename=(COL1=FY20))
      t_File9x_0 (in=b rename=(COL2=FY20));
	  s_racethnx = put(racethnx, xfmt.);
	  s_stat = put(stat, $yfmt.);
if a=1 then _name_ = '1';
else if b=1 then _name_ = '2';
run;
proc sort data=comb;
  by _name_  s_racethnx s_stat;
run;

/***********************************************************
* Item 3 (Continued)
* Direct the PROC REPORT to an Excel sheet
* for 'Dec 31 respondents' vs.  'All respondents' using a macro.	
***********************************************************/
Title "Table 3: Five measures of PERWTyyF by race/ethnicity for two respondent types";
Title2 "using data from the SAS output in Excel sheets - Item 3 (Solution 2)";
ods excel options(sheet_name="tab3" row_heights="0,0,0,14,0,0" sheet_interval='PROC'
  embedded_titles="yes" Title_footnote_width="80");
proc report data=new.Review2020Data; 
  column _name_ RACETHNX  stat  FY20   ;
  define _NAME_ /  "Respondent Type" order descending format= $name_fmt. width=25;
  define RACETHNX /  display "Race-ethnicity" format= race_fmt. width=25;
  define stat  /  "Description" order order=data format= $stat. width=25;
  define FY20 / display "FY20" Format =  mixedvalue. width=25;
 run;
ods excel close;
ods listing;
title;
proc printto;
run;


