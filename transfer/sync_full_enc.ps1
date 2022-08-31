param(
[string]$sourcePath,
[string]$destPath,
[boolean]$cut,       #  Cut files from sourcePath (1 or 0)
[float]$wh           #  Stand-by time in hours

)

# Usage: .\sync_full_enc.ps1 -sourcePath "..\data" -destPath "..\remotedata" -cut "remove source file" -wh "wait x hours after completion"


# $sourcePath = convert-path $sourcePath
# $destPath = convert-path  $destPath
# $cut = 0
# $wh = 1

$ws = $wh * 3600

$uid=(get-item $destPath).Name

if (!(Test-Path $destPath) ){ # -or ((Get-ChildItem W:\Private\patients_data\data_monitor | Measure-Object).count -eq 0)) {
    "info: empty $destPath"
    New-Item -path $destPath -ItemType "file" -name "dummy.txt" -force
}

$transfer_log= $destPath+"\transfer_log.log"

while($true) {
  
    $src_map=$sourcePath + "\" + "PatientsMapping.txt"
    
    $dest_map=$destPath + "\" + "PatientsMapping.txt"
    $dest_map_enc_gpg=$dest_map + ".gpg"
    
    # Systematically encrypt and replace the mapfile
    "encrypt: $src_map to $dest_map_enc_gpg"
    .\enc_dec_gpg.ps1 -inputFile $src_map -destFile $dest_map_enc_gpg -uid $uid
    ""
    

    "info: list patient directories"
    # Find all the patient directory
    $sourceDirs= Get-ChildItem -Path $sourcePath -recurse -Directory #| foreach-object -begin { $arr = @((get-item $sourcePath).fullname) } -process { $arr+= $_.fullname } -end { $arr }
    ""

    foreach ($patfolder in $sourceDirs){
        "info: $patfolder"

        $dest_patfolder = $destPath + "\" + $patfolder
        $src_patfolder = $sourcePath + "\" + $patfolder
        
        # If the patient directory does not exist in the destination, create it
        if (!(test-path $dest_patfolder )) {
            "create: $dest_patfolder"
            New-Item -path $dest_patfolder -ItemType "directory" -force
            New-Item -path $dest_patfolder -name "dummy.txt" -ItemType "file" -force 
        }

        # Find all files in the source directory   
        $SourceFiles= Get-ChildItem -Path $src_patfolder -recurse -File
     

        foreach ($src_file_ in $SourceFiles){
            $src_file=$src_file_.FullName
            "info: $src_file"
            
            # If datafile
            if ($src_file.Contains(".csv")) {
                "encrypt: $src_file to $dest_patfolder"
                .\enc_dec_gpg_data.ps1 -inputfile $src_file -dest $dest_patfolder -cut $cut
            }
            else {
                $dest_file=$dest_patfolder +"\"+$src_file_.Name

                # If the files are different or the dest file does not exist
                if ( !(test-path $dest_file) -or (Get-FileHash $src_file).hash -ne (Get-FileHash $dest_file).hash ){
                    "copy: $src_file to $dest_file"
                    Copy-Item $src_file $dest_file | wait-process
                }
                else {
                    "skip: $src_file to $dest_file"
                }
             
            }

        } # Files in patient folder
        ""
        #start-sleep -s 5
  }# all patient folders
  
   #  Flush time stamps of all the newly created files
   #.\flush_dates.ps1 $destPath 
    
    
    # Wait for some seconds 
    if ($wh -eq 0){
        write-output "$(Get-Date) No more stored data, Exit."
        exit
    }
    else{
        write-output "$(Get-Date) No more stored data, wait $($wh) hour(s)..."
        Start-Sleep -s $ws
    }

    
}
