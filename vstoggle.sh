#!/usr/bin/env bash
# Script to enable and disable V-Sync on intel GPU for current user
# v:1.6 2021-11-05

if (( BASH_VERSINFO[0] < 4 )); then
    printf "%s %s\n" "Bash 4 or higher currently required."
    exit 1
fi

scriptname='vstoggle'
scriptver='1.6'

usage() {
	cat <<EOF
$scriptname v:$scriptver

A simple script to enable and disable V-Sync on intel GPU for current user.

Usage: $scriptname [ -s | -y | -n | -h | -v ]

General Options:
  -s/--status       show V-Sync status
  -y/--yes          enable V-Sync
  -n/--no           disable V-Sync
  -h/--help         this usage information
  -v/--version      display version

EOF
}

version() {
	printf "%s %s\n" "$scriptname" "$scriptver"
}

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

status() {
if [ "$vstat" -eq 1 ]
then
echo -e "${GREEN}V-Sync is currently on"
exit 0
else
echo -e "${RED}V-Sync is currently off"
exit 0
fi
}

dsn="<device screen=\"0\" driver=\"dri2\">"
vbn="<option name=\"vblank_mode\" value=\"0\"\/>"
dsy="<device screen=\"0\" driver=\"dri3\">"
vby="<option name=\"vblank_mode\" value=\"3\"\/>"

if test -f ~/.drirc; then
    if [ ! -z "$(grep "device screen=\"1\"" ~/.drirc)" ]; then
    echo "vstoggle is not currently designed to work with multiple monitors"
    exit 1
    elif [ ! -z "$(grep "option name=\"vblank_mode\" value=\"0\"" ~/.drirc)" ]; then
    vstat=0
    else
    vstat=1
    fi
else
    cat >> ~/.drirc << EOF
<driconf>
<device screen="0" driver="dri3">
<application name="Default">
<option name="vblank_mode" value="3"/>
</application>
</device>
</driconf>
EOF
    vstat=1
fi

cmd() {
    if (( USE_STATUS )); then
        status
	elif (( USE_YES )); then
		if [ "$vstat" -eq 1 ]; then
        echo -e "${YELLOW}V-Sync is already on"
        exit 1
        else
        sed -i s/"$dsn"/"$dsy"/g ~/.drirc
        sed -i s/"$vbn"/"$vby"/g ~/.drirc
        echo -e "${GREEN}V-Sync now switched on.\n${NC}Restart to apply changes."
        exit 0
        fi
	elif (( USE_NO )); then
		if [ "$vstat" -eq 1 ]
        then
        sed -i s/"$dsy"/"$dsn"/g ~/.drirc
        sed -i s/"$vby"/"$vbn"/g ~/.drirc
        echo -e "${RED}V-Sync now switched off.\n${NC}Restart to apply changes."
        exit 0
        else
        echo -e "${YELLOW}V-Sync is already off"
        exit 1
        fi
	fi
}

if [ -z "$1" ]; then
    USE_STATUS=1
    usage
    cmd
    else
    while [[ -n "$1" ]]; do
    	case "$1" in
    		-s|--status)
    			USE_STATUS=1;;
    		-y|--yes)
    			USE_YES=1;;
    		-n|--no)
    			USE_NO=1;;
    		-h|--help)
    			usage; exit 0;;
    		-v|--version)
    			version
    			exit 0 ;;
    		*)
    			usage; exit 1;;
    	esac
    	shift
    done
fi

cmd

exit 0
