#!/bin/sh

setup_work_directory() {
	start_time=$(date +%s)
	echo_color "$RED" "Setting up work directory..."

	# Clean and prepare directories
	rm -rf "$DERIVED_DATA_PATH"
	rm -rf "$OUTPUT_PATH"
	mkdir -p "$OUTPUT_PATH"

	# Remove old work directory if it exists
	if [ -d "$WORK_DIR" ]; then
		rm -rf "$WORK_DIR"
	fi

	# Create new work directory
	mkdir -p "$WORK_DIR"

	# Copy entire project structure
	cp -R ./ "$WORK_DIR/"

	# Remove any build artifacts from the copy
	rm -rf "$WORK_DIR"/.build
	rm -rf "$WORK_DIR"/.swiftpm/xcode
	find "$WORK_DIR" -name ".DS_Store" -delete
	end_time=$(date +%s)
	elapsed_time=$((end_time - start_time))

	echo_color "$RED" "Time taken for removing build artifacts: $(format_time $elapsed_time)"
}
