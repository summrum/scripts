#!/bin/bash
# Script to look at the age of the root installation
# v:1.0 2021-10-25

scriptname='birthday'
scriptver='1.0'

usage() {
	cat <<EOF
$scriptname v:$scriptver

A simple script to look at the age of the root installation.

Usage: $scriptname [ -h | -v ]

General Options:
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

cmd () {
echo "Root installation created on $BIRTH_3/$BIRTH_2/$BIRTH_1; the operating system is $REPORT."
}

if [ -z "$1" ]; then
    cmd
    else
    while [[ -n "$1" ]]; do
    	case "$1" in
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

exit 0
