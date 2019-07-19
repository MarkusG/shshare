#!/bin/bash
# share screenshots or screencasts of the entire screen, a window, or a region

FFMPEG_PID=0
ARGV=("$@")

finish_screencast() {
	if [[ $FFMPEG_PID -ne 0 ]]; then
		kill -15 $FFMPEG_PID
		wait $FFMPEG_PID
		share ${ARGV[2]} < /tmp/screencast.mp4
		rm /tmp/screencast.mp4 # TODO allow preserving screenshots/casts
	fi
	exit 0
}

trap finish_screencast 10

error_exit() {
	echo "$(basename $0): ${1:-"Unknown error"}" 1>&2
}

print_usage() {
	printf "Usage:\n"
	printf "\t$(basename $0) <type> <selection> <destination>\n"
	printf "\nHelp Options:\n"
	printf "\t-h\t\t\t\tPrint this help message\n"
	printf "\nCapture types:\n"
	printf "\tscreenshot - a screenshot\n"
	printf "\tscreencast - a video recording\n" # TODO file
	printf "\nSelections:\n"
	printf "\tregion - a user-drawn region of the screen\n"
	printf "\tfocused - the currently focused window\n"
	printf "\tfull - the entire screen\n"
	printf "\nDestinations:\n"
	printf "\tclipboard - copy to the clipboard\n"
	printf "\tupload - upload using the uploader script\n"
}

share() {
	case $1 in
		"clipboard")
			if [[ ${ARGV[0]} != "screenshot" ]]; then
				echo "Cannot copy type ${ARGV[0]} to clipboard" >&2
				exit 1
			fi
			xclip -selection clipboard -target image/png
			;;
		"upload")
			case ${ARGV[0]} in
				# TODO call this from users config directory
				"screenshot")
					./upload.sh image
					;;
				"screencast")
					./upload.sh video
					;;
			esac
			;;
		*)
			if [[ -n $1 ]]; then
				error_exit "Invalid destination"
			else
				error_exit "No destination provided"
			fi
			;;
	esac
}

case $1 in
	"screenshot")
		case $2 in
			"region")
				maim --select --hidecursor | share $3
				;;
			"focused")
				maim --window=$(xdotool getactivewindow) --hidecursor | share $3
				;;
			"full")
				maim | share $3
				;;
		esac
		;;
	"screencast")
		if [[ $2 != "region" ]]; then
			echo "Unsupported screemcast selection: $2" 1>&2 # if someone wants to record their entire screen they should use OBS anyway
		fi
		region=$(slop --format="%x,%y %wx%h")
		size=$(echo $region | cut -d' ' -f 2)
		offset=$(echo $region | cut -d' ' -f 1)
		ffmpeg \
			-video_size $size \
			-framerate 60 \
			-f x11grab \
			-i :0.0+$offset \
			-pix_fmt yuv420p \
			/tmp/screencast.mp4 \
			-vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" & # pad regions who's dimensions are not divisible by 2 for x264 encoding
		FFMPEG_PID=$!
		wait $FFMPEG_PID # keep alive so we can catch SIGUSR1 when the user wants to stop the recording
		;;
	"screencast-stop")
		killall -10 $(basename $0)
		;;
	*)
		print_usage
		exit 1
		;;
esac
