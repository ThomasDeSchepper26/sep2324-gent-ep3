$VBoxManagePath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
Set-Alias -Name VBoxManage -Value $VBoxManagePath

# Get your main NIC of the bridge mode 
$NIC = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -First 1).NetAdapter.InterfaceDescription

# Path to the configuration file
$configFilePath = "./CreateClientConfig.txt"

# Defining Variables
$VM_FOLDER = "C:\VirtualBox"
$SHARED_FOLDER_PATH = [System.Environment]::GetFolderPath("Desktop")
$SHARED_FOLDER_NAME = "SharedHostFolder"

# Start with a clean terminal
Clear-Host

# -------------------------------------------------------------------------------------------------
# Provisioning
# -------------------------------------------------------------------------------------------------

Write-Host "Reading the configurations of your configuration file" -ForegroundColor Magenta

# Parsing of the config file
$VMConfigs = Get-Content $configFilePath -Raw
# Empty array to hold the VMs
$VMs = @() 
$VMConfigs -split "(?=\[VM\d+\])" | Where-Object { $_ } | ForEach-Object {
    # Current configuration has to be hold
    $currentVM = @{}
    $_ -split "`r`n" | Where-Object { $_ -match "=" } | ForEach-Object {
        $keyValue = $_ -split "=", 2
        $currentVM[$keyValue[0].Trim()] = $keyValue[1].Trim()
    }
    $VMs += $currentVM
}

Write-Host "Creating VM's" -ForegroundColor Magenta

# Building check list for the VMs
$existingVMs = VBoxManage list vms | ForEach-Object {
    if ($_ -match '"(.*?)"') {
        return $matches[1]
    }
}

# Loop through the VMs and create them
foreach ($VM in $VMs) {
    
    # Check if the VM is already present
    if ($VM["Name"] -in $existingVMs) {
        Write-Host "VM $($VM["Name"]) already present, deletion in progress" -ForegroundColor Yellow
        Write-Host "You have 10 seconds to cancel.. starting now" -ForegroundColor Red
        Start-Sleep -Seconds 10
        VBoxManage unregistervm $($VM["Name"]) --delete
        Write-Host "VM $($VM["Name"]) deleted successfully" -ForegroundColor Green
    }

    # Check on the disk to handle errors created by not cleaning up 
    $diskPath = "$VM_FOLDER\$($VM["Name"])\$($VM["Name"]).vdi"
    if (Test-Path $diskPath) {
        Write-Host "Disk file already exists. Attempting to unregister and delete: $diskPath" -ForegroundColor Yellow
        VBoxManage closemedium disk $diskPath --delete | Out-Null
        Remove-Item $diskPath -Force
    }

    # Create the VM
    Write-Host "Creating VM: $($VM["Name"])" -ForegroundColor Magenta
    VBoxManage createvm --name $($VM["Name"]) --ostype $($VM["OSTYPE"]) --register | Out-Null
    Write-Host "Setting memory and CPU configurations for $($VM["Name"])" -ForegroundColor Yellow | Out-Null
    VBoxManage modifyvm $($VM["Name"]) --memory $($VM["MemorySize"]) --cpus $($VM["CpuCount"]) | Out-Null
    Write-Host "Creating and attaching hard disk for $($VM["Name"])" -ForegroundColor Yellow | Out-Null
    VBoxManage createmedium disk --filename "$VM_FOLDER\$($VM["Name"])\$($VM["Name"]).vdi" --size $($VM["HddSize"]) --format VDI | Out-Null
    VBoxManage storagectl $($VM["Name"]) --name "SATA Controller" --add sata --controller IntelAhci | Out-Null
    VBoxManage storageattach $($VM["Name"]) --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_FOLDER\$($VM["Name"])\$($VM["Name"]).vdi" | Out-Null
    VBoxManage modifyvm $($VM["Name"]) --vram $($VM["Vram"]) | Out-Null
    
    # Network card adding 
    VBoxManage modifyvm $($VM["Name"]) --nic1 bridged --bridgeadapter1 $NIC

    # Shared folder and group adding
    VBoxManage sharedfolder add $($VM["Name"]) --name $SHARED_FOLDER_NAME --hostpath "$SHARED_FOLDER_PATH" --automount
    Write-Host "$($VM["Name"]) setup completed" -ForegroundColor Green
    Write-Host "-------------------------------------"
}


# Rebuild the check list once again to check if all VMs are present
$registeredVMs = VBoxManage list vms | ForEach-Object {
    if ($_ -match '"(.*?)"') {
        return $matches[1]
    }
}

$allVMsSetUp = $true

# Check if all VMs are present
foreach ($VM in $VMs) {
    if ($VM.Name -notin $registeredVMs) {
        Write-Host "WARNING: $($VM.Name) was not set up correctly!" -ForegroundColor Red
        $allVMsSetUp = $false
    }
}

# Output to terminal to give update of script status after run, this will also start the OS installation in case check is passed 
if ($allVMsSetUp) {
    Write-Host "All VMs have been set up successfully" -ForegroundColor Green
    Write-Host "Automatic installation of the VMs will start in 10 seconds" -ForegroundColor Magenta
    Start-Sleep -Seconds 10 
}
else {
    Write-Host "Some VMs were not set up correctly. Please review the warnings above." -ForegroundColor Red
    exit 1
}

# -------------------------------------------------------------------------------------------------
# Installation
# -------------------------------------------------------------------------------------------------

Write-Host "Starting the installation process for all VMs" -ForegroundColor Magenta

foreach ($VM in $VMs) {
    $VMName = $VM["Name"]
    $IsoPath = $VM["IsoPath"]
    $Username = $VM["Username"]
    $Password = $VM["Password"]
    $ImageIndex = $VM["ImageIndex"]
    $Language = $VM["Language"]
    $Country = $VM["Country"]
    $ProductKey = $VM["ProductKey"]

    Write-Host "Starting Windows installation for $VMName using ISO at $IsoPath" -ForegroundColor Magenta
    VBoxManage unattended install $VMName --iso=$IsoPath --user=$Username --password=$Password --image-index=$ImageIndex --key=$ProductKey --language=$Language --country=$Country --install-additions | Out-Null
    Write-Host "Starting VM $VMName headless" -ForegroundColor Magenta
    VBoxManage startvm $VMName --type headless | Out-Null
    Write-Host "Windows installation started for $VMName" -ForegroundColor Green
}

Write-Host "All VMs have started the unattended installation, script will exit" -ForegroundColor Green
Start-Sleep -Seconds 3