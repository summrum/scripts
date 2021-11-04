#!/usr/bin/env bash
# Script to look at the age of the root installation
# v:1.3 2021-11-01

scriptname='birthday'
scriptver='1.3'

usage() {
	cat <<EOF
$scriptname v:$scriptver

A simple script to look at the age of the root installation.
Date style currently set as $STYLE ($STYLE_F).

Usage: $scriptname [ -s <style> | -h | -v ]

Variables:
  -s/--style        set date style for report (e.g. DMY, YMD, MDY, YDM)

General Options:
  -h/--help         this usage information
  -v/--version      display version

EOF
}

version() {
	printf "%s %s\n" "$scriptname" "$scriptver"
}

BIRTH=$(LANG=C stat / | awk '/Birth: /{print $2}')
case "$BIRTH" in
    *2* ) DATE=$(date "+%Y-%m-%d"); BIRTH_S=$(date -d "$BIRTH" "+%s"); DATE_S=$(date "+%s") ;;
    * ) echo "Birth not recorded for root partition"; exit 1 ;;
esac

AGE_S=$((DATE_S-BIRTH_S))
AGE_D=$((AGE_S / 86400))
AGE_M=$((AGE_S / 2629800))
AGE_Y=$((AGE_S / 31557600))

IFS=- read BIRTH_1 BIRTH_2 BIRTH_3 <<< "$BIRTH"
BIRTH_Y=$((10#"$BIRTH_1"))
BIRTH_M=$((10#"$BIRTH_2"))
BIRTH_D=$((10#"$BIRTH_3"))

IFS=- read DATE_1 DATE_2 DATE_3 <<< "$DATE"
DATE_M=$((10#"$DATE_2"))
DATE_D=$((10#"$DATE_3"))

getage () { #FIXME
    if ((AGE_Y >= 1)); then
        if ((DATE_M == BIRTH_M)) && ((DATE_D == BIRTH_D)); then
        echo "exactly $AGE_Y years old today - Happy Birthday!"
        else
        echo "$AGE_Y years old."
        fi
    elif ((AGE_M >= 1)); then
    echo "$AGE_M months old."
    else
    echo "$AGE_D days old."
    fi
}

confmake() {
if test -f $HOME/.rumprefs/birthday; then
    [ -r $HOME/.rumprefs/birthday ] && . $HOME/.rumprefs/birthday
else
    mkdir -p $HOME/.rumprefs
    cat >> $HOME/.rumprefs/birthday << EOF
STYLE=DMY
EOF
    [ -r $HOME/.rumprefs/birthday ] && . $HOME/.rumprefs/birthday
fi
}

prefs() {
confmake
if [ $STYLE = "DMY" ]; then
STYLE_F="day/month/year"
elif [ $STYLE = "MDY" ]; then
STYLE_F="month/day/year"
elif [ $STYLE = "YDM" ]; then
STYLE_F="year/day/month"
elif [ $STYLE = "DYM" ]; then
STYLE_F="day/year/month"
elif [ $STYLE = "YMD" ]; then
STYLE_F="year/month/day"
elif [ $STYLE = "MYD" ]; then
STYLE_F="month/year/day"
else
STYLE_F="defaulting to day/month/year"
STYLE="unrecognised format"
fi
}

if
lsb_release -i > /dev/null; then
OSNAME=$(lsb_release -i | sed 's/Linux//g; s/linux//g; s/Distributor//g; s/ID://g' | sed 's/.*/\u&/' | xargs)
elif
cat /etc/*-release > /dev/null; then
OSNAME=$(cat /etc/*-release | grep DISTRIB_ID | sed 's/Linux//g; s/linux//g; s/"//g; s/DISTRIB_ID//g; s/=//g' | sed 's/.*/\u&/')
else
OSNAME="Unknown"
fi

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
echo "$OSNAME installation created on $INST; the operating system is $(getage)"
}

if [ -z "$1" ]; then
    prefs; cmd; exit 0
    else
    while [[ -n "$1" ]]; do
    	case "$1" in
    		-s|--style)
                confmake
                sed -i s/"STYLE=.*"/"STYLE=$2"/g $HOME/.rumprefs/birthday
                prefs; cmd; exit 0;;
    		-h|--help)
    			prefs; usage; exit 0;;
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
