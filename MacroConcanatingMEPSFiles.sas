/*********************************************************************************
* Topic: Concatenating multiple MEPS files using a Macro 
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/
OPTIONS nocenter nodate nonumber symbolgen;
libname pufmeps  'S:\CFACT\Shared\PUF SAS files\SAS V8' access=readonly;
libname new 'U:\A_DataRequest';
libname xnew 'U:\A_DataRequest\SDS';
proc datasets nolist kill; quit;

%macro loops(file) / mindelimiter=',' minoperator;
     %local xcount i yr;                                             
     %let xcount=%sysfunc(countw(&file, %STR(|))); /* Count the number of data sets*/
     %do i = 1 %to &xcount; /* Loop through the total # of data sets */   
	     %let yr=%sysfunc(putn(%eval(&i-1),z2.)); /* Generate values from 00 to 15*/
             data xnew.FY_&yr;
               set pufmeps.%scan(&file,&i,%str(|)) 
                  (keep= totexp: perwt:
						%if %scan(&file,&i,%str(|)) in (h50, h60) %then %do;
						      varstr&yr varpsu&yr
		                %end;
						%else %do;
						   varstr varpsu
		                %end;
				
                       rename=(
 				               %if %scan(&file,&i,%str(|)) in (h50, h60) %then %do;
				                  varpsu&yr=varpsu
		                          varstr&yr=varstr
                               %end;
                               )
                  );
		             year=20&yr.;
		             if totexp&yr >=0 then nmiss_exp=1; 
                     if totexp&yr >0 then any_exp=1;
             run;
    %end;
  %mend loops;
%loops(h50|h60|h70|h79|h89|h97|h105|h113|h121|h129|h138|h147|h155|h163|h171|h181)




