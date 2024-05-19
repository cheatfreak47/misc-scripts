#NoEnv
#NoTrayIcon
#SingleInstance Force
; Steam Clean Admin Relauncher by CheatFreak
; Requires you set up a scheduled task to launch steam as an administrator (aka "with highest priveleges") in Task Scheduler with no trigger. This script will call this task manually after cleanly closing Steam. Some edits will be needed to make it work for you, probably. Mainly the name of the task it tries to run.

; Check if it's being run with --build as an uncompiled script, and jump to build if it is.
if (!A_IsCompiled) {
	Loop, % A_Args.Length()
		{
			if (A_Args[A_Index] = "--build") {
				goto Build
			}
		}
}

RegRead, steamdir, HKEY_LOCAL_MACHINE, SOFTWARE\WOW6432Node\Valve\Steam, InstallPath
if (ErrorLevel) {
	RegRead, steamdir, HKEY_LOCAL_MACHINE, SOFTWARE\Valve\Steam, InstallPath
	if (ErrorLevel) {
		MsgBox, 48, Error, Steam installation location not found in the registry.
		ExitApp
	}
}
Process, Exist, Steam.exe  ; Check if Steam is running
if ErrorLevel  ; If the process was found
{
	RunWait, "%steamdir%\steam.exe" -shutdown
}

counter := 0

Relaunch:
	Process, Exist, Steam.exe  ; Check if Steam is running
	if !ErrorLevel  ; If the process was not found
	{
		;MsgBox, Relaunch Happen after %counter% loops
		Run, %ComSpec% /c schtasks /run /tn "CheatFreak's Tasks\Steam administrator",, Hide
			; Note this is being run with a hidden command prompt. It runs a scheduled task you must make that runs Steam as adminstrator with no trigger.
		ExitApp
	}
	else {
		Sleep, 200
		counter++
		if (counter >= 150) {
			MsgBox, 64, Error, Steam is taking too long to close.
			ExitApp
		}
		goto Relaunch
	}
MsgBox, 64, Error, Uncaught Exception
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
