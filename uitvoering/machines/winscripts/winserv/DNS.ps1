# Instellen van de DNS-zones en -records
Add-DnsServerPrimaryZone -Name "ad.g08-systemsolutions.internal" -ZoneFile "ad.g08-systemsolutions.internal.dns"
Add-DnsServerPrimaryZone -Name "108.168.192.in-addr.arpa" -ZoneFile "108.168.192.in-addr.arpa.dns"

# A-records toevoegen
Add-DnsServerResourceRecordA -Name "dbserver" -ZoneName "ad.g08-systemsolutions.internal" -IPv4Address "192.168.108.149"
Add-DnsServerResourceRecordA -Name "webserver" -ZoneName "ad.g08-systemsolutions.internal" -IPv4Address "192.168.108.150"
Add-DnsServerResourceRecordA -Name "tftpserver" -ZoneName "ad.g08-systemsolutions.internal" -IPv4Address "192.168.108.133"
Add-DnsServerResourceRecordA -Name "reverseproxy" -ZoneName "ad.g08-systemsolutions.internal" -IPv4Address "192.168.108.164"
Add-DnsServerResourceRecordA -Name "ad" -ZoneName "ad.g08-systemsolutions.internal" -IPv4Address "192.168.108.148"
Add-DnsServerResourceRecordA -Name "g08-systemsolutions" -ZoneName "ad.g08-systemsolutions.internal" -IPv4Address "192.168.108.150"

# Genereren van PTR-records
Add-DnsServerResourceRecordPtr -Name "149" -ZoneName "108.168.192.in-addr.arpa" -PtrDomainName "dbserver.ad.g08-systemsolutions.internal"
Add-DnsServerResourceRecordPtr -Name "150" -ZoneName "108.168.192.in-addr.arpa" -PtrDomainName "webserver.ad.g08-systemsolutions.internal"
Add-DnsServerResourceRecordPtr -Name "133" -ZoneName "108.168.192.in-addr.arpa" -PtrDomainName "tftpserver.ad.g08-systemsolutions.internal"
Add-DnsServerResourceRecordPtr -Name "164" -ZoneName "108.168.192.in-addr.arpa" -PtrDomainName "reverseproxy.ad.g08-systemsolutions.internal"
Add-DnsServerResourceRecordPtr -Name "148" -ZoneName "108.168.192.in-addr.arpa" -PtrDomainName "ad.ad.g08-systemsolutions.internal"
Add-DnsServerResourceRecordPtr -Name "150" -ZoneName "108.168.192.in-addr.arpa" -PtrDomainName "g08-systemsolutions.ad.g08-systemsolutions.internal"

# Genereren van CNAME-records
Add-DnsServerResourceRecordCName -Name "www" -ZoneName "ad.g08-systemsolutions.internal" -HostNameAlias "webserver.ad.g08-systemsolutions.internal"
Add-DnsServerResourceRecordCName -Name "g08-systemsolutions.internal" -ZoneName "ad.g08-systemsolutions.internal" -HostNameAlias "webserver.ad.g08-systemsolutions.internal"

# Instellen van de DNS-forwarder./
Set-DnsServerForwarder -IPAddress "8.8.8.8"

Write-Host "DNS-records zijn succesvol toegevoegd en forwarder is ingesteld."
