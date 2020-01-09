@echo off
rem Based on https://stackoverflow.com/questions/17996936/batchfile-to-create-backup-and-rename-with-timestamp
for /f "delims=" %%a in ('wmic OS Get localdatetime  ^| find "."') do set dt=%%a
set YYYY=%dt:~0,4%
set MM=%dt:~4,2%
set DD=%dt:~6,2%
set HH=%dt:~8,2%
set Min=%dt:~10,2%
set Sec=%dt:~12,2%

set stamp=%YYYY%-%MM%-%DD%_%HH%%Min%%Sec%
set savedir=%systemdrive%%homepath%\Saved Games\DCS.openbeta_server

ren "%savedir%\dcs.log" "dcs_%stamp%.log"
