## Powershell Extraction script. 
# cd src
# cd D:\work\DBNEO_2023\src
# import-module D:\Programs\SQLserver
# import-module .\my-invoke-sqlcmd.ps1 -force
# 
# Usage: .\mssql2csv.ps1 -outfolder ..\data\ -legal_pat .\LegalPatients.txt
# standalone queries: my-invoke-sqlcmd -inputfile export_LF_tr.sql -serverinstance 'DWC-TIER2'  -database 'Philips.PatientData'
# log file:  Get-Content -Path ..\data\log.log -wait -tail 10
# 

param(
[string]$outfolder,
[string]$legal_pat
)

#import-module D:\Programs\SQLserver -force
import-module .\my-invoke-sqlcmd.ps1 -force

$wh=2
$wd=pwd 			        # Define working directory

$server='DWC-TIER2'     	# Server instance name
$db='Philips.PatientData'	# Database name
$username='UserName'		# Credential: username

#$pass_secure = Read-Host "password for $username@$server/$db ?" -AsSecureString 
#$pwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
#    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass_secure))
$pwd=""

$output_folder= "$outfolder" #Output folder from argument

# Check if output folder exists
If(!(test-path $output_folder))
{
    New-Item -ItemType Directory -Force $output_folder
}

$logfile="$output_folder\log.log"

# Define & initiate map file
$pat_map_filename= "$output_folder\PatientsMapping.txt"

If(!(test-path $pat_map_filename)) {
    "ID;Personnummer;scramble;hash;" >> $pat_map_filename
    #get-content $pat_map_filename | out-file -encoding utf8 $pat_map_filename
}


$gethash_cpy="$wd\gethash_cpy.sql" #Query extracting the hash of patient
$gethash= $gethash_cpy | Foreach-Object {$_ -replace '_cpy', ''}

$getstartdate_cpy="$wd\getstartdate_cpy.sql" #Query extracting the hash of patient
$getstartdate= $getstartdate_cpy | Foreach-Object {$_ -replace '_cpy', ''}

$tmp_file="$wd\temp.txt"

$ExtractQuery= Get-Content "$wd\extraction_query.txt" #File containing the list of all queries to execute for each patient


while($true){
    $nfinished=0

    
    # Rebuild patient list
    .\build_patlist.ps1 -server $server -db $db -username $username -pwd $wd -outfile "$legal_pat"
    
    
    # Get Patients to extract
    Get-Content "$legal_pat" | WHERE { $_ -notmatch "^#" } | Set-Content "$wd\tmp_ExtractPatients.txt"
    $Extractpatients= (Get-Content "$wd\tmp_ExtractPatients.txt") -split '\n'
    $Extractpatients  | out-file  -filepath $logfile -append
    

    For($ipat=1;$ipat -le $Extractpatients.count;$ipat++){
        $extractpatient=$Extractpatients[$ipat-1]
        
        #"Patient $extractpatient"| out-file  -filepath $logfile -append
        
        $clean_pn = $extractpatient.Substring(2,$extractpatient.Length-4)
        
        if ( ($clean_pn -match "^.*[0-9].*$") ) {
            $mapfile= get-content $pat_map_filename
            #$SEL = Select-String -Path $pat_map_filename -Pattern $clean_pn
            $SEL = get-content $pat_map_filename | select-string -pattern  ";$clean_pn;" -encoding ASCII | select Line,LineNumber
            
            # Specify patient in start date query file
            Get-Content $getstartdate_cpy | Foreach-Object {$_ -replace '__clean_pn__',  ("'"+$clean_pn+"'")} | Set-Content $getstartdate

            $pat_start_date= (my-invoke-sqlcmd -MaxCharLength 16000 -InputFile $getstartdate -serverinstance $server -database $db).start_date  # -Username $username -Password $pwd 
           # "the patient start date "+  $pat_start_date  | out-file  -filepath $logfile -append
            
            
            if($SEL -ne $null) { #  patient already have a scramble number, look it up in the pat mapping file
           
                $ipat_map = ($SEL.Line -split ";")[0]
                # LOG
                $thelogstr="Known -> " + $mapfile[$SEL.LineNumber-1]# | out-file  -filepath $logfile -append
               
                
                $split_map_line=$mapfile[$SEL.LineNumber-1] -split ';'
                $scramble= $split_map_line[2]
                
            }
 
            else { # Patient do not have a scramble number, create one and add a line to the patient mapping file
                # Add random number of days (between 30 and 60 years) to timestamp
                $thelogstr="New"
                $scramble = get-random -Minimum 10950 -Maximum 21900
                $ipat_map = $mapfile.count
                .\get_pat_info.ps1 -gethash_cpy $gethash_cpy -extractpatient $extractpatient -pat_map_filename $pat_map_filename -scramble $scramble -server $server -db $db -username $username -pwd $pwd               
            }

            $log_time=(get-date -format "yyyy-MM-dd HH:mm:ss")
            "[$log_time] " +  "Patient $extractpatient" + ", " + $thelogstr | out-file  -filepath $logfile -append
            
            For($iquery=1; $iquery -le $ExtractQuery.count; $iquery++){
	            $query_cpy= (Get-Content "$wd\extraction_query.txt")[$iquery-1]
	            $query_cpy= "$wd\$query_cpy"

	            # LOG
	            # "Extraction query cpy->" + $query_cpy  | out-file  -filepath $logfile -append

	            $query= $query_cpy | Foreach-Object {$_ -replace '_cpy', ''}
                $query_datefree= $query_cpy | Foreach-Object {$_ -replace '_cpy', '_df'}
	        
                # LOG
                #"Extraction query-> " + $query   | out-file  -filepath $logfile -append

            
                Get-Content $query_cpy | Foreach-Object {$_ -replace 'Day,,', ("Day," + $scramble + ",")} | Set-Content $query_datefree

		        # Define output datafile
                $tmp_str=[io.path]::GetFilenameWithoutExtension($query)

        
		        $fulldatafile= $output_folder + "\pat$ipat_map\" + "pat" + $ipat_map + "_" + $tmp_str + ".csv"

 
                # Check if pat output folder exists
                If(!(test-path "$output_folder\pat$ipat_map")) {
                    New-Item -ItemType Directory -Force "$output_folder\pat$ipat_map"
                }

                # Check if patient is finished
                #  If(!(test-path ($fulldatafile -replace '.csv','_done.txt'))){
		    
                # Specify patient in query file
		        Get-Content $query_datefree | Foreach-Object {$_ -replace '__clean_pn__', ("'"+$clean_pn+"'")} | Set-Content $query
                
                   
                .\perform_query.ps1 -query $query -fulldatafile $fulldatafile -logfile $logfile -mapfile $pat_map_filename -patstartdate $pat_start_date -server $server -db $db -username $username -pwd $pwd

            }# QUERIES
       }
       else {
            "skip: tolvan tolvansson the test patient flooding the database"
       }

        
       # Leave 1 min between each patient Wait 10sec 
       sleep 1
    }# Patients

    # LOG
    "All patients are done"
    
    # If all patients are done
    #if($nfinished -eq $Extractpatients.count){
    write-output "$(Get-Date) No more stored data, wait $wh h..."
    $waiting_time_s= $wh*60*60
    Start-Sleep -s $waiting_time_s

}# While true       

