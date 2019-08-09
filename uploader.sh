#!/bin/bash

error_exit() {
	echo "$(basename $0): ${1:-"Unknown error"}" 1>&2
	exit $2
}

case $1 in
	"image")
		response=$(curl \
			--request POST 'https://api.imgur.com/3/upload' \
			--header 'Authorization: Client-ID 151d525929b4f98' \
			--form 'image=@-')
		success=$(echo $response | jq '.success')

		if [[ $success != "true" ]]; then
			echo $response >&2
			error_exit "Imgur returned unsuccessful response" 1
		fi

		echo $response | jq --raw-output '.data.link' | xsel --clipboard
		;;
	"video")
		response=$(curl \
			--request POST 'https://api.imgur.com/3/upload' \
			--header 'Authorization: Client-ID 151d525929b4f98' \
			--form 'video=@-')
		success=$(echo $response | jq '.success')

		if [[ $success != "true" ]]; then
			echo $response >&2
			error_exit "Imgur returned unsuccessful response" 1
		fi

		echo $response | jq --raw-output '.data.link' | xsel --clipboard
		;;
	*)
		error_exit "Invalid type: $1" 1
		;;
esac

notify-send -t 1000 'shshare: Uploaded.'
