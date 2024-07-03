
``` SAS
* Author: Rick Wicklin ;
data Grades;
input First $8. Last $10. @;
do Test = 1 to 4;
   input Score @; output;
end;
datalines;
Tim     Albertson  93  89  78  84
Sharad  Gupta     100  95  92  98
Tim     Williams   85  82  70  74
Mandy   Albertson  95  86  90  95
Min     Chen       88  92  85  95
;
proc print data=Grades; run;
```
