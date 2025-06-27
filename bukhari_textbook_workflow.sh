#!/bin/bash

# Access global variables
source .aliases

# Use Fuzzy to find the target XML file
file=$(find $DROP/Active_Directories/Publications -type f | fzf --preview 'cat {}' --delimiter / --with-nth -1)

echo "Selected file: $file"

# Extract just the name of the file for output reading file purposes
name="${file%.xml}"
name="${name##*/}"
echo "Processing: $name"

# Output file paths
output_dir="$PROJ/bactriana/docs/sandbox"
# Ensure output directory exists
mkdir -p "$output_dir"

xhtml_output="${output_dir}/${name}.xhtml"
css_file="${output_dir}/bukhari_style.css"
pdf_output="${output_dir}/${name}.pdf"

echo "Output XHTML: $xhtml_output"
echo "Output PDF: $pdf_output"

# XSLT Style Sheet source directory
xsl_dir="$PROJ/bactriana/docs/sandbox/transform_bukhari_textbook.xsl"

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

# Create CSS if it doesn't exist
if [ ! -f "$css_file" ]; then
    echo "Creating CSS file: $css_file"
    cat > "$css_file" << 'EOF'
/* Bukhari Textbook Styles */
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    line-height: 1.5;
    max-width: 800px;
    margin: 0 auto;
    padding: 2em;
    color: #333;
}

h1, h2, h3, h4, h5, h6 {
    color: #333;
    margin-top: 1.5em;
    margin-bottom: 0.5em;
    page-break-after: avoid;
}

h1 { font-size: 2.2em; }
h2 { font-size: 1.8em; }
h3 { font-size: 1.5em; }
h4 { font-size: 1.3em; }

p {
    margin-bottom: 1em;
}

/* Add styles for specific Bukhari elements here */
.arabic {
    font-family: "Amiri", "Scheherazade", serif;
    font-size: 1.2em;
    direction: rtl;
    text-align: right;
    line-height: 1.8;
    margin: 1em 0;
}

.translation {
    margin: 1em 0;
    font-style: italic;
}

.commentary {
    margin: 1em 0;
    padding-left: 1em;
    border-left: 3px solid #ddd;
}

.footnote {
    font-size: 0.9em;
    color: #555;
}

/* Print-specific styles */
@media print {
    body {
        max-width: none;
    }
    @page {
        margin: 2.5cm;
        size: letter;
    }

    a {
        color: #000;
        text-decoration: none;
    }

    .footnote {
        font-size: 0.85em;
    }
}
EOF
fi

# Run XSL transformation
echo "Running XSLT transformation..."
java -cp "$CLASSPATH" net.sf.saxon.Transform -s:"$file" -xsl:"$xsl_dir" -o:"$xhtml_output"

# Check if transformation was successful
if [ ! -f "$xhtml_output" ] || [ ! -s "$xhtml_output" ]; then
    echo "XSLT transformation failed. Creating simple HTML fallback..."

    # Create a simple HTML version as fallback
    echo '<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>'"$name"'</title>
    <link rel="stylesheet" href="bukhari_style.css">
</head>
<body>
    <h1>'"$name"'</h1>
    <div class="content">
        <!-- Content extracted from XML -->
        <pre>' > "$xhtml_output"

    # Extract and append content from the XML file (basic approach)
    cat "$file" | grep -v '<?xml' | grep -v '<\/?TEI' | sed 's/<[^>]*>//g' >> "$xhtml_output"

    # Close the HTML
    echo '        </pre>
    </div>
</body>
</html>' >> "$xhtml_output"

    echo "Created basic HTML version as fallback."
fi

# Create PDF using Pandoc and BasicTeX
echo "Creating PDF using Pandoc and BasicTeX..."
pdf_out="$pdf_output"

# Check if pandoc is installed
if ! command -v pandoc >/dev/null 2>&1; then
    echo "pandoc not found. Please install pandoc."
    exit 1
fi

# Check if pdflatex is installed
if ! command -v pdflatex >/dev/null 2>&1; then
    echo "pdflatex not found. Please install a LaTeX distribution (e.g., TeX Live or MiKTeX)."
    exit 1
fi

# Convert XHTML to PDF using Pandoc
pandoc "$xhtml_output" -o "$pdf_out" --pdf-engine=xelatex --css="$css_file"

# Check if PDF creation was successful
if [ -f "$pdf_out" ] && [ -s "$pdf_out" ]; then
    echo "✓ Successfully created PDF: $pdf_out"

    # Create and copy URL to clipboard
    pdf_filename=$(basename "$pdf_out")
    pdf_url="https://bactriana.org/sandbox/$pdf_filename"
    echo "Generated URL: $pdf_url"

    # Copy to clipboard using pbcopy (macOS) or xclip/xsel (Linux)
    if command -v pbcopy &> /dev/null; then
        echo "$pdf_url" | pbcopy
        echo "URL copied to clipboard!"
    elif command -v xclip &> /dev/null; then
        echo "$pdf_url" | xclip -selection clipboard
        echo "URL copied to clipboard!"
    elif command -v xsel &> /dev/null; then
        echo "$pdf_url" | xsel --clipboard
        echo "URL copied to clipboard!"
    else
        echo "Could not copy to clipboard: pbcopy, xclip, and xsel not found."
    fi

    # Open the PDF
    open "$pdf_out" 2>/dev/null || xdg-open "$pdf_out" 2>/dev/null
else
    echo "✗ PDF creation failed. Opening HTML instead."
    # Open the HTML file
    open "$xhtml_output" 2>/dev/null || xdg-open "$xhtml_output" 2>/dev/null
fi

# Git operations
echo ""
echo "Would you like to commit and push these files to the repository? (y/n)"
read git_confirmation

if [[ $git_confirmation == "y" || $git_confirmation == "Y" ]]; then
    # Navigate to the repository directory
    cd "$PROJ/bactriana"

    # Check if we're in a git repository
    if [ -d ".git" ]; then
        echo "Adding files to git..."
        git add "docs/sandbox/$(basename "$xhtml_output")" "docs/sandbox/$(basename "$pdf_output")"

        # Also add CSS file if it was newly created
        if [ -f "docs/sandbox/$(basename "$css_file")" ]; then
            git add "docs/sandbox/$(basename "$css_file")"
        fi

        # Prompt for commit message
        echo "Enter commit message (default: 'Add $name XHTML and PDF files'):"
        read commit_message
        if [ -z "$commit_message" ]; then
            commit_message="Add $name XHTML and PDF files"
        fi

        # Commit the files
        git commit -m "$commit_message"

        # Prompt for push confirmation
        echo "Push changes to remote repository? (y/n)"
        read push_confirmation
        if [[ $push_confirmation == "y" || $push_confirmation == "Y" ]]; then
            git push
            echo "Changes pushed successfully."
        else
            echo "Changes committed locally but not pushed."
        fi
    else
        echo "Error: Not a git repository. Files were created but not committed."
    fi
else
    echo "Files created but not committed to git."
fi

echo "Script completed."
