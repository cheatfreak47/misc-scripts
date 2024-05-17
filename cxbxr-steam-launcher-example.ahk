#NoEnv
#NoTrayIcon
#SingleInstance Force
; CxBx Reloaded Single Game Launcher Script by CheatFreak
; 1. Rename the script file to the name of the game you are customizing it for.
; 2. Change cxbx and game below to the full paths to your cxbxr install and your game xbe in quotes. Example provided below.
; 3. Download or otherwise make a ico file and also put it in the same folder as this script, with the same name as the script file.
; 4. Run the script with --build to create your launcher exe.
; 5. Add the launcher EXE to steam and customize the non-steam shortcut to your liking, or use it for whatever other launcher you want.

; Check if it's being run with --build as an uncompiled script, and jump to build if it is.
if (!A_IsCompiled) {
	Loop, % A_Args.Length()
		{
			if (A_Args[A_Index] = "--build") {
				goto Build
			}
		}
}

; Define CxBxReloaded and Game XBE location.
cxbx := "C:\Program Files (Simple)\CxBxReloaded\cxbx.exe"
game := "J:\UserData\ISOs\Microsoft - Xbox\JSRF - Jet Set Radio Future (USA)\default.xbe"

; Run the game
Run, "%cxbx%" "%game%",, UseErrorLevel
; Wait for the Window to appear before continuing
WinWait, ahk_exe %cxbx%
; Move the window to the top monitor- you can customize this depending on your preferred monitor layout, I keep my TV above my PC monitor, so Y minus 1080px puts it on the TV for me.
WinMove, ahk_exe %cxbx%, , 0, -1080
; Wait for the game to start and then send fullscreen command and exit.
Sleep, 6000
Send, {F10}
ExitApp

Build:
	RegRead, InstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\AutoHotkey, InstallDir
	if (ErrorLevel) {
		RegRead, InstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\AutoHotkey, InstallDir
	}
	if (ErrorLevel) {
		MsgBox, 48, Error, AutoHotkey installation location not found in the registry.
		ExitApp
	}
	ScriptName := SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".",, 0) - 1)
	RunWait, "%InstallDir%\Compiler\ahk2exe.exe" /in "%A_ScriptFullPath%" /out "%A_WorkingDir%\%ScriptName%.exe" /icon "%ScriptName%.ico"
	ExitApp
