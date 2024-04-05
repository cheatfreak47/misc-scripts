@echo off
color 03
:: Automatic Save File Backup Script by CheatFreak
:: A simple script developed to backup Save Files for games, developed initially for Sonic Generations, but made more generic for fun.
:: This script can be adapted for other games by changing the stuff in the Variables section below.

:Variables
::Set the game title
set "gamename=Sonic Generations"
::Set Backup Folder (without an ending backslash)
set "inDir=C:\Program Files (x86)\Steam\userdata\155201315\71340\remote"
::Set Backup Filename (without the extension)
set "inFile=sonic"
::Set Backup File Extension (without the dot)
set "inExt=sav"
::Set Output Folder (without an ending backslash)
set "outDir=H:\SteamLibrary\steamapps\common\Sonic Generations\savebackup"
::Set how many seconds to wait between backups. 300 is the default. It equates to 5 minutes. Should be a multiple of 60.
set "waittime=300"
::Set the number of backups before the script stops. 96 is the default. At 5 minutes, 96 equates to 8 hours of backups.
set "limit=96"

::Other Variables
set "counter=0"
set /A "waitmin=%waittime% / 60"
set /A "limitmin=%waitmin% * %limit%"
set /A "limithrs=%limitmin% / 60"
goto Start

:Start
echo -----------------------------------------------------------------------------------
echo  This script will backup %gamename% saves automatically every %waitmin% minutes.
echo  You can press any key to skip waiting to make the next backup.
echo  The script will stop itself after %limithrs% hours (%limit% backups) in case you forget to exit. 
echo  You may close the script window to exit anytime.
echo -----------------------------------------------------------------------------------
goto Timestamp

:Timestamp
::Fetch the Date & Time and store it, set it up and define it as a variable.
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "fullstamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"
goto Backup

:Backup
::Backup the save file.
echo F|xcopy  /S /Q /Y /F "%inDir%\%inFile%.%inExt%" "%outDir%\%inFile%_backup_%fullstamp%.%inExt%" > NUL
::Increment the counter and print a nice looking output.
set /A "counter=%counter%+1"
echo  Backup #%counter% ~ %inFile%_backup_%fullstamp%.%inExt%
goto Wait

:Wait
::Wait for a specified amount of seconds before checking that the counter and returning to Timestamp
::User can interrupt the wait anytime by pressing any regular keyboard key (such as space)
timeout /t %waittime% > NUL
if %counter% LSS %limit% goto Timestamp
::If the script reaches the limit it will fail to return to Timestamp, and display this message.
::This exists to prevent anyone who accidentally leaves this running from coming back to 1000s of probably redundant file backups.
echo -----------------------------------------------------------------------------------
echo  Reached the limit of %limit% backups per run. That's %limithrs% whole hours of backups!
echo  You probably didn't mean to let this run for this long. Press any key to exit...
pause > NUL
exit