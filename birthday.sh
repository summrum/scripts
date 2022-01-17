#!/usr/bin/env bash
# Script to look at the age of the root installation
# v:2.0 2022-01-17

if (( BASH_VERSINFO[0] < 4 )); then
    printf "%s %s\n" "Bash 4 or higher currently required."
    exit 1
fi

scriptname='birthday'
scriptver='2.0'

usage() {
	cat <<EOF
$scriptname v:$scriptver

A simple script to look at the age of the root installation.
Date style currently set as $style ($style_f).

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

birth=$(LANG=C stat / | awk '/Birth: /{print $2}' | xargs)

case "$birth" in
    *2* ) birth_s=$(date -d "$birth" "+%s"); date_s=$(date "+%s");;
    * ) printf "%s %s\n" "Birth not recorded for root partition"; exit 1 ;;
esac

unset current_IFS
[ -n "${IFS+current}" ] && current_IFS=$IFS
IFS=- read date_1 date_2 date_3 <<< "$(date "+%Y-%m-%d")"
IFS=- read birth_1 birth_2 birth_3 <<< "$birth"
date_m=$((10#"$date_2"))
date_d=$((10#"$date_3"))
birth_m=$((10#"$birth_2"))
birth_d=$((10#"$birth_3"))
day_sec=86400; month_sec=2629800; year_sec=31557600
age_s=$((date_s - birth_s)); age_d=$((age_s / day_sec)); age_m=$((age_s / month_sec)); age_y=$((age_s / year_sec))
IFS=$current_IFS

getage () {
    if ((age_s >= year_sec)); then
        if ((age_y == 1)); then
            y_nom=year
        else
            y_nom=years
        fi
        if ((date_m == birth_m)) && ((date_d == birth_d)); then
            printf "%s %s\n" "exactly $age_y $y_nom old today - Happy Birthday!"
        else
        remainder_m=$((age_s - (age_y * year_sec)))
        remainder_d=$((age_s - (age_m * month_sec)))
            if ((remainder_m >= month_sec)); then
                months=$((remainder_m / month_sec))
                if ((months == 1)); then
                    m_nom=month
                else
                    m_nom=months
                fi
                remainder_d=$((remainder_m - (months * month_sec)))
                if ((remainder_d >= day_sec)); then
                    days=$((remainder_d / day_sec))
                    if ((days == 1)); then
                        d_nom=day
                    else
                        d_nom=days
                    fi
                    printf "%s %s\n" "$age_y $y_nom, $months $m_nom and $days $d_nom old."
                else
                    printf "%s %s\n" "$age_y $y_nom and $months $m_nom old."
                fi
            elif ((remainder_d >= day_sec)); then
                days=$((remainder_d / day_sec))
                if ((days == 1)); then
                    d_nom=day
                else
                    d_nom=days
                fi
                printf "%s %s\n" "$age_y $y_nom and $days $d_nom old."
            else
                printf "%s %s\n" "$age_y $y_nom old."
            fi
        fi
    elif ((age_s >= month_sec)); then
        remainder_d=$((age_s - (age_m * month_sec)))
        if ((age_m == 1)); then
            m_nom=month
        else
            m_nom=months
        fi
        if ((remainder_d >= day_sec)); then
            days=$((remainder_d / day_sec))
            if ((days == 1)); then
                d_nom=day
            else
                d_nom=days
            fi
            printf "%s %s\n" "$age_m $m_nom and $days $d_nom old."
        else
            printf "%s %s\n" "$age_m $m_nom old."
        fi
    else
    if ((age_d == 1)); then
        d_nom=day
    else
        d_nom=days
    fi
    printf "%s %s\n" "$age_d $d_nom old."
    fi
}

confmake() {
if test -f $HOME/.rumprefs/birthday; then
    if [ ! -z "$(grep "STYLE=" $HOME/.rumprefs/birthday)" ]; then
    sed -i s/"STYLE="/"style="/g $HOME/.rumprefs/birthday
    fi
    [ -r $HOME/.rumprefs/birthday ] && . $HOME/.rumprefs/birthday
else
    mkdir -p $HOME/.rumprefs
    cat >> $HOME/.rumprefs/birthday << EOF
style=DMY
EOF
    [ -r $HOME/.rumprefs/birthday ] && . $HOME/.rumprefs/birthday
fi
}

prefs() {
confmake
if [ "$style" = "DMY" ]; then
style_f="day/month/year"
elif [ "$style" = "MDY" ]; then
style_f="month/day/year"
elif [ "$style" = "YDM" ]; then
style_f="year/day/month"
elif [ "$style" = "DYM" ]; then
style_f="day/year/month"
elif [ "$style" = "YMD" ]; then
style_f="year/month/day"
elif [ "$style" = "MYD" ]; then
style_f="month/year/day"
else
style_f="defaulting to day/month/year"
style="unrecognised format"
fi
}

if
cat /etc/*-release > /dev/null; then
osname=$(cat /etc/*-release | grep -E "^ID=" | sed 's/Linux//g; s/linux//g; s/"//g; s/ID//g; s/=//g' | sed 's/.*/\u&/')
elif
lsb_release -i > /dev/null; then
osname=$(lsb_release -i | sed 's/Linux//g; s/linux//g; s/Distributor//g; s/ID://g' | sed 's/.*/\u&/' | xargs)
else
osname="Unknown"
fi

cmd () {
if [ "$style" = "DMY" ]; then
inst="$birth_3/$birth_2/$birth_1"
elif [ "$style" = "MDY" ]; then
inst="$birth_2/$birth_3/$birth_1"
elif [ "$style" = "YDM" ]; then
inst="$birth_1/$birth_3/$birth_2"
elif [ "$style" = "DYM" ]; then
inst="$birth_3/$birth_1/$birth_2"
elif [ "$style" = "YMD" ]; then
inst="$birth_1/$birth_2/$birth_3"
elif [ "$style" = "MYD" ]; then
inst="$birth_2/$birth_1/$birth_3"
else
inst="$birth_3/$birth_2/$birth_1"
fi
printf "%s %s\n" "$osname installation created on $inst; the operating system is $(getage)"
}

if [ -z "$1" ]; then
    prefs; cmd; exit 0
    else
    while [[ -n "$1" ]]; do
    	case "$1" in
    		-s|--style)
                confmake
                sed -i s/"style=.*"/"style=$2"/g $HOME/.rumprefs/birthday
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
