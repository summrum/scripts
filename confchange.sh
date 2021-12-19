#! /bin/sh
# Script to find new configuration files and open to compare with originals; designed for use in Void and Arch GNU/Linux distributions.
# v:1.6 2021-12-19

scriptname='confchange'
scriptver='1.6'

usage() {
	cat <<EOF
$scriptname v:$scriptver

A simple script to look for new configuration files in Void and Arch GNU/Linux distributions.
Configuration of default editor used for file comparison and/or path(s) to search can be set in /etc/confchange.conf.

Usage: $scriptname [ -e <editor> ] [ -p <path> ] [ -d | -h | -v ]

Variables:
  -e/--editor       temporarily change editor from default
  -p/--path         temporarily change path(s) from default (/boot /etc /usr /var excluding /var/log)

General Options:
  -d/--defaults     permanently change defaults (/etc/confchange.conf file edited with $EDITOR)
  -h/--help         this usage information
  -v/--version      display version

EOF
}

version() {
	printf "%s %s\n" "$scriptname" "$scriptver"
}

if test -f /etc/confchange.conf; then
    [ -r /etc/confchange.conf ] && . /etc/confchange.conf
else
    touch /etc/confchange.conf  > /dev/null 2>&1 && cat >> /etc/confchange.conf << EOF
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

sudo_test() {
if [ ! -x /usr/bin/sudo ] ; then
    printf "%s %s\n" "confchange requires sudo to be installed for this function"
    exit 1
fi
}

main() {
# Find configuration files matching patterns given; change to add/remove naming patterns
confdiff=$(find $path -not \( -path /var/log -prune \) \( -name \*.new-\* -o -name \*.new -o -name \*.NEW -o -name \*.old-\* -o -name \*.old -o -name \*.OLD -o -name \*.bak -o -name \*- -o -name \*.pacnew -o -name \*.pacorig -o -name \*.pacsave -o -name '*.pacsave.[0-9]*' \) 2>/dev/null)

case "$confdiff" in
    "" ) printf "%s %s\n" "No new configurations found in searched directories"; exit 0 ;;
esac

for f in $confdiff; do
    case "$editor" in
        diff|colordiff) "$editor" -sy "${f%\.*}" "$f" | less &
        wait ;;
        kompare|kate) "$editor" "${f%\.*}" "$f" &
        wait ;;
        meld)   if [ -x /usr/lib/gvfs ] ; then
                    "$editor" "admin://${f%\.*}" "admin://$f" &
                    wait
                else
                    sudo_test; SUDO_EDITOR="$editor" sudo -e ${f%\.*} $f &
                    wait
                fi ;;
        *) sudo_test; SUDO_EDITOR="$editor" sudo -e ${f%\.*} $f &
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
        e) editor=$OPTARG; main ;;
        p) path=$OPTARG; main ;;
        d) sudo_test; SUDO_EDITOR="$EDITOR" sudo -e /etc/confchange.conf &
        wait
        [ -r /etc/confchange.conf ] && . /etc/confchange.conf; main ;;
        h) usage; exit 0 ;;
        v) version; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

shift "$(( OPTIND - 1 ))"

main
