#!/usr/bin/env bash

_shshare_completions() {
	local cur="${COMP_WORDS[$COMP_CWORD]}"
	local prev="${COMP_WORDS[$COMP_CWORD - 1]}"
	local root_words="
		shshare
		--stop-screencast"
	local args="
		-t --type
		-s --selection
		-d --destination
		--stop-screencast"
	local types="
		screenshot
		screencast"
	local selections="
		region
		focused
		full"
	local destinations="
		clipboard
		upload"

	case $prev in
		shshare)
			COMPREPLY=($(compgen -W "$args" -- "$cur"))
			return 0;
			;;
		-t|--type)
			COMPREPLY=($(compgen -W "$types" -- "$cur"))
			return 0;
			;;
		-s|--selection)
			COMPREPLY=($(compgen -W "$selections" -- "$cur"))
			return 0;
			;;
		-d|--destination)
			COMPREPLY=($(compgen -W "$destinations" -- "$cur"))
			return 0;
			;;
	esac
}

complete -F _shshare_completions shshare
