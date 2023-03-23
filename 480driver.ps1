Import-Module '480-utils' -Force

480Banner
$conf = Get-480Config -config_path "/home/mike/SYS-480/480.json"
480Connect -server $conf.vcenter_server

function main_menu () {
$option = Read-Host -Prompt "[L]inked clone of Base Snapshot | [V]irtual Switch | [P]ort Group | [G]et VM Info | [S]tart a VM | [SS]top a VM | [N]etwork Adapter"
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
}elseif ($option -eq "s" -or $option -eq "S")
{
    Select-VM -folder "480-Pinelli"
    StartVM
}elseif ($option -eq "ss" -or $option -eq "SS")
{
    Select-VM -folder "480-Pinelli"
    StopVM
}elseif ($option -eq "n" -or $option -eq "N")
{
    Select-VM -folder "480-Pinelli"
    Change-NetworkAdapter
}
}

main_menu

function return_to_main (){
$option2 = Read-Host -Prompt "Would you like to return to the main menu? [Y/N]"
if ($option2 -eq "y" -or $option -eq "Y")
{
    main_menu
}else{
    Write-Host "Goodbye!"
    Exit
}
}
