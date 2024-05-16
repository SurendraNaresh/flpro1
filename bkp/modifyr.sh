#!/bin/bash
#modify_inline

# Define file path
file_path="bkp.README.md"
total_lines=$(cat $file_path | wc -l )
# Read and iterate over each line in the file
while IFS= read -r line; do
    # Check if it's one of the top 3 lines or last 5 lines
    line_number=$((line_number + 1))
    if [ "$line_number" -le "3" ] || [ "$line_number" -gt "$((total_lines - 5))" ];
    then
        # Modify the content of the line
        modified_line="Modified: $line"
        echo "$modified_line" > "$file_path.new"
    else
        # if line={$line//flutter/golang/g;}
        # Output the line without modification
        echo "$line" > "$file_path.new"
    fi
done < "$file_path"
