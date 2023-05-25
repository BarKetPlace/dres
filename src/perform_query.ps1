Param(
[string]$query,
[string]$fulldatafile,
[string]$logfile,
[string]$mapfile,
[string]$patstartdate,
[string]$server,
[string]$db,
[string]$username,
[string]$pwd
)
# import-module .\my-invoke-sqlcmd.ps1 -force

$step_LF=5000
$step_HF=5000
$step=$step_HF
if($query.Contains("LF")){
    #"yes"
    $step=$step_LF
}

$result=1
$start=1

$fulldatafile_tr= $fulldatafile -replace '.csv', ("_start_" + $start + "_next_" + $step + ".csv")
$trunkname= $fulldatafile_tr -replace "_start_$start","_start_*"

$fulloutfolder=[io.path]::GetDirectoryName($fulldatafile)
$rawname=[io.path]::GetFileNameWithoutExtension($fulldatafile)
$startfile=  $fulldatafile -replace '.csv','_startpoint.txt'

#$date = get-date -Format "yy-MM-dd HH:mm:ss"

if (Test-Path $startfile){
    $start, $start_seq, $start_date=(Get-Content $startfile).split(";")
    # echo (Get-Content $startfile).split(";")
    # echo "patstartdate" $patstartdate
    
    if ($start_date -eq '') {
        " empty start file, replace with pat overview output !"
        $start_date=$patstartdate
    }

    $start=[int64]$start
    $start_seq=[int64]$start_seq
}

else {
    $start=1
    $start_seq=1
    $start_date=$patstartdate
    "$start;$start_seq;$start_date" > $startfile

}

#"$start;$start_seq;$start_date"


$query_tr= $query -replace '.sql','_tr.sql'

$stop_condition=0

while (!$stop_condition){        
    $start_date_str= $start_date -replace '[ \.:]','-'
    
   # "Start looking on $start_date_str"  | out-file  -filepath $logfile -append

    $fulldatafile_tr= $fulldatafile -replace '.csv', ("_start_" + $start_date_str + "_next_" + $step + ".csv") 
    
    #LOG
    #$logstr="Export " + $query + " in " + $fulldatafile_tr + "..."
    #$logstr  | out-file  -filepath $logfile -append
    
  
    #$start_seq
    #Limit number of row to extract
    # Get-Content $query | Foreach-Object {$_ -replace '^OFFSET.*$', ("OFFSET " + $start + " ROWS FETCH NEXT " + $step + " ROWS ONLY ")} | Set-Content $query_tr
    #if ($start -eq 1) {
    
    if ($start -eq 1) {
        Get-Content $query | Foreach-Object {($_ -replace '__start_date__', ("'$start_date'")) -replace 'and val.TimeStamp < __end_date__','' } | Set-Content $query_tr
    }
    else {
        #Get-Content $query | Foreach-Object {($_ -replace '__start_date__', ("'$start_date'")) -replace '__end_date__', ("  dateadd(hour,12,'$start_date')") } | Set-Content $query_tr
        Get-Content $query | Foreach-Object {($_ -replace '__start_date__', ("'$start_date'")) -replace '__end_date__', ("(dateadd(hour,4,CAST('$start_date' AS DATETIME2)) AT TIME ZONE 'Central European Standard Time')") } | Set-Content $query_tr
    }
    # 

    # Some delay to avoid overwhelming the db
    start-sleep -s 0.5

    #Perform extraction
    $time_start = get-date
    #"Enter my-invoke-sqlcmd"
    $result= my-invoke-sqlcmd -InputFile $query_tr -serverinstance $server -database $db  # -Username $username -Password $pwd 
    
    $result | export-csv $fulldatafile_tr -notypeinformation -Delimiter ";"
    
    $time_end = get-date
    
    if ($result -eq $null){
        $stop_condition=1
        $logstr2="results=NULL"
    }

    else {
        if ( $result.TimeStamp.count -eq $result.count) {
        $start_seq_new=$result.SequenceNumber[$result.count-1]
        #(Get-content -tail 1 $fulldatafile_tr).split(";")[1]
        #$result.TimeStamp[$result.count-1]

        $start_date_new=$result.TimeStamp[$result.count-1]
        #$start_seq_new=[int64]$start_seq_str_new.substring(1,$start_seq_str_new.Length-2)
        $lines = $result.count



        $logstr2="data between $start_date and $start_date_new : number of lines $lines"
        #"stop cond: ($start_date_new -eq $start_date) or ($lines -le $step)" | out-file  -filepath $logfile -append

        $stop_condition = ((get-date $start_date_new) -eq (get-date $start_date)) -or ($lines -lt $step)
        }
        else {
            $stop_condition= 1 -eq 1
        }
        #"$start;$start_seq_new" > $startfile

    }

    #LOGr
    $log_time=(get-date -format "yyyy-MM-dd HH:mm:ss")
    $outfname_split=((get-item $fulldatafile_tr).basename -split "_")
    
    $rate= [math]::round((Get-Item .\export_HF_cpy.sql).length/1KB / ($time_end - $time_start).Seconds,3)

    "[$log_time]     "+ ($outfname_split[0])+", "+$outfname_split[2]+", "+$logstr2 + " (" + $rate+" KB/sec) "+", "+"stop ? $stop_condition" | out-file  -filepath $logfile -append 
    
    # Limit cpu demand
    $waiting_time_s= 0.3
    Start-Sleep -s $waiting_time_s

    if (!$stop_condition){

        #Log
        $date = get-date -Format "yyyy-MM-dd HH:mm:ss"
       # (get-date -Format "yyyy-MM-dd HH:mm:ss")  | out-file  -filepath $logfile -append
        
        #"" + $result.TimeStamp[0] + ", " + $result.TimeStamp[$result.count-1] + ", " + ($time_end - $time_start).Seconds  | out-file  -filepath $logfile -append
        
        $start_seq=$start_seq_new
        $start_date=$start_date_new

        "$start;$start_seq;$start_date" > $startfile

        $last_start_data=$start
        $start=$start+$step

    }
    # Free memory
    $result=$null

}

#'query finished'

# $begining
# $last_start_data
# $start

# if last_start_data do not exist (!$last_..), it means we have not extracted any data during that round and we definetely 
if ((!$last_start_data) -or ($last_start_data -eq $begining)) { #no more data added to the patient folder with that query
    $finishedfile=  $fulldatafile -replace '.csv','_done.txt'
    'Done.'>  $finishedfile

}

#"Done"

