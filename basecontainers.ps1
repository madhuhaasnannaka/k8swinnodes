# Server containers needs to be on the same version as the host, so grab the version from the host before installing
$ComputerInfo = (Get-ComputerInfo)
$WindowsVersion = $ComputerInfo.WindowsVersion

docker pull "mcr.microsoft.com/windows/nanoserver:$WindowsVersion"
docker pull "mcr.microsoft.com/windows/servercore:$WindowsVersion"
docker pull "mcr.microsoft.com/dotnet/framework/runtime:4.8-windowsservercore-ltsc2019"

docker tag "mcr.microsoft.com/windows/nanoserver:$WindowsVersion" windows/nanoserver:latest
docker tag "mcr.microsoft.com/windows/nanoserver:$WindowsVersion" microsoft/nanoserver:latest
docker tag "mcr.microsoft.com/windows/servercore:$WindowsVersion" windows/servercore:latest
docker tag "mcr.microsoft.com/windows/servercore:$WindowsVersion" microsoft/servercore:latest