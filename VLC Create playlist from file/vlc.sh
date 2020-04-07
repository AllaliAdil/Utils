#!/bin/bash

shopt -s extglob
extensions='@(avi|mp4|mkv|m4v|mov|mpg|mpeg|wmv|ogg|flac|m4a|mp3|wav|3gp)'  # list of extensions for searching in current directory

# kill other instances of vlc to keep playlist clean (one-instance mode)
killall vlc; sleep 0.1

# launch empty vlc if no argument provided
if [ -z "$1" ]; then
	vlc; exit
fi

# parse argument
filename=$(realpath -- "$1")
dirname=$(dirname "$filename")
basename=$(basename "$filename")

# count files with matching extension, and get position of filename in current directory
n=$(ls "${dirname}"/*.${extensions} -1 2>/dev/null | wc -l)
pos=$(ls "${dirname}"/*.${extensions} -1 2>/dev/null | grep -n -F -- "${basename}" | cut -d: -f1)

# if the filename does not have one of the extension above, launch vlc with provided filename
if [ -z "$pos" ]; then
	vlc -- "${filename}"
	exit
fi

# change positions in playlist such as the first element is the opened file
ls "${dirname}"/*.${extensions} -1 | tail -n$(($n-$pos+1)) >  /tmp/vlc.m3u
ls "${dirname}"/*.${extensions} -1 | head -n$(($pos-1))    >> /tmp/vlc.m3u

# launch playlist
ARGS=""
NB=$(( $n - $(ls "${dirname}"/*.${extensions} -1 | grep -e '\.mkv' -e '\.mp4' | wc -l) ))
if [ "$NB" -ge 15 ]; then
	ARGS="--no-play-and-pause"
fi

IFS=$'\n'; read -d '' -r -a files < /tmp/vlc.m3u; vlc $ARGS "${files[@]}"
