#!/bin/bash

case $1 in
	"image")
		response=$(curl \
			--request POST 'https://api.imgur.com/3/upload' \
			--header 'Authorization: Client-ID 151d525929b4f98' \
			--form 'image=@-')
		success=$(echo $response | jq '.success')

		if [[ $success != "true" ]]; then
			echo "Imgur returned unsuccessful response:" >&2
			echo $response >&2
		fi

		echo $response | jq --raw-output '.data.link' | xsel --clipboard
		;;
	"video")
		response=$(curl \
			--request POST 'https://api.imgur.com/3/upload' \
			--header 'Authorization: Client-ID 151d525929b4f98' \
			--form 'video=@-')
		success=$(echo $response | jq '.success')

		echo $response

		if [[ $success != "true" ]]; then
			echo "Imgur returned unsuccessful response:" >&2
			echo $response >&2
		fi

		echo $response | jq --raw-output '.data.link' | xsel --clipboard
		;;
	"file")
		curl https://0x0.st --form 'file=@-' | xsel --clipboard
		;;
	*)
		echo "Invalid type: $1" 2>&1
		exit 1
		;;
esac

notify-send -t 1000 'Uploaded.' -i '/usr/share/icons/Arc/apps/symbolic/applets-screenshooter-symbolic.svg'
