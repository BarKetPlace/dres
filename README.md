# DREs - DWC Research Extraction scripts

## Overview
A set of Powershell scripts and MSSQL queries to save to disk data extracted from Philips Data Warehouse connect in-hospital databases.

The scripts iterate through a list of patients, extract and save the waveform and parameter data as semi-colons separated files to disk.
At each iteration, the list of patients is refreshed to include the patients that newly checked in.
For each patient, the scripts save the last encountered timestamp in a pointer file.
The pointer file content is used as a starting point the next time the patient is encountered.


## Usage
```powershell
cd src
./msql2csv.ps1 -outfolder <Output data directory> -legal_pat <Path to file listing the patients to extract>
```

## Details

**Patient identification** 

- DWC uses an internal patient unique identifier. The scripts read the information entered in the lifetimeID field of monitors. This can be adapted to different context and medical staff practices by editing the query.

- Query: `src/patstringAttribute.sql`
