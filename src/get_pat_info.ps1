Param(
[string]$gethash_cpy,
[string]$extractpatient,
[int]   $scramble,
[string]$pat_map_filename,
[string]$server,
[string]$db,
[string]$username,
[string]$pwd
)


# Get translation table
Get-Content $gethash_cpy | Foreach-Object {$_ -replace '^insert into.*$', ("insert into EthicalPatients values " + $extractpatient)} | Set-Content $gethash

#  $result= invoke-sqlcmd -InputFile $gethash -serverinstance $server -database $db -Username $username -Password $pwd
# Write translation table
#"$ipat;$($result.LifetimeID);$scramble;$($result.Hash)" >> $pat_map_filename

#LOG
#"$ipat_map;$($extractpatient.Substring(2,$extractpatient.Length-4));$scramble;ABCDEF;"

# Write to pat_map_filename
"$ipat_map;$($extractpatient.Substring(2,$extractpatient.Length-4));$scramble;ABCDEF;" >> $pat_map_filename

#cat $pat_map_filename
          
return
