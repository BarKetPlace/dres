import-module D:\Programs\SQLserver

$log_fname="\\storage.ad.cmm.se\tank\users\anthon\Private\server\responsiveness.log"
"timestamp,somedata,query_time,bytecount,ping_ms" > $log_fname

while (1) {
    echo "invoke-sqlcmd ..."

    $start_time=Get-Date
    $start_time_str=get-date -format "yyy-MM-dd HH:mm:ss"
    #$ping_ms = (test-connection dwc-tier2.mta.karolinska.se -count 1).ResponseTime
    $ping_ms = 1
    $results = invoke-sqlcmd  -InputFile "patstringAttribute.sql" -serverinstance 'DWC-TIER2' -database 'Philips.PatientData' -QueryTimeout 600 | Out-String
    
    $end_time=Get-Date
    
    #$results

    $elapsed=($end_time - $start_time).TotalSeconds


    $somedata= -not ($results -eq "")
    $datasize= [System.Text.Encoding]::UTF8.GetByteCount($results)

    $start_time_str + "," +"$somedata" + "," + "$elapsed" +"," + "$datasize" + "," + "$ping_ms"
    
    $start_time_str + "," +"$somedata" + "," + "$elapsed" +","+ "$datasize" + "," + "$ping_ms" >> $log_fname
    echo "Sleep 2 sec..."
    sleep 2
}
