Import-Module '480-utils' -Force

480Banner
$conf = Get-480Config -config_path = "/home/mike/SYS-480/480.json"
480Connect -server $conf.vcenter_server -user $conf.vcenter_username
Write-Host "Selecting VM"
Select-VM -folder "BASEVM"

$option = Read-Host -Prompt "[L]inked clone of Base Snapshot"
if ($option -eq "l" -or $option -eq "L")
{
    createlinkedclone
}