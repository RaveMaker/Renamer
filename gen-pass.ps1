<#
.SYNOPSIS
Saves Credentials to file

.DESCRIPTION
The gen-pass.ps1 script saves get-cred to a file.

.PARAMETER InputPath
Specifies the path to the CSV-based input file.

.INPUTS
None. You cannot pipe objects to Renamer.ps1.

.OUTPUTS
None. Renamer.ps1 does not generate any output.

.EXAMPLE
PS> .\gen-pass.ps1
#>

$user = "myUser"
$server = "myServer"
$file = "c:\Windows\Renamer\password.txt"

# Store password in a file at the beginning of your script
Read-Host "Enter Password for $user on $server" -AsSecureString | ConvertFrom-SecureString | Out-File $file
