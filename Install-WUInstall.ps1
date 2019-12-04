param(
    [parameter(Mandatory,ValueFromPipelinebyPropertyName = $false)]
    [Alias('Name')]
     [string[]]$VMName,
    [parameter(Mandatory)][pscredential]$Credential,
    [string]$NoMatch,
    [string]$Match,
    [switch]$RunAsync
)
## Add /rebootcycle 2 to wuinstall commands as a param perhaps. This will run two cycles of patches after reboot automaticlly.

$vms = get-vm $VMName |  ? {$_.guest.OSfullname -like "*server*"}
if ($NoMatch) {
        $script = "C:\wmbin\WuInstallProTrial\WUInstall.exe /install /logfile c:\wmbin\WuInstallProTrial\install.log /autoaccepteula /disableprompt /reboot_if_needed_force 10 /nomatch ""$NoMatch"" "
    } 
    elseif ($Match) {
        $script = "C:\wmbin\WuInstallProTrial\WUInstall.exe /install /logfile c:\wmbin\WuInstallProTrial\install.log /autoaccepteula /disableprompt /reboot_if_needed_force 10 /match ""$match"" "
    }
    else {
        $script = "C:\wmbin\WuInstallProTrial\WUInstall.exe /install /logfile c:\wmbin\WuInstallProTrial\install.log /autoaccepteula /disableprompt /reboot_if_needed_force 10 "
    }


if ($RunAsync){
    Invoke-VMScript -VM $vms -ToolsWaitSecs 30 -ScriptText $script `
    -ErrorAction SilentlyContinue -ScriptType Powershell -GuestCredential $Credential -RunAsync
} else {
    $report= Invoke-VMScript -VM $vms -ToolsWaitSecs 30 -ScriptText $script `
    -ErrorAction SilentlyContinue -ScriptType Powershell -GuestCredential $Credential
    write-output $report
}