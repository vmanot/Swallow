#!/bin/bash
# To generate documentation on your local machine, run this script from the project root directory.
# After successful generation, to serve the documentation locally:
#   1. Navigate to project-root/documentation folder
#   2. Run: npx http-server -p 8000 --cors -c-1
#   3. View documentation in browser at: http://127.0.0.1:8000/documentation/

set -e
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

OUTPUT_PATH="$PROJECT_DIR/documentation"
INDEX_HTML_PATH="$PROJECT_DIR/documentation/documentation/index.html"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/echo_color.sh" "."
source "$SCRIPT_DIR/extract_targets.sh" "."
source "$SCRIPT_DIR/setup_work_directory.sh" "."
source "$SCRIPT_DIR/build_documentation_for_targets.sh" "."
source "$SCRIPT_DIR/create_index_html.sh" "."

# Create .nojekyll file for GitHub Pages
# .nojekyll file is necessary if you plan to host the documentation on GitHub Pages.
# Without it, GitHub Pages (which uses Jekyll by default) will ignore folders that start with underscores (_).
touch "${OUTPUT_PATH}/.nojekyll"
echo_color "$GREEN" "Documentation generation complete!"
