# DREs - DWC Research Extraction scripts

## Usage
```powershell
$ cd src
$ ./msql2csv.ps1 -outfolder <data directory> -legal_pat <path to file listing the patients to extract:w>
```

## Overview
A set of powershell scripts and MSSQL queries to retrieve data from Philips Data Warehouse connect inhospital installations.

**Patient identification** 
- Query: `src/patstringAttribute.sql`

- Information: DWC uses an internal patient unique identifier. The scripts read the information entered in the lifetimeID field of monitors. This can be adapted to different context and medical staff practices by editing the query.

**Continuous data extraction**

