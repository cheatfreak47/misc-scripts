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
 - It is intended to be used with [Terraria Depot Downloader](https://github.com/RussDev7/TerrariaDepotDownloader/), which downloads and makes a folder of old Terraria versions for you. It's default behavior is to place these in the same Steam Library folder as Terraria itself, but if you decided to change the folder location in the program, you can use the `--depotspath` argument to point this script anywhere you want, as long as the subfolders for old Terraria copies are following the same naming convention.
 - Has a simple GUI for picking the 5 finalized major versions of Terraria. (Current, 1.3.5.3, 1.2.4.1, 1.1.2, and 1.0.1.6.)
 - By using the `--version` argument, you can specify which version of Terraria to run from your collection of depots at runtime, and this supports all possible versions of Terraria ever, rather than just the finalized major versions included in the GUI.
 - Choosing Current as your version makes the script operate as a passthrough to the currently installed version of Terraria.
 - Handles renaming save folders for you automatically to prevent issues with old clients crashing because of newer files, and even remembers the last version ran in the event of the game and script being terminated unexpectedly.
 - Save redirection is disabled for any version containing the text "Retro", as those versions of Terraria use their own save file folder already. (Terraria offers official means of running old Terraria's via Betas, these are called "Retro" versions internally, and if you want to set them up by copying them manually to your depots directory, then by all means.)
 - By using the `--logging` argument, you can keep a log of Terraria launches and the activity of the script.
 - All other arguments passed to the script outside of `--logging`, `--version`, and `--depotspath` are passed to the target version of Terraria, allowing you to continue to make use of [Terraria's own command-line parameters](https://terraria.wiki.gg/wiki/Command-line_parameters) if needed.
 - A lot of error handling and validation for the arguments.

Instructions:
 - Set up and use [Terraria Depot Downloader](https://github.com/RussDev7/TerrariaDepotDownloader/) to download old versions of Terraria to a folder on your computer. It does this in the same Steam Library folder as Terraria is installed by default. If you set up a different folder, make sure to make a note of the full path to that folder for later. If using the default location, after downloading all of the versions you want, make sure you launch the most recent game version to ensure the current version of Terraria is using the `/Terraria` folder.
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

`"C:\Program Files (x86)\Steam\steamapps\common\Terraria\terraria-redir.exe" %command% --version v1.0.6.1-Retro`
 - This would attempt to load `C:\Program Files (x86)\Steam\steamapps\common\Terraria-v1.0.6.1-Retro\Terraria.exe`
 
`"C:\Program Files (x86)\Steam\steamapps\common\Terraria\terraria-redir.exe" %command%`
 - This would open the GUI and assume your depot folders are at `C:\Program Files (x86)\Steam\steamapps\common`
##
### cxbxr-steam-launcher-example.ahk (AutoHotKey 1.1 Script)
This script exists for one reason:
 - I wanted to run Jet Set Radio Future from Steam without having to deal with any of that emulator's nonsense.

So I made a little editable script to help with this. If you want this, you can find details in the script itself, since you will need to customize the script to use it anyway.

Features: 
 - Easy to adapt for other games, not that CxBx runs that many too well, but still.
 - Can move the window to a desired monitor and fullscreen it for you there. (May require customization based on your monitor resolution and multimonitor layout)

##
### steam-admin-realuncher.ahk (AutoHotKey 1.1 Script)
This script exists for a few reasons:
 - Steam Remote Play cannot interact with administrator escelated programs when steam is running as a user, which can result in you accidentally getting softlocked on a remote device.
 - Steam Controller hardware handles this by switching to lizard mode, but obviously lizard mode is a compatibility feature, and still doesn't work remotely.
 - I actually *don't* want steam to always be running as administrator either, though, since it can often bother some games.
 
So I made a little script to cleanly close Steam and asks Windows (via a Scheduled Task you will have to manually set up) to launch Steam as administrator, bypassing the need for a UAC prompt, and also allows switching it to run as administrator remotely as well (although you will be disconnected by the steam relaunch, after relaunching it you can reconnect and operate as an administrator from then on.)

Features:
 - Asks Steam to close politely by sending a launch of it with `-shutdown`. Just a good thing to do rather than killing it.
 - Waits politely for steam to finish closing before trying to launch it again via the scheduled task. It does this with a counter and looping.
 - Basic error handling. If Steam takes too long to close, it just pops up an error message and quits instead.
 - Works fine if Steam isn't running too.
##
### srudb-backup-reset (AutoHotKey 1.1 Script)
This script exists for a few reasons:
 - I used to have a Data Cap with Xfinity and I wanted to make sure my own personal data usage is managed well.
 - I wanted the Data Usage database to reflect only the current calendar month.
 - Windows does not provide a means of clearing this data precisely on the last of every month, instead acting like a "this is the last 30 days of usage" sort of thing. Dumb.
 
So I made an AHK script that you can call with a scheduled task that will interrupt the service that tracks the data usage statistics, Backup and Archive the SRUDB file, and then delete it, and then restart that service, and exit.

Features:
 - Checks if it being ran as an Administrator and relaunches itself as one if needed. (Scheduled task should be set to run with highest privileges, this is more for testing the script or manual runs.)
 - Asks the service that is responsible for the file being updated to stop, and starts it again afterwards.
 - Backs up the SRUDB for you to a folder in Documents called Data Usage Statistics.
 - Backups are archived with your copy of 7-zip or 7-zip-ZStandard at LZMA2 Level 9 compression.
##
### NMS-Redir.ahk (AutoHotKey 1.1 Script)
This script exists for a few reasons:
 - I like No Man's Sky but I came into playing it so late, I missed old versions with a lot of interesting stuff that has since been removed. I wanted to check out these old versions.
 - The publicly available option for running old NMS versions, NMS Retro, at the time involved installing a Steam Emulator and cracking the SteamStub DRM on the old versions after downloading them legitimately from Steam via Steam Depot Downloader. I found this to be a bit strange, since it's completely possible to run old versions of games with DRM intact, and I know this from experience with another script I wrote to do something similar for Terraria.
 - I'm not fond of the method NMS Retro uses to redirect save files.
 - I can do it better.
 
So I did, and I even chatted up the devs at NMS Retro about the idea. Maybe they'll take this concept and run with it for a future update to NMS Retro. Who knows. All I know is, it works. This is a fork of my terraria-redir.ahk script that strips out some functionality and implements some others, but it mostly behaves the same.

It requires the user to use Depot Downloader with their legit Steam account to download the Depot Manifests for old No Man's Sky versions. Validate them, and rename the folders to conform to the naming scheme `NMS-vX.X.X`. Some example names: `NMS-v1.09.1`, `NMS-v1.24`, etc. And then move those NMS folders into your desired location. The default assumed location is your No Man's Sky Install Path in a subfolder called "Old Versions".

Some old versions may [require a mod](https://github.com/EthanRDoesMC/RetroShaderFix/releases/tag/v1.0) to work properly depending on your GPU.

It has the following features:
 - Works with clean unmodified copies of No Man's Sky. It uses the same trick as terraria-redir from this same repo, so refer to that for details.
 - Update proof.
 - Intended to be used with [Depot Downloader](https://github.com/SteamRE/DepotDownloader), a list of [Depot Manifests](https://steamdb.info/depot/275851/manifests/) and cross referencing those manifests to correspond to versions of [No Man's Sky listed on the Wiki](https://antifandom.com/nomanssky/wiki/Patch_notes).
 - Has the same functioning arguments as terraria-redir. Those being `--version`, `--logging`, and `--depotspath`, and supports the same argument passthrough functionality.
 - If `--version` is passed `Current` or is not specified, it operates as a passthrough to the live Steam version of No Man's Sky.
 - A lot of error handling and validation for arguments.
 
I'm not going to bother writing a full instruction manual for using it, but a short explaination is that you need to build it (by running the script with `--build` ideally) and then stick the `NMS-Redir.exe` in your NMS Install folder. Copy your old versions following the above mentioned naming scheme to a sub folder called `Old Versions` or wherever else on your PC you want, and then edit the launch command of Steam No Man's Sky to include the full path in quotes to `NMS-Redir.exe` followed by a space and `%command%`. Any additional commands you want can also go here, and if you used some other folder other than `Old Versions` in the install folder, then you need to use `--depotspath` to specify that. Use `--version` to choose what version of the game to run and use `--logging` if you want to keep a file record of all launches.

If you want to make desktop shortcuts to run old versions, make a shortcut to Steam and edit the launch section for the shortcut via the Properties menu to add the `-applaunch 275850` launch option and then follow that with `--version` and the version you want to boot with the shortcut. This setup expects that the Steam Launch Options for No Man's Sky is set up with no version specified.
##
### Backgrounder.ahk (AutoHotKey 1.1 Script)
This script exists for one reason:
 - My sister needed a way to batch apply background images to folders of png of a character with transparency.
 - XnView/XnConvert couldn't do it for some reason. (Add a damn z-position option to Watermark already XnSoft!)

So I helped her by throwing this together. It will use [ImageMagick](https://imagemagick.org/script/download.php#windows) which must be on PATH to composite the folder of PNGs it is ran from into a subfolder with the background you dragged onto it. It is explicitly designed to be dragged around from folder to folder and ran via windows-drag-and-drop, not from command line, and it definitely will misbehave if you attempt to put it on PATH and run it from command line.

Usage:
 - Install [ImageMagick](https://imagemagick.org/script/download.php#windows).
 - Have a folder of transparent PNGs.
 - Have a png of a background.
 - Put the script (or compiled script) in the folder of transparent PNGs.
 - Drag the desired background onto the script.
 - It will output a folder named after the background you dragged onto the script filled with the same images from the above folder with the background composited. The file names will be the original name with the background name appended.
##
### ASMRHelper.ahk (AutoHotKey 1.1 Script)
This script exists for a few reasons:
 - I wanted to download and archive a bunch of ASMR videos off YouTube because they frequently get taken down at random
 - ASMR Stream Vods frequently have a lot of dead air or BGM at the beginning and I wanted to crop this psudo-automatically
 - I use Yt-DLP to download the videos fine but it's annoying to crop them 1 by 1 via a command line
 
So I made this. I use a particular command already to pull playlists of videos and save them following a name structure, so this uses that name structure and ffmpeg and imagemagick to convert the thumbnails, bind the filename data to id3 tag metadata, and then it opens each video URL in Microsoft Edge (which I use for crap like this) and pops a text box for you to input the starting time of the actual stream, so it can crop it for you. It then moves onto the next one and repeats until you finish all the files in the folder.

This script is also known as "The Most Esoteric Bullshit Script I've Ever Made". Because it is. Nobody should use this. Not even me. In fact, it has multiple issues that I haven't bothered to solve, nor will I, because I don't care that much. Not all my scripts are winners, okay?
##