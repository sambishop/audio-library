#!/bin/bash

set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ffmpeg="$script_dir/ffmpeg.exe"

function compress_flac {
	local f="$1"
	local dst="$2"
	local w_input=$(cygpath --absolute --windows "$f")
	local w_output=$(cygpath --absolute --windows "$dst/${f/.flac/.ogg}")
	$ffmpeg -y -hide_banner -loglevel panic -i "$w_input" -ac 1 "$w_output"
}

function compress_directory {
	local src="$1"
	local dst="$2"
	cd "$src"
	echo push to $(pwd)
	[ -e "$dst" ] || mkdir "$dst"
	if [ -e .uncompressed ]; then
		echo Performing a recursive copy of an uncompressed directory
		cp -R * "$dst"
	else
		local f
		for f in *; do
			if [ -d "$f" ]; then
				compress_directory "$src/$f" "$dst/$f"
			elif [ -f "$f" ] && [[ "$f" == *.flac ]]; then
				echo $f
				compress_flac "$f" "$dst"
			else
				echo "Unhandled file: $f"
			fi
		done
	fi
	cd ..
	echo pop to $(pwd)
}

if [ "$#" -ne 1 ] || [[ "$1" != ripped/* ]]; then
	echo "Usage: $0 ripped/<folder>" > /dev/stderr
	exit 1
fi

if [ ! -e "$1" ]; then
	echo "No such file or directory: $1" > /dev/stderr
	exit 1
fi

src="$(readlink -v -e "$1")"
dst="$(readlink -v -f "${1/ripped/compressed}")"

compress_directory "$src" "$dst"

