
/********************************************************************************
ComparingAveOBVisitsLongitudinalFiles.SAS
Goals: Estimate the average number of ambulatory visits and changes in the average number
       of visits between years 1 and 2 among persosns ages 65 years or older,
       United States civilian non-institutionalized population

Data Used: Medical Expenditure Panel Surveys, Longitudinal Files, Panels 18-21
*************************************************************************************/
options nocenter nonumber nodate;
libname CDATA 'C:\Data';
* Create a macro variables with the variables of interest from MRPS Longitudinal Files;
%let kept_vars = DUPERSID AGEY1X ALL5RDS LONGWT VARSTR VARPSU OBTOTVY1 OPTOTVY1 OBTOTVY2 OPTOTVY2;

DATA WORK.POOL;
   SET CDATA.H183 (KEEP=&kept_vars) CDATA.H193 (KEEP=&kept_vars) CDATA.H202 (KEEP=&kept_vars);
   POOLWT = LONGWT/3 ; /* Pooled survey weight */

   * create the AMBULATORY-utilization variable for both years within apnel;
       array ambu[4] OBTOTVY1 OPTOTVY1 OBTOTVY2 OPTOTVY2;
         do i= 1 to 4;
        if ambu[i] <0 then ambu[i]=.;
        end;

       amb_v1 = sum(OBTOTVY1, OPTOTVY1);
       amb_v2 = sum(OBTOTVY2, OPTOTVY2);

  * create the DIFFERENCE  variable for the AMBULATORY-utilization variable;
	   diff_amb_v = amb_v2 - amb_v1;

  * create the DIFFERENCE  variable for the Office-based-visits-utilization variable;
	   diff_obv = OBTOTVY2 - OBTOTVY1;
  
   * Subpopulation of interest: Ages 65 or older and data were available for all 5 rounds in a panel;
   if AGEY1X GE 65 and ALL5RDS=1 then AGE65_plus=1; else   AGE65_plus=0;
RUN;

ODS GRAPHICS OFF;
ods listing; /* Open the listing destination*/
ODS EXCLUDE STATISTICS; /* Not to generate output for the overall population */
TITLE 'Medical Expenditure Panel Surveys, Longitudinal Files, Panels 18-21';
TITLE2 'Average number of ambulatory visits and changes in the average number of visits';
TITLE3 'between year 1 and year 2 among persons ages 65 years or older';
TITLE4 'United States civilian non-institutionalized population';
PROC SURVEYMEANS DATA=POOL; 
