
options nodate nonumber nosource;
ods html close;

*Ex11_download_unzip_create.sas;
*** Task 1: Download a particular ZIP SAS transport file from the MEPS web site;

Filename GoThere "C:\Data\h197gssp.zip";
proc http 
   url="https://meps.ahrq.gov/data_files/pufs/h197gssp.zip" 
   out=GoThere;
run;


*** Task 2: Unzip the SAS transport data file into the work folder;
filename inzip zip "c:\Data\h197gssp.zip" ;
filename sit "C:\Users\pmuhuri\downloads\h197g.ssp" ;
data _null_;
infile inzip(h197g.ssp) lrecl=256 recfm=F length=length eof=eof unbuf;
file sit lrecl=256 recfm=N;
input;
put _infile_ $varying256. length;
return;
eof: stop;
run;
