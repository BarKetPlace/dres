# DREs - DWC Research Extraction scripts
Data Warehouse Connect (DWC) databases are setup in hospital subnetworks inaccessible to outside research organisation.
Buying hardware and training IT staff to maintain and administer multiple database mirrors in different subnetworks requires investments not all hospitals can afford.
To enable data extraction for research for a large of institution, we developed simple scripts to continuously extract, transfer and pre-process monitor data from DWC.

The scripts are designed to be robust to network interruption and un-expected machine shutdown.
It is assumed that standard Windows software are provided on the database servers and intermediade machines. 
See the **Requirements** subsections for details.

## LICENSE
All hospital monitoring systems have different installations environment and specificities.
To enable a wide usage, we believe that any variation of these scripts, required to adapt them to a new IT environment should remain open source.
We therefore chose to license this project under GNU GENERAL PUBLIC LICENSE Version 3.

## Content
There are three sets of scripts for different pipeline operation
- [Extraction](./README.md#extraction-overview)
- [Transfer](./README.md#transfer-overview)
- [Parsing](./README.md#parsing-overview)

## Extraction overview
A set of Powershell scripts and MSSQL queries to save data extracted from Philips Data Warehouse connect in-hospital databases as plain files to disk.

The scripts iterate through a list of patients, extract and save the waveform and parameter data as semi-colons separated files to disk.
At each iteration, the list of patients is refreshed to include the patients that newly checked in.
For each patient, the scripts save the last encountered timestamp in a pointer file.
The pointer file content is used as a starting point the next time the patient is encountered.

### Requirements 
- Runs on the server with a DWC instance
- Powershell
  - `invoke-sqlcmd`
- Read and write to disk

### Usage
```ps
cd src
./mssql2csv.ps1 -outfolder "Output data directory" -legal_pat "Path to file listing the patients to extract"
```
E.g.
```ps
./mssql2csv.ps1 -outfolder ..\data\ -legal_pat .\LegalPatients.txt
```

### Database Authentication
By default, authentication is based on a local database instance account.
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

If the database authentication is delegated to the Windows authenticator on the database server, remove the `-Username $username -Password $pwd` options in the `invoke-sqlcmd` command of these files:
- [src/perform_query.ps1](./src/perform_query.ps1#85)
- [src/build_pat_list.ps1](./src/build_pat_list.ps1#15)
- [src/get_pat_info.ps1](./src/get_pat_info.ps1#16)


### Patient identification

DWC uses an internal patient unique identifier. The scripts read the information entered in the lifetimeID field of monitors.

DWC uses an internal patient unique identifier.
The scripts read the information entered in the lifetimeID field of monitors.
This can be adapted to different context and medical staff practices by editing the query:

- [src/patstringAttribute.sql](./src/patstringAttribute.sql)


For this make sure that the staff habits of entering IDs on the monitors matches with the entries expected in the `External_PatientStringAttribute` view.

In our case we rely on the lifetime ID field. The free text IDs are filtered for strings containing only numbers (see [src/msql2csv.ps1](./src/mssql2csv.ps1#L76)). Again this should be adapted to each context.

### Query templates
The template extraction queries for LF (parameter) and HF (waveform) data are:
- [src/export_HF_cpy.sql](./src/export_HF_cpy.sql)
- [src/export_LF_cpy.sql](./src/export_LF_cpy.sql)
- The active queries are listed in [src/extraction_query.txt](./src/extraction_query.txt)
  - To activate/deactivate extraction from one of the queries remove it from the list,
  - To write your own queries, copy one of the template, edit it, and add it to the list.

## Transfer overview
A set of powershell script to continuously encrypt and transfer data extracted from DWC.

### Requirement
- Run on an intermediate Windows machine

**Software**
- Powershell
- GPG for windows: [gpg4win](https://gpg4win.org/download.html) from [GNU Privacy Guard](https://gnupg.org/index.html)
  ```ps
  gpg --version
  v ...
  ```
- (optional) Certificate manager and GUI for GPG [Kleopatra](https://www.openpgp.org/software/kleopatra/)

**Permission**
- Read from disk where the data are extracted from and write on another partition
- A trusted public GPG key (the complementary private key will be used for decryption)

### Usage
```ps
.\sync_full_enc.ps1 -sourcePath "..\data" -destPath "..\remotedata" -cut "remove source file (0 or 1)" -wh "wait x hours after completion"
```

### Encryption
The files extracted so far are plain text and contain sensitive information.
We perform asymetric encryption with GPG (GNU Privacy Guard).
The data encryption is done at [./transfer/enc_dec_gpg_data.ps1#L25](./transfer/enc_dec_gpg_data.ps1#L25).
The patient map file is encrypted similarly at [./transfer/enc_dec_gpg.ps1#L17](./transfer/enc_dec_gpg.ps1#L17)

By default, GPG compresses data prior to encryption. 
This reduces the overload on the network due to data transfer.
It also allows transfer through potentially unsecure links within or outside the institution. 


## Parsing overview
