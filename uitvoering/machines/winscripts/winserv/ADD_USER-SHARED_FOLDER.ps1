# Vraag de gebruikersnaam op
$Username = Read-Host "Voer de gebruikersnaam in"

# Vraag het wachtwoord op
$Password = Read-Host "Voer het wachtwoord in" -AsSecureString

# Vraag de afdeling op
$Department = Read-Host "Voer de afdeling in (IT, Marketing, HR, Boekhouding)"

# Controleer of de gebruiker al bestaat
if (-not (Get-ADUser -Filter {SamAccountName -eq $Username})) {
    # Maak de gebruiker aan in de juiste OU en zorg ervoor dat het account wordt ingeschakeld
    New-ADUser -Name $Username -SamAccountName $Username -AccountPassword $Password -Enabled $true -Path "OU=$Department,DC=ad,DC=g08-systemsolutions,DC=internal"
    Write-Host "Gebruiker $Username is aangemaakt en toegevoegd aan de $Department afdeling."
} else {
    Write-Host "Gebruiker $Username bestaat al."
}

$Departments = @("IT", "Marketing", "HR", "Boekhouding")

# shared folder
foreach($User in $ADUsers)
{
    $Username = $User.username
    $Department = $User.department
    #create share folder
    New-Item -Path "C:\Shares\$Username" -ItemType Directory
    #set permissions, only the user and the domain admin has access
    if($Department -eq "IT")
    {
        New-SmbShare -Name $Username -Path "C:\Shares\$Username" -FullAccess $Username, $DomainAdmin
        Write-Host "Shared"
    }elseif($Department -eq "Marketing")
    {
        New-SmbShare -Name $Username -Path "C:\Shares\$Username" -FullAccess $Username, $DomainAdmin
        Write-Host "Shared"
    }elseif($Department -eq "HR")
    {
        New-SmbShare -Name $Username -Path "C:\Shares\$Username" -FullAccess $Username, $DomainAdmin
        Write-Host "Shared"
    }elseif($Department -eq "Boekhouding")
    {
        New-SmbShare -Name $Username -Path "C:\Shares\$Username" -FullAccess $Username, $DomainAdmin
        Write-Host "Shared"
    }
}

    Write-Host "Done"