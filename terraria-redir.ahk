; Terraria Redirector v0.9 by CheatFreak
	; WIP ToDo List
		; - Add Logging, this is just a good idea probably
		; - Write Better Instructions
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
    MsgBox, 16, Error, This script must be run from Steam by modifying the launch command for Terraria, not by launching it directly in Windows. `nSome examples of possible correctly set launch commands would be:`n`n"C:\Program Files (x86)\Steam\steamapps\common\Terraria\terraria-redir.exe" `%command`%`n`n"G:\Games\Steam\steamapps\common\Terraria\terraria-redir.exe" `%command`% --version v1.1.2 --depotspath "G:\Games\TerrariaDepots"
    ExitApp
}
else
{
	; Checks if the program is being ran from Steam. Terraria does not run if it is not a child process of Steam launching it as AppID 105600. 
	Loop, % A_Args.Length()
	{
		; We check this by validating that the Steam Provided %command% is passed to the script as one of the arguments. If it is not, we assume we are running in the wrong context and throw an error.
		if (!InStr(A_Args[A_Index], "Terraria.exe"))
		{
			MsgBox, 16, Error, This script must be run from Steam by modifying the launch command for Terraria.`nSome examples of possible correctly set launch commands would be:`n`n"C:\Program Files (x86)\Steam\steamapps\common\Terraria\terraria-redir.exe" `%command`%`n`n"G:\Games\Steam\steamapps\common\Terraria\terraria-redir.exe" `%command`% --version v1.1.2 --depotspath "G:\Games\TerrariaDepots"
			ExitApp
		}
		break
	}
}

; Set up some variables for the functionality of the program.
args := ""
version := ""
savepath := A_MyDocuments . "\My Games"
depotspath := ""

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
	; If none was specified, we just guess the default by checking where Terraria is installed.
	; Terraria Depot Downloader defaults to Terraria's Install Location, I think, so this is the best case assumption.
	; Dev note: It may be possible to poll TDD's config XML file for a path, but I decided against it because that same file may also potentially contain sensitive data, like the user's Steam account name and Password. (I reported this to the TDD dev, because this is a terrible practice!)
	RegRead, TerrInstall, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 105600, InstallLocation
	lastSlash := InStr(TerrInstall, "\",, 0)
	depotspath := SubStr(TerrInstall, 1, lastSlash - 1)
}

; If the path was not found after attempting the RegRead, we can't continue. A depots path is required for functionality, so we throw an error message and exit.
if (depotspath = "")
{
	MsgBox, 16, Error, No Depots Path was able to be found, nor was one specified. Please provide the location of your collection of Terraria Depots downloaded by Terraria Depot Downloader using --depotspath in the launch commands section for Terraria on Steam.
	ExitApp
}

; Check some edge case possible error conditions.
if (depotspath = "--version")
{
	MsgBox, 16, Error, --depotspath was called but no path to Terraria depots was provided. Please provide the path enclosed in quotes with no trailing backslash after --depotspath in your Terraria Launch Options on Steam.
	ExitApp
}
if (version = "--depotspath")
{
	MsgBox, 16, Error, --version was called but no Terraria version was specified. Please provide the desired version after --version in your Terraria Launch Options on Steam.
	ExitApp
}
; Dev note: I could probably also check if someone stuck %command% in one of those spots but I figured some other error handle will handle that condition later.

; Scrub all arguments intended for Terraria Redirect, and store the remaining arguments for passage to Terraria. Terraria supports several launch commands itself, so it is essential we retain that functionality.
Loop, % A_Args.Length()
{
	; Discards Steam %command%, --version and --depotspath
	if (InStr(A_Args[A_Index], "Terraria.exe") || A_Args[A_Index - 1] = "--version" || A_Args[A_Index] = "--version" || A_Args[A_Index - 1] = "--depotspath" || A_Args[A_Index] = "--depotspath")
	continue
	; Pipes the remaining arguments into a variable.
	args .= A_Args[A_Index] " "
}


; Main Logic

