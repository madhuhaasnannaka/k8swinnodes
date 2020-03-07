param(
  [parameter(Mandatory=$true)] $Version
)

$DownloadDirectory = (Join-Path -Path (Get-Item Env:TEMP).Value -ChildPath "wmi")
New-Item -Path $DownloadDirectory -ItemType "directory"
wget "https://github.com/martinlindhe/wmi_exporter/releases/download/v$Version/wmi_exporter-$Version-amd64.msi" -OutFile "$DownloadDirectory/wmi.msi"

$logFile = "c:/wmi_install.log"
$file = Get-Item -Path "$DownloadDirectory/wmi.msi"
$MSIArguments = @("/i", ('"{0}"' -f $file.fullname), "/qn", "/L*v", $logFile, "ENABLED_COLLECTORS=cpu,cs,container,logical_disk,net,os,service,system,tcp")
Start-Process "msiexec.exe" -ArgumentList $MSIArguments

Remove-Item -Path $DownloadDirectory -Recurse