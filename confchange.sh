#! /bin/sh
# Script to find new configuration files and open to compare with originals; designed for use in Void and Arch GNU/Linux distributions.
# v:1.9 2022-02-25

scriptname='confchange'
scriptver='1.9'

usage() {
	cat <<EOF
$scriptname v:$scriptver

A simple script to look for new configuration files in Void and Arch GNU/Linux distributions.
Configuration of default editor used for file comparison and/or path(s) to search can be set in /etc/confchange.conf.

Usage: $scriptname [ -e <editor> ] [ -p <path> ] [ -d | -h | -v ]

Variables:
  -e/--editor       temporarily change editor from default ($editor)
  -p/--path         temporarily change path(s) from default ($path excluding /var/log)

General Options:
  -d/--defaults     permanently change defaults (/etc/confchange.conf file edited with $EDITOR)
  -h/--help         this usage information
  -v/--version      display version

EOF
}

version() {
	printf "%s %s\n" "$scriptname" "$scriptver"
}

sudo_test() {
if [ ! -x /usr/bin/sudo ] ; then
    printf "%s %s\n" "confchange requires sudo to be installed for this function"
    exit 1
fi
}

if test -f /etc/confchange.conf; then
    [ -r /etc/confchange.conf ] && . /etc/confchange.conf
else
	sudo_test
    sudo touch /etc/confchange.conf  > /dev/null 2>&1 && sudo tee -a /etc/confchange.conf > /dev/null << EOF
################################################################################################################
# This is the configuration file for confchange. Delete this file (/etc/confchange.conf) to reset any changes. #
# See confchange --help for further details                                                                    #
# https://github.com/summrum/scripts                                                                           #
################################################################################################################

# Set default editor for comparing files
editor=meld
# Set default path(s) for configuration files to be searched (note: /var/log is excluded by confchange)
path="/boot /etc /usr /var"
EOF
    [ -r /etc/confchange.conf ] && . /etc/confchange.conf
fi

main() {
# Find configuration files matching patterns given; change to add/remove naming patterns
confdiff=$(find $path -not \( -path /var/log -prune \) \( -name \*.new-\* -o -name \*.new -o -name \*.NEW -o -name \*.old-\* -o -name \*.old -o -name \*.OLD -o -name \*.bak -o -name \*.pacnew -o -name \*.pacorig -o -name \*.pacsave -o -name '*.pacsave.[0-9]*' \) 2>/dev/null)

case "$confdiff" in
    "" ) printf "%s %s\n" "No new configurations found in searched directories"; exit 0 ;;
esac

for f in $confdiff; do
	orig=$(echo "$f" | cut -f 1,2 -d '.')
# sudoedit not used for *diff ; column display for *diff; -d option added to *vim
    case "$editor" in
        diff|colordiff) "$editor" -sy "$orig" "$f" | less &
        wait ;;
        nvim|vim) sudo_test; SUDO_EDITOR="$editor -d" sudo -e $orig $f &
        wait ;;
        *) sudo_test; SUDO_EDITOR="$editor" sudo -e $orig $f &
        wait ;;
    esac
    if [ "$?" = "0" ] ; then
        while true; do
            printf "Delete \""$f"\"? (Y/n): "
            read -r YyNn
            case $YyNn in
            [Yy]* ) sudo_test; sudo rm "$f" && \
            printf "%s %s\n" "Deleted \""$f"\""
            break ;;
            [Nn]* ) break ;;
            *     ) printf "%s %s\n" "Answer (Y)es or (n)o" ;;
            esac
        done
    else
        printf "%s %s\n" "Cannot open file(s) in "$editor"!"
        exit 1
    fi
done

exit 0
}

for arg in "$@"; do
shift
    case "$arg" in
        "--editor")   set -- "$@" "-e" ;;
        "--path")     set -- "$@" "-p" ;;
        "--defaults") set -- "$@" "-d" ;;
        "--help")     set -- "$@" "-h" ;;
        "--version")  set -- "$@" "-v" ;;
        "--"*)        usage; exit 1 ;;
        *)            set -- "$@" "$arg" ;;
    esac
done

while getopts ":e:p:dhv" opt; do
    case $opt in
        e) editor=$OPTARG;;
        p) path=$OPTARG;;
        d) sudo_test; SUDO_EDITOR="$EDITOR" sudo -e /etc/confchange.conf &
        wait
        [ -r /etc/confchange.conf ] && . /etc/confchange.conf;;
        h) usage; exit 0 ;;
        v) version; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

shift "$(( OPTIND - 1 ))"

main
