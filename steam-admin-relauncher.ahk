#NoEnv
#NoTrayIcon
#SingleInstance Force
; Steam Clean Admin Relauncher by CheatFreak
; Requires you set up a scheduled task to launch steam as an administrator (aka "with highest priveleges") in Task Scheduler with no trigger. This script will call this task manually after cleanly closing Steam. Some edits will be needed to make it work for you, probably. Mainly the name of the task it tries to run.

; Check if it's being run with --build as an uncompiled script, and jump to the Build routine if it is.
if (!A_IsCompiled) {
	Loop, % A_Args.Length()
		{
			if (A_Args[A_Index] = "--build") {
				goto Build
			}
		}
}

; Check the location of steam and pipe it into a Varaible
RegRead, steamdir, HKEY_LOCAL_MACHINE, SOFTWARE\WOW6432Node\Valve\Steam, InstallPath
if (ErrorLevel) {
	RegRead, steamdir, HKEY_LOCAL_MACHINE, SOFTWARE\Valve\Steam, InstallPath
	if (ErrorLevel) {
		MsgBox, 48, Error, Steam installation location not found in the registry.
		ExitApp
	}
}
; Check if Steam is running
Process, Exist, Steam.exe 
; Ask steam to close by launching steam's main application with the shutdown command to make it cleanly close.
if ErrorLevel {
	RunWait, "%steamdir%\steam.exe" -shutdown
}

; Setup the counter for checking if steam finished closing
counter := 0

; Define relaunch routine
Relaunch:
	; Check if steam has closed yet.
	Process, Exist, Steam.exe
	; Once it has closed launch steam again via a scheduled task.
	if !ErrorLevel {
		;MsgBox, Debug Msg: Relaunch Happen after %counter% loops
		Run, %ComSpec% /c schtasks /run /tn "CheatFreak's Tasks\Steam administrator",, Hide
		; Note this is being run with a hidden command prompt. It runs a scheduled task you must make that runs Steam as adminstrator with no trigger.
		ExitApp
	}
	else {
		; If steam is still open, wait 200ms
		Sleep, 200
		; Increment the loop counter
		counter++
		; if the loop counter makes it to 150, or 30 seconds of checks, print an error and close. Steam is not co-operating with a shutdown for some reason and the user should deal with that.
		if (counter >= 150) {
			MsgBox, 64, Error, Steam is taking too long to close.
			ExitApp
		}
		; Go back to the beginning of the Relaunch routine (thereby checking again.)
		goto Relaunch
	}
; Catch all exceptions this should normally never get ran
MsgBox, 64, Error, Uncaught Exception
ExitApp

; Define build routine
Build:
	; Read AutoHotKey Installation Directory
	RegRead, InstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\AutoHotkey, InstallDir
	if (ErrorLevel) {
		RegRead, InstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\AutoHotkey, InstallDir
	}
	if (ErrorLevel) {
		MsgBox, 48, Error, AutoHotkey installation location not found in the registry.
		ExitApp
	}
	; Sanitize the script name into a new variable
	ScriptName := SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".",, 0) - 1)
	; generic command to compile the current script with the compiler using the script name as a base
	RunWait, "%InstallDir%\Compiler\ahk2exe.exe" /in "%A_ScriptFullPath%" /out "%A_WorkingDir%\%ScriptName%.exe" /icon "%ScriptName%.ico"
	ExitApp
