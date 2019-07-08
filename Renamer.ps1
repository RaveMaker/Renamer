<#
.SYNOPSIS
Joins a computer to domain.

.DESCRIPTION
The Renamer.ps1 script renames the computer account name if needed
and joins it to a specified domain in a specified OU.

- Get Current IP Address
- Calculate New Computer Name
- Get current Computer Name and rename if needed including reboot
- Check if Local Computer is Domain joined
- Check if Object exists in AD
- Join to a specified OU if available or just join to a default computers OU

.PARAMETER InputPath
Specifies the path to the CSV-based input file.

.INPUTS
None. You cannot pipe objects to Renamer.ps1.

.OUTPUTS
None. Renamer.ps1 does not generate any output.

.EXAMPLE
PS> .\Renamer.ps1
#>

# Set-ExecutionPolicy –ExecutionPolicy RemoteSigned

# Dry run only $true/$false
$dryRun = $true

# Check if computer has a valid network address
# Exit if connection is not detected or in the wrong format:
# *.71.*.*
if ($network -eq 71)
{
    Write-Host -ForegroundColor Green "Network ready $fullIPAddress"
}
else
{
    Write-Host -ForegroundColor Red "Network disconnected"
    exit 1
}

# Actions
$joinDomain = $false
$joinDomainLocally = $false

# Declarations
$domain = "ad.biu.ac.il"
$shortDomain = "CCDOM"

# Network Params
$fullIPAddress = ((Test-Connection -ComputerName $env:ComputerName -Count 1).IPV4Address.IPAddressToString)
$splitPAddress = ($fullIPAddress -split ('\.'))
$network = [int]$splitPAddress[1]
$vlan = "{0:000}" -f [int]$splitPAddress[2]
$ipAddress = "{0:000}" -f [int]$splitPAddress[3]

# Set Destination OU and Department by IP Address: *.*.VLAN.*
# if no VLAN is in the valid list, Computer Account will be placed in 'Computers' Generic OU with 'COMP' prefix.
$file = Get-Content .\vlan.txt
$file | foreach {
    if ($_.StartsWith($vlan + " ")) {
        $line = ($_ -split (' '))
        $department = $line[1]
        $destOU = $line[2]
    }
}
if (!($department)) {
    $department = "COMP"
    $destOU = "CN=Computers,DC=ad,DC=biu,DC=ac,DC=il"
}


# Get current computer name and new computer name
$currentComputerName = Get-Content env:computername
$newCompName = $department + $vlan + $ipAddress

# Rename Computer if needed
if ($newCompName -ne $currentComputerName)
{
    Write-Host -ForegroundColor Green "Changing $currentComputerName to $newCompName"
    if (!($dryRun)) {
        Rename-Computer -NewName $newCompName -Restart -ErrorAction Stop
    }
}

# AD Search params
$credential = Get-Credential($shortDomain + "\")
$domaininfo = New-Object DirectoryServices.DirectoryEntry("LDAP://ad.biu.ac.il/DC=ad,DC=biu,DC=ac,DC=il", $credential.UserName, $credential.Password)
$searcher = New-Object System.DirectoryServices.DirectorySearcher($domaininfo)
$searcher.filter = "(cn=$newCompName)"
$searchparm = $searcher.FindOne

# Check if computer is already joined to domain (locally)
if ((Get-WmiObject win32_computersystem).PartOfDomain)
{
    Write-Host -ForegroundColor Green "Computer is already joined to domain"
    $joinDomainLocally = $false
}
else
{
    Write-Host -ForegroundColor Green "Computer is in a Workgroup!"
    $joinDomainLocally = $true
}

# Check if a Computer account object already exist in AD
if (!($searchparm))
{
    Write-Host -ForegroundColor Green "Computer account not found in AD"
    $joinDomain = $true
}
else
{
    Write-Host -ForegroundColor Green "Computer account found in AD"
    $joinDomain = $false
}

# Join Domain
if (($joinDomain) -or ($joinDomainLocally))
{
    try
    {
        # Check if a Computer account object already exist in AD
        if ($joinDomain)
        {
            Write-Host -ForegroundColor Green "Trying to join computer $newCompName to domain $domain"
            if (!($dryRun))
            {
                Add-Computer -DomainName $domain -OUPath $destOU -Credential $credential $shortDomain\ -Restart -ErrorAction Stop
            }
        }
        else
        {
            Write-Host -ForegroundColor Green "Trying to overwrite computer $newCompName in domain $domain"
            if (!($dryRun))
            {
                Add-Computer -DomainName $domain -Credential $credential $shortDomain\ -Restart -ErrorAction Stop
            }
        }
    }
    catch
    {
        $errorMessage = $_.Exception.Message
        Write-Host -ForegroundColor Red "There was an error joining computer $newCompName to domain $domain"
        Write-Host -ForegroundColor Red "ERROR: $errorMessage"
    }
}
