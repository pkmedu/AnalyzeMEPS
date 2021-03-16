*This file resides in C:\Users\Pradip.Muhuri;
/*********************************************************************************
* Topic: How to add librefs to some of the routinely used SAS Libraries 
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/
libname pufmeps  'S:\CFACT\Shared\PUF SAS files\SAS V8' access=readonly;
libname HD "C:\Users\Pradip.Muhuri\OneDrive - HHS Office of the Secretary\HomeDrive";
libname HDTWO "C:\Users\Pradip.Muhuri\OneDrive - HHS Office of the Secretary\HomeDrive2";
%macro clib;
%do i= 1994 %to 2016;
  libname pufhis%substr(&i,3,2) "S:\CFACT\Shared\NHIS\NHIS&i" access=readonly;
%end;
%mend clib;
%clib
