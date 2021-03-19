
/*********************************************************************************
* Topic: Comparing mean total payments for physician visits by speciality: 
* Private versus Medicaid Insutance  
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**** Program: 		Figures_FourFive_2014_2015.sas     		    ****
**** Author: 		Pradip Muhuri, Steve Machlin     		    ****
**** Purpose:  		Generate the estimates reported	        	    ****
**** 				in Figures 4 and 5 of                       ****
****                    Stat Brief #504    				    ****
**** Data Files 	1. full year consolidated files, 2014-2015          ****
****                    2. medical provider visit files, 2014-2015          ****
**********************************************************************************/
proc datasets nolist kill; quit;
proc format ;
 value agefmt 1= '0-17'
              2 = '18-64'
		      3 = '65+';
value ins_cat_F  0='Total'
                 1= 'Medicaid'
                 2='Private'
                 3='Other';
value regionfmt 0= 'Total'
                 1= 'NORTHEAST' 
                 2='MIDWEST' 
                 3='SOUTH' 
                 4 ='WEST'; 
value YY_speclty_F  0 = 'Total'
                 .N = ' '
                 .M = ' '
                 1 ='PRIMARY CARE'
                 2='PEDIATRICS'
                 3='PSYCHIATRY'
                 4='OPHALMOLOGY'
                 5='ORTHOPEDICS'
                 6 = 'Other';
value Rcvvac_F 0 = 'Total'
                  1 =  'Yes'
                  2 =  'No'
                  3 =  'No Service Received'
                  . = ' ';
run;
* 2014-2015 MEPS FY Consolidated Files ;	
%macro loop(dslist);
%local yr i ;
%let yr=14;
          %DO i = 1 %to %sysfunc(countw(&dslist, | ));
		               data fy_20&yr.rev; 
				       set %scan(&dslist, &i, |) 
                           (keep= dupersid agelast 
				            varstr varpsu perwt&yr.f
  				            region31 region42 region53 region&yr);

                    /* Create the age group variable */ 
                    if agelast<=17 then age_grp=1;
					else if 18<=agelast<=64 then age_grp=2;
					else if agelast>=65 then age_grp =3;

					/*create the region variable */
                    if region&yr>0  then region=region&yr;
					else if region&yr<0 and region42>0  then region=region42;
					else region=region31;	
	       FORMAT age_grp agefmt. region regionfmt.;
		   run;
		   proc sort data= fy_20&yr.rev; by dupersid; run; 
	  %let yr= %eval(1+&yr);
	  %end;
%mend loop;
%loop(%str(pufmeps.h171|pufmeps.h181))

*** Read visit-level files;

%macro loop (dslist);
 %local yr i ;
  %let yr=14;
          %DO i = 1 %to %sysfunc(countw(&dslist, | ));
		     data ob_20&yr.rev;  
             set %scan(&dslist, &i, | ) 
			    (keep= DUPERSID SEETLKPV SEEDOC varstr varpsu 
                           perwt&yr.f 
						   OBTC&yr.x  /* total charge */
						   OBXP&yr.x  /* the sum of the 12 sources of payment for the office-based expenditures */
						   OBSF&yr.x  /*self/family*/
                           OBMR&yr.x  /*Medicare */
						   OBOU&yr.x  /* other public insurance */
                           OBMD&yr.x  /*Medicaid*/
                           OBPV&yr.x /*private insurance*/
						   OBTR&yr.x  /*Tricare*/
			               OBVA&yr.x  /*Veterans*/
                           OBWC&yr.x  /* Workers Compensation*/
						   OBSL&yr.x  /* state and local (non-federal) government sources */
			               OBOF&yr.x /* other federal sources*/
                           OBOR&yr.x  /* other private insurance */
                           OBOT&yr.x  /*other insurance */
                           		               
                           ANESTH eeg ekg labtest mammog MEDPRESC mri 
                           RCVVAC SONOGRAM THRTSWAB XRAYS
                           SURGPROC drsplty   VSTCTGRY);

			          *3-category insurance variable;
				     if OBMD&yr.x >0 then Ins_cat=1;
	                 else if OBPV&yr.x >0 then Ins_cat=2;
                     else  Ins_cat=3;
					  				
					 * Year variable;
    				 xyear=cats(20,&yr);
                   run;
				   proc sort data=fy_20&yr.rev; by dupersid; run; 
 	            %let yr = %eval(&yr + 1);
               %end;
