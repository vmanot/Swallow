#!/usr/bin/env bash

set -o pipefail
set -u

DEFAULT_XCODE_APPS=(
    "/Applications/Xcode_16_4.app"
    "/Applications/Xcode_26_1.app"
    "/Applications/Xcode_26_2.app"
    "/Applications/Xcode_26_4_1.app"
    "/Applications/Xcode_26_5.app"
)

PLATFORM_NAMES=(
    "macOS"
    "Mac Catalyst"
    "iOS"
    "iOS Simulator"
    "tvOS"
    "tvOS Simulator"
    "watchOS"
    "watchOS Simulator"
    "visionOS"
    "visionOS Simulator"
)

PLATFORM_PACKAGE_NAMES=(
    "macos"
    "ios"
    "ios"
    "ios"
    "tvos"
    "tvos"
    "watchos"
    "watchos"
    "visionos"
    "visionos"
)

DESTINATIONS=(
    "generic/platform=macOS"
    "generic/platform=macOS,variant=Mac Catalyst"
    "generic/platform=iOS"
    "generic/platform=iOS Simulator"
    "generic/platform=tvOS"
    "generic/platform=tvOS Simulator"
    "generic/platform=watchOS"
    "generic/platform=watchOS Simulator"
    "generic/platform=visionOS"
    "generic/platform=visionOS Simulator"
)

SDKS=(
    ""
    ""
    "iphoneos"
    "iphonesimulator"
    "appletvos"
    "appletvsimulator"
    "watchos"
    "watchsimulator"
    "xros"
    "xrsimulator"
)

print_help() {
    cat <<'EOF'
Usage:
  Scripts/test-xcode-platform-matrix.sh [options] [XCODE_APP ...]

Options:
  -h, --help
      Print this help menu and exit.

  -s, --scheme SCHEME
      Build SCHEME. Defaults to the package root directory name.

  -p, --platform PLATFORM
      Build only PLATFORM. Repeat for multiple platforms.

  -x, --xcode XCODE_APP
      Build with XCODE_APP. Repeat for multiple Xcode installations.
      Positional XCODE_APP arguments are also accepted.

Platforms:
  macOS
  Mac Catalyst
  iOS
  iOS Simulator
  tvOS
  tvOS Simulator
  watchOS
  watchOS Simulator
  visionOS
  visionOS Simulator

Defaults:
  Xcode apps:
    /Applications/Xcode_16_4.app
    /Applications/Xcode_26_1.app
    /Applications/Xcode_26_2.app
    /Applications/Xcode_26_4_1.app
    /Applications/Xcode_26_5.app

Build behavior:
  - Debug configuration only.
  - build action only; clean is never run.
  - x86 slices are excluded with EXCLUDED_ARCHS=i386 x86_64.
  - ONLY_ACTIVE_ARCH=YES is set.
  - Successful xcodebuild and xcbeautify output is swallowed.
  - Failed cases print both xcbeautify output and raw xcodebuild output.
  - Unsupported or unavailable platforms are reported as SKIP, not FAIL.
  - Platforms omitted from Package.swift are reported as SKIP before building.
  - Every PASS, SKIP, and FAIL line includes elapsed duration.
  - Temporary logs are written under .build/xcode-platform-matrix and removed.
  - Per-Xcode DerivedData paths preserve incremental builds across runs.
EOF
}

if [[ "$#" -eq 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
    print_help
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR_NAME="$(basename "$SCRIPT_DIR")"

if [[ "$SCRIPT_DIR_NAME" != "Scripts" ]]; then
    echo "error: this script must reside in a directory named Scripts" >&2
    exit 2
fi

ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ ! -f "$ROOT/Package.swift" ]]; then
    echo "error: expected Package.swift at $ROOT/Package.swift" >&2
    exit 2
fi

cd "$ROOT"

