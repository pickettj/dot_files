#!/bin/bash

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Java is not installed or not in your PATH. Please install Java first."
    echo "Visit https://www.java.com for more information."
    exit 1
fi

# Define the Dropbox location directly since we can't source aliases
DROP="$HOME/Dropbox"

# Use Fuzzy to find the target XML file
file=$(find ../../Dropbox/Active_Directories/Notes/Primary_Sources -type f | fzf --preview 'cat {}' --delimiter / --with-nth -1)

echo "$file"

# Extract just the name of the file for output reading file purposes
name="${file%.xml}"
name="${name##*/}"
echo "$name"

# Output file name
output_name="${name}.xhtml"
output_path="../xml_development_eurasia/reading_views/${output_name}"
echo "$output_path"

# XSLT Style Sheet source directory
xsl_dir="../xml_development_eurasia/xslt/persian_document_reading_view_basic.xsl"

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

# Run XSL transformation
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
