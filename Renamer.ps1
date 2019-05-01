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

#Set-ExecutionPolicy RemoteSigned
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

$newCompName = $department + $vlan + $ipAddress
$joinDomain = $false
$useDestOU = $true

# Check if computer has a BIU network address: 132.71.*.*
if ($network -eq 71)
{
    Write-Host -ForegroundColor Green "Network ready"
}
else
{
    Write-Host -ForegroundColor Red "Network disconnected"
    exit 1
}

# Check if computer is already joined to domain
if ((Get-WmiObject win32_computersystem).PartOfDomain)
{
    Write-Host -ForegroundColor Green "Computer is already joined to domain"
    # Check if a Computer account object already exist in AD
    try
    {
        Get-ADComputer -Identity $newCompName
        Write-Host -ForegroundColor Green "Computer object exists"
        exit
    }
    catch
    {
        Write-Host -ForegroundColor Green "$newCompName Computer object not found"
        $joinDomain = $true
    }
}
else
{
    Write-Host -ForegroundColor Green "Computer is in a Workgroup!"
    $joinDomain = $true
}

if ($joinDomain)
{
    try
    {
        Write-Host -ForegroundColor Green "Trying to join computer $newCompName to domain $domain"
        if ($useDestOU)
        {
            Add-Computer -DomainName $domain -NewName $newCompName -OUPath $destOU -Credential $shortDomain\ -Restart -ErrorAction Stop
        }
        else
        {
            Add-Computer -DomainName $domain -NewName $newCompName -Credential $shortDomain\ -Restart -ErrorAction Stop
        }
    }
    catch
    {
        $errorMessage = $_.Exception.Message
        Write-Host -ForegroundColor Red "There was an error joining computer $newCompName to domain $domain"
        Write-Host -ForegroundColor Red "ERROR: $errorMessage"
    }
}
