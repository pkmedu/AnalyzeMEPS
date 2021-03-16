

/*********************************************************************************
* Topic: Documenting formats and managing entries in format catalogs 
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/

proc datasets lib=work nolist kill; quit; /* Delete  all files in the WORK library */
OPTIONS NOCENTER LS=155 PS=79 NODATE NONUMBER FORMCHAR="|----|+|---+=|-/\<>*" PAGENO=1;

proc format;
value sex_fmt 1 = 'Male'
              2 = 'Female';
value povcat_fmt 
    1   = 'Poor'
    2,3 = 'Near Poor/Low Income'
	4   = 'Middle Income'
    5   = 'High Income';
run;
proc format lib=work fmtlib;
run;
proc catalog cat=work.formats;
 contents;
run;
