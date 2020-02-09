@echo off
whoami /groups | find "12288" || echo "Run me as Admin" && pause && exit
REM sc.exe create Renamer binPath= "C:\Windows\Renamer\Renamer.cmd" displayname= "Renamer" depend= tcpip start= delayed-auto
C:\Windows\System32\sc.exe create Renamer binPath= "C:\Windows\Renamer\Renamer.cmd" displayname= "Renamer" depend= tcpip start= auto
powershell Set-ExecutionPolicy Bypass