SCHEME="$(basename "$ROOT")"
XCODE_APPS=()
SELECTED_PLATFORM_NAMES=()

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        -s|--scheme)
            if [[ "$#" -lt 2 ]]; then
                echo "error: $1 requires a scheme name" >&2
                exit 2
            fi

            SCHEME="$2"
            shift 2
            ;;
        --scheme=*)
            SCHEME="${1#*=}"
            shift
            ;;
        -p|--platform)
            if [[ "$#" -lt 2 ]]; then
                echo "error: $1 requires a platform name" >&2
                exit 2
            fi

            SELECTED_PLATFORM_NAMES+=("$2")
            shift 2
            ;;
        --platform=*)
            SELECTED_PLATFORM_NAMES+=("${1#*=}")
            shift
            ;;
        -x|--xcode)
            if [[ "$#" -lt 2 ]]; then
                echo "error: $1 requires an Xcode app path" >&2
                exit 2
            fi

            XCODE_APPS+=("$2")
            shift 2
            ;;
        --xcode=*)
            XCODE_APPS+=("${1#*=}")
            shift
            ;;
        --)
            shift

            while [[ "$#" -gt 0 ]]; do
                XCODE_APPS+=("$1")
                shift
            done
            ;;
        -*)
            echo "error: unknown option: $1" >&2
            exit 2
            ;;
        *)
            XCODE_APPS+=("$1")
            shift
            ;;
    esac
done

if [[ "${#XCODE_APPS[@]}" -eq 0 ]]; then
    XCODE_APPS=("${DEFAULT_XCODE_APPS[@]}")
fi

PLATFORM_INDEXES=()

if [[ "${#SELECTED_PLATFORM_NAMES[@]}" -eq 0 ]]; then
    for index in "${!PLATFORM_NAMES[@]}"; do
        PLATFORM_INDEXES+=("$index")
    done
else
    for selected_platform_name in "${SELECTED_PLATFORM_NAMES[@]}"; do
        matched_platform_index=""

        for index in "${!PLATFORM_NAMES[@]}"; do
            if [[ "${PLATFORM_NAMES[$index]}" == "$selected_platform_name" ]]; then
                matched_platform_index="$index"
                break
            fi
        done

        if [[ -z "$matched_platform_index" ]]; then
            echo "error: unknown platform: $selected_platform_name" >&2
            print_help >&2
            exit 2
        fi

        PLATFORM_INDEXES+=("$matched_platform_index")
    done
fi

print_help
echo

missing_xcodes=()

for xcode_app in "${XCODE_APPS[@]}"; do
    if [[ ! -d "$xcode_app/Contents/Developer" ]]; then
        missing_xcodes+=("$xcode_app")
    fi
done

if [[ "${#missing_xcodes[@]}" -gt 0 ]]; then
    echo "error: one or more Xcode installations are unavailable:" >&2

    for xcode_app in "${missing_xcodes[@]}"; do
        echo "  $xcode_app" >&2
    done

    exit 2
fi

if ! command -v xcbeautify >/dev/null 2>&1; then
    echo "error: xcbeautify is not installed or not on PATH" >&2
    exit 127
fi

failures=0
TEMP_LOGS=()
LOG_DIR="$ROOT/.build/xcode-platform-matrix"
DERIVED_DATA_ROOT="$HOME/Library/Developer/Xcode/DerivedData"
CONFIGURATION="Debug"
ACTION="build"
BUILD_SETTINGS=(
    "ONLY_ACTIVE_ARCH=YES"
    "EXCLUDED_ARCHS=i386 x86_64"
    "COMPILER_INDEX_STORE_ENABLE=NO"
)

remove_temp_logs() {
    if [[ "${#TEMP_LOGS[@]}" -gt 0 ]]; then
        rm -f "${TEMP_LOGS[@]}"
    fi
}

trap remove_temp_logs EXIT

mkdir -p "$LOG_DIR"

now_milliseconds() {
    if command -v perl >/dev/null 2>&1; then
        perl -MTime::HiRes=time -e 'printf "%.0f\n", time * 1000'
    else
        echo "$(($(date +%s) * 1000))"
    fi
}

format_duration() {
    local milliseconds="$1"

    printf "%d.%03ds" "$((milliseconds / 1000))" "$((milliseconds % 1000))"
}

print_case_result() {
    local result="$1"
    local xcode_name="$2"
    local platform_name="$3"
    local started_at="$4"
    local message="${5:-}"
    local finished_at
    local elapsed

    finished_at="$(now_milliseconds)"
    elapsed="$(format_duration "$((finished_at - started_at))")"

    if [[ -n "$message" ]]; then
        echo "$result: $xcode_name / $platform_name ($message, elapsed $elapsed)"
    else
        echo "$result: $xcode_name / $platform_name (elapsed $elapsed)"
    fi
}

is_unsupported_platform_failure() {
    local raw_log="$1"

    grep -Eiq \
        "(xcodebuild: error: (Unable to find a destination|Found no destinations|SDK .* cannot be located|.*destination.*not supported|.*platform.*not installed)|(iOS|tvOS|watchOS|visionOS) [0-9.]+ is not installed|unsupported (platform|destination)|(package|product|target).*does not support.*(macOS|Mac Catalyst|iOS|tvOS|watchOS|visionOS))" \
        "$raw_log"
}

