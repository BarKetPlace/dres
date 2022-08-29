# DREs - DWC Research Extraction scripts

## Overview
A set of powershell scripts and MSSQL queries to retrieve data from Philips Data Warehouse connect inhospital installations.

**Patient identification** 
- Query: `src/patstringAttribute.sql`

- Information: DWC uses an internal patient unique identifier. The scripts read the information entered in the lifetimeID field of monitors. This can be adapted to different context and medical staff practices by editing the query.

**Continuous data extraction**


## PowerShell Extraction Scripts. Tested for PowerShell v4.0 on a Windows Server 2012 R2. ##
v1: 03-08-2017 Antoine Honore #################################################################

1) Overview: The script performs the queries listed in "extraction_query.txt" and for each patient listed and uncommented in "LegalPatients.txt". SQL server tends to throw Connection Timeout error if the data are extracted in one bloc. To avoid such a problem, the queries are executed iteratively, from row (a) to row (a+step),until the result of the query is NULL. The step value can be tuned in "perform_query.ps1". You can follow the procedure in a logfile "log.log".
The result is stored in a file named pat(1,2,3...)_(querynameWithoutextension)_from_(StartRow)_next(StepValue).csv

