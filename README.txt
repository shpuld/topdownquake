Top-down Quake by Shpuld, 16th Feb 2021

Simple CSQC mod to give you a cool "isometric" top down perspective with intuitive controls.


Installation:
- Get FTEQW engine, no other quake engine supports the necessary features to run this mod. Get it here: http://fteqw.org/
- Put the topdownquake directory in the quake directory, so your folder structure will have both "id1" and "topdownquake" folders on the same level.
- Run the FTEQW engine with launch parameter "-game topdownquake", you can do this by creating a shortcut to the .exe and then right-click -> properties, and edit the Target line so that it's something like "<your file path>\fteglqw.exe -game topdownquake"
- The game starts in first person mode, but when you click right click (bound to command +toggletopdown by default) it will activate the top down mode, after that it will stay in top down, but holding right click will temporarily put you in first person mode if you need it to progress.
- If you need to change the key used for toggling top down mode, you use console and do something like "bind shift +toggletopdown"


If you want to run this with another mod, you can just copy the csprogs.dat file into any other mod directory (unless they have their own csprogs.dat already, then you can't). You'll have to copy the fte.cfg or bind +toggletopdown to a key manually to be able to use it)


Sources are in the src folder, under MIT license.