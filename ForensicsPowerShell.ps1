$csvData = New-Object -TypeName psobject
$date = Get-Date
$timezone = (Get-TimeZone).Id
$uptime = $date - $operatingSystem.LastBootUpTime
$computername = Get-CimInstance -ClassName Win32_ComputerSystem
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$cpu = Get-CimInstance -ClassName CIM_Processor
$ram = RAM -Value ("{0:N2}GB" -f ($computername.TotalPhysicalMemory/1GB))
$disks = Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object DeviceID,VolumeName,FileSystem,@{l='Size';e={("{0:N2}GB" -f ($_.Size/1GB))}}

$DC = Get-ADDomainController
