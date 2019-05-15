<#
.SYNOPSIS
Joins a computer to domain.

.DESCRIPTION
The Renamer.ps1 script updates the computer account name
and joins it to the specified domain.

.PARAMETER InputPath
Specifies the path to the CSV-based input file.

.INPUTS
None. You cannot pipe objects to Renamer.ps1.

.OUTPUTS
None. Renamer.ps1 does not generate any output.

.EXAMPLE
PS> .\Renamer.ps1
#>

# Set-ExecutionPolicy RemoteSigned
Set-ExecutionPolicy -Scope process -ExecutionPolicy allsigned

# Declarations
$destOU = "OU=Computers,OU=Physics,OU=ESC,DC=ad,DC=biu,DC=ac,DC=il"
$domain = "ad.biu.ac.il"
$shortDomain = "CCDOM"
$department = "PH"

$fullIPAddress = ((Test-Connection -ComputerName $env:ComputerName -Count 1).IPV4Address.IPAddressToString -split ('\.'))
$network = [int]$fullIPAddress[1]
$vlan = "{0:000}" -f [int]$fullIPAddress[2]
$ipAddress = "{0:000}" -f [int]$fullIPAddress[3]

$currentComputerName = gc env:computername
$newCompName = $department + $vlan + $ipAddress

# Check if computer has a BIU network address: 132.71.*.*
if ($network -eq 70)
{
    Write-Host -ForegroundColor Green "Network ready"
}
else
{
    Write-Host -ForegroundColor Red "Network disconnected"
    exit 1
}

$credential = New-Object System.Management.Automation.PsCredential("[DOMAIN\JoinUser]", (ConvertTo-SecureString "[password]" -AsPlainText -Force))
$domaininfo = New-Object DirectoryServices.DirectoryEntry(LDAP://[DOMAIN_CONTROLLER_IP_ADDRESS]/[domain root path e.g. dc = mydomain, dc = local], "[DOMAIN\ReadOnlyUser]", "[password]")
$ComputerName = gc env:computername
$searcher = New-Object System.DirectoryServices.DirectorySearcher($domaininfo)
$searcher.filter = "(cn=$ComputerName)"
$searchparm = $searcher.FindOne()

$joinDomain = $true
$renameComp = $true

# Check if rename is needed
if ($newCompName -eq $currentComputerName)
{
    $renameComp = $false
}

# Check if computer is already joined to domain
if ((Get-WmiObject win32_computersystem).PartOfDomain)
{
    Write-Host -ForegroundColor Green "Computer is already joined to domain"
    # Check if a Computer account object already exist in AD
    $joinDomain = $false
}
else
{
    Write-Host -ForegroundColor Green "Computer is in a Workgroup!"
}

if ($joinDomain)
{
    try
    {
        Write-Host -ForegroundColor Green "Trying to join computer $newCompName to domain $domain"
        if (!($searchparm))
        {
            #            Add-Computer -DomainName $domain -OUPath $destOU -Credential $credential $shortDomain\ -Restart -ErrorAction Stop
        }
        else
        {
            #            Add-Computer -DomainName $domain -Credential $credential $shortDomain\ -Restart -ErrorAction Stop
        }
    }
    catch
    {
        $errorMessage = $_.Exception.Message
        Write-Host -ForegroundColor Red "There was an error joining computer $newCompName to domain $domain"
        Write-Host -ForegroundColor Red "ERROR: $errorMessage"
    }
}
