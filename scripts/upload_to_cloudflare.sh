#!/bin/bash

cd ~/Preternatural/Swallow/documentation || { echo "Failed to change directory"; exit 1; }
echo "Current directory: $(pwd)"

total_files=$(find . -type f | wc -l)
echo "Found $total_files files to upload"

counter=0
find . -type f | while read file; do
    counter=$((counter + 1))
    cleaned_file=${file#./}
    printf "[%d/%d] Uploading: %s\n" "$counter" "$total_files" "$cleaned_file"
    npx wrangler r2 object put "swallowdocs/documentation/$cleaned_file" --file "$file" > /dev/null 2>&1
done
