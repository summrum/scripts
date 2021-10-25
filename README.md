# Scripts
A collection of simple scripts I have created to carry out various tasks. Created for, and tested using, Arch and Void GNU/Linux distributions. Currently contain Bashisms but I am working towards compatibility with Dash. I would imagine it highly likely that these scripts contain bugs.  
  
## 1. confchange:  
A Bash script to look for new and backup configuration files. Files matching the following patterns are searched for:  
\*.new-\* \*.new \*.NEW \*.old-\* \*.old \*.OLD \*.bak \*.pacnew \*.pacorig \*.pacsave \*.pacsave.[0-9]*  
Files are opened in editor for comparison with original/new version(s) using sudoedit. Please be aware that this script requires sudo to run; whilst it works for me, and I have had no issues with it, I highly recommend you read the code fully before using a script from a random person on the internet and giving it sudo rights.  
### Usage: 
```
confchange [ -e <editor> ] [ -p <path> ] [ -h | -v ]  
```
### Variables:  
  -e/--editor&emsp;Change editor from default (set as Meld https://github.com/GNOME/meld as that works for me). Change $editor in script for default change. Incorrect program name will default to $EDITOR.  
  -p/--path&emsp;Change path(s) from default (/boot /etc /usr /var). Change $path in script for default change. /var/log is ignored.  
### General Options:  
  -h/--help&emsp;Display usage information  
  -v/--version&emsp;Display version
  
## 2. picrename:  
A Bash script to rename files in given path matching given pattern to date+time and recode any video files of chosen format(s) to selected preset. Video recoding requires handbrake-cli (https://handbrake.fr/). Designed to unify names of pictures and videos taken across various devices.  
### Usage:  
```
picrename [ -f <filepattern> ] [ -p <path> ]  [ -P <preset> ] [ -V <video> ] [ -C <container> ]  [ -h | -v ]  
```
### Variables:  
  -f/--file&emsp;Change file pattern from default (DSCN|IMG|WA)  
  -p/--path&emsp;Change path(s) from default ($HOME/Pictures)  
  -P/--preset&emsp;Change handbrake-cli recoding preset from default (H.264 MKV 1080p30)  
  -V/--video&emsp;Change video file types searched for from default (\*.mov)  
  -C/--container&emsp;Change container for recoded video files from default (mkv)  
### General Options:  
  -h/--help&emsp;Display usage information  
  -v/--version&emsp;Display version  

## 3. vstoggle:  
A Bash script to enable and disable V-Sync on intel GPU for current user; works by creating ~/.drirc file (if not already present) and setting vblank_mode=0 (see https://wiki.archlinux.org/title/Intel_graphics#Disable_Vertical_Synchronization_(VSYNC)). Turning vsync on sets vblank_mode=3. Not tested with multi-monitor setups and will exit if simple check for second screen in .drirc found. Also not really designed for those with a complex .drirc file - backup your ~/.drirc before usage. Improvements to come after further testing...    
### Usage: 
```
vstoggle [ -s | -y | -n | -h | -v ]  
```
### General Options:  
  -s/--status&emsp;Show V-Sync status  
  -y/--yes&emsp;Enable V-Sync  
  -n/--no&emsp;Disable V-Sync  
  -h/--help&emsp;Display usage information  
  -v/--version&emsp;Display version
  
  ## 4. birthday:  
A Bash script to look at the age of the root installation.    
### Usage: 
```
birthday [ -h | -v ]  
```
### General Options:   
  -h/--help&emsp;Display usage information  
  -v/--version&emsp;Display version
