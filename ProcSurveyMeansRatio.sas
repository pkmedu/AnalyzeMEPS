/*********************************************************************************
ProcSurveyMeansRatio.sas
Topic: Generate ratio estimates for means or proportions of analysis variables 
Wtitten by Pradip Muhuri
Use the program at your own risk (no warranties).
**********************************************************************************/
Options nocenter nodate nonumber ls=132; 
LIBNAME pufmeps 'C:\Data';
proc format;
value povcat_fmt 
    1 = 'Poor'
    2,3 = 'Near Poor/Low Income'
	4 = 'Middle Income'
    5 = 'High Income';
run;
proc surveymeans data=pufmeps.h209;
  			stratum varstr;
  			cluster varpsu;
  			var  totexp18 obvexp18  optexp18 
                 ertexp18 iptexp18 rxexp18 hhaexp18;
			weight perwt18f;
            ratio obvexp18  optexp18 ertexp18 
                  iptexp18 rxexp18 hhaexp18 / totexp18;
			*ods output domainratio=domain_ratio;	
run;
