#!/bin/sh

extract_targets() {
	temp_script="/tmp/parse_package.swift"
	cat >"$temp_script" <<'EOF'
import Foundation

guard let packageContent = try? String(contentsOfFile: "Package.swift", encoding: .utf8) else {
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

for target in targets {
    print(target)
}
EOF

	swift "$temp_script"
	rm "$temp_script"
}
