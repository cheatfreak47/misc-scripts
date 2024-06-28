@echo on
:: No Man's Sky Decompressinator Script by CheatFreak

:: This is a batch file that will systematically decompress (unpack and repack uncompressed) No Man's Sky PAK files. 
:: It requires the PS3 SDK PSARC Tool either in the same folder as this batch file or placed somewhere on the PATH Environment Variable.
:: You can get the PS3 SDK PSARC Tool from from archive.org or dig it out of your dev files if you were a PS3 Dev. 
:: I make no claims about the legality of doing so, though I very much doubt Sony cares about an SDK tool from over a decade ago. 
:: You can find it here. (https://archive.org/download/ps3_sdks) in file "PS3 4.50 SDK-YLoD [450_001].7z". The required file is called psarc.exe.

:: ---------------------------------------------------------------------------------------------------------------------------------------------------------------

:: Running the game files uncompressed (but NOT unpacked) has significant performance benefits.
:: The game has to spend no time or CPU decompressing assets. Eliminates pesky lag spikes, such as the infamous ones when entering/exiting planet atmospheres. 
:: This performs better than running the game fully unpacked as well, since the game does not have to open 1000s of file handles to get the data.
:: The exact amount you will benefit from this depends largely on your rig.

:: To use, place psarc.exe and this batch file in install folder in \No Man's Sky\GAMEDATA\PCBANKS and run the batch file. It will take a while to run.
:: All your old compressed pack files will be moved into "PackedFileBackup".
:: After running, verify the game works properly for you. If it does, good! Feel free to delete the PackedFileBackup if all is well.
:: Consider getting NMSResign from the link below and overwriting the file verification table so you don't get the "tampering" nag every boot.

:: 	Any Drawbacks? 
::		- the game takes up an assload more space- about  39GB or so, possibly more as the game keeps getting updated.
::  	- it breaks whenever the game updates. when it breaks, validate the cache. Delete the old backup folder, and run it again.
::  	- nms complains about tampering with the files, use NMSResign to fix this. (https://www.nexusmods.com/nomanssky/mods/1565)
::  	- takes a while to run, depending on how slow your PC is.

for %%f in (*.pak) do (
	mkdir "PackedFileBackup"
    psarc.exe extract "%%f" --to="%%~nf"
    move /Y "%%~nxf" "PackedFileBackup"
    psarc.exe create -i "%%~nf" -N -y -o "%%~nxf" -s ".*?%%~nf"
	rmdir /s /q %%~nf
)
echo All Done!
pause