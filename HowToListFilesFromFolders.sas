

proc options option=RLANG;
run;

PROC IML;
SUBMIT / R;
setwd ("C:/Data")
list.files(pattern="SAS*", full.names = TRUE, ignore.case = TRUE) 
ENDSUBMIT;
QUIT;

options nodate nonumber notes source;
 ods html close;
 Filename filelist pipe "dir /b /s c:\Data\SDS_Folder\*.SAS7bdat";
 Data Flist;                                        
     Infile filelist truncover;
     Input filename $100.;
	  /* Put filename=; */
   Run; 
  proc print data=Flist;
  run;
