#! /bin/sh
# Script to find new configurations and open to compare with originals
# v:1.3 2021-11-04

scriptname='confchange'
scriptver='1.3'

usage() {
	cat <<EOF
$scriptname v:$scriptver

A simple script to look for new configuration files.

Usage: $scriptname [ -e <editor> ] [ -p <path> ] [ -h | -v ]

Variables:
  -e/--editor       change editor from default
  -p/--path         change path(s) from default (/boot /etc /usr /var)

General Options:
  -h/--help         this usage information
  -v/--version      display version

EOF
}

version() {
	printf "%s %s\n" "$scriptname" "$scriptver"
}

# Set editor for comparing files; change this to default editor of choice
editor=meld
# Set path(s) for configuration files to be searched; change to default path(s) of choice
path="/boot /etc /usr /var"

for arg in "$@"; do
shift
    case "$arg" in
        "--editor")  set -- "$@" "-e" ;;
        "--path")    set -- "$@" "-p" ;;
        "--help")    set -- "$@" "-h" ;;
        "--version") set -- "$@" "-v" ;;
        "--"*)       usage; exit 1 ;;
        *)           set -- "$@" "$arg" ;;
    esac
done

while getopts ":e:p:hv" opt; do
    case $opt in
        e) editor=$OPTARG ;;
        p) path=$OPTARG ;;
        h) usage; exit 0 ;;
        v) version; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

shift "$(( OPTIND - 1 ))"

# Find configuration files matching patterns given; change to add/remove naming patterns
confdiff=$(sudo find $path -not \( -path /var/log -prune \) \( -name \*.new-\* -o -name \*.new -o -name \*.NEW -o -name \*.old-\* -o -name \*.old -o -name \*.OLD -o -name \*.bak -o -name \*.pacnew -o -name \*.pacorig -o -name \*.pacsave -o -name '*.pacsave.[0-9]*' \))

case "$confdiff" in
    "" ) printf "%s %s\n" "No new configurations found in searched directories"; exit 0 ;;
esac

for f in $confdiff; do
    SUDO_EDITOR="$editor" sudo -e ${f%\.*} $f &
    wait
    if [ "$?" = "0" ]; then
        while true; do
            printf "Delete \""$f"\"? (Y/n): "
            read -r YyNn
            case $YyNn in
            [Yy]* ) sudo rm "$f" && \
            printf "%s %s\n" "Deleted \""$f"\""
            break ;;
            [Nn]* ) break ;;
            *     ) printf "%s %s\n" "Answer (Y)es or (n)o" ;;
            esac
        done
    else
        printf "%s %s\n" "Cannot open file(s) in editor!"
        exit 1
    fi
done

exit 0
