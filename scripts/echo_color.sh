#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
NC="\033[0m"

echo_color() {
	color="$1"
	message="$2"
	printf "%b%s%b\n" "$color" "$message" "$NC"
}
