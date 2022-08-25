# DREs - DWC Research Extraction scripts


## PowerShell Extraction Scripts. Tested for PowerShell v4.0 on a Windows Server 2012 R2. ##
## v1: 03-08-2017 Antoine Honore #################################################################

## 1) Overview: The script performs the queries listed in "extraction_query.txt" and for each patient listed and uncommented in "LegalPatients.txt". SQL server tends to throw Connection Timeout error if the data are extracted in one bloc. To avoid such a problem, the queries are executed iteratively, from row (a) to row (a+step),until the result of the query is NULL. The step value can be tuned in "perform_query.ps1". You can follow the procedure in a logfile "log.log".
The result is stored in a file named pat(1,2,3...)_(querynameWithoutextension)_from_(StartRow)_next(StepValue).csv

## 2) Example: >> .\msql2csv.ps1 "data\"

## 3) Argument: The only input is the relative path of the required output folder

## 4) Necessary files: mssql2csv.ps1, perform_query.ps1, get_pat_info.ps1, LegalPatients.txt, pwd.txt, extraction_query.txt, export_HF_cpy.sql, export_LF_cpy.sql, gethash_cpy.sql

## 5) Created files: log.log, PatientMapping.txt, datafiles...

## 6) Anonymization: The data are anonymized during the query. The personnummer of the patient is removed and stored in a mapping file "PatientMapping.txt". The date is scrambled by adding a random number of day to all the timestamps. This random number is stored in the mapping file.  

## 7) Scalability: In theory the scripts are not generalizable to any SQL query because the step value depends on the presence of HF or LF in the name of the query. In practice it is easy to solve this problem by removing a few lines in perform_query.ps1 (L11-18 are the problem).

## 8) Login to server: The servername, database name and username are hard coded at the beginning of the "mssql2csv.ps1". The password is saved in a separate file and MUST NOT leave the server.

## 9) Legal/ethics: The extracted patients are strictly contained in the file "LegalPatients.txt". No other patient is to be extracted. 
It is not the only file containing personnummer as copies of the personnummer can be found in the queries. (Easy to fix but not done)

## 10) Possible improvements for future versions: Multithread(Parallel) extraction: Extract several patients in parallel
Remove personnummer copy in the queries
