#!/bin/sh

check_status() {
	if [ $? -eq 0 ]; then
		echo_color "$GREEN" "✓ $1"
	else
		echo_color "$RED" "✗ $1"
		return 1
	fi
}
