# misc-scripts
Miscellaneous scripts I've written to perform various tasks or automate something. Each script will have a section in this readme to at least vaguely explain what it does.
##
### sonicbackup.bat (Windows Batch Script)
This script exists for one reason:
 - Sonic Generations randomly deleted my save file and I wanted to make sure that wouldn't happen again on my unfortunately *second* quest to 100% the game.
 
An old script I made that has a lot more functionality than was really necessary, so it could be used with other things. I've since used it for No Man's Sky and a couple other titles, but the uploaded version here remains set up to work for Sonic Generations. Never did get around to finishing Sonic Generations 100% though.

It has the following features:
 - Generic Game Save Backup Support by Editing the Variables
 - Custom Backup Intervals
 - A limiter to prevent accidentally backing up files for days if you somehow leave it running.
##
### retroarch-redir.ahk (AutoHotKey 1.1 Script)
This script exists for a few reasons:
 - I use Steam Input API almost religiously to do misc tasks while dealing with my controllers, so I want RetroArch launched with Steam Input available.
 - I dislike the Steam Version of RetroArch because it lacks the Online Updater that the mainstream builds have.
 - Steam does not allow you to run Non-Steam Games via Commandline using `steam.exe -applaunch <shortcutID>`. I wish I knew why. 
 - While it does support launching Shortcuts via the Steam Protocol URLs, this is unhelpful because you cannot pass arguments to a URL, and...
 - ...Windows does not allow you to associate a filetype with a URL, only an executable. This one makes sense, as URLs are really not designed to handle arguments anyway.
 - I've been playing a lot of Link's Awakening DX on Archipelago and that really necessitates associating `*.gbc` files with RetroArch in some way, which is obviously anti-thetical to me wanting to Steam Input on everything.

So I designed an AHK script that allows you to effectively take over the Steam Copy of RetroArch and redirect it's launch to a copy of the mainstream build of RetroArch elsewhere on your computer.

It has the following features:
 - Steam Update Proof. By editing the "Launch Options" for the Steam Build of RetroArch to say `"C:\Program Files (x86)\Steam\steamapps\common\RetroArch\retroarch-redir.exe" %command%` you effectively are able to launch the compiled redirector with the typical command Steam uses to launch RetroArch (most likely just `retroarch.exe`) as an argument. The script simply disregards this argument entirely, since our goal is to take over RetroArch for our own uses. This makes it update proof because RetroArch updates on Steam will never overwrite our program.
 - Maintains Arguments beyond the disregarded one and passes them to the target program. This is necessary to do things like load cores and roms in retroarch, but in general it's just a good behavior for something like this.
 - Logging. This was more for my benefit in debugging but it does work properly so I left it in. Feel free to comment out all the `FileAppend` lines before compiling if you want to disable it.
 - Run multiple things based on active machine context at runtime. I use this to check if my Archipelago Client for Link's Awakening is open, and if it is, then I set up launching it's Magpie Tracker as well. Obviously all this code is unnecessary but it provides examples of how to do weird things like launching a batch file with it's own context maintained, among other things.
 
