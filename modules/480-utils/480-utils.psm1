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

function 480Connect ([string] $server, [string] $user)
{
    $conn = $global:DefaultVIserver
    if ($conn){
        $msg = "Already Connected to: {0}" -f $conn
        Write-Host -ForegroundColor Green $msg
    }else {
        $conn = Connect-VIServer -Server $server -User $user
    }
}

function Get-480Config([string] $config_path)
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
}

function Select-VM([string] $folder)
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
            Write-Host "You chose " $selected_vm.name
            return $selected_vm
        }
        catch {
            Write-Host "Invalid Index: $pick_index" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Invalid Folder: $folder" -ForegroundColor Red
    }
    
}

function createbasevm() {
    Get-VM
    $cvm = Read-Host -Prompt "Please enter the VM you want to clone (name)"
    $vm = Get-VM -Name $cvm
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
    Get-VM
    $cvm = Read-Host -Prompt "Please enter the VM you want to clone (name)"
    $vm = Get-VM -Name $cvm
    $vmhost = Get-VMHost -Name "192.168.7.23"
    $ds = Get-DataStore -Name "datastore2 -super13"
    $snapshot = Get-Snapshot -VM $vm -Name "Base"
    $linkedClone = Read-Host -Prompt "Please enter the new VM's name"
    $linkedVM = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
    $net_vm = Read-Host -Prompt "Please enter the network you want the new VM to be on"
    $linkedVM | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $net_vm
    Get-VM
}