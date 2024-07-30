# Vraag de gebruikersnaam op die je wilt verwijderen
$UsernameToDelete = Read-Host "Voer de gebruikersnaam in die je wilt verwijderen"

# Controleer of de gebruiker bestaat
if (Get-ADUser -Filter {SamAccountName -eq $UsernameToDelete}) {
    # Verwijder de gebruiker
    Remove-ADUser -Identity $UsernameToDelete -Confirm:$false
    Write-Host "Gebruiker $UsernameToDelete is succesvol verwijderd."
} else {
    Write-Host "Gebruiker $UsernameToDelete bestaat niet."
}
