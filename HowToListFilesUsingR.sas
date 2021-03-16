/*********************************************************************************
* Topic: How to file names  
* Wtitten by Pradip Muhuri
* Use the program at your own risk (no warranties).
**********************************************************************************/

PROC IML;
SUBMIT / R;
setwd ("C:/Data/zipfiles")
 
list.files (path = "C:/Data/zipfiles")
list.files (path = "C:/Data/xptfiles")
list.files (path = "C:/Data/cptfiles")
list.files (path = "C:/Data/MySDS")

ENDSUBMIT;
QUIT;
