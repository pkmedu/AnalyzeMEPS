
/* Load files */


FILENAME in_brr 'C:\Data\xptfiles\h36brr18.ssp';
proc xcopy in = in_brr out = WORK IMPORT;
run;

%LET DataFolder = C:\DATA\MySDS;  /* Adjust the folder name, if needed */
libname CDATA "&DataFolder"; 

%let kept_vars_2018 =  DUPERSID PERWT: VARSTR VARPSU TOTEXP: SEX;
data meps_2018x;
 set CDATA.h209 (keep= &kept_vars_2018);
run;
/* Merge BRR replicate weights onto FYC file */ 
proc sort data = h36brr18 nodupkey; by DUPERSID; run;
proc sort data =meps_2018x nodupkey; by DUPERSID; run;

data fyc_brr;
	merge 
		meps_2018x (in = a) 
		h36brr18;
	by DUPERSID;
	if a;

	/* Multiply BRR Weights by 2 and PERWT17F */
	array BRR  {*} BRR1-BRR128;
	array BRRW {*} BRRW1-BRRW128;
	do i = 1 to 128;
		BRRW{i} = 2*BRR{i}*PERWT18F;
	end;
run;

ods graphics off;
title 'Default Standard Errors using Taylor Series expansion';
PROC SURVEYMEANS DATA = h201 mean median clm;
	STRATA  VARSTR ;
	CLUSTER VARPSU;
	WEIGHT PERWT18;
	var totexp18;
	DOMAIN sex;
RUN;

title 'BRR standard errors using REPWEIGHTS';
PROC SURVEYMEANS DATA = fyc_brr varmethod=brr mean median clm;
	WEIGHT PERWT18F;
	REPWEIGHTS BRRW1-BRRW128;
	var totexp18;
	DOMAIN sex;
RUN;
