@echo on
:: This is a batch file that will systematically decompress (unpack and repack uncompressed) No Man's Sky PAK files. It requires the PS3 ASK PSARC tool either in the same folder as this batch file or placed somewhere on the PATH Environment Variable. You can get the PS3 SDK PSARC Tool from from archive.org. I make no claims about the legality of doing so, though I very much doubt Sony cares about an SDK tool from over a decade ago.
:: https://archive.org/download/ps3_sdks in file "PS3 4.50 SDK-YLoD [450_001].7z". The file is called psarc.exe
:: ---------------------------------------------------------------------------------------------------------------------------------------------------------------

:: Running the game files uncompressed has some performance benefits, since the game has to spend no time decompressing assets, including those pesky lag spikes when entering/exiting Planet Atmospheres. This performs vastly better than running the game fully unpacked as well, since the game does not have to open 1000s of file handles to get the data, which can also cause lag and general slowness in load speed.

:: To use, place psarc.exe and this batch file in install folder in \No Man's Sky\GAMEDATA\PCBANKS and run the batch file. It will take a good long time to run.
:: All your old compressed pack files will be moved into "PackedFileBackup".
:: After running, verify the game works properly for you. If it does, good!
:: Consider getting NMSResign and overwriting the file verification table so you don't get the "tampering" nag every boot.

:: 	Any Drawbacks? 
::		- the game takes up an assload more space (+39GB or so, possibly more as the game keeps getting updated.
::  	- it breaks whenever the game updates. when it breaks, validate the cache. Delete the old backup folder, and run it again.
::  	- nms complains about tampering with the files, use NMSResign to fix this. (https://www.nexusmods.com/nomanssky/mods/1565)
::  	- takes a while to run 

for %%f in (*.pak) do (
	mkdir "PackedFileBackup"
    psarc.exe extract "%%f" --to="%%~nf"
    move /Y "%%~nxf" "PackedFileBackup"
	sleep 500
    psarc.exe create -i "%%~nf" -N -y -o "%%~nxf" -s ".*?%%~nf"
	rmdir /s /q %%~nf
)
echo All Done!
pause