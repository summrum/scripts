# Scripts
A collection of simple scripts I have created to carry out various tasks. Created for, and tested using, Arch and Void GNU/Linux distributions.  
  
- **confchange**: A Bash script to look for new and backup configuration files. Files matching the following patterns are searched for:  
\*.new-\* \*.new \*.NEW \*.old-\* \*.old \*.OLD \*.bak \*.pacnew \*.pacorig \*.pacsave \*.pacsave.[0-9]*  
Files are opened in editor for comparison with original/new version(s) using sudoedit.   
Usage: confchange [ -e \<editor\> ] [ -p \<path\> ] [ -h | -v ]  
Variables:  
  -e/--editor&emsp;Change editor from default (set as Meld https://github.com/GNOME/meld as that works for me). Change $editor in script for default change. Incorrect program name will default to $EDITOR.  
  -p/--path&emsp;Change path(s) from default (/boot /etc /usr /var). Change $path in script for default change. /var/log is ignored.  
General Options:  
  -h/--help&emsp;Display usage information  
  -v/--version&emsp;Display version

- **vstoggle**: A Bash script to enable and disable V-Sync on intel GPU for current user; works by creating ~/.drirc file (if not already present) and setting vblank_mode=0 (see https://wiki.archlinux.org/title/Intel_graphics#Disable_Vertical_Synchronization_(VSYNC)). Turning vsync on sets vblank_mode=3. Not tested with multi-monitor setups and will exit if simple check for second screen in .drirc found. Also not really designed for those with a complex .drirc file - backup your ~/.drirc before usage. Improvements to come after further testing...    
Usage: vstoggle [ -s | -y | -n | -h | -v ]  
General Options:  
  -s/--status&emsp;Show V-Sync status  
  -y/--yes&emsp;Enable V-Sync  
  -n/--no&emsp;Disable V-Sync  
  -h/--help&emsp;Display usage information  
  -v/--version&emsp;Display version
