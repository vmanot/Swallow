#!/bin/sh
start_time=$(date +%s)

set -e
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

PACKAGE_NAME="Swallow"
DERIVED_DATA_PATH="/tmp/docbuild"
OUTPUT_PATH="$PROJECT_DIR/docs"
HOSTING_BASE_PATH="Swallow"
BUNDLE_IDENTIFIER="com.swallow.documentation"
WORK_DIR="/tmp/swallow_doc_work"

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
NC="\033[0m"

. "$PROJECT_DIR/scripts/echo_color.sh"
. "$PROJECT_DIR/scripts/check_status.sh"
. "$PROJECT_DIR/scripts/format_time.sh"
. "$PROJECT_DIR/scripts/setup_work_directory.sh"
. "$PROJECT_DIR/scripts/extract_targets.sh"
. "$PROJECT_DIR/scripts/build_documentation.sh"

echo_color "$BLUE" "Generating documentation for ${PACKAGE_NAME}..."

setup_work_directory
cd "$WORK_DIR"

echo_color "$BLUE" "Extracting targets from Package.swift..."
TARGETS=$(extract_targets)
TARGET_COUNT=$(printf "%s\n" "$TARGETS" | wc -l)
check_status "Found $TARGET_COUNT targets"

. "$PROJECT_DIR/scripts/build_documentation_for_targets.sh"
build_documentation_for_targets

echo_color "$BLUE" "Generating documentation index page..."
#. "$PROJECT_DIR/scripts/create_index_html.sh"
#create_index_html
#check_status "Index page generated"

# Create .nojekyll file for GitHub Pages
touch "${OUTPUT_PATH}/.nojekyll"

# Clean up work directory
rm -rf "$WORK_DIR"

echo "<script>window.location.href += \"/documentation/swiftuix\"</script>" > docs/index.html;

echo_color "$GREEN" "Documentation generation complete!"
echo -e "Documentation can be found in: ${BLUE}${OUTPUT_PATH}${NC}"
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

echo_color "$RED" "Time taken for documentation generation $(format_time $elapsed_time)"
