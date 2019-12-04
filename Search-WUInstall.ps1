param(
    [parameter(Mandatory,ValueFromPipelinebyPropertyName = $false)]
    [Alias('Name')]
     [string[]]$VMName,
    [parameter(Mandatory)][pscredential]$Credential,
    [string]$NoMatch,
    [string]$Match,
    [validateSet("Simple","Extended","Full")]
    [string]$ReportType = "Full"
)
$vms = get-vm $VMName | ? {($_.guest.OSfullname -like "*server*") -AND ($_.guest.state -eq 'Running')}

if ($NoMatch) {
        $script = "C:\wmbin\WuInstallProTrial\WUInstall.exe /search /maxruntime 1 /nomatch ""$NoMatch"" "
    } elseif ($Match) {
        $script = "C:\wmbin\WuInstallProTrial\WUInstall.exe /search /maxruntime 1 /match ""$Match"" "
    } else {
        $script = "C:\wmbin\WuInstallProTrial\WUInstall.exe /search /maxruntime 1"
    }

$report= Invoke-VMScript -VM $vms -ToolsWaitSecs 30 -ScriptText $script `
 -ErrorAction SilentlyContinue -ScriptType Powershell -GuestCredential $Credential

switch ($ReportType) {
    'Simple' {
        $report | 
        select VM,@{
            n="Updates";e={
                (($_.ScriptOutput -split "\n" | 
                Select-String -Pattern '^\d+ Updates|^No updates|^operation Result' ) -as [string]).trim()
                }
        }
    }
    'Extended' {
        $list = [collections.arraylist]@()
        foreach ($r in $report) {
            $split = $r.scriptoutput -split '\n'
            $full = $split | Select-String -Pattern '^\d+\.' -Context 0,6
            foreach ($f in $full) {
                [void]$list.add(
                    $($f | select @{n="VM";e={$r.vm.name}},
                    @{n="Size";e={($f.Context.PostContext[5] -split ":")[1] -as [int]}},
                    @{n="Patches";e={$_.line.trim()}}
                    )
                )

            }
        }
        write-output $list
        
        #$report | 
        #select VM,@{n="Patches";e={$_.ScriptOutput -split "\n" |
        #Select-String -Pattern '^\d+\.'}} 
    }
    'Full' {
        $report    
    
    }
}
