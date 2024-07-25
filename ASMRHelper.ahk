#NoEnv
#NoTrayIcon
#SingleInstance Force

; ASMR YouTube Download Assistant by CheatFreak
; 	 "The Most Esoteric Bullshit Script I've Ever Made"
;
; It assists you in cropping and applying thumbnail images as album art and applying metadata
; 
; Run script from a folder where you ran a yt-dlp commands like this one:
; yt-dlp <playlist-url-here> --write-thumbnail --playlist-items <items-here> -f bestaudio -x --audio-format mp3 --audio-quality 2 -o "%(uploader)s - %(upload_date)s - %(title)s - %(id)s.%(ext)s" --postprocessor-args "-ar 44100"
;
; The filename format MUST follow "%(uploader)s - %(upload_date)s - %(title)s - %(id)s.%(ext)s", as the script is designed around this.

SetWorkingDir %A_ScriptDir%

; Make Webps Into JPGs
Loop, Files, *.webp
{
	webpFile := A_LoopFileFullPath
	baseName := A_LoopFileName
	SplitPath, baseName, name, dir, ext, name_no_ext, drive
    jpgFile := name_no_ext . ".jpg"
	RunWait, magick convert "%webpFile%" -quality 95 "%jpgFile%", , Hide
	
}

; Trim MP3s and attach Thumbnails
Loop, Files, *.mp3
{
    mp3File := A_LoopFileFullPath
    baseName := A_LoopFileName
    SplitPath, baseName, name, dir, ext, name_no_ext, drive
    parts := StrSplit(name_no_ext, " - ")
    uploader := Trim(parts[1])
    upload_date := SubStr(Trim(parts[2]), 1, 4)
    title := Trim(parts[3])
    id := Trim(parts[4])
    album := uploader . " Past Lives"
    album_artist := "Various ASMRtists (SFW YouTube)"
    genre := "ASMR"
	timestamp := ""
	
    ; Open the YouTube URL in Microsoft Edge
    Run, msedge.exe https://www.youtube.com/watch?v=%id%
    Sleep, 500
	
	Gosub ShowTimestampInputGUI
	
	; Use the timestamp from the GUI, or "00:00:00" if the text box is left blank
    timestamp := (Timestamp = "") ? "00:00:00" : Timestamp
	
    ;Debug MsgBox
    MsgBox, Uploader: %uploader%`nUpload Date: %upload_date%`nTitle: %title%`nID: %id%`nAlbum: %album%`nAlbum Artist: %album_artist%`nGenre: %genre%`nTimestamp: %Timestamp%
	
	; Set the variables for these things.
    jpgFile := name_no_ext . ".jpg"
    webpFile := name_no_ext . ".webp"
	; Crop the audio file based on the provided timestamp
	RunWait, ffmpeg -i "%mp3File%" -ss %Timestamp% -acodec copy "temp.mp3", , Hide
	Sleep 1000
	RunWait, cmd /c del "%mp3File%", , Hide
	Sleep 1000
	RunWait, cmd /c ren "temp.mp3" "%mp3file%", , Hide
	Sleep 1000
	; Apply the metadata and thumbnail
	RunWait, ffmpeg -i "%mp3File%" -i "%jpgFile%" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata ARTIST="%uploader%" -metadata TITLE="%title%" -metadata YEAR="%upload_date%" -metadata COMMENT="%id%" -metadata ALBUM="%album%" -metadata ALBUMARTIST="%album_artist%" -metadata GENRE="%genre%" "temp.mp3", , Hide
	Sleep 1000
	RunWait, cmd /c del "%mp3File%", , Hide
	Sleep 1000
	RunWait, cmd /c ren "temp.mp3" "%mp3file%", , Hide
	Sleep 1000
	; clean up useless webp files
	RunWait, cmd /c del "%webpFile%", , Hide
    ;Debug MsgBox
    MsgBox, Done with %mp3file%!
}

Loop, Files, *.jpg 
{
	jpgFile := A_LoopFileFullPath
    baseName := A_LoopFileName
    SplitPath, baseName, name, dir, ext, name_no_ext, drive
	jpgFile := name_no_ext . ".jpg"
	FileRecycle, %jpgFile%
}

ExitApp

ShowTimestampInputGUI:
    ; Create a GUI for timestamp input
    Gui, Add, Text,, Enter the timestamp in 00:00:00 format:
    Gui, Add, Edit, vTimestamp
    Gui, Add, Button, gButtonOK Default, OK

    ; Show the GUI and wait for the user to click OK
	Gui, +AlwaysOnTop
    Gui, Show,, Timestamp Input
	Pause, On

ButtonOK:
    Gui, Submit, Hide
    Gui, Destroy
	Pause, Off
    Return