Helpful note, if you intend to use this in a similar way to me, you may need a program to easily associate steam launches with a rom file type, you can use [Ystr's Types](https://ystr.github.io/types/) to do this. Or if you're batshit you can just edit the crap manually in the Windows Registry Editor. 

An example of launching `*.gbc` roms is associating the format with the Open Command `"C:\Program Files (x86)\Steam\Steam.exe" -applaunch 1118310 -L sameboy_libretro.dll "%1"`.
##
### retroarch-redir-simplified.ahk (AutoHotKey 1.1 Script)
This script exists for a few reasons:
 - My friend wanted to take over RetroArch to allow him to Remote Play Together any program. Effectively using RetroArch as dummy program to run anything he wants.
 - My previous script seemed prime for edits to accomplish this task.
 
So I made those edits and forked my script, and removed a bunch of unnecessary stuff from the above script. It seems to work most of the time, but may need further edits, like changing working directory in different ways or whatever if specific programs are unfriendly to it.

It has the following features:
 - Steam Update Proof. See main script for details.
 - Maintains Arguments. See main script for details.
 - Logging. See main script for details.
 - More direct maintaining of program launch environment by manually setting the Working Directory of the script before launching the program, and then setting it back after the program terminates. This allows you to run games that are super sensitive to their working directory without issues (at least in theory).
 - Should be friendly to users attempting to play via Steam Remote Play. It doesn't do anything that should break it, but in testing it came up that with some games that do not use a standard display API like Direct3D, OpenGL, or Vulkan, the remote user may get stuck behind the dialog that appears when the host user tabs out of the game. This is not caused by the redirect script, it's just an unfortunate consequence of how Steam Remote Play works.
##
### terraria-redir.ahk (AutoHotKey 1.1 Script)
This script exists for a few reasons:
 - Playing old versions of Terraria is annoying because you can't just click on the EXE file, it *requires* launching from the Steam Client as the Terraria AppID (106500).
 - Save files are also a pain in the ass when running old versions, as newer version saves crash older versions of the Terraria client very easily.
 - The normal method (full file replacement/folder renaming) is not update-proof.

So after a bit of work, I wrote up a script that addresses these problems, allowing a seamless means of accessing old, locally stored copies of Terraria.

![terraria-redir_2024-04-13_22-01-06](https://github.com/cheatfreak47/misc-scripts/assets/7818664/aefe252b-2717-456a-8137-8b4eaef2c064)
![steamwebhelper_2024-04-13_22-00-06](https://github.com/cheatfreak47/misc-scripts/assets/7818664/7055726c-3761-48c1-9f80-84d8b046c415)

It has the following features:
 - Works with clean unmodified copies of old Steam versions of Terraria. It does this by sitting between Steam and the target version of Terraria to run, which allows those target versions to still be running as a child process of Steam running the game under the Terraria AppID.
 - Update proof. This does not replace any existing Terraria executable or file. Simply place the compiled binary in your Terraria install folder, and then change the Launch Options for Terraria on Steam to include the full path to the compiled script, followed by `%command%` and any other arguments intended for either the script, or Terraria itself. This same trick is used by SMAPI for Stardew Valley modding.
 - It is intended to be used with [Terraria Depot Downloader]([https://github.com/RussDev7/TerrariaDepotDownloader/]), which downloads and makes a folder of old Terraria versions for you. It's default behavior is to place these in the same Steam Library folder as Terraria itself, but if you decided to change the folder location in the program, you can use the `--depotspath` argument to point this script anywhere you want, as long as the subfolders for old Terraria copies are following the same naming convention.
 - Has a simple GUI for picking the 5 finalized major versions of Terraria. (Current, 1.3.5.3, 1.2.4.1, 1.1.2, and 1.0.1.6.)
 - By using the `--version` argument, you can specify which version of Terraria to run from your collection of depots at runtime, and this supports all possible versions of Terraria ever, rather than just the finalized major versions included in the GUI.
 - Choosing Current as your version makes the script operate as a passthrough to the currently installed version of Terraria.
 - Handles renaming save folders for you automatically to prevent issues with old clients crashing because of newer files, and even remembers the last version ran in the event of the game and script being terminated unexpectedly.
 - Save redirection is disabled for any version containing the text "Undeluxe", as those versions of Terraria use their own save file folder already. (This functionality is subject to change pending support by Terraria Depot Downloader for downloading Undeluxe Editions of old Terraria versions.)
 - By using the `--logging` argument, you can keep a log of Terraria launches and the activity of the script.
 - All other arguments passed to the script outside of `--logging`, `--version`, and `--depotspath` are passed to the target version of Terraria, allowing you to continue to make use of [Terraria's own command-line parameters](https://terraria.wiki.gg/wiki/Command-line_parameters) if needed.
 - A lot of error handling and validation for the arguments.

Instructions:
 - Set up and use [Terraria Depot Downloader]([https://github.com/RussDev7/TerrariaDepotDownloader/]) to download old versions of Terraria to a folder on your computer. It does this in the same Steam Library folder as Terraria is installed by default. If you set up a different folder, make sure to make a note of the full path to that folder for later. If using the default location, after downloading all of the versions you want, make sure you launch the most recent game version to ensure the current version of Terraria is using the `/Terraria` folder.
 - Download the script and install AutoHotKey 1.1.
 - Compile the script. You can use the `--build` argument with the uncompiled script to try to do this automatically.
 - Place the compiled `terraria-redir.exe` in your Steam Terraria installation folder.
 - Shift-Right Click `terraria-redir.exe` and choose `Copy as path`.
 - Open Terraria's Properties on Steam and paste this path into `Launch Options`.
 - Add a space and add `%command%`. If you had a custom path for Terraria Depots, add another space and add `--depotspath` another space, and then the full path to your folder of Terraria Depots.
 - If you wish to make it run a specific version of Terraria you downloaded, you may also add `--version` followed by a space and a version, for example `1.1.2` or `v1.2.4.1`. Use `Current` to passthrough to the current version of Terraria managed by Steam.
 - If you run it with no `--version` it will open a GUI with options to launch each of the final major versions of Terraria. Make sure you have those Depots though, or else you will get an error.
 
Some Example Launch Options lines:

`"C:\Program Files (x86)\Steam\steamapps\common\Terraria\terraria-redir.exe" %command% --depotspath "T:\Software\Terraria Anthology" --version v1.1.2`
 - This would attempt to load `T:\Software\Terraria Anthology\Terraria-v1.1.2\Terraria.exe` 

`"G:\Games\Steam\steamapps\common\Terraria\terraria-redir.exe" %command% --depotspath "G:\Games\TerrariaDepots" --version 1.0.6.1 --logging`
 - This would attempt to load `G:\Games\TerrariaDepots\Terraria-v1.0.6.1\Terraria.exe`

`"C:\Program Files (x86)\Steam\steamapps\common\Terraria\terraria-redir.exe" %command% --version v1.0.6.1-Undeluxe`
 - This would attempt to load `C:\Program Files (x86)\Steam\steamapps\common\Terraria-v1.0.6.1-Undeluxe\Terraria.exe`
 
`"C:\Program Files (x86)\Steam\steamapps\common\Terraria\terraria-redir.exe" %command%`
 - This would open the GUI and assume your depot folders are at `C:\Program Files (x86)\Steam\steamapps\common`
##
 
