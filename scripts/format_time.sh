#!/bin/sh

format_time() {
	total_seconds="$1"
	minutes=$((total_seconds / 60))
	seconds=$((total_seconds % 60))
	printf "%02d minutes, %02d seconds" "$minutes" "$seconds"
}
