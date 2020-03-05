$AWSSelfServiceUri = "169.254.169.254/latest"
$AuthorizedKeys = "C:/ProgramData/ssh/administrators_authorized_keys"
$sshd = Get-WindowsCapability -Online -Name OpenSSH.Server*
Add-WindowsCapability -Online -Name $sshd[0].Name
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd
Stop-Service sshd

wget https://raw.githubusercontent.com/geodata-no/window-cubeup/master/sshd_config -OutFile c:/programdata/ssh/sshd_config
wget https://raw.githubusercontent.com/PowerShell/openssh-portable/latestw_all/contrib/win32/openssh/OpenSSHUtils.psm1 -OutFile c:/OpenSSHUtils.psm1

$keypairs = (wget "http://$AWSSelfServiceUri/meta-data/public-keys" -UseBasicParsing).Content
$keypair = $keypairs.split("=")
$keyid = $keypair[0]
$pubkey = (wget "http://$AWSSelfServiceUri/meta-data/public-keys/$keyid/openssh-key" -UseBasicParsing).Content
Set-Content -Path $AuthorizedKeys -Value $pubkey -Force

ipmo c:/OpenSSHUtils.psm1

$adminsSid = Get-UserSID -WellKnownSidType ([System.Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid)
$systemSid = Get-UserSID -WellKnownSidType ([System.Security.Principal.WellKnownSidType]::LocalSystemSid)
$ConfirmPreference = "None"

Repair-FilePermission -Owners $adminsSid,$systemSid $AuthorizedKeys -FullAccessNeeded $systemSid
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

Remove-Item c:/OpenSSHUtils.psm1
Start-Service sshd