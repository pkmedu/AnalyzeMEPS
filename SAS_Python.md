
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
```Python
import pandas as pd
import io

# Create the data as a string
data_string = """First,Last,Test,Score
Tim,Albertson,1,93
Tim,Albertson,2,89
Tim,Albertson,3,78
Tim,Albertson,4,84
Sharad,Gupta,1,100
Sharad,Gupta,2,95
Sharad,Gupta,3,92
Sharad,Gupta,4,98
Tim,Williams,1,85
Tim,Williams,2,82
Tim,Williams,3,70
Tim,Williams,4,74
Mandy,Albertson,1,95
Mandy,Albertson,2,86
Mandy,Albertson,3,90
Mandy,Albertson,4,95
Min,Chen,1,88
Min,Chen,2,92
Min,Chen,3,85
Min,Chen,4,95"""

# Read the data into a pandas DataFrame
Grades = pd.read_csv(io.StringIO(data_string))

# Print the DataFrame
print(Grades)
```
```sas
proc means data=Grades ;
   by First notsorted;      
   var Score;
run;
```
```Python
import pandas as pd
import io

# Assuming we've already created the Grades DataFrame as in the previous example
# If not, we'll need to recreate it here

# Group by 'First' name and calculate summary statistics
summary_stats = Grades.groupby('First', sort=False)['Score'].agg(['count', 'mean', 'std', 'min', 'max'])

# Rename columns to match SAS output
summary_stats = summary_stats.rename(columns={
    'count': 'N', 
    'mean': 'Mean', 
    'std': 'Std Dev', 
    'min': 'Minimum', 
    'max': 'Maximum'
})

# Print the summary statistics
print(summary_stats)

```
