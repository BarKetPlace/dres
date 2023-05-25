function my-invoke-sqlcmd {
    # Re-try the query at most 10 times before returning an empty result.
    # each query has a timeout of 2 minutes, and there is a pause of 1sec between two trials.

    Param(
    [string]$serverinstance,
    [string]$database,
    [string]$username,
    [string]$inputfile
    )
    $TIMEOUT=120 # 2 min
    $somedata= 0 -eq 1 #false

    #while (-not $somedata) {
    #    $results = invoke-sqlcmd  -QueryTimeout 240 -InputFile "patstringAttribute.sql" -serverinstance  $serverinstance -database $database | Out-String 
    #    $somedata= -not ($results -eq "")
    #    if (-not $somedata) {
    #        echo "Waiting ..."
    #        sleep 5     
    #    }
    #}
    #import-module D:\Programs\SQLserver -force
    $somedata= 0 -eq 1 #false
    #echo "in my-invoke-sqlcmd"

    $n_max_repeats=10
    $irepeats=0
    $results=""
    
    # $flags=@()
    # echo $flags

    while ((-not $somedata) -and ($irepeats -lt $n_max_repeats)){
        $results=""

        $Job = Start-Job -ScriptBlock {   
            import-module D:\Programs\SQLserver -force         
            invoke-sqlcmd  -MaxCharLength 16000 -InputFile $args[0] -serverinstance $args[1] -database $args[2] | Write-Output
        } -argumentlist $inputfile, "$serverinstance", "$database"
        
        #Write-Error "Wait for the job to finish..."
        
        $Job | Wait-Job -Timeout $TIMEOUT  >$null
        
        #Write-Error "Job is finished ..."

        $results = receive-job $Job
        $Job | Remove-Job -force

        #echo "results:" $results.Value

        # -Username $username -Password $pwd
        $somedata= -not ( ($results| Out-String) -eq "")
        if (-not $somedata) {
            #Write-Error "Waiting 1 sec before trying again " + ($irepeats+1)+ "/" + $n_max_repeats + " ..."
            sleep 1
        }
        $irepeats++
    }
    # It seems that  using return fails to free the memory
    $results | Write-Output
}
