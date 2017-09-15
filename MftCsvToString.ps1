# Robert Suter
# MftCsv To String
# turns csv file into string

Param (
  [Parameter(Mandatory = $true)]
  [string] $Path, [string] $GetData, section of [string] $Csv #directory, name of data, name of csv
)

if ($GetData -and $Csv){
    Write-Error "Only `$GetData or `$CSV not both"
    return
}

if ((-not ($Path.Substring($Path.Length-1) -eq "\")) -and (-not ($Path -eq "."))){
    $Path = $Path + "\"
}

if($Path -eq "."){
    $Path = ""
}

if($GetData){
    try{
        $Files = "$(((Get-ChildItem $Path -Include "*$GetData" -Recurse).FullName).Replace("[","``[").Replace("]","``]").Replace("$GetData ", "$GetData    "))".Split("    ")
    }
    
    catch{
        Write-Error "Could not find the specified file in the directory"
        return
    }
    
    ForEach ($File in $Files){
        Write-Host -f Gray $File
        Get-Content $File
    }
}

else{
    $CsvFile = Import-Csv -Path ($Path + $Csv) -Delimiter "|"
    ForEach ($File in $CsvFile){
        $File | Select-Object @{l="Timestamp";e={$_.Date.ToString() + " " + $_.Time.ToString()}},
        @{l="FileType";e={$_.SourceType}},@{l="Path";e={$_.Desc}},MACB | Format-Table *
    }
}
