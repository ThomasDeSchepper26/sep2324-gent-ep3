# Variabelen
$vmnaam = "WinClientg8"
$os_type = "Windows10_64"
$domeinnaam = "g08-systemsolutions.internal"
$user_name = "Administrator"
$password = "23Admin24"
$geheugen = 2048
$vram = 128
$processor_cores = 2
$drive_size = 25000
$graphics_controller = "vboxsvga"
$iso_path = "C:\Users\thomd\Downloads\SW_DVD9_Win_Pro_10_20H2.10_64BIT_English_Pro_Ent_EDU_N_MLF_X22-76585.ISO"
$nat_network_name = "SEPNETWORK"

# Maak een nieuwe virtuele machine aan met de opgegeven naam en het opgegeven besturingssysteemtype
vboxmanage createvm --name "$vmnaam" --ostype $os_type --register

# Wijzig de geheugen-, videogeheugen-, CPU- en grafische controllerinstellingen van de virtuele machine
vboxmanage modifyvm $vmnaam --memory $geheugen --vram $vram --cpus $processor_cores --graphicscontroller $graphics_controller

# Configureer de netwerkadapter van de virtuele machine met NAT-netwerkadapter en de opgegeven NAT-netwerk
vboxmanage modifyvm $vmnaam --nic1 natnetwork --nat-network1 $nat_network_name

# Creëer een nieuwe virtuele harde schijf met de opgegeven bestandsnaam en grootte
vboxmanage createmedium disk --filename "C:\Users\thomd\VirtualBox VMs\$vmnaam\$vmnaam.vdi" --size $drive_size

# Voeg een nieuwe SATA-controller toe aan de virtuele machine
vboxmanage storagectl $vmnaam --name "SATA Controller" --add sata --controller IntelAHCI

# Koppel de virtuele harde schijf aan de SATA-controller
vboxmanage storageattach $vmnaam --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "C:\Users\thomd\VirtualBox VMs\$vmnaam\$vmnaam.vdi"

# Koppel het ISO-bestand aan de virtuele machine als een dvd-station
vboxmanage storageattach $vmnaam --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium $iso_path

# Stel de opstartvolgorde van de virtuele machine in
vboxmanage modifyvm $vmnaam --boot1 dvd --boot2 disk --boot3 none --boot4 none

# Installatie
# Voer een onbeheerde installatie uit met de opgegeven parameters, inclusief post-installatieopdrachten
vboxmanage unattended install $vmnaam `
    --iso $iso_path `
    --hostname "WinClientg8.g08-systemsolutions.internal" `
    --user $user_name `
    --password $password `
    --country BE `
    --locale nl_BE `
    --install-additions `
    --post-install-command "powershell Set-ExecutionPolicy RemoteSigned -Scope LocalMachine ; Shutdown /r /t 5"

# Extra configuratie na installatie
# Stel de bidirectionele klembordfunctie in
vboxmanage modifyvm $vmnaam --clipboard bidirectional
# Stel de bidirectionele slepen-en-neerzetten-functie in
vboxmanage modifyvm $vmnaam --draganddrop bidirectional

# Voeg een gedeelde map toe
$shared_folder_path = "C:\Users\thomd\HoGent\3de JAAR\SEP\sep2324-gent-g08\uitvoering\machines\winscripts\winclient"
vboxmanage sharedfolder add $vmnaam --name "shared" --hostpath $shared_folder_path --automount

# Start de virtuele machine
vboxmanage startvm $vmnaam
