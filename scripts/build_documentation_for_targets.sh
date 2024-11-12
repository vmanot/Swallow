#!/bin/sh

build_documentation_for_targets() {
    printf "%s\n" "$TARGETS" | while IFS= read -r target; do
        [ -z "$target" ] && continue

        echo_color "$YELLOW" "Processing ${target}..."

        start_time=$(date +%s)
        build_documentation "$target"
        end_time=$(date +%s)
        elapsed_time=$((end_time - start_time))

        echo_color "$RED" "Time taken for building documentation $(format_time $elapsed_time)"

        build_status=$?

        if [ $build_status -ne 0 ]; then
            echo_color "$RED" "Documentation build failed for ${target}"
            continue
        fi
    done
}
