#!/bin/bash

setup_work_directory() {
  echo_color "$RED" "Setting up work directory..."

  rm -rf "$OUTPUT_PATH"
  mkdir -p "$OUTPUT_PATH"

  end_time=$(date +%s)
  elapsed_time=$((end_time - start_time))
}

setup_work_directory