manifest_platforms() {
    local developer_dir="$1"

    if ! command -v python3 >/dev/null 2>&1; then
        return 0
    fi

    DEVELOPER_DIR="$developer_dir" xcrun swift package dump-package 2>/dev/null | python3 -c '
import json
import sys

try:
    package = json.load(sys.stdin)
except Exception:
    sys.exit(0)

for platform in package.get("platforms") or []:
    platform_name = platform.get("platformName")

    if platform_name:
        print(platform_name.lower())
'
}

platform_is_declared() {
    local supported_platforms="$1"
    local platform_name="$2"

    if [[ -z "$supported_platforms" ]]; then
        return 0
    fi

    grep -Fxq "$platform_name" <<<"$supported_platforms"
}

for xcode_app in "${XCODE_APPS[@]}"; do
    developer_dir="$xcode_app/Contents/Developer"
    xcode_name="$(basename "$xcode_app")"
    xcode_key="${xcode_name%.app}"
    derived_data_path="$DERIVED_DATA_ROOT/$SCHEME-$xcode_key"
    supported_platforms="$(manifest_platforms "$developer_dir")"

    echo "===== $xcode_name ====="
    DEVELOPER_DIR="$developer_dir" xcrun swiftc -version | head -n 1
    echo "SCHEME: $SCHEME"
    echo "CONFIGURATION: $CONFIGURATION"
    echo "ACTION: $ACTION"
    echo "BUILD SETTINGS: ${BUILD_SETTINGS[*]}"
    echo "DERIVED DATA: $derived_data_path"

    for index in "${PLATFORM_INDEXES[@]}"; do
        platform_name="${PLATFORM_NAMES[$index]}"
        package_platform_name="${PLATFORM_PACKAGE_NAMES[$index]}"
        destination="${DESTINATIONS[$index]}"
        sdk="${SDKS[$index]}"
        started_at="$(now_milliseconds)"

        if ! platform_is_declared "$supported_platforms" "$package_platform_name"; then
            print_case_result "SKIP" "$xcode_name" "$platform_name" "$started_at" "Package.swift does not declare $package_platform_name"
            continue
        fi

        if [[ -n "$sdk" ]] && ! DEVELOPER_DIR="$developer_dir" xcrun --sdk "$sdk" --show-sdk-path >/dev/null 2>&1; then
            print_case_result "SKIP" "$xcode_name" "$platform_name" "$started_at" "SDK $sdk unavailable"
            continue
        fi

        args=(-quiet -scheme "$SCHEME" -configuration "$CONFIGURATION" -derivedDataPath "$derived_data_path" -destination "$destination" "$ACTION" "${BUILD_SETTINGS[@]}")

        echo "BUILD: $xcode_name / $platform_name"

        raw_log="$(mktemp "$LOG_DIR/xcodebuild-output.XXXXXX")"
        beautified_log="$(mktemp "$LOG_DIR/xcbeautify-output.XXXXXX")"
        TEMP_LOGS+=("$raw_log" "$beautified_log")

        set +e
        DEVELOPER_DIR="$developer_dir" xcodebuild "${args[@]}" 2>&1 | tee "$raw_log" | xcbeautify >"$beautified_log" 2>&1
        pipeline_status=("${PIPESTATUS[@]}")

        xcodebuild_status="${pipeline_status[0]}"
        xcbeautify_status="${pipeline_status[2]}"

        if [[ "$xcodebuild_status" -eq 0 && "$xcbeautify_status" -eq 0 ]]; then
            print_case_result "PASS" "$xcode_name" "$platform_name" "$started_at"
        elif is_unsupported_platform_failure "$raw_log"; then
            print_case_result "SKIP" "$xcode_name" "$platform_name" "$started_at" "unsupported or unavailable platform"
        else
            print_case_result "FAIL" "$xcode_name" "$platform_name" "$started_at" "xcodebuild status $xcodebuild_status, xcbeautify status $xcbeautify_status"
            echo "--- xcbeautify ---"
            cat "$beautified_log"
            echo "--- raw xcodebuild ---"
            cat "$raw_log"
            failures=$((failures + 1))
        fi

        rm -f "$raw_log" "$beautified_log"
    done
done

exit "$failures"
