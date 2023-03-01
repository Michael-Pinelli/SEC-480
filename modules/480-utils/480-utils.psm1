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