#Robert Suter
 #CSEC475
 #Powershell Script that gathers information on target computer
 
 $csvData = New-Object -TypeName psobject

#Time
$date = Get-Date
$timezone = (Get-TimeZone).Id
$uptime = $date - $operatingSystem.LastBootUpTime

#windows
$computername = Get-CimInstance -ClassName Win32_ComputerSystem
$os = Get-CimInstance -ClassName Win32_OperatingSystem

#Hardware
$cpu = Get-CimInstance -ClassName CIM_Processor
$ram = RAM -Value ("{0:N2}GB" -f ($computername.TotalPhysicalMemory/1GB))
$disks = Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object DeviceID,VolumeName,FileSystem,@{l='Size';e={("{0:N2}GB" -f ($_.Size/1GB))}}

#Domain Controler
$DC = Get-ADDomainController

#users
$users = Get-LocalUser | Select-Object Name,FullName,Enabled,LastLogon,SID
$sysAccounts = Get-CimInstance -ClassName Win32_SystemAccount | Select-Object Name,Domain,InstallDate,SID
for($i = 0; $i -lt $services.Length; $i++)
{
        if(-not $serviceAccounts.Contains($services[$i].StartName))
        {
            $serviceAccounts += $services[$i].StartName
    }
}

#Start at boot
$services = Get-CimInstance -ClassName Win32_Service | Where-Object {$_.StartMode -eq "Auto"}
$programs = Get-CimInstance -ClassName Win32_StartupCommand | Select-Object Name,Command,Location

#List of tasks
$tasks = Get-ScheduledTask | Select-Object TaskName,TaskPath

#Network
$arpTable = Get-NetNeighbor | Where-Object { (-not ($_.LinkLayerAddress -eq $null)) -and ($_.ifIndex -eq 3) } | Select-Object IPAddress,LinkLayerAddress
$macaddress = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { -not ($_.MACAddress -eq $null)} | Select-Object Description,IPAddress,MACAddress,DefaultIPGateway,DHCPServer,InterfaceIndex
$routingTable = Get-NetRoute | Select-Object DestinationPrefix,Nexthop
#DNSServer ----
#connections ----
$dnsCache = Get-DnsClientCache | Where-Object {$_.Status -eq 0} | Select-Object Name,Data

#Networkshares, printers, and wifi access profiles
$netshares = Get-CimInstance -ClassName Win32_share | Where-Object {(-not ($_.Path -eq "")) -and (-not ($_.Path -eq $null))} | Select-Object Path
$printer = Get-Printer | Select-Object Name
$wifi = netsh.exe wlan show profiles

#installed software
$programs = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {(-not ($_.DisplayName -eq $null)) -and (-not ($_.DisplayName -eq ""))} | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

#proccesses
$processes = Get-CimInstance -ClassName Win32_Process | Select-Object Name,ProcessID,ParentProcessID,Path,@{l='User';e={(Invoke-CimMethod -InputObject $_ -MethodName GetOwner).User}}

#drivers
$drivers = Get-WindowsDriver -All -Online | Select-Object Name,BootCritical,Path,Version,Date,ProviderName

#user downloads
$users = Get-ChildItem -Path "C:\Users" | Select-Object Name
ForEach ($user in $users)
{
$downloads = Get-ChildItem -Path ("C:\Users\" + $user.Name + "\Downloads") | Select-Object Name
$documents = Get-ChildItem -Path ("C:\Users\" + $user.Name + "\Documents") | Select-Object Name
}

#three of own
#1: see partitions
$partitions = Get-PSDrive -PSProvider 'FileSystem'
#2: see conected usb devices
$conectedusb = gwmi Win32_USBControllerDevice |%{[wmi]($_.Dependent)} | Sort Manufacturer,Description,DeviceID | Ft -GroupBy Manufacturer Description,Service,DeviceID
#3: usb device history????


#Make CSV
Add-Member -InputObject $csvData -Name Date -Value $date.ToString()
Add-Member -InputObject $csvData -Name TimeZone -Value $timezone
Add-Member -InputObject $csvData -Name UpTime -Value $uptime
Add-Member -InputObject $csvData -Name ComputerName -Value $computername
Add-Member -InputObject $csvData -Name Opertaing System -Value $os
Add-Member -InputObject $csvData -Name Cpu -Value $cpu
Add-Member -InputObject $csvData -Name RAM -Value $ram
Add-Member -InputObject $csvData -Name Discks -Value $disks
Add-Member -InputObject $csvData -Name DomainControler -Value $DC
Add-Member -InputObject $csvData -Name Users -Value $users
Add-Member -InputObject $csvData -Name SystemAccounts -Value $sysAccounts
Add-Member -InputObject $csvData -Name ServiceAccounts -Value $serAccounts
Add-Member -InputObject $csvData -Name Services -Value $services
Add-Member -InputObject $csvData -Name RunningPrograms -Value $programs1
Add-Member -InputObject $csvData -Name Tasks -Value $tasks
Add-Member -InputObject $csvData -Name ARPTable -Value $arpTable
Add-Member -InputObject $csvData -Name MACAddress -Value $macaddress
Add-Member -InputObject $csvData -Name RoutingTable -Value $routingTable
Add-Member -InputObject $csvData -Name DNSCache -Value $dnsCache
Add-Member -InputObject $csvData -Name NetworkShares -Value $netshares
Add-Member -InputObject $csvData -Name Printers -Value $printer
Add-Member -InputObject $csvData -Name WIFI -Value $wifi
Add-Member -InputObject $csvData -Name InstalledPrograms -Value $programs
Add-Member -InputObject $csvData -Name Proccesses -Value $proccesses
Add-Member -InputObject $csvData -Name Drivers -Value $drivers
Add-Member -InputObject $csvData -Name Downloads -Value $downloads
Add-Member -InputObject $csvData -Name Documents -Value $documents
Add-Member -InputObject $csvData -Name Partitions -Value $partitions
Add-Member -InputObject $csvData -Name ConnectedUSB -Value $conectedusb


$csvData | Export-Csv -Path (".\Desktop\ComputerInformation.csv")
