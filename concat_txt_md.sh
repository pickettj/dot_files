#!/bin/bash

# just copy the literal path to the directory

# Check if directory path is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

# Get the input directory
INPUT_DIR="$1"

# Check if directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Directory '$INPUT_DIR' does not exist."
    exit 1
fi

# Get directory name and create timestamp
DIR_NAME=$(basename "$INPUT_DIR")
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="$INPUT_DIR/${DIR_NAME}_${TIMESTAMP}.txt"

# Create the output file with main header
echo "# $DIR_NAME $TIMESTAMP" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Function to get relative path from input directory
get_relative_path() {
    local file_path="$1"
    local relative_path="${file_path#$INPUT_DIR/}"
    echo "$relative_path"
}

# Function to get subdirectory name
get_subdir_name() {
    local file_path="$1"
    local relative_path=$(get_relative_path "$file_path")
    local subdir=$(dirname "$relative_path")
    
    if [ "$subdir" = "." ]; then
        echo "$DIR_NAME"
    else
        echo "$subdir"
    fi
}

# Track current subdirectory to avoid duplicate headers
CURRENT_SUBDIR=""

# Find all .md and .txt files recursively and sort them
find "$INPUT_DIR" -type f \( -name "*.md" -o -name "*.txt" \) | sort | while read -r file; do
    # Skip the output file itself
    if [ "$file" = "$OUTPUT_FILE" ]; then
        continue
    fi
    
    # Get subdirectory and filename
    SUBDIR=$(get_subdir_name "$file")
    FILENAME=$(basename "$file")
    
    # Add subdirectory header if it's different from current
    if [ "$SUBDIR" != "$CURRENT_SUBDIR" ]; then
        echo "## $SUBDIR" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        CURRENT_SUBDIR="$SUBDIR"
    fi
    
    # Add filename header
    echo "**$FILENAME**" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Add file contents
    cat "$file" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

echo "Files concatenated into: $OUTPUT_FILE"