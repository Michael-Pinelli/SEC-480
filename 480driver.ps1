Import-Module '480-utils' -Force

480Banner
$conf = Get-480Config -config_path "/home/mike/SYS-480/480.json"
480Connect -server $conf.vcenter_server
Write-Host "Listing VMs"

$option = Read-Host -Prompt "[L]inked clone of Base Snapshot | [V]irtual Switch | [P]ort Group | [G]et VM Info"
if ($option -eq "l" -or $option -eq "L")
{
    Select-VM -folder "BASEVM"
    createlinkedclone
}elseif ($option -eq "v" -or $option -eq "V")
{
    Create-VS -vmhost $conf.esxi_host
}elseif ($option -eq "p" -or $option -eq "P")
{
    Create-PG
}elseif ($option -eq "g" -or $option -eq "G")
{
    Select-VM -folder "480-Pinelli"
    GetVM-Info
}