%mend loop;
%loop(%str(pufmeps.h168g|pufmeps.h178g))


run;
*** Merge the individual-level and visit-level files;
%macro run_by_year(start=, stop=);
   %do yr= &start %to &stop;
	    * merge obv EVENT and PERSON files to add the AGELAST variable from the PERSON file;
     	data obv20&yr.M_rev ;
	   		merge ob_20&yr.rev(in=a)
                  fy_20&yr.REV (in=b drop=perwt&yr.f varpsu varstr); by dupersid;       
			if a=b;
        run;  
		proc sort data=obv20&yr.M_rev; by varpsu varstr; run;
		run;
	 %end;
%mend run_by_year;
%run_by_year(start=14, stop=15);

data OBV2014_15_ana_rev;
   set OBV2014M_rev (in=File14)
       OBV2015M_rev (in=File15);

      if agelast<=17 & seedoc=1 & seetlkpv=1
      & (perwt14f>0 | perwt15f>0)
      & ins_cat >=1 and ins_cat <=2 then subpop_obv=1;
      else subpop_obv= 2;

     if file14=1 then do;
        perwt14_15f=perwt14f/2;
        obxp14_15x=obxp14x;
     end;
     if file15=1 then do;
       perwt14_15f=perwt15f/2;
       obxp14_15x=obxp15x;
     end;

* 6 category Specialty;
if drsplty = -1 then YY_specialty=.N;
else if drsplty in (-7, -8, -9) then YY_specialty=.M;
else if drsplty in (6, 8, 14) then YY_specialty=1;
else if drsplty = 24  then YY_specialty=2;
else if drsplty = 28 then YY_specialty=3;
else if drsplty = 19  then YY_specialty=4;
else if drsplty = 20 then YY_specialty=5;
else YY_specialty=6;
run;
proc sort data=OBV2014_15_ana_rev; by varpsu varstr; run;
proc descript data=OBV2014_15_ana_rev filetype=sas DESIGN=WR;
       		nest varpsu varstr  / missunit;
       		subpopn agelast<=17 & seedoc=1 & seetlkpv=1 & perwt14_15f>0
             & ins_cat >=1 and ins_cat <=2;
       		weight perwt14_15f;
			var obxp14_15x;
       		subgroup ins_cat  region;
       		levels   2 4;
			tables region*ins_cat ;
			rformat ins_cat ins_cat_F.;
			rformat region regionfmt.;
			setenv colwidth=18 decwidth=0;
      		print nsum wsum MEAN SEMEAN 
                  / STYLE=NCHS nsumfmt=F12.0 wsumfmt=F15.0  
                   meanfmt=f7.2 semeanfmt=F7.3 ;
		  run;

proc descript data=OBV2014_15_ana_rev filetype=sas DESIGN=WR;
       		nest varpsu varstr  / missunit;
       		subpopn agelast<=17 & seedoc=1 & seetlkpv=1 & perwt14_15f>0
             & ins_cat >=1 and ins_cat <=2;
       		weight perwt14_15f;
			var obxp14_15x;
       		subgroup ins_cat  YY_specialty ;
       		levels   2 6;
			tables YY_specialty*ins_cat ;
			rformat ins_cat ins_cat_F.;
			rformat YY_specialty YY_speclty_F.;
			setenv colwidth=18 decwidth=0;
      		print nsum wsum MEAN SEMEAN 
                  / STYLE=NCHS nsumfmt=F12.0 wsumfmt=F15.0  
                   meanfmt=f7.2 semeanfmt=F7.3 ;
		  
         run;

