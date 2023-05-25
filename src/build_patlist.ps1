Param(
[string]$server,
[string]$db,
[string]$username,
[string]$pwd,
[string]$outfile
)

$query_dbpat=      "$pwd\patstringAttribute.sql"

Remove-Item -Path $outfile -Force
New-Item -ItemType File $outfile | Out-Null

#echo "my-invoke-sqlcmd -InputFile $query_dbpat -serverinstance $server -database $db"

$result= my-invoke-sqlcmd -InputFile $query_dbpat -serverinstance $server -database $db  # -Username $username -Password $pwd

$result.Value | ForEach-Object {
        
        "('$_')" >> "$outfile"

}

return
