Computer-Rename-and-Join-Domain
===============================

PowerShell Script - Change computer name, join Active Directory domain and place computer account in a specified OU

### Installation

1. Clone this script from github or copy the files manually to 'C:\Windows\Renamer'

2. Edit the following variables:

```
$dryRun = $true
$validNetwork = 71
$domainUser = "accountop"
$domain = "ad.biu.ac.il"
$shortDomain = "CCDOM"
$defaultCompOU = "CN=Computers,DC=ad,DC=biu,DC=ac,DC=il"
$defaultDepartment = "COMP"
$ldapUrl = "LDAP://ad.biu.ac.il/DC=ad,DC=biu,DC=ac,DC=il"
```

### Use "instsrv.exe","srvany.exe" to create a service for it:
1. The installation files assume folder location of C:\Windows\Renamer\ to change edit: Install.cmd,Renamer.cmd,Renamer.reg

2. Install.cmd will create service Called "Renamer" and will execute it at startup.

#### It will need 2 restarts to rename and join the computer to active directory.

Author: [RaveMaker][RaveMaker].

[RaveMaker]: http://ravemaker.net
