#!/bin/bash

# Resolve paths relative to the script's own location,
# not the working directory from which it is invoked.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse flags
GIT_AUTO=false
for arg in "$@"; do
    case "$arg" in
        --git) GIT_AUTO=true ;;
    esac
done

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Java is not installed or not in your PATH. Please install Java first."
    echo "Visit https://www.java.com for more information."
    exit 1
fi

# Define the Dropbox location directly since we can't source aliases
DROP="$HOME/Dropbox"

# Prompt user to select stylesheet mode
echo "Select transformation type:"
echo "  1) Standard transcription reading view"
echo "  2) Translation parallel view"
read -rp "Enter 1 or 2: " mode

case "$mode" in
    1)
        xsl_dir="$SCRIPT_DIR/../xml_development_eurasia/xslt/persian_document_reading_view_basic.xsl"
        suffix=""
        ;;
    2)
        xsl_dir="$SCRIPT_DIR/../xml_development_eurasia/xslt/translation_document.xsl"
        suffix="_trans"
        ;;
    *)
        echo "Invalid selection. Please enter 1 or 2."
        exit 1
        ;;
esac

# Use fzf to find the target XML file
file=$(find "$HOME/Dropbox/Active_Directories/Notes/Primary_Sources" -type f \
    | fzf --preview 'cat {}' --delimiter / --with-nth -1)

echo "$file"

# Extract just the name of the file for output purposes
name="${file%.xml}"
name="${name##*/}"
echo "$name"

# Output file name: append _trans suffix if translation mode
output_name="${name}${suffix}.xhtml"
output_path="$SCRIPT_DIR/../bactriana/docs/sandbox/${output_name}"
echo "$output_path"

# Saxon directory and JAR file location
SAXON_DIR="$DROP/Sync/SaxonHE12-5J"
SAXON_JAR="$SAXON_DIR/saxon-he-12.5.jar"
echo "Using Saxon jar: $SAXON_JAR"

# Check if the Saxon jar file exists
if [ ! -f "$SAXON_JAR" ]; then
    echo "Error: Saxon jar file not found at $SAXON_JAR"
    echo "Please check the path and make sure the file exists."
    exit 1
fi

# Build classpath with Saxon JAR and all JARs in the lib directory
CLASSPATH="$SAXON_JAR"
if [ -d "$SAXON_DIR/lib" ]; then
    for jar in "$SAXON_DIR"/lib/*.jar; do
        CLASSPATH="$CLASSPATH:$jar"
    done
    echo "Including additional libraries from: $SAXON_DIR/lib"
fi

# Ensure the output directory exists
OUTPUT_DIR=$(dirname "$output_path")
mkdir -p "$OUTPUT_DIR"

# Run XSLT transformation
echo "Running XSLT transformation..."
java -cp "$CLASSPATH" net.sf.saxon.Transform -s:"$file" -xsl:"$xsl_dir" -o:"$output_path"

# Check if transformation was successful
if [ -f "$output_path" ]; then
    echo "Transformation successful. Opening file..."
    open "$output_path"
else
    echo "Transformation failed. Output file was not created."
    exit 1
fi

# ── Git ──────────────────────────────────────────────────────────────
default_msg="Add ${output_name}"

if $GIT_AUTO; then
    # --git flag: add, commit, push with default message, no prompts
    cd "$SCRIPT_DIR/../bactriana" || exit 1
    git add "docs/sandbox/${output_name}"
    git commit -m "$default_msg"
    git push
    echo "Changes pushed successfully."
else
    # No flag: ask whether to push at all
    echo ""
    read -rp "Push to git? (y/n): " git_confirmation
    if [[ $git_confirmation == "y" || $git_confirmation == "Y" ]]; then
        read -rp "Custom commit message? Leave blank to use default ('${default_msg}'): " commit_message
        if [ -z "$commit_message" ]; then
            commit_message="$default_msg"
        fi
        cd "$SCRIPT_DIR/../bactriana" || exit 1
        git add "docs/sandbox/${output_name}"
        git commit -m "$commit_message"
        git push
        echo "Changes pushed successfully."
    else
        echo "Files created but not committed to git."
    fi
fi