; Terraria Version Redirector WIP
	; To Do List
		; - Add Logging, this is just a good idea probably
		; - Write Instructions
; Specify some script settings to ensure it is running as it should.
#NoEnv
#NoTrayIcon
#SingleInstance Force

; Build script breakout
Loop, % A_Args.Length()
{
	if (A_Args[A_Index] = "--build") {
		goto Build
	}
	break
}

; Checks if the program is running *as* an AHK script or if it has been compiled and handles it if it isn't compiled. You cannot have Steam run an AHK script. Only an executable.
if (!A_IsCompiled) {
    MsgBox, 16, Error, This script must be run as a compiled .exe, not as a .ahk script.
    ExitApp
}

; Checks if the script is being ran with no arguments at all.
if %0% = 0
{
    MsgBox, 16, Error, This script must be run from Steam by modifying the launch command for Terraria, not by launching it directly in Windows. `nSome examples of possible correctly set launch commands would be:`n`n"C:\Program Files (x86)\Steam\steamapps\common\Terraria\terraria-redir.exe" `%command`%`n`n"G:\Games\Steam\steamapps\common\Terraria\terraria-redir.exe" `%command`% --version v1.1.2 --depotspath "G:\Games\TerrariaDepots"
    ExitApp
}
else
{
	; Checks if the program is being ran from Steam. Terraria does not run if it is not a child process of Steam launching it as AppID 105600. We check this by validating that the Steam Provided %command% is passed to the script as one of the arguments. If it is not, we assume we are running in the wrong context and throw an error.
	Loop, % A_Args.Length()
	{
		if (!InStr(A_Args[A_Index], "Terraria.exe"))
		{
			MsgBox, 16, Error, This script must be run from Steam by modifying the launch command for Terraria.`nSome examples of possible correctly set launch commands would be:`n`n"C:\Program Files (x86)\Steam\steamapps\common\Terraria\terraria-redir.exe" `%command`%`n`n"G:\Games\Steam\steamapps\common\Terraria\terraria-redir.exe" `%command`% --version v1.1.2 --depotspath "G:\Games\TerrariaDepots"
			ExitApp
		}
		break
	}
}

; Init variables
args := ""
version := ""
savepath := A_MyDocuments . "\My Games"
depotspath := ""
;look through and collect up data from arguments
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

if (depotspath = "")
{
	;If no depot was specified, we assume the user is storing them in the same location as Terraria, so the steam install, this is generally the default with Terraria Depot Downloader, if it ends up being wrong, an error message will cover specifying the correct location to the user, so it's okay.
	RegRead, TerrInstall, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 105600, InstallLocation
	lastSlash := InStr(TerrInstall, "\",, 0)
	depotspath := SubStr(TerrInstall, 1, lastSlash - 1)
}

if (depotspath = "")
{
	; If nothing is still found, we can't continue, so we throw and error and exit.
	MsgBox, 16, Error, No Depots Path was able to be found, nor was one specified. Please provide the location of your collection of Terraria Depots downloaded by Terraria Depot Downloader using --depotspath in the launch commands section for Terraria on Steam.
	ExitApp
}

Loop, % A_Args.Length()
{
	; Skip the argument with Terraria.exe and the --version argument and following version when building the string to pass to the game
	if (InStr(A_Args[A_Index], "Terraria.exe") || A_Args[A_Index - 1] = "--version" || A_Args[A_Index] = "--version" || A_Args[A_Index - 1] = "--depotspath" || A_Args[A_Index] = "--depotspath")
	continue
	; Add the argument to the args string
	args .= A_Args[A_Index] " "
}

if (version != "") and (version != "Current")
{
	if !FileExist(depotspath . "\Terraria-" . version)
	{
		MsgBox, 16, Error, The requested Terraria version could not be found at:`n`n"%depotspath%\Terraria-%version%"`n`nIf the above path is not where your depots are located, please ensure you pass the correct path using --depotspath in the launch commands section for Terraria on Steam.`n`nIf the path is correct, then you probably do not have the specified Terraria version depot downloaded.
		ExitApp
	}
	;todo Save Redirect Stuff goes here
	if (FileExist(savepath . "\Terraria_" . version) && !InStr(version, "Undeluxe"))
	{
		FileMoveDir, %savepath%\Terraria, %savepath%\Terraria_Current, R
		FileMoveDir, %savepath%\Terraria_%version%, %savepath%\Terraria, R
		;MsgBox, Redirected Save Folder`n`n%savepath%\Terraria\
	}
	else if (!InStr(version, "Undeluxe"))
	{	
		FileMoveDir, %savepath%\Terraria, %savepath%\Terraria_Current, R
		FileCreateDir, %savepath%\Terraria
		;MsgBox, Made New Save Folder`n`n%savepath%\Terraria\
	}
	;dev ;debug textbox
    ;MsgBox, Debug Message`n`nVersion Ran: %version%`n`nCommand To Run:`n%ComSpec% /c cd /D "%depotspath%\Terraria-%version%" && Terraria.exe %args%`n`nSave Path: "%savepath%"`n`nAnthology Path: "%depotspath%"
	
	;Run the appropriate version of the game
	RunWait, %ComSpec% /c cd /D "%depotspath%\Terraria-%version%" && Terraria.exe %args%,, Hide
	
	;todo Save Redirect Undo stuff goes here
	if (!InStr(version, "Undeluxe"))
	{
		FileMoveDir, %savepath%\Terraria, %savepath%\Terraria_%version%
		FileMoveDir, %savepath%\Terraria_Current, %savepath%\Terraria
		;MsgBox, Unredirected Save Folder, Restored Current Version Save Folder
	}
	ExitApp
}
else if (version == "Current")
{
	;dev ;debug textbox
	    ;MsgBox, Debug Message`n`nVersion Ran: %version%`n`nCommand To Run:`nTerraria.exe %args%`n`nSave Path: "%savepath%"`n`nAnthology Path: "%depotspath%"
	
	;dev; commented out for testing
	Run, Terraria.exe %args%
	ExitApp
}
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
ExitApp

LaunchGame:
	Gui, Submit, NoHide
	version := A_GuiControl
    Run, %A_ScriptFullPath% Disregarded\Terraria.exe --version %version% --depotspath "%depotspath%" %args%
	ExitApp
Build:
	; Try to read the install location from the 64-bit registry path
	RegRead, InstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\AutoHotkey, InstallDir
	; If the above registry path doesn't exist (i.e., on a 32-bit machine), try the 32-bit registry path
	if (ErrorLevel) {
		RegRead, InstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\AutoHotkey, InstallDir
	}
	; If the install location is still not found, show an error message
	if (ErrorLevel) {
		MsgBox, 48, Error, AutoHotkey installation location not found in the registry.
		ExitApp
	}
	if (FileExist(terraria-redir.ico)) {
	RunWait, "%InstallDir%\Compiler\ahk2exe.exe" /in "%A_WorkingDir%\terraria-redir.ahk" /out "%A_WorkingDir%\terraria-redir.exe" /icon "terraria-redir.ico"
	}
	else {
	RunWait, "%InstallDir%\Compiler\ahk2exe.exe" /in "%A_WorkingDir%\terraria-redir.ahk" /out "%A_WorkingDir%\terraria-redir.exe"
	}
	MsgBox, 64, Information, Compiled script.
	ExitApp
GuiClose:
	ExitApp
