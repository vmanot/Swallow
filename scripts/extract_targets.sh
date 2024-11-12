#!/bin/bash

extract_targets() {
    local temp_script="/tmp/parse_package.swift"
    local package_dir="$1"
    
    # Change to the package directory if provided
    if [ -n "$package_dir" ]; then
        cd "$package_dir" || { echo "Error: Could not change to directory $package_dir" >&2; return 1; }
    fi
    
    if [ ! -f "Package.swift" ]; then
        echo "Error: Package.swift not found in current directory $(pwd)" >&2
        return 1
    fi
    
    cat > "$temp_script" << 'EOF'
import Foundation

guard let packageContent = try? String(contentsOfFile: "Package.swift", encoding: .utf8) else {
    print("Error: Could not read Package.swift")
    exit(1)
}

let targetPattern = #"\.target\(\s*name:\s*"([^"]+)""#
let regex = try! NSRegularExpression(pattern: targetPattern)
let range = NSRange(packageContent.startIndex..<packageContent.endIndex, in: packageContent)
let matches = regex.matches(in: packageContent, range: range)

let targets = matches.compactMap { match -> String? in
    guard let range = Range(match.range(at: 1), in: packageContent) else { return nil }
    let target = String(packageContent[range])
    return target.hasSuffix("Tests") ? nil : target
}

let uniqueTargets = Array(Set(targets)).sorted().reversed()
for target in uniqueTargets {
    print(target)
}
EOF

    if ! swift "$temp_script"; then
        echo "Error: Failed to execute Swift script" >&2
        rm "$temp_script"
        return 1
    fi
    
    rm "$temp_script"
}

# Get the package path from the first argument
PACKAGE_DIR="$1"

# Run extract_targets with the package directory
if ! TARGETS_OUTPUT=$(extract_targets "$PACKAGE_DIR"); then
    echo "Failed to extract targets" >&2
    exit 1
fi

# Convert output to array (macOS compatible way)
TARGETS=()
while IFS= read -r line; do
    if [ -n "$line" ]; then
        TARGETS+=("$line")
    fi
done <<< "$TARGETS_OUTPUT"

if [ ${#TARGETS[@]} -eq 0 ]; then
    echo "Error: No targets found in Package.swift" >&2
    exit 1
fi

echo "Found the following targets:"
printf '%s\n' "${TARGETS[@]}"

# Export the TARGETS array
export TARGETS