#!/bin/bash
# Script to look at the age of the root installation
# v:1.1 2021-10-26

scriptname='birthday'
scriptver='1.1'

usage() {
	cat <<EOF
$scriptname v:$scriptver

A simple script to look at the age of the root installation.

Usage: $scriptname [ -h | -v ]

General Options:
  -s/--style        set date style for report (e.g. DMY, YMD, MDY, YDM)
  -h/--help         this usage information
  -v/--version      display version

EOF
}

version() {
	printf "%s %s\n" "$scriptname" "$scriptver"
}

BIRTH=$(stat / | awk '/Birth: /{print $2}')
DATE=$(date "+%Y-%m-%d")

IFS=- read BIRTH_1 BIRTH_2 BIRTH_3 <<< "$BIRTH"
BIRTH_Y=$((10#"$BIRTH_1"))
BIRTH_M=$((10#"$BIRTH_2"))
BIRTH_D=$((10#"$BIRTH_3"))

IFS=- read DATE_1 DATE_2 DATE_3 <<< "$DATE"
DATE_Y=$((10#"$DATE_1"))
DATE_M=$((10#"$DATE_2"))
DATE_D=$((10#"$DATE_3"))

AGE_Y=$((DATE_Y-BIRTH_Y))
AGE_M=$((DATE_M-BIRTH_M))
AGE_D=$((DATE_D-BIRTH_D))

getage () {
    if (($AGE_Y > 0)); then
    echo "$AGE_Y years, $AGE_M months and $AGE_D days old"
    elif (($AGE_M > 0)); then
    echo "$AGE_M months and $AGE_D days old"
    else
    echo "$AGE_D days old"
    fi
}

REPORT=$(getage)

prefs() {
if test -f $HOME/.rumprefs; then
    [ -r $HOME/.rumprefs ] && . $HOME/.rumprefs
else
    cat >> $HOME/.rumprefs << EOF
STYLE=DMY
EOF
    [ -r $HOME/.rumprefs ] && . $HOME/.rumprefs
fi
}

cmd () {
if [ $STYLE = "DMY" ]; then
INST="$BIRTH_3/$BIRTH_2/$BIRTH_1"
elif [ $STYLE = "MDY" ]; then
INST="$BIRTH_2/$BIRTH_3/$BIRTH_1"
elif [ $STYLE = "YDM" ]; then
INST="$BIRTH_1/$BIRTH_3/$BIRTH_2"
elif [ $STYLE = "DYM" ]; then
INST="$BIRTH_3/$BIRTH_1/$BIRTH_2"
elif [ $STYLE = "YMD" ]; then
INST="$BIRTH_1/$BIRTH_2/$BIRTH_3"
elif [ $STYLE = "MYD" ]; then
INST="$BIRTH_2/$BIRTH_1/$BIRTH_3"
else
INST="$BIRTH_3/$BIRTH_2/$BIRTH_1"
fi
echo "Root installation created on $INST; the operating system is $REPORT."
}

if [ -z "$1" ]; then
    prefs; cmd; exit 0
    else
    while [[ -n "$1" ]]; do
    	case "$1" in
    		-s|--style)
                sed -i s/"STYLE=.*"/"STYLE=$2"/g $HOME/.rumprefs
                prefs; cmd; exit 0;;
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
