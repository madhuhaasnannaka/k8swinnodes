sc.exe config wuauserv start= disabled
sc.exe stop wuauserv

$AUSettings = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
$AUSettings.NotificationLevel = 1
$AUSettings.Save