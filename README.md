# Scripts
A collection of simple scripts I have created to carry out various tedious tasks:

- **vstoggle**: A Bash script to enable and disable V-Sync on intel GPU for current user  
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
