
*** Create a folder called Data using DATA Step;
%LET RootPath=C:\; 
Data _Null_;
SubDIR='TestData';
FolderName=DCREATE(SubDIR,"&RootPath");
Put FolderName=;
Run;

* Delete the folder called TestData that was created earlier;
%let TargetPath=c:\TestData;
FILENAME FMyRep "&TargetPath";
%LET rc=%SYSFUNC(FDELETE(FMyRep));
%PUT rc=&rc;
FILENAME FMyRep CLEAR;

**** Create a folder called Data using %SYSFUNC and the
     DCREATE function in open code;
%LET RootPath=C:\;
%LET Folder=%SYSFUNC(DCREATE(TestData,&RootPath)); 
%PUT Folder=&Folder;

options symbolgen mprint;
%LET Folder=c:\Data;
%let sub_folders = TestFolder1 TestFolder2 TestFolder3 TestFolder4;
%put &=Folder;
%put &=Sub_folders;

%MACRO cf;
%DO i= 1 %to 4;
     %SYSFUNC(DCREATE(%scan(&sub_folders, &i),&Folder));
 %END; 
%MEND cf;
%cf
