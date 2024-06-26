; No Man's Sky Redirector v1.0 by CheatFreak
; See https://github.com/cheatfreak47/misc-scripts?tab=readme-ov-file#nms-redirahk-autohotkey-11-script for details. (this doesn't exist yet lol)
; PS. Hello NMS Retro Dev ;)

; Startup Logic~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Specify some script settings to ensure it is running as it should.
#NoEnv
#NoTrayIcon
#SingleInstance Force
; Checks if the program is running *as* an AHK script or if it has been compiled and handles it if it isn't compiled. You cannot have Steam run an AHK script. Only an executable.
if (!A_IsCompiled) {
	; Checks to see if the script was ran with --build. If so, it performs the Build tasks near the bottom of the script.
	Loop, % A_Args.Length()
	{
		if (A_Args[A_Index] = "--build") {
			goto Build
		}
		break
	}
	; If not, then throw an error.
    MsgBox, 16, Error, This script must be run as a compiled .exe, not as a .ahk script. Running the script directly with --build will allow you to compile the script automatically.
    ExitApp
}
; Checks if the script is being ran with no arguments at all and throw an error if it is receiving no arguments.
if %0% = 0
{
    MsgBox, 16, Error, This script must be run from Steam by modifying the launch options for No Man's Sky, not by launching it directly in Windows. `nSome examples of possible correctly set launch options would be:`n`n"C:\Program Files (x86)\Steam\steamapps\common\No Man's Sky\NMS-Redir.exe" `%command`%`n`n"G:\Games\Steam\steamapps\common\No Man's Sky\NMS-Redir.exe" `%command`% --version v1.1.2 --depotspath "G:\Games\NMS-Depots"
    ExitApp
}
else
{
	; Checks if the program is being ran from Steam. NMS does not run if it is not a child process of Steam launching it as it's AppID. 
	Loop, % A_Args.Length()
	{
		; We check this by validating that the Steam Provided %command% is passed to the script as one of the arguments. One argument should always contain NMS.exe if it is ran in the correct context.
		if (InStr(A_Args[A_Index], "NMS.exe"))
		{
			found := true
			break
		}
	}
	if (!found)
	{
		; If the flag is still false, "NMS.exe" was not found in any argument, so we throw an error.
		MsgBox, 16, Error, This script must be run from Steam by modifying the launch options for No Man's Sky, not by launching it directly in Windows. `nSome examples of possible correctly set launch options would be:`n`n"C:\Program Files (x86)\Steam\steamapps\common\No Man's Sky\NMS-Redir.exe" `%command`%`n`n"G:\Games\Steam\steamapps\common\No Man's Sky\NMS-Redir.exe" `%command`% --version v1.1.2 --depotspath "G:\Games\NMS-Depots"
		ExitApp
	}
}

