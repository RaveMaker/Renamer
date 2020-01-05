@echo off
echo "Run me as Admin"
c:\Windows\Renamer\instsrv.exe Renamer c:\Windows\Renamer\srvany.exe
c:\Windows\Renamer\renamer.reg
powershell Unblock-File c:\Windows\Renamer\Renamer.ps1
