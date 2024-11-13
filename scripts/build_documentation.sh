#!/bin/sh

build_documentation() {
	swift package resolve
	target="$1"

	# Create scheme for all targets
	create_scheme "$target"

	LOG_DIR="$WORK_DIR/build_logs"
	LOG_FILE="$LOG_DIR/${target}.log"
	mkdir -p "$LOG_DIR"

	if is_runtime_target "$target"; then
		echo_color "$YELLOW" "Using swift build for runtime target ${target}..."

		start_time=$(date +%s)
		# Enable symbol graph extraction during the build
		SWIFTPM_ENABLE_SYMBOL_GRAPH_EXTRACTION=1 \
			swift build \
			--package-path "$WORK_DIR" \
			--target "$target" >"$LOG_FILE" 2>&1

		build_status=$?
		if [ $build_status -ne 0 ]; then
			echo_color "$RED" "Build failed for ${target}"
			echo_color "$YELLOW" "Here are the last few lines of the log:"
			tail -n 20 "$LOG_FILE"
			return $build_status
		fi
		end_time=$(date +%s)
		elapsed_time=$((end_time - start_time))

		echo_color "$RED" "Time taken for swift build $(format_time $elapsed_time)"

		# Create a minimal .docc catalog in the WORK_DIR
		create_docc_catalog "$target"

		echo_color "$BLUE" "Generating documentation for ${target}..."
		INPUT_PATH="${WORK_DIR}/Sources/${target}/${target}.docc"
		HOSTING_PATH="${HOSTING_BASE_PATH}/${target}"

		start_time=$(date +%s)
		# Use docc to generate documentation
		$(xcrun --find docc) convert \
			"$INPUT_PATH" \
			--output-path "${OUTPUT_PATH}/${target}" \
			--additional-symbol-graph-dir "$WORK_DIR/.build" \
			--hosting-base-path "$HOSTING_PATH" >>"$LOG_FILE" 2>&1

		end_time=$(date +%s)
		elapsed_time=$((end_time - start_time))

		echo_color "$RED" "Time taken for docc convert $(format_time $elapsed_time)"

		return $?
	else
		echo_color "$YELLOW" "Building documentation for ${target} using xcodebuild..."

		start_time=$(date +%s)
		xcodebuild docbuild \
			-scheme "$target" \
			-derivedDataPath "${DERIVED_DATA_PATH}/${target}" \
			-destination "platform=macOS,arch=arm64" \
			OTHER_DOCC_FLAGS="--fallback-bundle-identifier ${BUNDLE_IDENTIFIER}.${target}" \
			OTHER_SWIFT_FLAGS="-Xfrontend -enable-experimental-string-processing" \
			DOCC_JSON_PRETTYPRINT=YES |
			xcbeautify >>"$LOG_FILE" 2>&1

		end_time=$(date +%s)
		elapsed_time=$((end_time - start_time))

		echo_color "$RED" "Time taken for xcodebuild $(format_time $elapsed_time)"

		build_status=$?

		if [ $build_status -ne 0 ]; then
			echo_color "$RED" "Documentation build failed for ${target}"
			echo_color "$YELLOW" "Here are the last few lines of the log:"
			tail -n 20 "$LOG_FILE"
			return $build_status
		fi

		DOCARCHIVE_PATH=$(find "${DERIVED_DATA_PATH}/${target}" -name "${target}.doccarchive" | head -n 1)

		if [ -z "$DOCARCHIVE_PATH" ]; then
			echo_color "$RED" "Could not find .doccarchive for ${target}, skipping..."
			return 1
		fi

		start_time=$(date +%s)
		echo_color "$BLUE" "Transforming documentation for ${target}..."
		$(xcrun --find docc) process-archive \
			transform-for-static-hosting "$DOCARCHIVE_PATH" \
			--output-path "${OUTPUT_PATH}/${target}" \
			--hosting-base-path "${HOSTING_BASE_PATH}/${target}"
		end_time=$(date +%s)
		elapsed_time=$((end_time - start_time))

		echo_color "$RED" "Time taken for docc process-archive $(format_time $elapsed_time)"

		check_status "Documentation transformed for ${target}"
	fi
}

create_docc_catalog() {
	target="$1"
	catalog_dir="${WORK_DIR}/Sources/${target}/${target}.docc"

	# Create the .docc directory
	mkdir -p "$catalog_dir"

	# Create an Info.plist file if it doesn't exist
	if [ ! -f "$catalog_dir/Info.plist" ]; then
		cat >"$catalog_dir/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_IDENTIFIER}.${target}</string>
    <key>CFBundleName</key>
    <string>${target}</string>
</dict>
</plist>
EOF
	fi

	# Create a minimal Overview.md if it doesn't exist
	if [ ! -f "$catalog_dir/Documentation/Overview.md" ]; then
		mkdir -p "$catalog_dir/Documentation"
		cat >"$catalog_dir/Documentation/Overview.md" <<EOF
# ${target}

Welcome to the documentation for **${target}**.

EOF
	fi
}

create_scheme() {
	mkdir -p ".swiftpm/xcode/xcshareddata/xcschemes"
	cat >".swiftpm/xcode/xcshareddata/xcschemes/${target}.xcscheme" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "${target}"
               BuildableName = "${target}"
               BlueprintName = "${target}"
               ReferencedContainer = "container:">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
</Scheme>
EOF
}

is_runtime_target() {
	start_time=$(date +%s)
	target="$1"
	case "$target" in
	"_RuntimeKeyPath" | "_RuntimeC" | "Runtime" | "Swallow")
		return 0 # true
		;;
	*)
		return 1 # false
		;;
	esac
	end_time=$(date +%s)
	elapsed_time=$((end_time - start_time))

	echo_color "$RED" "Time taken for is_runtime_target $(format_time $elapsed_time)"
}