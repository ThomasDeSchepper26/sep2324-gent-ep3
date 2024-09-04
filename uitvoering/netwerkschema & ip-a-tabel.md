# Netwerk

Range: 192.168.108.0/24

| subnetwerk                        | ID  | netwerkadres    | subnet          | prefix | 1ste hostadres  | laatste hostadres | broadcastadres  |
| --------------------------------- | --- | --------------- | --------------- | ------ | --------------- | ----------------- | --------------- |
| Vlan 11 werkstations en employees | 11  | 192.168.108.0   | 255.255.255.128 | /25    | 192.168.108.1   | 192.168.108.126   | 192.168.108.127 |
| Vlan 1 network management         | 1   | 192.168.108.128 | 255.255.255.240 | /28    | 192.168.108.129 | 192.168.108.142   | 192.168.108.143 |
| Vlan 42 interne servers           | 42  | 192.168.108.144 | 255.255.255.240 | /28    | 192.168.108.145 | 192.168.108.158   | 192.168.108.159 |
| Vlan 13 DMZ                       | 13  | 192.168.108.160 | 255.255.255.240 | /29    | 192.168.108.161 | 192.168.108.166   | 192.168.108.167 |
| iSP en uplink                     | N/A | 192.168.108.248 | 255.255.255.248 | /29    | 192.168.108.249 | 192.168.108.254   | 192.168.108.255 |

## Adresseringstabel

| Machine       | Interface | VLAN | IP-address      | Subnetmask      | prefix | Def. Gateway    |
| ------------- | --------- | ---- | --------------- | --------------- | ------ | --------------- |
| R1            | G0/0      | N/A  | 172.22.200.108  | 255.255.0.0     | /16    | G0/0/0          |
|               | G0/1.1    | 1    | 192.168.108.129 | 255.255.255.240 | /28    | N/A             |
|               | G0/1.11   | 11   | 192.168.108.1   | 255.255.255.128 | /25    | N/A             |
|               | G0/1.13   | 13   | 192.168.108.161 | 255.255.255.248 | /29    | N/A             |
|               | G0/1.42   | 42   | 192.168.108.145 | 255.255.255.240 | /28    | N/A             |
| R2            | G0/0      | N/A  | 172.22.200.208  | 255.255.0.0     | /16    | G0/0/0          |
|               | G0/1.1    | 1    | 192.168.108.130 | 255.255.255.240 | /28    | N/A             |
|               | G0/1.11   | 11   | 192.168.108.2   | 255.255.255.128 | /25    | N/A             |
|               | G0/1.13   | 13   | 192.168.108.162 | 255.255.255.248 | /29    | N/A             |
|               | G0/1.42   | 42   | 192.168.108.146 | 255.255.255.240 | /28    | N/A             | 
| HSRP          | G0/0      | N/A  | 192.168.108.251 | 255.255.255.248 | /29    | N/A             |
|               | G0/1.1    | 1    | 192.168.108.131 | 255.255.255.240 | /28    | N/A             |
|               | G0/1.11   | 11   | 192.168.108.3   | 255.255.255.128 | /25    | N/A             |
|               | G0/1.13   | 13   | 192.168.108.163 | 255.255.255.248 | /29    | N/A             |
|               | G0/1.42   | 42   | 192.168.108.147 | 255.255.255.240 | /28    | N/A             |
| S1            | SVI       | 1    | 192.168.108.132 | 255.255.255.240 | /28    | N/A             | 
| Winclient     | fa0       | 11   | 192.168.108.4   | 255.255.255.128 | /25    | 192.168.108.3   | 
| TFTP Server   | Fa0       | 1    | 192.168.108.133 | 255.255.255.240 | /28    | 192.168.108.131 |
| DB Server     | Fa0       | 42   | 192.168.108.149 | 255.255.255.240 | /28    | 192.168.108.147 |
| Web Server    | Fa0       | 42   | 192.168.108.150 | 255.255.255.240 | /28    | 192.168.108.147 |
| WinServ       | Fa0       | 42   | 192.168.108.148 | 255.255.255.240 | /28    | 192.168.108.147 |
| Proxy         | Fa0       | 13   | 192.168.108.164 | 255.255.255.248 | /29    | 192.168.108.163 |
| ISP Router    | G0/0      | N/A  | 192.168.108.254 | 255.255.255.248 | /29    | N/A             |

## Switch poorten

| S1      | verbonden met |
|---------|---------------|
| G0/1    | R1            |
| G0/2    | R2            |
| Fa0/1   | Winclient     |
| Fa0/2   | WinServ       |
| Fa0/3   | DB Server     |
| Fa0/4   | Web Server    |
| Fa0/5   | TFTP Server   |
| Fa0/6   | Proxy         |

## Router poorten

| R1      | verbonden met |
|---------|---------------|
| G0/0/0  | ISPSwitch     |
| G0/0/1  | S1            |

| R2      | verbonden met |
|---------|---------------|
| G0/0/0  | ISPSwitch     |
| G0/0/1  | S1            |

Nuttige commando's:

- ophalen running-config op S1
```bash
 en
 conf t
 interface FastEthernet0/5
 switchport access vlan 1
 switchport mode access
 no shutdown
 interface Vlan1
 ip address 192.168.108.132 255.255.255.240
 no shutdown
 end
 copy tftp running-config
 192.168.108.133
 S1_startup-config.txt
```

- ophalen running-config op R1
```bash
 en
 conf t
 interface g0/0/1
 ip address 192.168.108.134 255.255.255.240
 no shut
 exit
 ip tftp source-interface g0/0/1
 end
 copy tftp running-config
 192.168.108.133
 R1_startup-config.txt
```

- ophalen running-config op R2
```bash
 en
 conf t
 interface g0/0/1
 ip address 192.168.108.135 255.255.255.240
 no shut
 exit
 ip tftp source-interface g0/0/1
 end
 copy tftp running-config
 192.168.108.133
 R2_startup-config.txt
```