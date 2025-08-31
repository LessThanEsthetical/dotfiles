#!/bin/bash

# Check if it's run by root. Don't allow root for safety
if [[ "$EUID" = 0 ]]; then
	echo -n -e "Hey, it's not a good idea to run this as a root, don't you think?\nPlease run as a normal user"
	exit 1
fi

# Check if FFmpeg is installed
if ! command -v ffmpeg 2>&1 >/dev/null
then
    echo "Please, install FFmpeg first" 
    exit 1
fi

videos=$@

# This should explain what it does
echo -n -e "This script is made to optimize raw video file(s) to suit YouTube's standards\n"

# If no files provided for script, ask for them again
if [[ $@ == "" ]]; then
	echo -n -e "You can also use this script to pass videos automatically ($0 video1.mkv video2.mkv) \n"
	read -e -p "Provide files: " videos

	# If still no video(s) provided, exit script
	if [[ $videos == "" ]]; then
		echo "Please provide files"
		exit 1
	fi
fi

# Make new folder in case if it's missing
mkdir optimized 2>/dev/null

# Process input files
for i in $videos; do
	[ -e "$i" ] || continue

	ffmpeg -i "$i" \
		-threads 16 \
		-map 0:v -map 0:a:1 \
		-c:a copy \
		-c:v libx264 -crf 18 -b:v 15M -r 60 \
		-pix_fmt yuv420p -bf 2 -profile:v high -preset veryslow -coder 1 -g 30 \
		-movflags +faststart \
		"./optimized/${i%.mkv}.mp4"; \
done

# Provide simple results
echo -e "Done converting $(find ./optimized/*.mp4 -type f | wc -l) videos."
