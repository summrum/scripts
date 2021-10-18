#!/bin/bash
# Script to rename files in given path matching given pattern to date+time and recode any video files of chosen format(s) to selected preset
# v.4.5 2021-10-18

scriptname='picrename'
scriptver='4.5'

usage() {
	cat <<EOF
$scriptname v:$scriptver

A simple script to rename files in given path matching given pattern to date+time and recode any video files of chosen format(s) to selected preset. Video recoding required handbrake-cli (https://handbrake.fr/).

Usage: $scriptname [ -f <filepattern> ] [ -p <path> ]  [ -P <preset> ] [ -V <video> ] [ -C <container> ]  [ -h | -v ]

Variables:
  -f/--file         change editor from default
  -p/--path         change path(s) from default ($HOME/Pictures)
  -P/--preset       change handbrake-cli recoding preset from default (H.264 MKV 1080p30)
  -V/--video        change video file types searched for from default (*.mov)
  -C/--container    change container for recoded video files from default (mkv)

General Options:
  -h/--help         this usage information
  -v/--version      display version

EOF
}

version() {
	printf "%s %s\n" "$scriptname" "$scriptver"
}

# Select path to file(s) here
path="$HOME/Pictures"
# Select default file name pattern to search for here
filepattern="DSCN|IMG|WA"
# Select video format(s) for recoding here
video="*.mov"
# Select video output format here
preset="H.264 MKV 1080p30"
# Select video output container here
container="mkv"

error_exit() {
    echo "$1" 1>&2
    exit 1
}

for arg in "$@"; do
shift
    case "$arg" in
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

while getopts ":f:p:C:P:V:hv" opt; do
    case $opt in
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
    echo "No files to rename"
    exit 0
fi

logdate=$(date +%Y%m%d_%H%M%S)
echo "Path = "$path"" >> "$path"/rename_log_"$logdate"
echo "Pattern searched for = "$filepattern"" >> "$path"/rename_log_"$logdate"
echo "Video file extension(s) recoded ="$video"" >> "$path"/rename_log_"$logdate"
echo "Video output format = "$preset" in "$container" container" >> "$path"/rename_log_"$logdate"
echo >> "$path"/rename_log_"$logdate"

start=$(date "+%H:%M %a %d %B %Y")

for f in $rename; do
    find "$f" -type f -print0 | xargs -0 chmod 644
    fp=$(dirname "$f") 
    fe="$(tr '[:upper:]' '[:lower:]' <<<"${f##*.}")"
    fx=$(date -r "$f" +%Y%m%d_%H%M%S)
    if test -f "$fp"/"$fx"."$fe"; then
    echo "Cannot rename found file "$f" as "$fp"/"$fx"."$fe" already exists!" 
    echo "Cannot rename found file "$f" as "$fp"/"$fx"."$fe" already exists!" >> "$path"/rename_log_"$logdate"
    else
        mv -n "$f" "$fp"/"$fx"."$fe"
        if [ "$?" = "0" ]; then
        echo "Renamed "$f" to "$fp"/"$fx"."$fe"" >> "$path"/rename_log_"$logdate"
        else
        echo "Cannot rename found "$filepattern" file(s)!" >> "$path"/rename_log_"$logdate"
        error_exit "Cannot rename found "$filepattern" file(s)!"
        fi
    fi
done

movs=$(find "$path" -name "$video")
if [[ -z "$movs" ]]; then 
    echo >> "$path"/rename_log_"$logdate"
    echo "No files to recode" >> "$path"/rename_log_"$logdate"
fi

for m in $movs; do
    mn=$(basename "$m" "${m##*.}")
    HandBrakeCLI -i "$m" -o "$fp"/"$mn""$container" --preset="$preset" | tee -a "$path"/rename_log_"$logdate"
    vidcheck=$(find "$path" -name "$mn""$container")    
    if [[ -n "$vidcheck" ]]; then
        rm "$m"
        echo >> "$path"/rename_log_"$logdate"
        echo "Recoded "$m" to "$fp"/"$mn""$container"" >> "$path"/rename_log_"$logdate"
        elif [ "$?" = "0" ]; then
        echo "Recode loop started, no error reported by HandBrakeCLI, but no recoded file(s) found!" >> "$path"/rename_log_"$logdate"
        error_exit "Recode loop started, no error reported by HandBrakeCLI, but no recoded file(s) found!"          
        else
        echo "Cannot recode found "$video" file(s)!" >> "$path"/rename_log_"$logdate"
        error_exit "Cannot recode found "$video" file(s)!"       
    fi
done
echo

end=$(date "+%H:%M %a %d %B %Y")

if test -f "$path"/rename_log_"$logdate"; then
    cat "$path"/rename_log_"$logdate" | grep 'Renamed\|Recoded\|No files to recode'
    echo
    echo >> "$path"/rename_log_"$logdate"
    echo "Started at $start, finished at $end" >> "$path"/rename_log_"$logdate"
    while true; do
        read -p "Delete log file? (Y/n): " Yn
        case $Yn in
        # Delete log file if answered y
        [Yy]* ) rm "$path"/rename_log_"$logdate" && \
        echo "Deleted log file"
                break                         ;;
        [Nn]* ) break                         ;;
        *     ) echo "Answer (Y)es or (n)o." ;;
        esac
    done
fi
echo

echo "Started at $start, finished at $end"

exit 0
