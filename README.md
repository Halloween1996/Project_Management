# what's this about?
It is my habit to move, rename, noting, delete files accordingly¡­¡­in my order. Most of them are command prompt tools, which mean No User Interface. Basically, 3 way for running them:
1. double click it with your mouse;
2. drag a file or folder to it;
3. run it in command prompt.

# why it didn't work when I just download and click it?
Well, you have to set up a configuration file for each script necessary variable initialization. I will post example for configuration file¡­¡­or not.

# What are those script about?
a.ps1 - reach out all of current directory's files, and base on its configuration file: Sort-bank.ini, search files' name characteristics, move them into the directory I want.
qu.ps1, push.ps1, i.ps1 - a set of note taking system:
- push.ps1 respond to push file to a specific folder and make a log to the specific folder note; 
- qu.ps1 respond to directing; it is Navigator between the specific folder and the those notes which representing that specific folder; 
- i.ps1 is to record whatever I wrote to the note Which representing a specific folder, with a timestamp.
Pretime.ps1 and postime.ps1 - rename the cited file, putting current date and time in front or the end of file name.
s.ps1 is for searching and opening a website or existing shortcut. Need to set up Search_Dir.ini for necessary variable initialization.