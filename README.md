# DREs - DWC Research Extraction scripts

## Overview
A set of Powershell scripts and MSSQL queries to save data extracted from Philips Data Warehouse connect in-hospital databases as plain files to disk.

The scripts iterate through a list of patients, extract and save the waveform and parameter data as semi-colons separated files to disk.
At each iteration, the list of patients is refreshed to include the patients that newly checked in.
For each patient, the scripts save the last encountered timestamp in a pointer file.
The pointer file content is used as a starting point the next time the patient is encountered.


## Usage
```ps
cd src
./mssql2csv.ps1 -outfolder "Output data directory" -legal_pat "Path to file listing the patients to extract"
```
E.g.
```ps
./mssql2csv.ps1 -outfolder ..\data\ -legal_pat .\LegalPatients.txt
```


## Database Authentication
By default, the authentication method is with a local account in the database instance.
The username and the database details are hardcoded in [src/msql2csv.ps1](./src/mssql2csv.ps1#L14).
```ps
$server='ServerName'	#Server instance name
$db='InstanceName'	#Database name
$username='UserName'		#Credential: username
```

The password to the user account is passed via a prompted:
```ps
$pwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto(  [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass_secure)  )
```

In the case of authentication delegated to the Windows authenticator on the database sever, 
-  remove the `-Username $username -Password $pwd` options in the `invoke-sqlcmd` command of these files: [src/perform_query.ps1](./src/perform_query.ps1#L85), [src/build_pat_list.ps1](./src/build_pat_list.ps1#L15) and [src/get_pat_info.ps1](./src/get_pat_info.ps1#L16)
-  comment the prompt [src/msql2csv.ps1](./src/mssql2csv.ps1#L19)


## Patient identification

DWC uses an internal patient unique identifier. The scripts read the information entered in the lifetimeID field of monitors.

This can be adapted to different context and medical staff practices by editing the query:

- [src/patstringAttribute.sql](./src/patstringAttribute.sql)

For this make sure that the staff habits of entering IDs on the monitors matches with the entries expected in the `External_PatientStringAttribute` view.

In our case we rely on the lifetime ID field. The free text IDs are filtered for strings containing only numbers (see [src/msql2csv.ps1](./src/mssql2csv.ps1#L76)). Again this should be adapted to each context.
