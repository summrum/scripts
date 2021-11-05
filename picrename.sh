#!/usr/bin/env bash
# Script to rename files in given path matching given pattern to date+time and recode any video files of chosen format(s) to selected preset
# v.4.8 2021-11-05

if (( BASH_VERSINFO[0] < 4 )); then
    printf "%s %s\n" "Bash 4 or higher currently required."
    exit 1
fi

scriptname='picrename'
scriptver='4.8'

usage() {
	cat <<EOF
$scriptname v:$scriptver

A simple script to rename files in given path matching given pattern to date+time and recode any video files of chosen format(s) to selected preset. Video recoding requires handbrake-cli (https://handbrake.fr/).

Usage: $scriptname [ -f <filepattern> ] [ -p <path> ]  [ -P <preset> ] [ -V <video> ] [ -C <container> ]  [ -d | -h | -v ]

Variables:
  -f/--file         temporarily change file pattern from default ("$filepattern")
  -p/--path         temporarily change path(s) from default ("$path")
  -P/--preset       temporarily change handbrake-cli recoding preset from default ("$preset")
  -V/--video        temporarily change video file types searched for from default ("$video")
  -C/--container    temporarily change container for recoded video files from default ("$container")

General Options:
  -d/--defaults     permanently change defaults (preferences file edited with $EDITOR)
  -h/--help         this usage information
  -v/--version      display version

EOF
}

version() {
	printf "%s %s\n" "$scriptname" "$scriptver"
}

error_exit() {
    printf "%s %s\n" "$1" 1>&2
    exit 1
}

if test -f $HOME/.rumprefs/picrename; then
    [ -r $HOME/.rumprefs/picrename ] && . $HOME/.rumprefs/picrename
else
    mkdir -p $HOME/.rumprefs
    cat >> $HOME/.rumprefs/picrename << EOF
# picrename default variables; ensure double quotes ("") are used around options

# Select path to file(s) here
path="$HOME/Pictures/Emily_Pictures"

# Select default file name pattern to search for here
filepattern="DSCN|IMG|WA"

# Select video format(s) for recoding here
video="*.mov"

# Select video output format here
preset="H.264 MKV 1080p30"

# Select video output container here
container="mkv"
EOF
    [ -r $HOME/.rumprefs/picrename ] && . $HOME/.rumprefs/picrename
fi

for arg in "$@"; do
shift
    case "$arg" in
        "--defaults")   set -- "$@" "-d" ;;
        "--file")       set -- "$@" "-f" ;;
        "--path")       set -- "$@" "-p" ;;
        "--container")  set -- "$@" "-C" ;;
        "--preset")     set -- "$@" "-P" ;;
        "--video")      set -- "$@" "-V" ;;
        "--help")       set -- "$@" "-h" ;;
        "--version")    set -- "$@" "-v" ;;
        "--"*)          usage; exit 1 ;;
        *)              set -- "$@" "$arg" ;;
    esac
done

while getopts ":f:p:C:P:V:dhv" opt; do
    case $opt in
        d) $EDITOR $HOME/.rumprefs/picrename &
        wait
        [ -r $HOME/.rumprefs/picrename ] && . $HOME/.rumprefs/picrename ;;
        f) filepattern=$OPTARG ;;
        p) path=$OPTARG ;;
        C) container=$OPTARG ;;
        P) preset=$OPTARG ;;
        V) video=$OPTARG ;;
        h) usage; exit 0 ;;
        v) version; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

shift "$(( OPTIND - 1 ))"

rename=$(find "$path" -regextype posix-extended -regex ".*("$filepattern").*")
if [[ -z "$rename" ]]; then
    printf "%s %s\n" "No files to rename"
    exit 0
fi

logdate=$(date +%Y%m%d_%H%M%S)
printf "%s %s\n" "Path = "$path"" >> "$path"/rename_log_"$logdate"
printf "%s %s\n" "Pattern searched for = "$filepattern"" >> "$path"/rename_log_"$logdate"
printf "%s %s\n" "Video file extension(s) recoded ="$video"" >> "$path"/rename_log_"$logdate"
printf "%s %s\n" "Video output format = "$preset" in "$container" container" >> "$path"/rename_log_"$logdate"
echo >> "$path"/rename_log_"$logdate"

