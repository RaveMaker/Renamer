$user = "myUser"
$server = "myServer"
$file = "c:\Windows\Renamer\password.txt"

# Store password in a file at the beginning of your script
Read-Host "Enter Password for $user on $server" -AsSecureString | ConvertFrom-SecureString | Out-File $file
