; Terraria Version Redirector WIP
	; To Do List
		; - Add Error Handling, this thing breaks easily
		; - Add Logging, this is just a good idea probably
		; - Change Anthology Path to DepotDownloads path, and allow passing it to the program via argument
		; - Write Instructions
		; - Write Build Script

; Specify some script settings to ensure it is running as it should.
#NoEnv
#NoTrayIcon
#SingleInstance Force

; Checks if the program is running *as* an AHK script or if it has been compiled and handles it if it isn't compiled. The program only works if it is compiled, because you cannot associate a URL with an ahk file.
if (!A_IsCompiled) {
    MsgBox, 16, Error, This script must be run as a compiled .exe, not as a .ahk script.
    ExitApp
}

; Init variables
args := ""
version := ""
savepath := A_MyDocuments . "\My Games"
anthologypath := "T:\Software\Terraria Anthology"
	; "anthologypath must be set before compile, this is not ideal and should probably be an argument instead but I am lazy

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
	; Skip the argument with Terraria.exe and the --version argument and following version when building the string to pass to the game
	    if (InStr(A_Args[A_Index], "Terraria.exe") || A_Args[A_Index - 1] = "--version" || A_Args[A_Index] = "--version")
		continue

	; Add the argument to the args string
	args .= A_Args[A_Index] " "
}

if (version != "") and (version != "Current")
{
	;dev ;msgboxes are for debug purposes, will be commented out later
	
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
		;sgBox, Made New Save Folder`n`n%savepath%\Terraria\
	}
	;dev ;debug textbox
    ;MsgBox, Debug Message`n`nVersion Ran: %version%`n`nCommand To Run:`n%ComSpec% /c cd /D "%anthologypath%\Terraria-%version%" && Terraria.exe %args%`n`nSave Path: "%savepath%"`n`nAnthology Path: "%anthologypath%"
	
	;Run the appropriate version of the game
	RunWait, %ComSpec% /c cd /D "%anthologypath%\Terraria-%version%" && Terraria.exe %args%,, Hide
	
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
	    ;MsgBox, Debug Message`n`nVersion Ran: %version%`n`nCommand To Run:`nTerraria.exe %args%`n`nSave Path: "%savepath%"`n`nAnthology Path: "%anthologypath%"
	
	;dev; commented out for testing
	Run, Terraria.exe %args%
	ExitApp
}
else
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
    Run, %A_ScriptFullPath% --version %version% %args%
GuiClose:
	ExitApp
