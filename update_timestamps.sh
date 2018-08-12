#!/bin/bash

# The MP3 player lists folders by their modification times.  So in order to get
# the listed order to be alphabetical, the modification times are updated in
# alphabetical order.

set -e

function update_directory {
	cd "$1"
	for f in *; do
		if [ -d "$f" ]; then
			sleep .1
			echo "Updating access and modification times of $f"
			touch "$f"
			update_directory "$f"
		fi
	done
	cd ..
}

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <MP3 Audiobook root>" > /dev/stderr
	exit 1
fi

update_directory "$1"