start=$(date "+%H:%M %a %d %B %Y")

for f in $rename; do
    find "$f" -type f -print0 | xargs -0 chmod 644
    fp=$(dirname "$f")
    fe="$(tr '[:upper:]' '[:lower:]' <<<"${f##*.}")"
    fx=$(date -r "$f" +%Y%m%d_%H%M%S)
    if test -f "$fp"/"$fx"."$fe"; then
    printf "%s %s\n" "Cannot rename found file "$f" as "$fp"/"$fx"."$fe" already exists!"
    printf "%s %s\n" "Cannot rename found file "$f" as "$fp"/"$fx"."$fe" already exists!" >> "$path"/rename_log_"$logdate"
    else
        mv -n "$f" "$fp"/"$fx"."$fe"
        if [ "$?" = "0" ]; then
        printf "%s %s\n" "Renamed "$f" to "$fp"/"$fx"."$fe"" >> "$path"/rename_log_"$logdate"
        else
        printf "%s %s\n" "Cannot rename found "$filepattern" file(s)!" >> "$path"/rename_log_"$logdate"
        error_exit "Cannot rename found "$filepattern" file(s)!"
        fi
    fi
done

movs=$(find "$path" -name "$video")
if [[ -z "$movs" ]]; then
    echo >> "$path"/rename_log_"$logdate"
    printf "%s %s\n" "No files to recode" >> "$path"/rename_log_"$logdate"
fi

for m in $movs; do
    mn=$(basename "$m" "${m##*.}")
    if command -v HandBrakeCLI >/dev/null 2>&1 ; then
        HandBrakeCLI -i "$m" -o "$fp"/"$mn""$container" --preset="$preset" | tee -a "$path"/rename_log_"$logdate"
        vidcheck=$(find "$path" -name "$mn""$container")
        else
        printf "%s %s\n" "Cannot recode found "$video" file(s), HandBrakeCLI not found!" >> "$path"/rename_log_"$logdate"
        error_exit "Cannot recode found "$video" file(s), HandBrakeCLI not found!"
    fi
    if [[ -n "$vidcheck" ]]; then
        rm "$m"
        echo >> "$path"/rename_log_"$logdate"
        printf "%s %s\n" "Recoded "$m" to "$fp"/"$mn""$container"" >> "$path"/rename_log_"$logdate"
        elif [ "$?" = "0" ]; then
        printf "%s %s\n" "Recode loop started, no error reported by HandBrakeCLI, but no recoded file(s) found!" >> "$path"/rename_log_"$logdate"
        error_exit "Recode loop started, no error reported by HandBrakeCLI, but no recoded file(s) found!"
        else
        printf "%s %s\n" "Cannot recode found "$video" file(s)!" >> "$path"/rename_log_"$logdate"
        error_exit "Cannot recode found "$video" file(s)!"
    fi
done
echo

end=$(date "+%H:%M %a %d %B %Y")

if test -f "$path"/rename_log_"$logdate"; then
    cat "$path"/rename_log_"$logdate" | grep 'Renamed\|Recoded\|No files to recode'
    echo
    echo >> "$path"/rename_log_"$logdate"
    printf "%s %s\n" "Started at $start, finished at $end" >> "$path"/rename_log_"$logdate"
    while true; do
        read -p "Delete log file? (Y/n): " Yn
        case $Yn in
        # Delete log file if answered y
        [Yy]* ) rm "$path"/rename_log_"$logdate" && \
        printf "%s %s\n" "Deleted log file"
                break                         ;;
        [Nn]* ) break                         ;;
        *     ) printf "%s %s\n" "Answer (Y)es or (n)o." ;;
        esac
    done
fi
echo

printf "%s %s\n" "Started at $start, finished at $end"

exit 0
