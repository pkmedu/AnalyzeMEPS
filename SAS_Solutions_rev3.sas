/**************************************************************************** 
* SAS Program: Web Scraping to create a List of All MEPS-HC Data File Links *
*****************************************************************************/

DM "Log; clear; output; clear; odsresults; clear";
options mprint nocenter nodate nonumber nosymbolgen;
proc datasets  lib=work kill  nolist; quit; 
filename source 'C:\MySUG\web_file.txt';
proc http
     url = "https://meps.ahrq.gov/data_stats/download_data_files.jsp"
     out=source;
run;

/* Step 2:  Parsing source code and saving the necessary variable in a SAS data set */
data FileId (keep = file_id);  
	length file_id $ 10; 
	infile source length = reclen lrecl = 32767; 
	input string $varying32767. reclen;  
	position = prxmatch('m/"HC-\w+/i',string); 
	if find(string,'CD-ROM','i') ^= 0 
	    | find(string,'IC Linked Data',' i') ^= 0 
	    | find(string,'replaced','i') ^= 0
	    | find(string,'Population Characteristics','i') ^= 0 then position = 0;
	 
	if position ^= 0 then do;
	    file_id = scan(string, 2, '"');
	    output;
	end;
run;

proc transpose data = FileID prefix = file_ out=wide;
  var file_id;
  where ranuni(0) <0.02;
run;
proc print data = wide noobs;
run;

/* Step 3: Creating macro variables using CALL SYMPUTX  */
  data _null_;
	  set FileID end = eof;
	  link = "https://meps.ahrq.gov/data_stats/download_data_files_detail.jsp?cboPufNumber=";
	  count+1;
	  call symputx(cats('url1_', count),cats(link, file_id));
	  if eof then call symputx('max',count);  
   run;  

 options symbolgen;
 %put &=url1_1;
 %put &=url1_2;
 %put &=url1_365;
 %put &=max;

/* Step 4:  Creating parts of SAS steps using an iterative %DO loop in a macro */

options nosymbolgen nomprint;
%macro runit;
  %do i = 1 %to &max;
	filename source "C:\MySUG\url2_&i..txt";
	
 /* Running PROC HTTP for each value of url1_&i  */
	proc http
	url = "&&url1_&i"
     out = source;
	run;

/* Creating data file names/descriptions and data file format-specific URLs */
    Filename source "C:\MySUG\url2_&i..txt";
	data url2_&i (keep =  url2)
         summary_&i (keep = fname); 
	 	length url2 $ 75 fname $ 85; 
	 	infile source length = reclen lrecl = 32767; 
     	input string $varying32767. reclen;  

		/* Creating data file names/descriptions  */
     	d_position = prxmatch('m/class="OrangeBox"/',string);      	
     	if d_position ^= 0 then do;
	    	fname = scan(scan(scan(string, 2, '#'), 2, '>'), -2,'<') ;
	 	end;
	
		/* Creating data file format-specific URLs */
		u_position = prxmatch('m/class="sectionDividerGrey"/',string); 	 	  
     	if u_position ^= 0 and index(string, 'zip') > 0 then do;
 	  	 	url2 = cats('https://meps.ahrq.gov',  scan(string, 2, '.'), '.zip');
		end;

		if url2 ne  '  ' then output url2_&i;  /* Detailed  data set */
		if fname ne  ' ' then output summary_&i; /* Summary data  set */
 	run;

 /* Adding the summary information to the detailed data set */
		data url2s_&i;
           if _n_ = 1 then set summary_&i;
  		   set url2_&i;
  		run;
%end;
%mend runit;
%runit
options ls = 132;
proc print data = url2s_1 label;
var fname url2;
label fname = 'MEPS-HC PUF name'
  	url2 = 'Data file format-specific URLs'; 
run;

/* Step 5: Concatenating SAS data sets */
libname new 'c:\MySUG';
data new.all_url2s;
   set url2s_:;
run;

/* Step 6: Running PROC PRINT and routing the output to an Excel spreadsheet */
ods listing close;
ods excel file = 'C:\MySug\Trigger_URLs.xlsx'
   options (embedded_titles = 'on'  sheet_name = 'Sheet1'); 
   title 'Listing Data File Format-Specific URLs by MEPS PUF names';
        proc report data=new.all_url2s; 
        column fname url2;
        define fname / display;
        define url2 / order;
         compute URL2;
           call define(_col_,"url2",url2);
        endcomp;
        run;
title;
ods excel close;
ods listing;


/* Code block 7: Testing url2s HTTP requests */
%macro runit_x;
%local i url2_list num_url2s ;  
proc sql noprint;                                                                                                                              
  select quote(strip(url2))                                                                                                         
  INTO  :url2_list separated by '|'                                                                                              
  from new.all_url2s;   
  %let num_url2s = &sqlobs; 
quit;                                                                                                                                   
                                                                                                                   
%do i = 1 %to &num_url2s; 
    proc http  url = %scan(&url2_list,&i,%str(|));
	run;
    data scode&i;
	  status_code = "&SYS_PROCHTTP_STATUS_CODE";
    run;
%end; 
%mend runit_x;                                            
%runit_x

data scode_all;
 set scode:;
 _200_ok = (status_code eq '200');
 _ErrorFound = (status_code ne '200');

run;

proc sql;
    select sum(_200_ok) as Count_200_ok format=comma7.,
      sum(_ErrorFound) as Count_ErrorFound format=comma7.
from scode_all;
quit;

proc contents data = scode_all p;
ods select variables;
run;
