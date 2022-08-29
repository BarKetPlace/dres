Param(
[string]$server,
[string]$db,
[string]$username,
[string]$pwd,
[string]$outfile
)

$query_dbpat=      "$wd\patstringAttribute.sql"

Remove-Item -Path $outfile -Force
New-Item -ItemType File $outfile | Out-Null


$result= invoke-sqlcmd  -QueryTimeout 65535 -MaxCharLength 16000 -InputFile $query_dbpat -serverinstance $server -database $db -Username $username -Password $pwd

$result.Value | ForEach-Object {

        "('$_')" >> "$outfile"

}

return