param(
    [parameter(Mandatory,ValueFromPipelinebyPropertyName=$false)]
    [Alias('Name')]
     [string[]]$VMName,
    [parameter(Mandatory)]
     [validateset("East","West")]
     [string]$Datacenter,
    [parameter(Mandatory)][pscredential]$Credential
)
if ($Datacenter -eq "West"){
    $vms = get-vm $VMName -server vcsa01l-whs-02|  ? {$_.guest.OSfullname -like "*server*"}
    $Scripttext = {
    if ((gci env:USERDOMAIN).value -eq "PROD") {
        New-PSDrive z -PSProvider FileSystem "\\10.62.48.50\software$\" | Out-Null
    }else {
        New-PSDrive z -PSProvider FileSystem "\\10.32.30.81\software$\" | Out-Null 
    }
    if (!(Test-Path "c:\wmbin\WuInstallProTrial\WUInstall.exe" -PathType Leaf)) {
        Copy-Item -Container "z:\brian\Installs\WuInstallProTrial" -Destination "C:\wmbin\" -Recurse
        Write-Output "Copied"
        } else {
            Write-Output "There already"
        }
    gci C:\wmbin\WuInstallProTrial | select name
    #Remove-PSDrive z -Confirm:$true  
    }
} else {
    $vms = get-vm $VMName -Server iad18vcsa01 |  ? {$_.guest.OSfullname -like "*server*"}
    $Scripttext = {
    if ((gci env:USERDOMAIN).value -eq "PROD") {
        New-PSDrive z -PSProvider FileSystem "\\10.60.50.50\software$\" | Out-Null
    }else {
        New-PSDrive z -PSProvider FileSystem "\\10.32.30.81\software$\" | Out-Null 
    }
    if (!(Test-Path "c:\wmbin\WuInstallProTrial\WUInstall.exe" -PathType Leaf)) {
        Copy-Item -Container "z:\brian\Installs\WuInstallProTrial" -Destination "C:\wmbin\" -Recurse
        Write-Output "Copied"
        } else {
            Write-Output "There already"
        }
    gci C:\wmbin\WuInstallProTrial | select name
    #Remove-PSDrive z -Confirm:$true  
    }
}

$results= Invoke-VMScript -VM $vms -ScriptText $Scripttext  -ErrorVariable noway -ErrorAction SilentlyContinue -ScriptType Powershell -GuestCredential $Credential 
$results | select vm,ScriptOutput | ft -Wrap
