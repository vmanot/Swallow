#!/bin/sh
echo_color() {
	color="$1"
	message="$2"
	printf "%b%s%b\n" "$color" "$message" "$NC"
}
