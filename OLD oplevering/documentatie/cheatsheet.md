# Cheatsheet

_The following document will include some loosly written commandos to remember so we have a quick sheet for common used commandos_

## General

| COMMANDO                                   | USE CASE                                                            |
| ------------------------------------------ | ------------------------------------------------------------------- |
| sudo passwd root                           | Set root password, usefull to test ssh root login                   |
| curl -I -k https://www.t01-syndus.internal | Curl for only HTTP headers, can be used to proof HTTP/2 requirement |
| copy tftp: running-config                  | move tftp to running config on network device                       |

## Windows

| COMMANDO                                          | USE CASE                                |
| ------------------------------------------------- | --------------------------------------- |
| Set-WinUserLanguageList -Force 'en-BE'            | Change input language to Belgian Azerty |
| Add-Computer -DomainName "ad.t01-syndus.internal" | CLI join domain                         |

## Vagrant

| COMMANDO       | USE CASE                 |
| -------------- | ------------------------ |
| vagrant reload | Reloads the vagrant file |

## TFTP

| COMMANDO              | USE CASE                                            |
| --------------------- | --------------------------------------------------- |
| nmcli connection show | Show connections                                    |
| tftp localhost        | tftp within server                                  |
| get file              | copy a document of tftp server to current directory |
| put file              | copy a document to tftp server to tftp directory    |

## General troubleshooting tips

- Indien je een `\r` error krijgt op de config files, even vanonder in VS Code de CRLF naar LF veranderen en dan de file opnieuw saven.
