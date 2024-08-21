# Vraag de gebruikersnaam op die je wilt verwijderen
$UsernameToDelete = Read-Host "Voer de gebruikersnaam in die je wilt verwijderen"
$SharePath = "C:\Shares\$UsernameToDelete"

# Verwijder de gedeelde map als deze bestaat
try {
    if (Get-SmbShare -Name $UsernameToDelete -ErrorAction SilentlyContinue) {
        # Verwijder de SMB-share
        Remove-SmbShare -Name $UsernameToDelete -Force
        Write-Host "De share $UsernameToDelete is succesvol verwijderd."
    } else {
        Write-Host "Geen gedeelde map gevonden voor gebruiker $UsernameToDelete."
    }
} catch {
    Write-Host "Fout bij het verwijderen van de SMB-share: $_"
}

# Verwijder de lokale map
try {
    if (Test-Path -Path $SharePath) {
        # Verwijder de lokale map
        Remove-Item -Path $SharePath -Recurse -Force
        Write-Host "De lokale map $SharePath is succesvol verwijderd."
    } else {
        Write-Host "Geen lokale map gevonden voor gebruiker $UsernameToDelete."
    }
} catch {
    Write-Host "Fout bij het verwijderen van de lokale map: $_"
}

# Verwijder de gebruiker uit Active Directory, als deze nog bestaat
try {
    if (Get-ADUser -Filter {SamAccountName -eq $UsernameToDelete}) {
        Remove-ADUser -Identity $UsernameToDelete -Confirm:$false
        Write-Host "Gebruiker $UsernameToDelete is succesvol verwijderd."
    } else {
        Write-Host "Gebruiker $UsernameToDelete bestaat niet meer."
    }
} catch {
    Write-Host "Fout bij het verwijderen van de gebruiker: $_"
}
