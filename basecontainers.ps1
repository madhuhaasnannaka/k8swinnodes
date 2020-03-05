$PauseImageVersion = "1909"
$WindowsVersions = @("1909")

foreach($WindowsVersion in $WindowsVersions) {
    docker pull "mcr.microsoft.com/windows/nanoserver:$WindowsVersion"
    docker pull "mcr.microsoft.com/windows/servercore:$WindowsVersion"

    docker tag "mcr.microsoft.com/windows/nanoserver:$WindowsVersion" windows/nanoserver:latest
    docker tag "mcr.microsoft.com/windows/nanoserver:$WindowsVersion" microsoft/nanoserver:latest
    docker tag "mcr.microsoft.com/windows/servercore:$WindowsVersion" windows/servercore:latest
    docker tag "mcr.microsoft.com/windows/servercore:$WindowsVersion" microsoft/servercore:latest
}