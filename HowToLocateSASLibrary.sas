
/*********************************************************************************
* Topic: How to locate a folder (SAS Library) 
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/
 %put %sysfunc(pathname(SASUSER));
 %put %sysfunc(pathname(OneDrive));
 %put %sysfunc(pathname(OneDrive\HomeDrive));
 %put %sysfunc(pathname(HomeDrive));
 %put %sysfunc(pathname(HomeDrive2));

