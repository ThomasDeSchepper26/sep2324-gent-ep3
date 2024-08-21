# Vraag de gebruikersnaam op
$Username = Read-Host "Voer de gebruikersnaam in"

# Vraag het wachtwoord op
$Password = Read-Host "Voer het wachtwoord in" -AsSecureString

# Vraag de afdeling op
$Department = Read-Host "Voer de afdeling in (IT, Marketing, HR, Boekhouding)"

# Controleer of de gebruiker al bestaat
$User = Get-ADUser -Filter {SamAccountName -eq $Username}
if (-not $User) {
    # Maak de gebruiker aan in de juiste OU en zorg ervoor dat het account wordt ingeschakeld
    New-ADUser -Name $Username -SamAccountName $Username -AccountPassword $Password -Enabled $true -Path "OU=$Department,DC=ad,DC=g08-systemsolutions,DC=internal"
    Write-Host "Gebruiker $Username is aangemaakt en toegevoegd aan de $Department afdeling."
} else {
    Write-Host "Gebruiker $Username bestaat al."
}

# Verkrijg de domeinadmin-accounts
$DomainAdmins = Get-ADGroupMember -Identity "Domain Admins" | Where-Object { $_.objectClass -eq "user" }

# Maak de gedeelde map aan en stel machtigingen in
$SharePath = "C:\Shares\$Username"

# Maak de map aan
if (-not (Test-Path $SharePath)) {
    New-Item -Path $SharePath -ItemType Directory -Force
}

# Voeg de share toe met de juiste machtigingen
$FullAccessUsers = @($Username) + $DomainAdmins.SamAccountName
New-SmbShare -Name $Username -Path $SharePath -FullAccess $FullAccessUsers

# Verwijder standaard toegang voor andere gebruikers
$Acl = Get-Acl $SharePath

# Verwijder bestaande regels voor 'Everyone'
$ArEveryone = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Deny")
$Acl.RemoveAccessRule($ArEveryone)

# Voeg regels toe voor de specifieke gebruiker
$UserAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$Acl.AddAccessRule($UserAccessRule)

# Voeg regels toe voor de domeinadmins
foreach ($Admin in $DomainAdmins) {
    $AdminAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($Admin.SamAccountName, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.AddAccessRule($AdminAccessRule)
}

# Pas de ACL toe
Set-Acl -Path $SharePath -AclObject $Acl

Write-Host "De map $SharePath is gedeeld met toegang voor $Username en Domain Admins."
