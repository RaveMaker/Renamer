@echo off
whoami /groups | find "12288" || echo "Run me as Admin" && pause && exit
c:\Windows\Renamer\instsrv.exe Renamer c:\Windows\Renamer\srvany.exe
regdit /s c:\Windows\Renamer\renamer.reg
powershell Set-ExecutionPolicy Bypass
