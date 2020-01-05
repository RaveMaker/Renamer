@echo off
echo "Run me as Admin"
c:\Windows\Renamer\instsrv.exe Renamer c:\Windows\Renamer\srvany.exe
c:\Windows\Renamer\renamer.reg
powershell Set-ExecutionPolicy RemoteSigned
