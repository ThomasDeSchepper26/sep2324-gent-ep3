# Network Documentation

## Iteratie 1

### IP specificaties

- IPv4 in eerste opzet
- Range is vastgelegd op 192.168.115.0/24
- ISP gateway op 192.168.115.254/30
- Uplink op 192.168.115.253/30

### VLAN specificaties

| VLAN | Naam               | IP range           | Omschrijving                                                                                            |
| ---- | ------------------ | ------------------ | ------------------------------------------------------------------------------------------------------- |
| 1    | NETWORK MANAGEMENT | 192.168.115.136/29 | De vaste IP-adressen voor netwerkinfrastructuur, enkel toegankelijk voor TFTP-server                    |
| 11   | WERKSTATIONS       | 192.168.115.0/25   | DHCP dynamic, routable naar interne servers en internet                                                 |
| 13   | DMZ                | 192.168.115.144/30 | Static IP, routable naar **benodigde** servers internal en bereikbaar vanuit VLAN employees en internet |
| 42   | INTERNAL SERVERS   | 192.168.115.128/29 | Static IP, toewijzing op server basis                                                                   |

_De inter-VLAN routering wordt verzorgt door router-on-a-stick configuratie_

### IP tabel

| RANGE                                               | VLAN | RANGES                | SUBNETMASK      | GATEWAY         | BROADCAST       | USABLE HOST | MAPS TO            |
| --------------------------------------------------- | ---- | --------------------- | --------------- | --------------- | --------------- | ----------- | ------------------ |
| 192.168.115.0/25                                    | 11   | 192.168.115.2 - 126   | 255.255.255.128 | 192.168.115.1   | 192.168.115.127 | 126         | Workstations       |
| 192.168.115.128/29                                  | 42   | 192.168.115.130 - 134 | 255.255.255.248 | 192.168.115.129 | 192.168.115.135 | 6           | Internal Servers   |
| 192.168.115.136/29                                  | 1    | 192.168.115.138 - 142 | 255.255.255.248 | 192.168.115.137 | 192.168.115.143 | 6           | Network Management |
| 192.168.115.144/30                                  | 13   | 192.168.115.146 - 146 | 255.255.255.252 | 192.168.115.145 | 192.168.115.147 | 2           | DMZ                |
| **VERVANGEN NA EERSTE ITERATIE** 192.168.115.252/30 |      | 192.168.115.253 - 254 | 255.255.255.252 | 192.168.115.253 | 192.168.115.255 | 2           | ISP                |

### Vaste IP adressen

| Device                                 | IP Address      | Subnet Mask     | VLAN | Omschrijving        |
| -------------------------------------- | --------------- | --------------- | ---- | ------------------- |
| R1                                     | DHCP            |                 |      | Uplink naar ISP     |
| **VERVANGEN NA EERSTE ITERATIE** R-ISP | 192.168.115.254 | 255.255.255.252 |      | Default Gateway ISP |
| S1                                     | 192.168.115.138 | 255.255.255.248 | 1    |                     |
| TFPT                                   | 192.168.115.139 | 255.255.255.248 | 1    |                     |
| Reverse Proxy                          | 192.168.115.146 | 255.255.255.252 | 13   |                     |
| Web Server                             | 192.168.115.130 | 255.255.255.248 | 42   |                     |
| Database Server                        | 192.168.115.131 | 255.255.255.248 | 42   |                     |
| Windows Server                         | 192.168.115.132 | 255.255.255.248 | 42   |                     |

_De end devices voor users liggen in VLAN 11 en werkt op basis van DHCP_

### Interface tabel

| Device    | Interface | Type   | IP Address      | Subnet Mask     | Default Gateway |
| --------- | --------- | ------ | --------------- | --------------- | --------------- |
| R1        | G0/1.1    | Router | 192.168.115.137 | 255.255.255.248 |                 |
|           | G0/1.11   |        | 192.168.115.1   | 255.255.255.128 |                 |
|           | G0/1.13   |        | 192.168.115.145 | 255.255.255.252 |                 |
|           | G0/1.42   |        | 192.168.115.129 | 255.255.255.248 |                 |
| S1        | SVI       | Switch | 192.168.115.138 | 255.255.255.248 | 192.168.115.137 |
| TFPT      | Fa0/1     | Server | 192.168.115.139 | 255.255.255.248 | 192.168.115.137 |
| Proxy     | Fa0/2     | Server | 192.168.115.146 | 255.255.255.252 | 192.168.115.145 |
| Database  | Fa0/3     | Server | 192.168.115.131 | 255.255.255.248 | 192.168.115.129 |
| WEB       | Fa0/4     | Server | 192.168.115.130 | 255.255.255.248 | 192.168.115.129 |
| WinServ   | Fa0/5     | Server | 192.168.115.132 | 255.255.255.248 | 192.168.115.129 |
| WinServ2  | Fa0/6     | Server | 192.168.115.133 | 255.255.255.248 | 192.168.115.129 |
| WinClient | Fa0/7     | Client | DHCP            | DHCP            | DHCP            |

### Logical topology

[Logical Topology Diagram](./img/logicalTopology.png)

### Routing specificaties

De inter-VLAN routering baseert zich op de router-on-a-stick configuratie, in onze opstelling zal R1 deze taak op zich nemen. Voor een extra herharling op concept en configuratie, kan je volgende links raadplegen:

- [Network Academy](https://www.networkacademy.io/ccna/ethernet/router-on-a-stick)
- [Cisco Press](https://www.ciscopress.com/articles/article.asp?p=3089357&seqNum=5)
- [Naj Qazi Youtube](https://www.youtube.com/watch?v=OvWffDLRlyY)

Een paar extra vereisten worden gesteld voor inter-VLAN routering:

- VLAN 1 mag enkel toegankelijk zijn voor de TFTP-server.
- VLAN 13 moet toegankelijk zijn vanaf het internet en vanaf VLAN 42, maar mag zelf enkel naar het VLAN 42 voor de benodigde servers.
- VLAN 11 moet toegang hebben tot VLAN 42 en het internet.

### Extra informatie

- Configuraties van netwerk infrastructuur komt van TFTP-server
- Traffic naar default ISP-router, static routes die nodig zijn doorgeven aan lector
- Opstelling lokaal met VMs _(laptop in bridged mode)_
