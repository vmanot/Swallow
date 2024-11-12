#!/bin/bash

build_documentation_for_targets() {
    echo_color "$BLUE" "Generating documentation..."
    target_args=""
    for target in "${TARGETS[@]}"; do
        target_args+="--target $target "
    done

    swift package \
        --allow-writing-to-directory "$OUTPUT_PATH" \
        generate-documentation \
        --transform-for-static-hosting \
        --disable-indexing \
        --output-path "$OUTPUT_PATH" \
        $target_args \
        --enable-experimental-combined-documentation
}
build_documentation_for_targets
