#NoEnv
#Persistent
#SingleInstance Force

; If the script is not elevated, relaunch as administrator and kill current instance:
if (A_IsCompiled) {
	full_command_line := DllCall("GetCommandLine", "str")
	if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
	{
		try ; leads to having the script re-launching itself as administrator
		{
			if A_IsCompiled
				Run *RunAs "%A_ScriptFullPath%" /restart
			else
				Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
		}
		ExitApp
	}
}

; Check if it's being run with --build as an uncompiled script, and jump to the Build routine if it is.
if (!A_IsCompiled) {
	Loop, % A_Args.Length()
		{
			if (A_Args[A_Index] = "--build") {
				goto Build
			}
		}
}

; Define the path to the SRUDB.dat file
SRUDBPath := "C:\Windows\System32\sru\SRUDB.dat"

; Define the backup directory
BackupDir := A_MyDocuments . "\Data Usage Statistics\"

; Check if the backup directory exists, if not, create it
IfNotExist, %BackupDir%
    FileCreateDir, %BackupDir%

; Define the backup file name
BackupFile := BackupDir . "SRUDB"
BackupArchive := BackupDir . "SRUDB - " . A_Now

; Stop the Diagnostic Policy Service
RunWait, % "net stop DPS", , Hide

; Try to read the 7-Zip location from various registry paths
RegRead, SevenZipDir, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\7-Zip, Path
if (ErrorLevel) {
    RegRead, SevenZipDir, HKEY_LOCAL_MACHINE, SOFTWARE\7-Zip, Path
}
if (ErrorLevel) {
	RegRead, SevenZipDir, HKEY_LOCAL_MACHINE, SOFTWARE\Wow6432Node\7-Zip-Zstandard, Path
}
if (ErrorLevel) {
    RegRead, SevenZipDir, HKEY_LOCAL_MACHINE, SOFTWARE\7-Zip-Zstandard, Path
}
; If the 7-Zip location is still not found, show an error message
if (ErrorLevel) {
    MsgBox, 48, Error, 7-Zip installation location not found in the registry.
    ExitApp
}

; Copy the SRUDB.dat file to the backup directory
FileCopy, %SRUDBPath%, %BackupFile%.dat

RunWait, cmd /c ""%SevenZipDir%7z.exe" a -t7z -m0=lzma2 -mx=9 "%BackupArchive%.7z" "%BackupFile%.dat"", , Hide
if !ErrorLevel {
	FileDelete, %BackupFile%.dat
	FileDelete, %SRUDBPath%
}

; Start the Diagnostic Policy Service
RunWait, % "net start DPS", , Hide

; Exit the script
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
