@echo on
:: This is a batch file that will systematically decompress (unpack and repack uncompressed) No Man's Sky PAK files. It requires the PS3 ASK PSARC tool either in the same folder as this batch file or placed somewhere on the PATH Environment Variable. You can get the PS3 SDK PSARC Tool from from archive.org. I make no claims about the legality of doing so, though I very much doubt Sony cares about an SDK tool from over a decade ago.
:: https://archive.org/download/ps3_sdks in file "PS3 4.50 SDK-YLoD [450_001].7z"
::------------------------------------------------------------------------------------------------------
:: To use, place psarc.exe and this batch file in install folder in \No Man's Sky\GAMEDATA\PCBANKS and run the batch file. It will take a good long time to run.
:: After it's finished it will have renamed all your stock .pak files to .null and placed new ones that are much larger, because they are uncompressed. You may delete the .null files afterwards if you wish.
:: Running the game files uncompressed has some performance benefits, since the game has to spend no time decompressing assets. This performs vastly better than running the game fully unpacked as well, since the game does not have to open 1000s of file handles to get it's files either. 
::
::Drawbacks? 
:: - the game takes up an assload more space (+39GB or so.)
:: - it breaks whenever the game updates, and will need ran again after validating the Steam Cache to fix it.
:: - nms complains about tampering with the files (it's fine, don't worry)
:: - takes a while to run
::
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