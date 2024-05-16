#!/usr/bin/bash

# Check if filename is provided as an argument
if [ -z "$1" ]; then
  echo "Error: Please provide a filename as an argument." >&2
  exit 1
fi

filename="$1"

# Define replacements as an associative array
declare -A replacements=(
  ["myWidget_show"]="appSimple_show"
  ["myWidget_home"]="appSimple_home"
  ["myWidget_state"]="appSimple_state"
)

# Define function for replacement and counting
replace_and_count() {
  local line="$1"
  local replaced_line="$line"
  local count=0
  
  # Perform replacements and count occurrences
  for key in "${!replacements[@]}"; do
    replaced_line="${replaced_line//$key/${replacements[$key]}/g}"
    #count=$((count + grep -o "$key" <<< "$replaced_line" | wc -l))
  done
  
  echo "$replaced_line" > "$filename"
  echo "$count"  # Output count on a separate line
}

# Process the file line by line
total_count=0
while IFS= read -r line; do
#  replacedlines=$(replace_and_count "$line" )
    for key in "${!replacements[@]}"; do
        replaced_line="${line//$key/${replacements[$key]}/og}"
        count=`expr $count + $(grep -o "$key" <<<$replaced_line| wc -l )`
        #count=$((count + grep -o "$key" <<< "$replaced_line" | wc -l))
        if [ -n $count  ] ; then
          echo "$line" 
        fi
    done
#count=$(echo -e "$replaced_line" | tail -n1)  # Extract count from previous line
    total_count=$((total_count + count))
done < "$filename"

# Print total count
echo "Total replacements: $total_count"

# diff -s $filename.replaced $filename
