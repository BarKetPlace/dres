param(
[string]$inputFile, # File to encrypt
[string]$destFile,
[string]$uid
)

$local_tmp="tmp\patmap_$uid-utf16.txt"
$local_tmp_utf8="tmp\patmap_$uid.txt"

if (!(test-path $local_tmp)) {
    "copy: $inputFile to $local_tmp"
    copy-item $inputFile $local_tmp |wait-process
    "encode: $local_tmp to utf8 at $local_tmp_utf8"
    get-content $local_tmp | set-content -encoding utf8 $local_tmp_utf8

    "encrypt: $local_tmp_utf8 to $destFile"
    gpg -e -r antoine --yes -o $destFile $local_tmp_utf8 |wait-process
    
    "remove: $local_tmp and $local_tmp_utf8"
    remove-item $local_tmp | wait-process
    remove-item $local_tmp_utf8 | wait-process
}
else { 
    "error:tmp copy of $inputFile at $local_tmp already exists"
}