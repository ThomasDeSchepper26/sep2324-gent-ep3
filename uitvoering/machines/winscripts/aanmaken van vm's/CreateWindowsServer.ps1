# Variabelen
$vmnaam = "Winserverg8"
$ostype = "Windows2022_64"
$geheugen = 2048
$vram = 128
$processorkernen = 1
$nat_network_name = "SEPNETWORK"
$drivesize1 = 20000
$drivesize2 = 10000

# Winserver aanmaken
# Maak een nieuwe virtuele machine aan met de opgegeven naam en het opgegeven besturingssysteemtype
vboxmanage createvm --name "$vmnaam" --ostype $ostype --register
# Wijzig de geheugen- en videogeheugeninstellingen van de virtuele machine
vboxmanage modifyvm $vmnaam --memory $geheugen --vram $vram
# Wijzig het aantal processorcores van de virtuele machine
vboxmanage modifyvm $vmnaam --cpus $processorkernen

# Configureer de netwerkadapter van de virtuele machine met een NAT-netwerkadapter
vboxmanage modifyvm $vmnaam --nic1 natnetwork --nat-network1 $nat_network_name

# Toevoegen VDI & ISO, opstartvolgorde Boot drives
# Maak een nieuwe virtuele harde schijf aan voor de virtuele machine
vboxmanage createmedium --filename "C:\Users\thomd\VirtualBox VMs\$vmnaam\$vmnaam.vdi" --size $drivesize1
# Maak een nieuwe virtuele harde schijf aan voor gedeelde mappen
vboxmanage createmedium --filename "C:\Users\thomd\VirtualBox VMs\$vmnaam\Winserverg8_2.vdi" --size $drivesize2

# Voeg een nieuwe SATA-controller toe aan de virtuele machine
vboxmanage storagectl $vmnaam --name "SATA Controller" --add sata --controller IntelAHCI
# Koppel de virtuele harde schijven aan de SATA-controller
vboxmanage storageattach $vmnaam --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "C:\Users\thomd\VirtualBox VMs\$vmnaam\$vmnaam.vdi"
# Koppel het ISO-bestand aan de virtuele machine als een dvd-station
vboxmanage storageattach $vmnaam --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium "C:\Users\thomd\Downloads\en-us_windows_server_2022_x64_dvd_620d7eac.iso"
# Stel de opstartvolgorde van de virtuele machine in
vboxmanage modifyvm $vmnaam --boot1 dvd --boot2 disk --boot3 none --boot4 none

# Installatie
# Voer een onbeheerde installatie uit met de opgegeven parameters, inclusief post-installatieopdrachten
vboxmanage unattended install $vmnaam `
    --iso "C:\Users\thomd\Downloads\en-us_windows_server_2022_x64_dvd_620d7eac.iso" `
    --hostname "ad.g08-systemsolutions.internal" `
    --user "Administrator" `
    --password "23Admin24" `
    --country "BE" `
    --locale "nl_BE" `
    --additions-iso "C:\Program Files\Oracle\VirtualBox\VBoxGuestAdditions.iso" `
    --install-additions `
    --post-install-command "Shutdown /r /t 5"

# Extra configuratie na installatie
# Stel de bidirectionele klembordfunctie in
vboxmanage modifyvm $vmnaam --clipboard bidirectional
# Stel de bidirectionele slepen-en-neerzetten-functie in
vboxmanage modifyvm $vmnaam --draganddrop bidirectional

# Voeg een gedeelde map toe
$shared_folder_path = "C:\Users\thomd\HoGent\3de JAAR\EP3\SEP\sep2324-gent-ep3\uitvoering\machines\winscripts\winserv"
vboxmanage sharedfolder add $vmnaam --name "shared" --hostpath $shared_folder_path --automount

# Start de virtuele machine
vboxmanage startvm $vmnaam
