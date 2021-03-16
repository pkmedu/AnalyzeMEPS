
/*********************************************************************************
* Topic: Working with SAS Transport files 
* PROC COPY, PROC CPORT, PROC CIMPORT
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/

*** Create a SAS Transport file using PROC COPY;
proc datasets kill; quit;
libname my_lib xport "c:\temp\x_class.xpt";                                                                                            
proc copy in=sashelp out=my_lib; 
 select class;
run;
proc datasets; quit; 
*** Create a SAS data set from the SAS transport file;

libname my_lib xport "c:\temp\x_class.xpt";  /* not required if added earlier */
proc copy in=my_lib out=work;   
Run;               
proc datasets library = work nolist; 
change class=r_class;
quit; 

*** Print the meta data from the SAS data set;
ods select all;
proc sql;
select memname,
       nobs format =comma9.
       ,nvar format =comma9.
from dictionary.tables
 where libname='WORK' and memname = "R_CLASS";
 quit;
run;

* The following code creates a SAS Transport file using PROC CPORT;
filename SaveTo 'U:\A_DataRequest\class.cpt'; 
* Use of data statement to specify only one dataset;
proc cport
     data=SASHELP.CLASS
     file=SaveTo;
run;
* Restore SAS Transport file back to a SAS data set using PROC CPORT;
libname sasfiles 'U:\_misc'; 
filename cptfiles 'U:\A_DataRequest\class.cpt'; 
PROC CIMPORT FILE=cptfiles LIBRARY=sasfiles;
RUN;

ods select all;
proc sql;
select memname,
       nobs format =comma9.
       ,nvar format =comma9.
from dictionary.tables
 where libname='SASFILES' and memname = "CLASS";
 quit;
run;
