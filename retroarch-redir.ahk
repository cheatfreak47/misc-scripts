#NoEnv
#NoTrayIcon
; RetroArch Steam Redirection Script
; modify this script to suit your needs, place it in the RetroArch Steam Install Directory, and compile the script.
; Edit the Launch Options of RetroArch on Steam 
; to say: "C:\Program Files (x86)\Steam\steamapps\common\RetroArch\retroarch-redir.exe" %command%
; You may edit that path if your copy of RetroArch Steam is located elsewhere.
; This will run your compiled redirect script instead of RetroArch and ensure RetroArch getting Steam Updates will not impact this script's function

; Initialize an empty string for the arguments
args := ""

; Loop over each argument in A_Args
Loop, % A_Args.Length()
{
    ; Skip the first argument (This will always be the steam retroarch.exe, we disregard this to run our own program later.)
    if (A_Index = 1)
        continue

    ; Check if the argument contains a space
    if (InStr(A_Args[A_Index], " "))
    {
        ; If it does, add quotes around the argument
        args .= """" . A_Args[A_Index] . """ "
    }
    else
    {
        ; If it doesn't, add the argument as is
        args .= A_Args[A_Index] " "
    }
}

; Trim the trailing space from the args string
args := Trim(args)

; Get the current date and time and format the timestamp for the runtime operations
timestamp := A_Now
FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss

; Check if there were any arguments left after processing them
if (args != "")
{
    ; If there are, log that the program was launched with arguments //runtime
    FileAppend, [%timestamp%] RetroArch Launched with Arguments`n[%timestamp%] retroarch.exe %args%`n, redirectlog.txt
}
else
{
    ; If there aren't, log that the program was launched cleanly //runtime
    FileAppend, [%timestamp%] RetroArch Launched`n, redirectlog.txt
}

; Initialize a flag for the ArchipelagoLinksAwakeningClient
ArchipelagoClientRunning := false

; Check if "ArchipelagoLinksAwakeningClient.exe" is running (this is an example also of how to perform additional operations if you want)
Process, Exist, ArchipelagoLinksAwakeningClient.exe
if (ErrorLevel != 0)
{
	; If it is, set the flag to true
    ArchipelagoClientRunning := true
	; If it is, change directory and launch the LADXR Magpie Tracker 
	; (note: we're running this in a weird way here, because the batch file gets confused if it's not ran from the correct folder.)
    Run, cmd /c cd /D "C:\Program Files (Simple)\magpie-local\" && magpie.bat
	; Log that we launched Magpie Tracker //runtime
	FileAppend, [%timestamp%] Magpie Tracker Launched`n, redirectlog.txt
}

; Run and pass the arguments that were intended for the program through to the target program and wait for the program before continuing with closing operations
RunWait, "C:\Program Files (Simple)\RetroArch\retroarch.exe" %args%

; Get the current date and time and format the timestamp for the closing operations
timestamp := A_Now
FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
; When the user finishes/is done playing, log when it closed //closing
FileAppend, [%timestamp%] RetroArch Closed`n, redirectlog.txt

; Check if "magpie-data.exe" is running if we ran it earlier
Process, Exist, magpie-data.exe
if (ErrorLevel != 0 && ArchipelagoClientRunning)
{
    ; If it is, terminate it and its child processes
    Run, %ComSpec% /c start /B taskkill /F /IM magpie-data.exe /T
	; Get the current date and time and format the timestamp
	timestamp := A_Now
	FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
    ; log that we terminated magpie-data.exe
    FileAppend, [%timestamp%] Magpie Tracker Closed`n, redirectlog.txt
}
;finalize log file with a newline to separate runs in the log
FileAppend, `n, redirectlog.txt