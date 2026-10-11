@echo off
rem DJMax Technika 1 China Version - dongle-free launcher
rem (crack lives in RCGrandDogW32.dll + RC_GrandLocal.dll; the game just runs)
rem   run_free.bat            - original client.exe, default private server
rem   run_free.bat -u         - unpacked client_unpacked.exe (via run_unpacked.exe)
rem   run_free.bat <IP:port>  - custom server
if /i "%~1"=="-u" goto unpacked
if "%~1"=="" (
    "%~dp0client.exe" IP:端口
) else (
    "%~dp0client.exe" %*
)
goto :eof
:unpacked
shift
if "%~1"=="" (
    "%~dp0run_unpacked.exe" IP:端口
) else (
    "%~dp0run_unpacked.exe" %*
)
