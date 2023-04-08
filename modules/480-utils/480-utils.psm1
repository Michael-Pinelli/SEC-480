Import '/home/mike/SYS-480'

function 480Banner()
{   
    $banner=@'
  ______   __      __  ______           __    __   ______    ______  
  /      \ /  \    /  |/      \         /  |  /  | /      \  /      \ 
 /$$$$$$  |$$  \  /$$//$$$$$$  |        $$ |  $$ |/$$$$$$  |/$$$$$$  |
 $$ \__$$/  $$  \/$$/ $$ \__$$/  ______ $$ |__$$ |$$ \__$$ |$$$  \$$ |
 $$      \   $$  $$/  $$      \ /      |$$    $$ |$$    $$< $$$$  $$ |
  $$$$$$  |   $$$$/    $$$$$$  |$$$$$$/ $$$$$$$$ | $$$$$$  |$$ $$ $$ |
 /  \__$$ |    $$ |   /  \__$$ |              $$ |$$ \__$$ |$$ \$$$$ |
 $$    $$/     $$ |   $$    $$/               $$ |$$    $$/ $$   $$$/ 
  $$$$$$/      $$/     $$$$$$/                $$/  $$$$$$/   $$$$$$/  
                                                                                      
'@

    Write-Host $banner
}

function 480Connect ([string] $server)
{
    $conn = $global:DefaultVIserver
    if ($conn){
        $msg = "Already Connected to: {0}" -f $conn
        Write-Host -ForegroundColor Green $msg
    }else {
        $conn = Connect-VIServer -Server $server
    }
}

Function Get-480Config([string] $config_path)
{
    Write-Host "Reading " $config_path
    $conf=$null
    if(Test-Path $config_path)
    {
        $conf = (Get-Content -Raw -Path $config_path | ConvertFrom-Json)
        $msg = "Using Configuration at {0}" -f $config_path
        Write-Host -ForegroundColor Green $msg
    }else{
        Write-Host -ForegroundColor Yellow "No Configuration!"
    }
    return $conf
}

$global:selected_vm2=$null
Function Select-VM([string] $folder)
{
    $selected_vm=$null
    try
    {
        $vms = Get-VM -Location $folder
        $index = 1
        foreach($vm in $vms)
        {
            Write-Host [$index] $vm.Name
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you want to choose?"
        try{
            $selected_vm = $vms[$pick_index -1]
            Write-Host "You chose:" $selected_vm.name
            $global:selected_vm2 = $selected_vm
            return $selected_vm
        }
        catch {
            Write-Host "Invalid Index: $pick_index" -ForegroundColor Red
            Select-VM
        }
    }
    catch {
        Write-Host "Invalid Folder: $folder" -ForegroundColor Red
    }
    
}

function createbasevm() {
    $vm = $global:selected_vm2
    $vmhost = Get-VMHost -Name "192.168.7.23"
    $ds = Get-DataStore -Name "datastore2 -super13"
    $snapshot = Get-Snapshot -VM $vm -Name "Base"
    $linkedClone = "{0}.linked" -f $vm.Name
    $vm_name = Read-Host -Prompt "Please enter the new VM's name"
    $linkedVM = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
    $new_vm = New-VM -Name $vm_name -VM $linkedVM -VMHost $vmhost -Datastore $ds
    $new_vm | New-Snapshot -Name "Base"
    $linkedVM | Remove-VM
    Get-VM
}
    
function createlinkedclone() {
    $vm = $global:selected_vm2
    $vmhost = Get-VMHost -Name "192.168.7.23"
    $ds = Get-DataStore -Name "datastore2 -super13"
    $snapshot = Get-Snapshot -VM $vm -Name "Base"
    $linkedClone = Read-Host -Prompt "Please enter the new VM's name"
    New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
    Get-VM
    return_to_main
}

function Create-VS([string] $vmhost)
{
    Get-VirtualSwitch | Select Name
    $name = Read-Host -Prompt "Please enter the new Virtual Switch name"
    $new_vs = New-VirtualSwitch -VMHost $vmhost -Name $name
    Write-Host "Created: " $new_vs
    $option = Read-Host -Prompt "Do you want to create a new port group [Y/N]"
    if ($option -eq "y" -or $option -eq "Y")
    {   
        $name = Read-Host -Prompt "Please enter the new Port Group name"
        $new_pg = New-VirtualPortGroup -VirtualSwitch $new_vs -Name $name
        Write-Host "Created: " $new_pg
    }else {
        Get-VirtualSwitch  | Select Name
    }
    Get-VirtualSwitch  | Select Name
    return_to_main
}


function Create-PG()
{
    Get-VirtualSwitch | Select Name
    $vswitch = Read-Host -Prompt "Please enter the Virtual Switch's name"
    $name = Read-Host -Prompt "Please enter the new Port Group name"
    $new_pg = New-VirtualPortGroup -VirtualSwitch $vswitch -Name $name
    Write-Host "Created: " $new_pg
    return_to_main

}

function GetVM-Info()
{
    #Shoutout to Lucd on the VMware forums :)
    Get-VM -Name $global:selected_vm2 -PipelineVariable vm | where{$_.Guest.Nics.IpAddress} | Get-NetworkAdapter |
    Select @{N='VM';E={$vm.Name}},Name,@{N=”IP Address”;E={$nic = $_; ($vm.Guest.Nics | where{$_.Device.Name -eq $nic.Name}).IPAddress -join '|'}},MacAddress
    return_to_main
}

function StartVM ()
{
    Start-VM -VM $global:selected_vm2
    return_to_main
}

function StopVM ()
{
    Stop-VM -VM $global:selected_vm2
    return_to_main
}

function Edit-VM ()
{
    Write-Host "Options"
    Write-Host "[1] Change the Network Adapter "
    Write-Host "[2] Change the Memory (GB)" 
    Write-Host "[3] Change CPU Count"
    Write-Host ""
    $menuInput = Read-Host 'Please Select an Option'
    if ($menuInput -eq "1"){
        Get-NetworkAdapter -VM $global:selected_vm2 | Select Name
        $net_adapter_q = Read-Host -Prompt "Please select which network adapter you want to change"
        $net_adapter = Get-NetworkAdapter -VM $global:selected_vm2 -Name $net_adapter_q
        Get-VirtualPortGroup | Select Name
        $new_net = Read-Host -Prompt "Please select which network you want to change to"
        Set-NetworkAdapter -NetworkAdapter $net_adapter -NetworkName $new_net
        return_to_main
    }elseif($menuInput -eq '2'){
        $new_ram = Read-Host -Prompt "Enter the new amount of memory (GB)"
        Set-VM -VM $global:selected_vm2 -MemoryGB $new_ram
    }elseif($menuInput -eq '3'){
        $new_cpu = Read-Host -Prompt "Enter the new amount of CPU cores"
        Set-VM -VM $global:selected_vm2 -NumCpu $new_cpu
    }else{
        Write-Host -ForegroundColor "Red" "Invalid Selection."
        Edit-VM
    }
}