wget https://raw.githubusercontent.com/geodata-no/windows-kops-nodeup/master/nodedrainer.ps1 -OutFile c:/nodedrainer.ps1
$nssm = (Get-Item -Path "c:/k/bin/nssm.exe").FullName
$serviceName = 'NodeDrainer'
$powershell = (Get-Command powershell).Source
$scriptPath = 'C:/nodedrainer.ps1'
$arguments = '-ExecutionPolicy Bypass -NoProfile -File "{0}"' -f $scriptPath
& $nssm install $serviceName $powershell $arguments
& $nssm status $serviceName
Start-Service $serviceName