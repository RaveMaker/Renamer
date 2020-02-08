Renamer - Computer-Rename-and-Join-Domain
=========================================

PowerShell Script - Change computer name, join Active Directory domain and place computer account in a specified OU

### Installation

1. Clone this script from github or copy the files manually to 'C:\Windows\Renamer'

2. Generate a password file using 'gen-pass.ps1' script

3. Edit the following variables:

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

4. run 'Install.cmd' as Administrator. It will create a service Called "Renamer" and will execute it at startup.

Author: [RaveMaker][RaveMaker].

[RaveMaker]: http://ravemaker.net
