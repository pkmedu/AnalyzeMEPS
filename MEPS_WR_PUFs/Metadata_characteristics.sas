

proc print data=sashelp.vcolumn label;
  var memname name type format length label;
  where libname='PUFMEPS' and memname in ('H204', 'H212', 'H219', 'H228') and 
    name like '%WT%P';
run;

proc print data=sashelp.vcolumn label;
  var memname name type format length label;
  where libname='PUFMEPS' and memname in ('H204', 'H212', 'H219', 'H228') and 
    prxmatch('/WT\d{2}P/i', name);
run;


proc print data=sashelp.vcolumn label;
  var memname name type format length label;
  where libname='PUFMEPS' and memname in ('H233') and 
    label like '%LIMITATION%';
run;

proc print data=sashelp.vcolumn label;
  var name type length label;
  where libname='PUFMEPS' and memname in ('H233') and 
    prxmatch('/LIMITATION|DIFFICULTY/i', trim(label)) and 
	prxmatch('/5\/3$/i', trim(label)) and
    not prxmatch('/SOCIAL|SCHOOL/i', trim(label));
run;

proc print data=sashelp.vcolumn label;
  var name type length label;
  where libname='PUFMEPS' and memname in ('H233') and 
    prxmatch('/LIMITATION|DIFFICULTY/i', trim(label)) and 
	prxmatch('/3\/1$/i', trim(label)) and
    not prxmatch('/SOCIAL|SCHOOL/i', trim(label));
run;

%macro runit (F, L);
proc print data=sashelp.vcolumn label;
  var name type length label;
  where libname='PUFMEPS' and memname in ('H233') and 
    prxmatch('/LIMITATION|DIFFICULTY|ADL|IADL/i', trim(label)) and 
	prxmatch("/&F\/&L$/i", trim(label)) and
    not prxmatch('/SOCIAL|SCHOOL|DRESSING|ALONE|HOUSEWORK/i', trim(label)) ;
run;
%mend runit;
%runit(3,1)
%runit(5,3)
%runit(4,2)







