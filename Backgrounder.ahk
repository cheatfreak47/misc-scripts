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
}
; Main Logic ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SetWorkingDir %A_ScriptDir%
Loop %0%  ; For each file dropped onto the script (or passed as a parameter).
{
    GivenPath := %A_Index%  ; Retrieve the next command line parameter.
    Loop %GivenPath%, 1
        background = %A_LoopFileLongPath%
}
Loop %background%, 1
    backgroundName := A_LoopFileName
backgroundName := SubStr(backgroundName, 1, InStr(backgroundName, ".", true) - 1)

if !FileExist ("%backgroundName%") {
	FileCreateDir, %backgroundName%
}

Loop, Files, *.png
{
    If (A_LoopFileName != backgroundName . ".png")
    {
		LoopName := SubStr(A_LoopFileName, 1, InStr(A_LoopFileName, ".", true) - 1)
		Run, %ComSpec% /c magick.exe "%background%" "%A_LoopFileName%" -composite "%backgroundName%\%LoopName% %backgroundName%.png",, Hide
    }
}
;MsgBox, Done!
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