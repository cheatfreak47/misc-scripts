#NoEnv
#NoTrayIcon
; RetroArch Steam Redirection Script
; modify this script to suit your needs, place it in the RetroArch Steam Install Directory, and compile the script.
; Edit the Launch Options of RetroArch on Steam 
; to say: "C:\Program Files (x86)\Steam\steamapps\common\RetroArch\retroarch-redir-simplified.exe" %command%
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
    ; If there are, log that the program was launched with arguments
    FileAppend, [%timestamp%] Program Launched with Arguments`n[%timestamp%] %args%`n, redirectlog.txt
}
else
{
    ; If there aren't, log that the program was launched cleanly
    FileAppend, [%timestamp%] Program Launched`n, redirectlog.txt
}

; Run and pass the arguments that were intended for the program through to the target program
SetWorkingDir, C:\path\to\your\target\
RunWait, "C:\path\to\your\target\program.exe" %args%

; Revert Working dir back to script location
SetWorkingDir, "%A_ScriptDir%"

; Get the current date and time and format the timestamp for the closing operations
timestamp := A_Now
FormatTime, timestamp, %timestamp%, yyyy-MM-dd HH:mm:ss
; When the user finishes/is done playing, log when it closed //closing
FileAppend, [%timestamp%] Program Closed`n, redirectlog.txt

;finalize log file with a newline to separate runs in the log
FileAppend, `n, redirectlog.txt
; terminate cleanly
ExitApp
