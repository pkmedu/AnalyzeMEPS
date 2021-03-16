
/******************************************************************** 
* Topic: Listing MEPS data file names dynamically;
* Labels can be added to the data set using PROC DATASETS (not done here)
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
***********************************************************************/
options nocenter nodate nonumber;
ods listing close; /* This prevents duplicate output */

/* Please modify this line to change the folder name */
ods excel file = 'C:\Data\MEPS_Datasets_rev2.xlsx'
   options (embedded_titles='on'  sheet_name='List'); 
title "Listing of MEPS Data Files (SAS Data Sets) from  CFACT's Shared Drive";
libname pufmeps  'S:\CFACT\Shared\PUF SAS files\SAS V8' access=readonly;
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
