#!/bin/sh

create_index_html() {
	if [ -z "$OUTPUT_PATH" ]; then
		echo "OUTPUT_PATH is not set. Please set it before calling create_main_index."
		return 1
	fi

	echo "<!DOCTYPE html>
<html>
<head>
    <title>Documentation Index</title>
</head>
<body>
    <h1>Documentation Index</h1>
    <ul>" >"${OUTPUT_PATH}/index.html"

	# List all targets in the OUTPUT_PATH directory
	for target in $(ls "${OUTPUT_PATH}"); do
		# Skip if not a directory
		if [ -d "${OUTPUT_PATH}/${target}" ]; then
			echo "        <li><a href=\"./${target}/index.html\">${target}</a></li>" >>"${OUTPUT_PATH}/index.html"
		fi
	done

	echo "    </ul>
</body>
</html>" >>"${OUTPUT_PATH}/index.html"
}
