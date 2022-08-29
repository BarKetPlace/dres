$server='SMONDWLDB1701'
$db='Philips.PatientData'
$username='supportuser'
$pwd=Get-Content ".\pwd.txt"


$tmp_file=".\temp.txt"
$output=".\infofile.txt"
Get-Date -Format g >> $output

$result= invoke-sqlcmd -InputFile information.sql -serverinstance $server -database $db -Username $username -Password $pwd
$result | export-csv $tmp_file -notypeinformation -Delimiter ";"

cat $tmp_file >> $output
