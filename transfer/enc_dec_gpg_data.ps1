param(
[string]$inputFile,  # File to encrypt
[string]$destFolder, 
[boolean]$cut
)

# Write an encrypted source file into a destination folder.
# If cut=0, the source file is left in the original folder, if cut=1, the original file is removed, only if it is a csv file.
# The name of the gpg key is hard coded.
# 
# Usage:    .\enc_dec_gpg_data.ps1 -inputfile .\test_src_folder\secret2.csv -dest .\test_dest_folder -cut 0
# 


$src_fullname=(Get-Item $inputFile).FullName
$dest_path=(Get-Item $destFolder).FullName

$src_name=(get-item $src_fullname).Name
$dest_name=$src_name+".gpg"

$dest_fullname=$dest_path+"\"+$dest_name
$dest_fullname_tmp=$dest_fullname+".tmp"


gpg -e -r antoine --yes -o $dest_fullname_tmp  $inputFile | Wait-Process


# echo (get-item $dest_fullname_tmp).length +"," + (get-item $dest_fullname).Length+2
# exit

# Move the tmp file to the destFile, if the destFile does not exist, or the destfile is smaller than the tmp file.
if ( (!(test-path $dest_fullname)) -or ((get-item $dest_fullname_tmp).length -gt ((get-item $dest_fullname).Length+2))) {
    "move: $dest_fullname_tmp to $dest_fullname"
    move-item -Force $dest_fullname_tmp $dest_fullname | Wait-Process
}

# The destfile exist and is larger than the tmp file
else {
    "remove: $dest_fullname_tmp"
    Remove-Item -Force $dest_fullname_tmp | Wait-Process
}

# If it is a datafile, it has been successfully copied, and the cut option is activated
if ($cut -and (test-path $dest_fullname)) {
    # "REMOVE"
    #$copysrc
    "remove: $inputFile"
    Remove-Item -Force $inputFile | Wait-Process
}