; Argument Handling Logic~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Set up some variables for the functionality of the program.
args := ""
version := ""
savepath := A_AppData . "\HelloGames"
depotspath := ""
logging := 0
lastrun := ""
; Check if Logging was enabled and pump that result into the logging variable to enable logs throughout the rest of the runtime.
Loop, % A_Args.Length()
{
    if (A_Args[A_Index] = "--logging")
    {
        logging := 1
        break
    }
}
; Load the lastrun into the lastrun variable.
FileRead, lastrun, NMS-Redir-lastrun.log
; Test and try to fix a possible condition where the script might have been killed unexpectedly during No Man's Sky runtime.
If (FileExist(savepath . "\NMS_Current"))
{
	; Try to fix the save folders, if not, throw an error and exit.
	if (lastrun != "") {
		; Fix the save files folders
		FileMoveDir, %savepath%\NMS, %savepath%\NMS_%lastrun%, R
		FileMoveDir, %savepath%\NMS_Current, %savepath%\NMS, R
		; Print an error to notify the user this happened.
		MsgBox, 48, Notice, During the previous run of NMS %lastrun%, the script was terminated unexpectedly. Save file folders have been corrected, but please refrain from terminating the script in this way, it may result in save file loss or corruption.
		; If Logging is enabled, log this event in the log file.
		if(logging) {
			timestamp := A_Now
			FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
			FileAppend, `n[%timestamp%] During the previous run of NMS %lastrun%`, the script was terminated unexpectedly.`n[%timestamp%] Renamed save folders back to normal.`n, NMS-Redir.log
		}
	}
	else {
		; This only runs if lastrun failed to populate from the lastrun file. This should never happen but just in case, it is handled.
		MsgBox, 16, Error, During the previous run of NMS, the script was terminated unexpectedly. No lastrun file could be found, so the script is unable to correct your save file folders. You will need to manually fix your save files in the AppData/Roaming/HelloGames/ folder before continuing.
		; If Logging is enabled, log this event in the log file.
		if(logging) {
			timestamp := A_Now
			FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
			FileAppend, `n[%timestamp%] During the previous run of NMS %lastrun%`, the script was terminated unexpectedly.`n[%timestamp%] Exited due to uncorrectable invalid save folder state.`n`n, NMS-Redir.log
		}
		ExitApp
	}
}
; Look through the provided arguments and populate the arguments into the variables we set up.
Loop, % A_Args.Length()
{
    if (A_Args[A_Index] = "--version" && A_Index < A_Args.Length())
    {
        version := A_Args[A_Index + 1]
        break
    }
}
Loop, % A_Args.Length()
{
    if (A_Args[A_Index] = "--depotspath" && A_Index < A_Args.Length())
    {
        depotspath := A_Args[A_Index + 1]
        break
    }
}
; Check if there is no specified Depots Path after polling the arguments.
if (depotspath = "")
{
	; If none was specified, we just guess the default by checking where NMS is installed.
	RegRead, NMSInstall, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 275850, InstallLocation
	lastSlash := InStr(NMSInstall, "\",, 0)
	LibraryPath := SubStr(NMSInstall, 1, lastSlash - 1)
	depotspath := NMSInstall . "\Old Versions"
}
; If the path was not found after attempting the RegRead, we can't continue. A depots path is required for functionality, so we throw an error message and exit, unless the version is Current, which does not require a depot.
if (depotspath = "") && ((version != "Current") OR (version != ""))
{
	MsgBox, 16, Error, No Depots Path was able to be found, nor was one specified. Please provide the location of your collection of NMS Depots downloaded by Depot Downloader using --depotspath in the Launch Options section for No Man's Sky on Steam.
	ExitApp
}
; Check some edge case possible error conditions.
if (InStr(depotspath, "--version") || InStr(depotspath, "NMS.exe") || InStr(depotspath, "--logging"))
{
	MsgBox, 16, Error, --depotspath was called but no path or an invalid path to NMS depots was provided. Please provide the path enclosed in quotes with no trailing backslash after --depotspath in your No Man's Sky Launch Options on Steam.
	; If Logging is enabled, log this event in the log file.
	if(logging) {
		timestamp := A_Now
		FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
		FileAppend, [%timestamp%] Exited due to --depotspath error.`n`n, NMS-Redir.log
	}
	ExitApp
}
if (InStr(version,"--depotspath") || InStr(version, "NMS.exe") || InStr(version, "--logging"))
{
	MsgBox, 16, Error, --version was called but no NMS version was specified. Please provide the desired version after --version in your No Man's Sky Launch Options on Steam.
	; If Logging is enabled, log this event in the log file.
	if(logging) {
		timestamp := A_Now
		FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
		FileAppend, [%timestamp%] Exited due to --version error.`n`n, NMS-Redir.log
	}
	ExitApp
}
; Check if version starts with a v and if it doesn't then insert it- unless the version is Current, which has special treatment.
if (version != "Current" && SubStr(version, 1, 1) != "v" && version != "")
{
	version := "v" . version
}
; Scrub all arguments intended for NMS Redirect, and store the remaining arguments for passage to NMS. NMS supports several launch options itself, so it is essential we retain that functionality.
Loop, % A_Args.Length()
{
	; Discards Steam %command%, --version and --depotspath
	if (InStr(A_Args[A_Index], "NMS.exe") || A_Args[A_Index - 1] = "--version" || A_Args[A_Index] = "--version" || A_Args[A_Index - 1] = "--depotspath" || A_Args[A_Index] = "--depotspath" || A_Args[A_Index] = "--logging")
	continue
	; Pipes the remaining arguments into a variable.
	args .= A_Args[A_Index] " "
}

; Main Logic~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Update the lastrun file if needed to catch invalid save folder states if the script is forcefully terminated unexpectedly during NMS runtime.
if (lastrun != version) 
{
	FileOpen("NMS-Redir-lastrun.log", "w").Close()
	FileAppend, %version%, NMS-Redir-lastrun.log
}
; If a version is specified and that version is not current, we have to do some specific steps.
if (version != "") && (version != "Current")
{
	; Validate the provided version directs to a copy of NMS that actually exists. If not, throw an error.
	if !FileExist(depotspath . "\NMS-" . version)
	{
		MsgBox, 16, Error, The requested NMS version could not be found at:`n`n"%depotspath%\NMS-%version%"`n`nIf the above path is not where your depots are located, please ensure you pass the correct path using --depotspath in the launch options section for No Man's Sky on Steam.`n`nIf the path is correct, then you probably do not have the specified No Man's Sky version depot downloaded.
		; If Logging is enabled, log this event in the log file.
		if(logging) {
			timestamp := A_Now
			FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
			FileAppend, [%timestamp%] Exited due to target version not found error.`n`n, NMS-Redir.log
		}
		ExitApp
	}	
	; If the user has saves for the requested old NMS version already, Temporarily rename the current NMS save folder and then rename the old version folder so the game will use it. Your saves will never be in danger because we manually specify R on these moves, meaning it only ever will attempt to rename these folders.
	if (FileExist(savepath . "\NMS_" . version))
	{
		FileMoveDir, %savepath%\NMS, %savepath%\NMS_Current, R
		FileMoveDir, %savepath%\NMS_%version%, %savepath%\NMS, R
		; If Logging is enabled, log this event in the log file.
		if(logging) {
			timestamp := A_Now
			FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
			FileAppend, [%timestamp%] Renamed save folders to run NMS %version%.`n, NMS-Redir.log
		}
		; Debug Message Commented Out
		;MsgBox, Debug`n`nRedirected Save Folder`n`n%savepath%\NMS\
	}
	; If there is no saves for the specified version, rename the folder for Current NMS and make a new empty one for the game to use.
	else {	
		FileMoveDir, %savepath%\NMS, %savepath%\NMS_Current, R
		FileCreateDir, %savepath%\NMS
		; If Logging is enabled, log this event in the log file.
		if(logging) {
			timestamp := A_Now
			FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
			FileAppend, [%timestamp%] Created and renamed save folders to run NMS %version%.`n, NMS-Redir.log
		}
		; Debug Message Commented Out
		;MsgBox, Debug`n`nMade New Save Folder`n`n%savepath%\NMS\
	}
	; Debug Message Commented Out
	;MsgBox, Debug`n`nVersion Ran: %version%`n`nCommand To Run:`n%ComSpec% /c cd /D "%depotspath%\NMS-%version%\Binaries" && NMS.exe %args%`n`nSave Path: "%savepath%"`n`nAnthology Path: "%depotspath%"
	; If Logging is enabled, log this event in the log file.
	if(logging) {
		timestamp := A_Now
		FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
		if(args != "") {
			FileAppend, [%timestamp%] Launched NMS %version% with arguments %args%.`n, NMS-Redir.log
		}
		else {
		FileAppend, [%timestamp%] Launched NMS %version%.`n, NMS-Redir.log
		}
	}
	; Run the copy of NMS the user requested with --version and wait until the player is done playing NMS before we continue.
	RunWait, %ComSpec% /c cd /D "%depotspath%\NMS-%version%\Binaries" && NMS.exe %args%,, Hide
	; If Logging is enabled, log this event in the log file.
	if(logging) {
		timestamp := A_Now
		FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
		FileAppend, [%timestamp%] NMS %version% exited.`n, NMS-Redir.log
	}
	; Now that the game has closed, we rename the folder of saves it was using to specify the version it was, and restore the Current version's save folder back to it's default name.
	
	FileMoveDir, %savepath%\NMS, %savepath%\NMS_%version%, R
	FileMoveDir, %savepath%\NMS_Current, %savepath%\NMS, R
	; If Logging is enabled, log this event in the log file.
	if(logging) {
		timestamp := A_Now
		FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
		FileAppend, [%timestamp%] Renamed save folders back to normal. Script exited cleanly.`n`n, NMS-Redir.log
	}
	; Debug Message Commented Out
	;MsgBox, Debug`n`nUnredirected Save Folder, Restored Current Version Save Folder
	; Exit now that everything is complete.
	ExitApp
}
; If the version specified is current. We operate as a passthrough to run the current version of NMS.
else if (version == "Current") OR (version == "")
{
	; Debug Message Commented Out
	;MsgBox, Debug`n`nVersion Ran: %version%`n`nCommand To Run:`Binaries\NMS.exe %args%`n`nSave Path: "%savepath%"`n`nAnthology Path: "%depotspath%"
	;MsgBox, %depotspath%`n%LibraryPath%`n%NMSInstall%
	; Check if current NMS exists. If not, throw an error.
	if !FileExist(NMSInstall . "\Binaries\" . "NMS.exe")
	{ 
		MsgBox, NMS Redirect is not located in the NMS install folder. Passthrough functionality only works if NMS-Redir.exe is placed in your current NMS install folder.
		; If Logging is enabled, log this event in the log file.
		if(logging) {
			timestamp := A_Now
			FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
			FileAppend, [%timestamp%] Script exited due to passthrough failure error.`n`n, NMS-Redir.log
		}
		ExitApp
	}
	; Run Current NMS and exit the script. We do not need to wait either.
	Run, "%NMSInstall%\Binaries\NMS.exe" %args%
	; If Logging is enabled, log this event in the log file.
	if(logging) {
		timestamp := A_Now
		FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
		FileAppend, [%timestamp%] Launched NMS as a passthrough. Script closed cleanly.`n`n, NMS-Redir.log
	}
	ExitApp
}
; Unused ExitApp in case some condition we didn't handle happens. This should never be ran in theory, but we print an error anyway.
MsgBox, 16, Error, If you see this error message. Please make an issue on the Github page and let the author know about it and what Launch Options you used that somehow triggered it.
ExitApp

; Special Condition Behavior Logic~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Build:
	; Try to read the install location of AutoHotKey 1.1 from the 64-bit registry path
	RegRead, InstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\AutoHotkey, InstallDir
	; If the above registry path doesn't exist (i.e., on a 32-bit machine), try the 32-bit registry path
	if (ErrorLevel) {
		RegRead, InstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\AutoHotkey, InstallDir
	}
	; If the install location of AutoHotKey 1.1 is still not found, show an error message
	if (ErrorLevel) {
		MsgBox, 48, Error, AutoHotkey installation location not found in the registry.
		ExitApp
	}
	; Try to build with an icon if it exists.
	ScriptName := SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".",, 0) - 1)
	if FileExist(ScriptName . .ico) {
	RunWait, "%InstallDir%\Compiler\ahk2exe.exe" /in "%A_ScriptFullPath%" /out "%A_WorkingDir%\%ScriptName%.exe" /icon "%ScriptName%.ico"
	}
	else {
	RunWait, "%InstallDir%\Compiler\ahk2exe.exe" /in "%A_ScriptFullPath%" /out "%A_WorkingDir%\%ScriptName%.exe"
	}
	MsgBox, 64, Information, Compiled script.
	ExitApp
