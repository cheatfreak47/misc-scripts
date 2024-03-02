# misc-scripts
misc scripts I've written to perform various tasks. each script will have a section in this readme to at least vaguely explain what it does
 
### retroarch-redir.ahk
This script exists for a few reasons:
 - I use Steam Input API almost religiously to do misc tasks while dealing with my controllers, so I want RetroArch launched with Steam Input available.
 - I dislike the Steam Version of RetroArch because it lacks the Online Updater that the mainstream builds have.
 - Steam does not allow you to run Non-Steam Games via Commandline using `steam.exe -applaunch <shortcutID>`. I wish I knew why. 
 - While it does support launching Shortcuts via the Steam Protocol URLs, this is unhelpful because you cannot pass arguments to a URL, and...
 - ...Windows does not allow you to associate a filetype with a URL, only an executable. This one makes sense, as URLs are really not designed to handle arguments anyway.
 - I've been playing a lot of Link's Awakening DX on Archipelago and that really necessitates associating `*.gbc` files with RetroArch in some way, which is obviously anti-thetical to me wanting to Steam Input on everything.

So I designed an AHK script that allows you to effectively take over the Steam Copy of RetroArch and redirect it's launch to a copy of the mainstream build of RetroArch elsewhere on your computer.

It has the following features:
 - Update Proof. By editing the "Launch Options" for the Steam Build of RetroArch to say `"C:\Program Files (x86)\Steam\steamapps\common\RetroArch\retroarch-redir.exe" %command%` you effectively are able to launch the compiled redirector with the typical command Steam uses to launch RetroArch (most likely just `retroarch.exe`) as an argument. The script simply disregards this argument entirely, since our goal is to take over RetroArch for our own uses. This makes it update proof because RetroArch updates on Steam will never overwrite our program.
 - Maintains Arguments beyond the disregarded one and passes them to the target program. This is necessary to do things like load cores and roms in retroarch, but in general it's just a good behavior for something like this.
 - Logging. This was more for my benefit in debugging but it does work properly so I left it in. Feel free to comment out all the `FileAppend` lines before compiling if you want to disable it.
 - Run multiple things based on active machine context at runtime. I use this to check if my Archipelago Client for Link's Awakening is open, and if it is, then I set up launching it's Magpie Tracker as well. Obviously all this code is unnecessary but it provides examples of how to do weird things like launching a batch file with it's own context maintained, among other things.
 
Helpful note, if you intend to use this in a similar way to me, you may need a program to easily associate steam launches with a rom file type, you can use [Ystr's Types](https://ystr.github.io/types/) to do this. Or if you're batshit you can just edit the crap manually in the Windows Registry Editor. 

An example of launching `*.gbc` roms is associating the format with the Open Command `"C:\Program Files (x86)\Steam\Steam.exe" -applaunch 1118310 -L sameboy_libretro.dll "%1"`.
 
### retroarch-redir-simplified.ahk
This script exists for a few reasons:
 - My friend wanted to take over RetroArch to allow him to Remote Play Together any program. Effectively using RetroArch as dummy program to run anything he wants.
 - My previous script seemed prime for edits to accomplish this task.
 
So I made those edits and forked my script, and removed a bunch of unnecessary stuff from the above script. It seems to work most of the time, but may need further edits should it not be as functional as it should be.

It has the following features:
 - Update Proof. See main script for details.
 - Maintains Arguments. See main script for details.
 - Logging. See main script for details.
 - More direct maintaining of program launch environment by manually setting the Working Directory of the script before launching the program, and then setting it back after the program terminates. This allows you to run games that are super sensitive to their working directory without issues (at least in theory).
 - Should be friendly to users attempting to play via Steam Remote Play. It doesn't do anything that should break it, at the very least, but in testing I think I've seen the Remote User get stuck behind a dialog that is supposed to claim the host has tabbed out of the game, even whilest it isn't.
 