Import-Module '480-utils' -Force

480Banner
$conf = Get-480Config -config_path "/home/mike/SYS-480/480.json"
480Connect -server $conf.vcenter_server

function main_menu () {
    Write-Host "Options"
    Write-Host "[1] Create a Linked Clone"
    Write-Host "[2] Create a Virtual Switch" 
    Write-Host "[3] Create a Port Group"
    Write-Host "[4] Get VM Info"
    Write-Host "[5] Start a VM"
    Write-Host "[6] Stop a VM"
    Write-Host "[7] Edit a VM"
    Write-Host ""
    $menuInput = Read-Host 'Please Select an Option'
    if ($menuInput -eq "1"){
        Select-VM -folder "BASEVM"
        createlinkedclone
    }elseif($menuInput -eq '2'){
        Create-VS -vmhost $conf.esxi_host
    }elseif($menuInput -eq '3'){
        Create-PG
    }elseif($menuInput -eq '4'){
        Select-VM -folder "480-Pinelli"
        GetVM-Info
    }elseif($menuInput -eq '5'){
        Select-VM -folder "480-Pinelli"
        StartVM
    }elseif($menuInput -eq '6'){
        Select-VM -folder "480-Pinelli"
        StopVM
    }elseif($menuInput -eq '7'){
        Select-VM -folder "480-Pinelli"
        Edit-VM
    }else{
        Write-Host -ForegroundColor "Red" "Invalid Selection."
        main_menu
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
