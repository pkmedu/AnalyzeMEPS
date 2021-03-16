/*********************************************************************************
* Topic: How to create folders dynamically (Various) 
* Wtitten by Pradip Muhuri
* Acknowledgements: Online Sources
* Use the program at your own risk (no warranties).
**********************************************************************************/

%LET RootPath=c:\mydata; *common usage : never complete a path with a separator;
%LET Folder=%SYSFUNC(DCREATE(MyNewFolder,&RootPath)); * separator unnecessary;
%PUT Folder=&Folder;
%LET RootPath=C:\; 
Data _Null_;
SubDIR='TeachingSAS';
FolderName=DCREATE(SubDIR,"&RootPath");
Put FolderName=;
Run;

*Macro Function;
%LET Folder=%SYSFUNC(DCREATE(MacroFolder,&RootPath)); 
%PUT Folder=&Folder;

%LET RootPath=c:\SASCourse;
%MACRO CF (start, stop);
  %DO num= &start %to &stop;
     %LET Folder1=%SYSFUNC(DCREATE(Week&num,&RootPath));
  %END; 
%MEND CF;
%CF(1,15)

%let TargetPath=c:\data\temp\Folder;
FILENAME FMyRep "&TargetPath";
%LET rc=%SYSFUNC(FDELETE(FMyRep));
%PUT rc=&rc;
FILENAME FMyRep CLEAR;
Russ Tyndall





