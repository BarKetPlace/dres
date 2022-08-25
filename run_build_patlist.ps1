Param(
[string]$outfile
)

$wd=pwd
$server='SMONDWCDB1901'	#Server instance name
$db='Philips.PatientData'	#Database name

$username='br81'		#Credential: username
$pwd=Get-Content "$wd\pwd.txt"	#Credential passwd

.\build_patlist -server $server -db $db -username $username -pwd $pwd -outfile $outfile
