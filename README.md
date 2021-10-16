# Scripts
A collection of simple scripts I have created to carry out various tasks. Created for, and tested using, Arch and Void GNU/Linux distributions.

- **vstoggle**: A Bash script to enable and disable V-Sync on intel GPU for current user; works by creating ~/.drirc file and setting vblank_mode=0 (see https://wiki.archlinux.org/title/Intel_graphics#Disable_Vertical_Synchronization_(VSYNC)).  
Usage: vstoggle [ -s | -y | -n | -h | -v ]  
General Options:  
  -s/--status&emsp;Show V-Sync status  
  -y/--yes&emsp;Enable V-Sync  
  -n/--no&emsp;Disable V-Sync  
  -h/--help&emsp;Display usage information  
  -v/--version&emsp;Display version
  
- **confchange**: A Bash script to look for new configuration files.  
Usage: confchange [ -e "EDITOR" ] [ -p "PATH" ] [ -h | -v ]  
Variables:  
  -e/--editor&emsp;Change editor from default (set as Meld https://github.com/GNOME/meld). Change $editor in script for default change.  
  -p/--path&emsp;Change path(s) from default (/boot /etc /usr /var). Change $path in script for default change.  
General Options:  
  -h/--help&emsp;Display usage information  
  -v/--version&emsp;Display version