; If a version is specified and that version is not current, we have to do some specific steps.
if (version != "") and (version != "Current")
{
	; Validate the provided version directs to a copy of Terraria that actually exists. If not, throw an error.
	if !FileExist(depotspath . "\Terraria-" . version)
	{
		MsgBox, 16, Error, The requested Terraria version could not be found at:`n`n"%depotspath%\Terraria-%version%"`n`nIf the above path is not where your depots are located, please ensure you pass the correct path using --depotspath in the launch commands section for Terraria on Steam.`n`nIf the path is correct, then you probably do not have the specified Terraria version depot downloaded.
		ExitApp
	}
	
	; If the user has saves for the requested old Terraria version already, Temporarily rename the current Terraria save folder and then rename the old version folder so the game will use it. We also validate that the version is not an Undeluxe version, which operate under special circumstances. Your saves will never be in danger because we manually specify R on these moves, meaning it only ever will attempt to rename these folders.
	if (FileExist(savepath . "\Terraria_" . version) && !InStr(version, "Undeluxe"))
	{
		FileMoveDir, %savepath%\Terraria, %savepath%\Terraria_Current, R
		FileMoveDir, %savepath%\Terraria_%version%, %savepath%\Terraria, R
		; Debug Message Commented Out
		;MsgBox, Debug`n`nRedirected Save Folder`n`n%savepath%\Terraria\
	}
	; If there is no saves for the specified version, rename the folder for Current Terraria and make a new empty one for the game to use.
	else if (!InStr(version, "Undeluxe"))
	{	
		FileMoveDir, %savepath%\Terraria, %savepath%\Terraria_Current, R
		FileCreateDir, %savepath%\Terraria
		; Debug Message Commented Out
		;MsgBox, Debug`n`nMade New Save Folder`n`n%savepath%\Terraria\
	}
    
	; Debug Message Commented Out
	;MsgBox, Debug`n`nVersion Ran: %version%`n`nCommand To Run:`n%ComSpec% /c cd /D "%depotspath%\Terraria-%version%" && Terraria.exe %args%`n`nSave Path: "%savepath%"`n`nAnthology Path: "%depotspath%"
	
	; Run the copy of Terraria the user requested with --version and wait until the player is done playing Terraria before we continue.
	RunWait, %ComSpec% /c cd /D "%depotspath%\Terraria-%version%" && Terraria.exe %args%,, Hide
	; Dev Note: We are deliberately running Terraria with an invisible independent cmd to ensure the integrity of Terraria's launch is maintained. Trying to do this in other ways, like calling it directly or calling it with a working directory will not work here, as Terraria gets confused about where it should be looking for it's files, usually resulting in the game crashing or missing music or something.
	
	; Now that the game has closed, we rename the folder of saves it was using to specify the version it was, and restore the Current version's save folder back to it's default name.
	if (!InStr(version, "Undeluxe"))
	{
		FileMoveDir, %savepath%\Terraria, %savepath%\Terraria_%version%, R
		FileMoveDir, %savepath%\Terraria_Current, %savepath%\Terraria, R
		; Debug Message Commented Out
		;MsgBox, Debug`n`nUnredirected Save Folder, Restored Current Version Save Folder
	}
	; Exit now that everything is complete.
	ExitApp
}
; If the version specified is current. We operate as a passthrough to run the current version of Terraria.
else if (version == "Current")
{
	; Debug Message Commented Out
	;MsgBox, Debug`n`nVersion Ran: %version%`n`nCommand To Run:`nTerraria.exe %args%`n`nSave Path: "%savepath%"`n`nAnthology Path: "%depotspath%"
	
	; Check if current Terraria exists. If not, throw an error.
	if !FileExist("Terraria.exe")
	{ 
		MsgBox, Terraria Redirect is not located in the Terraria install folder. Passthrough functionality only works if terraria-redirect.exe is placed in your current Terraria install folder.
		ExitApp
	}
	; Run Current Terraria and exit the script. We do not need to wait either.
	Run, Terraria.exe %args%
	ExitApp
}
; If no version is specified, we set up a little GUI that displays buttons for each final major version release of Terraria. Clicking these buttons will jump to the Launch Game section below while passing it the version we clicked.
else if (version == "")
{
	Gui, Font, s12  ; Set the font size
	Gui, Add, Button, w230 h24 Center gLaunchGame, Current
	Gui, Add, Button, w230 h24 Center gLaunchGame, v1.3.5.3
	Gui, Add, Button, w230 h24 Center gLaunchGame, v1.2.4.1
	Gui, Add, Button, w230 h24 Center gLaunchGame, v1.1.2
	Gui, Add, Button, w230 h24 Center gLaunchGame, v1.0.6.1-Undeluxe
	Gui, Show, , Version Select
	return
}

; Unused ExitApp in case some condition we didn't handle happens. This should never be ran in theory, but we print an error anyway.
MsgBox, 16, Error, If you see this error message. Please make an issue on the Github page and let the author know about it and what Launch Options you used that somehow triggered it.
ExitApp

; GUI Buttons sends you here.
LaunchGame:
	; We collect the data and populate version with it and then relaunch the script, this time with the data from the GUI button clicked.
	Gui, Submit, NoHide
	version := A_GuiControl
    Run, %A_ScriptFullPath% Disregarded\Terraria.exe --version %version% --depotspath "%depotspath%" %args%
	; Dev note: You may notice a weird path here. We have to pretend that we've been launched from Steam here to allow error handling earlier in the script to not catch GUI launches erroneously. This part of the script can only ever be ran if the script was ran from Steam to begin with, so this is fine.
	ExitApp

; Running the AHK script with --build sends you here. Can only be called if you are running it as a script too.
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
	if (FileExist(terraria-redir.ico)) {
	RunWait, "%InstallDir%\Compiler\ahk2exe.exe" /in "%A_WorkingDir%\terraria-redir.ahk" /out "%A_WorkingDir%\terraria-redir.exe" /icon "terraria-redir.ico"
	}
	else {
	RunWait, "%InstallDir%\Compiler\ahk2exe.exe" /in "%A_WorkingDir%\terraria-redir.ahk" /out "%A_WorkingDir%\terraria-redir.exe"
	}
	MsgBox, 64, Information, Compiled script.
	ExitApp

; If the user closes the GUI without choosing a version, the script exits.
GuiClose:
	ExitApp