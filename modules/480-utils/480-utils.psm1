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
    $linkedVM = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
    $linkedVM | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName "480-WAN"
    Get-VM
}