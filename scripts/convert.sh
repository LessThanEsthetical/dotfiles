#!/bin/bash

# This script made to "modernize" old videos recorded with digital camera
# Just put it with videos at same directory and run

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

shopt -s nocaseglob

mkdir ./new 2>/dev/null

for i in *.{mpg,avi,vob,mov,mp4}; do 
	[ -e "$i" ] || continue

	# Get sample rate and bitrate of audio streams
	# And get framerate
	read -d '' -r -a audio_info <<< $(ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate,codec_name,channels -of default=noprint_wrappers=1:nokey=1 "$i")
	read framerate <<< $(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 "$i")	

	# If audio isn't aligns wtih any of these, re-encode
	if [[ "${audio_info[0]}" == aac ]] && [[ "${audio_info[2]}" -eq 2 ]]; then
		audio_set="-c:a copy"
	else
		if [[ "${audio_info[1]}" -ge 44100 ]]; then	
			audio_set="-c:a aac -b:a 192k -ar ${audio_info[1]} -ac 2"
		else
			audio_set="-c:a aac -b:a 192k -ar 44100 -ac 2"
		fi
	fi
	
	# Make framerate stable 30 or 60fps
	if [[ "$framerate" == "30000/1001" ]]; then
		frames=",fps=fps=30"
	elif [[ "$framerate" == "60000/1001" ]]; then
		frames=",fps=fps=60"
	else
		frames=""
	fi

	# Actual operation
	ffmpeg -hide_banner -i "$i" \
		-movflags +faststart \
		-c:v libx264 -profile:v High -crf 23 -preset veryslow \
		-vf "yadif$frames" -pix_fmt yuv420p -color_range pc -color_primaries bt709 -color_trc bt709 -colorspace bt709 \
		$audio_set \
		-threads 16 \
		-y "./new/${i%.*}.mp4"; \
done

shopt -u nocaseglob

# Inform of results
echo ""
echo "Done converting $(find ./new -type f | wc -l) out of $(find ./ -type f | wc -l) files."
