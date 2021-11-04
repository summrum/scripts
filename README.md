# Scripts
A collection of simple shell scripts I have created to carry out various tasks and to help me learn shell scripting. Created for, and tested using, Arch and Void GNU/Linux distributions using Bash 5.1.8. I would imagine it highly likely that these scripts contain bugs.  
  
## 1. confchange:  
A shell script to look for new and backup configuration files; should hopefully be POSIX-compliant. Files matching the following patterns are searched for:  
`*.new-*` `*.new` `*.NEW` `*.old-*` `*.old` `*.OLD` `*.bak` `*.pacnew` `*.pacorig` `*.pacsave` `*.pacsave.[0-9]*`  
Files are opened in editor for comparison with original/new version(s) using sudoedit. Please be aware that this script requires sudo to run; whilst it works for me, and I have had no issues with it, I highly recommend you read the code fully before using a script from a random person on the internet and giving it sudo rights.  
### Usage: 
```
confchange [ -e <editor> ] [ -p <path> ] [ -h | -v ]  
```
### Options: 
 - `-e/--editor <editor>` Change editor from default (set as Meld https://github.com/GNOME/meld as that works for me) to `<editor>`. Change `$editor` in script to change the default permanently. Incorrect program name selection will default to environment variable `$EDITOR`  
 - `-p/--path <path>` Change path(s) from default (`/boot /etc /usr /var`) to `<path>`. Change `$path` in script to change the default permanently. `/var/log` is ignored   
  - `-h/--help` Display usage information  
  - `-v/--version` Display version
  
## 2. picrename:  
A Bash script to rename files in given path matching given pattern to date+time and recode any video files of chosen format(s) to selected preset. Video recoding requires handbrake-cli (https://handbrake.fr/). Designed to unify names of pictures and videos taken across various devices.  
### Usage:  
```
picrename [ -f <filepattern> ] [ -p <path> ]  [ -P <preset> ] [ -V <video> ] [ -C <container> ]  [ -h | -v ]  
```
### Options:  
 - `-f/--file <filepattern>` Temporarily change file pattern from default (`DSCN|IMG|WA`) to `<filepattern>`  
 - `-p/--path <path>` Temporarily change path(s) from default (`$HOME/Pictures`) to `<path>`  
 - `-P/--preset <preset>` Temporarily change handbrake-cli recoding preset from default (`H.264 MKV 1080p30`) to `<preset>`  
 - `-V/--video <video>` Temporarily change video file types searched for from default (`*.mov`) to `<video>`  
 - `-C/--container <container>` Temporarily change container for recoded video files from default (`mkv`) to `<container>`   
 - `-d/--defaults` Permanently change the saved defaults for the current user with the environment variable `$EDITOR`
 - `-h/--help` Display usage information  
 - `-v/--version` Display version  

## 3. vstoggle:  
A Bash script to enable and disable V-Sync on intel GPU for current user; works by creating ~/.drirc file (if not already present) and setting vblank_mode=0 (see https://wiki.archlinux.org/title/Intel_graphics#Disable_Vertical_Synchronization_(VSYNC)). Turning vsync on sets vblank_mode=3. Not tested with multi-monitor setups and will exit if simple check for second screen in .drirc found. Also not really designed for those with a complex .drirc file - backup your ~/.drirc before usage. Improvements to come after further testing...    
### Usage: 
```
vstoggle [ -s | -y | -n | -h | -v ]  
```
### Options:  
 - `-s/--status` Show V-Sync status  
 - `-y/--yes` Enable V-Sync  
 - `-n/--no` Disable V-Sync  
 - `-h/--help` Display usage information  
 - `-v/--version` Display version
  
  ## 4. birthday:  
A Bash script to look at the age of the root installation. Date style set by -s (or --style) option will be remembered for subsequent runs so doesn't need re-setting (only for changing).    
### Usage: 
```
birthday [ -s <style> | -h | -v ]  
```
### Options:   
 - `-s/--style <style>` Set date style for report to `<style>` (in the format `DMY`, `YMD`, `MDY`, `YDM` etc.)  
 - `-h/--help` Display usage information  
 - `-v/--version` Display version  
