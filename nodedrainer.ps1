Import-Module AWSPowerShell

$AWSSelfServiceUri = "169.254.169.254/latest"
$PollInterval = 15

$InstanceId = (Invoke-WebRequest "http://$AWSSelfServiceUri/meta-data/instance-id" -UseBasicParsing).Content
$AwsRegion = ((wget "http://$AWSSelfServiceUri/dynamic/instance-identity/document" -UseBasicParsing).Content | ConvertFrom-Json).region
$NodeName = (wget "http://$AWSSelfServiceUri/meta-data/local-hostname" -UseBasicParsing).Content

$TerminationSource = ''

$AutoScalingGroups = Get-ASAutoScalingGroup
$AutoScalingGroup = ''
foreach($asg in $AutoScalingGroups) {
    foreach($instance in $asg.Instances) {
        if($instance.InstanceId -eq $InstanceId) {
            $AutoScalingGroup = $ASG.AutoScalingGroupName
        }
    }
}

while ($true) {
    try
    {
        $Response = Invoke-WebRequest "http://$AWSSelfServiceUri/meta-data/spot/termintaion-time" -ErrorAction Stop
        # This will only execute if the Invoke-WebRequest is successful.
        $TerminationStatusCode = $Response.StatusCode
    }
    catch
    {
        $TerminationStatusCode = $_.Exception.Response.StatusCode.value__
    }

    if($TerminationStatusCode -eq 200) {
        $TerminationSource = 'spot'
        break
    }

    $IsTerminating = (Get-ASAutoScalingGroup -AutoScalingGroupName $AutoScalingGroup).Instances | ? {$_.InstanceId -eq $InstanceId -and $_.LifecycleState -eq "Terminating:Wait"}
    if($IsTerminating) {
        $TerminationSource = 'ags'
        break
    }

    Start-Sleep -Seconds $PollInterval
}

while ($true) {
    Write-Host "Cordoning node $NodeName"
    c:/k/bin/kubectl.exe --kubeconfig=c:/k/kconfigs/kubelet.kcfg cordon $NodeName

    Write-Host "Draining node $NodeName"
    c:/k/bin/kubectl.exe --kubeconfig=c:/k/kconfigs/kubelet.kcfg drain --ignore-daemonsets=true --delete-local-data=true --force=true --timeout=60s $node

    if($TerminationSource -eq 'ags') {
        Write-Host "Notifying ASG that instance $InstanceId can be terminated"

        if($AutoScalingGroup -eq '') {
            Write-Host "No AutoScalingGroup found for instance $InstanceId. Done."
            Start-Sleep -Seconds 300
            break
        }

        $Hook = Get-ASLifecycleHook -AutoScalingGroupName $AutoScalingGroup | ? {$_.LifecycleHookName -eq 'nodedrainer'}
        Complete-ASLifecycleAction -AutoScalingGroupName $AutoScalingGroup -InstanceId $InstanceId -LifecycleHookName $Hook.LifecycleHookName -LifecycleActionResult "CONTINUE"
        Write-Host "Completed lifecycle hook for instance $InstanceId"
    }
    Start-Sleep -Seconds 300
}