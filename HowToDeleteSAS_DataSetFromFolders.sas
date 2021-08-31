
libname new ('C:\Data\Zip_folder' 'C:\Data\Xpt_folder' 
             'C:\Data\Cpt_folder' 'C:\Data\SDS_folder');
proc datasets library=new kill;
run;
quit;