proc descript data=OBV2014_15_ana_rev filetype=sas DESIGN=WR;
       		nest varpsu varstr  / missunit;
       		subpopn agelast<=17 & seedoc=1 & seetlkpv=1 & perwt14_15f>0
             & ins_cat >=1 and ins_cat <=2;
       		weight perwt14_15f;
			var obxp14_15x;
       		subgroup ins_cat  YY_specialty ;
       		levels   2 6;
			Tables YY_specialty;
			rformat ins_cat ins_cat_F.;
			rformat YY_specialty YY_speclty_F.;
			CONTRAST ins_cat = (1 -1) /name="Medicaid vs. Private Insurance";
			setenv colwidth=18 decwidth=0;
      		print nsum wsum MEAN SEMEAN T_MEAN="T-Stat" P_MEAN="P-Value"
                  /STYLE=NCHS nsumfmt=F12.0 wsumfmt=F15.0  
                   meanfmt=f7.2 semeanfmt=F7.3 t_meanfmt=f7.4 p_meanfmt=f7.4;
			                    
         run;


proc descript data=OBV2014_15_ana_rev filetype=sas DESIGN=WR;
       		nest varpsu varstr  / missunit;
       		subpopn agelast<=17 & seedoc=1 & seetlkpv=1 & perwt14_15f>0
             & ins_cat >=1 and ins_cat <=2;
       		weight perwt14_15f;
			var obxp14_15x;
       		subgroup ins_cat  YY_specialty ;
			rformat ins_cat ins_cat_F.;
			rformat YY_specialty YY_speclty_F.;
       		levels   2 6;
			CONTRAST ins_cat = (1 -1)*YY_specialty = (1 -1 0 0 0 0) /name="Primary Care vs. Pediatrics P-M Diff";
			CONTRAST ins_cat = (1 -1)*YY_specialty = (1 0 -1 0 0 0) /name="Primary Care vs. Psychiatry P-M Diff";
            CONTRAST ins_cat = (1 -1)*YY_specialty = (1  0 0 -1 0 0) /name="Primary Care vs. Ophthalmology P-M Diff";
			CONTRAST ins_cat = (1 -1)*YY_specialty = (1 0 0 0 -1 0) /name="Primary Care vs. Orthopedics P-M Diff";
			CONTRAST ins_cat = (1 -1)*YY_specialty = (1 0 0 0 0 -1)/name="Primary Care vs. Others P-M Diff";

			CONTRAST ins_cat = (1 -1)*YY_specialty = (0 1 -1 0 0 0)/name="Pediatrics vs. Psychiaty P-M Diff";
            CONTRAST ins_cat = (1 -1)*YY_specialty = (0 1 0 -1 0 0)/name="Pediatrics vs. Ophthalmology P-M Diff";
            CONTRAST ins_cat = (1 -1)*YY_specialty = (0 1 0 0 -1 0)/name="Pediatrics vs. Orthopedics P-M Diff";
			CONTRAST ins_cat = (1 -1)*YY_specialty = (0 1 0 0 0 -1) /name="Pediatrics vs. Others P-M Diff";

            CONTRAST ins_cat = (1 -1)*YY_specialty = (0 0 1 -1 0 0)/name="Psychiatry vs. Ophthalmology P-M Diff";
            CONTRAST ins_cat = (1 -1)*YY_specialty = (0 0 1 0 -1 0)/name="Psychiatry vs. Orthopedics P-M Diff";
			CONTRAST ins_cat = (1 -1)*YY_specialty = (0 0 1 0 0 -1)/name="Psychiatry vs. Others P-M Diff";

            CONTRAST ins_cat = (1 -1)*YY_specialty = (0 0 0 1 -1 0)/name="Ophthalmology vs. Orthopedics P-M Diff";
			CONTRAST ins_cat = (1 -1)*YY_specialty = (0 0 0 1 0 -1)/name="Ophthalmology vs. Others P-M Diff";

            CONTRAST ins_cat = (1 -1)*YY_specialty = (0 0 0 0 1 -1)/name="Orthopedics vs. Others P-M Diff";


			setenv colwidth=18 decwidth=0;
      		print nsum wsum MEAN SEMEAN T_MEAN="T-Stat" P_MEAN="P-Value"
                  /STYLE=NCHS nsumfmt=F12.0 wsumfmt=F15.0  
                   meanfmt=f7.2 semeanfmt=F7.3 t_meanfmt=f7.4 p_meanfmt=f7.4;
			                    

         run;
   
