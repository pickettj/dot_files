#!/bin/bash

# Set global variables
DROP="$HOME/Dropbox"
OUTPUT_DIR="$DROP/Active_Directories/Inbox"
CSS_FILE="$HOME/.pandoc/default.css"
USE_CSS_MODE=false

# Define common search locations for markdown files
SEARCH_DIRS=(
  "$DROP/Active_Directories"
)

# Function to display usage information
show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help                 Show this help message"
    echo "  -d, --directory DIR        Specify custom output directory"
    echo "  -f, --fuzzy-dir           Use fuzzy search to select output directory"
    echo "  -c, --css FILE            Specify a CSS file for styling"
    echo "  --css-mode                Force CSS-based conversion instead of LaTeX"
    echo "  -a, --all                 Search all of Dropbox (slower)"
    echo "  --toc                     Include table of contents"
    echo "  --no-links                Disable hyperlinks in PDF"
    exit 0
}

# Parse command line options
INCLUDE_TOC=false
ENABLE_LINKS=true

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -d|--directory)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -f|--fuzzy-dir)
            custom_dir=$(find "$DROP/Active_Directories" -type d | fzf --height 40% --reverse --prompt="Select output directory: ")
            if [ -n "$custom_dir" ]; then
                OUTPUT_DIR="$custom_dir"
            fi
            shift
            ;;
        -c|--css)
            CSS_FILE="$2"
            USE_CSS_MODE=true
            shift 2
            ;;
        --css-mode)
            USE_CSS_MODE=true
            shift
            ;;
        --toc)
            INCLUDE_TOC=true
            shift
            ;;
        --no-links)
            ENABLE_LINKS=false
            shift
            ;;
        -a|--all)
            SEARCH_DIRS=("$DROP")
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"
echo "Output directory: $OUTPUT_DIR"

# Create an enhanced default CSS file if it doesn't exist
if [ ! -f "$CSS_FILE" ]; then
    mkdir -p "$(dirname "$CSS_FILE")"
    cat > "$CSS_FILE" << EOF
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    line-height: 1.5;
    max-width: 800px;
    margin: 0 auto;
    padding: 1em;
    color: #333;
}
h1, h2, h3, h4, h5, h6 {
    color: #333;
    margin-top: 1.5em;
    margin-bottom: 0.5em;
    line-height: 1.3;
}
h1 {
    font-size: 2.2em;
    border-bottom: 2px solid #333;
    padding-bottom: 0.3em;
}
h2 {
    font-size: 1.8em;
    border-bottom: 1px solid #666;
    padding-bottom: 0.2em;
}
h3 {
    font-size: 1.5em;
    color: #555;
}
h4 {
    font-size: 1.3em;
    color: #666;
}
h5 {
    font-size: 1.1em;
    color: #777;
    font-weight: 600;
}
h6 {
    font-size: 1em;
    color: #888;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
}
code, pre {
    font-family: SFMono-Regular, Menlo, Monaco, Consolas, monospace;
    background-color: #f5f5f5;
    border-radius: 3px;
}
code {
    padding: 0.2em 0.4em;
}
pre {
    padding: 1em;
    overflow-x: auto;
    border-left: 3px solid #0366d6;
}
a {
    color: #0366d6;
    text-decoration: none;
}
a:hover {
    text-decoration: underline;
}
table {
    border-collapse: collapse;
    width: 100%;
    margin: 1em 0;
}
th, td {
    border: 1px solid #ddd;
    padding: 8px;
}
th {
    background-color: #f5f5f5;
    text-align: left;
}
blockquote {
    border-left: 4px solid #ddd;
    padding-left: 1em;
    color: #666;
    margin-left: 0;
    font-style: italic;
}
img {
    max-width: 100%;
}
/* Table of Contents styling */
.toc {
    background: #f9f9f9;
    border: 1px solid #ddd;
    padding: 1em;
    margin-bottom: 2em;
    border-radius: 5px;
}
.toc ul {
    margin: 0;
    padding-left: 1.5em;
}
.toc > ul {
    padding-left: 0;
}
@media print {
    body {
        max-width: none;
    }
    a {
        color: #000;
    }
    @page {
        margin: 2.5cm;
    }
}
EOF
    echo "Created enhanced CSS at $CSS_FILE"
fi

# Function to select markdown file using fzf
find_markdown() {
    echo "Searching for Markdown files in common directories..."
    find "${SEARCH_DIRS[@]}" -type f -name "*.md" | fzf -m --preview 'cat {}' --delimiter / --with-nth -1
}

# Main conversion function
md2pdf() {
    local file="$1"
    name="${file%.md}"
    name="${name##*/}"
    echo "Processing: $name"

    # Check if BasicTeX is installed
    if ! command -v pdflatex >/dev/null 2>&1 && ! command -v xelatex >/dev/null 2>&1; then
        echo "BasicTeX not found. Falling back to CSS-based conversion..."
        USE_CSS_MODE=true
    fi

    if [ "$USE_CSS_MODE" = true ]; then
        # CSS-based conversion method
        html_out="$OUTPUT_DIR/${name}.html"
        echo "Using CSS-based conversion..."

        # Build pandoc command for HTML
        html_cmd=(pandoc "$file" -o "$html_out" --standalone --embed-resources --css="$CSS_FILE" -t html5)

        if [ "$INCLUDE_TOC" = true ]; then
            html_cmd+=(--toc --toc-depth=6)
        fi

        "${html_cmd[@]}"

        if [ ! -f "$html_out" ] || [ ! -s "$html_out" ]; then
            echo "✗ Error creating HTML for $name"
            return 1
        fi

        pdf_out="$OUTPUT_DIR/${name}.pdf"
        echo "Creating PDF using Chrome..."

        # Find Chrome executable
        chrome_path=""
        if [ -f "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
            chrome_path="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
        elif [ -f "/Applications/Chromium.app/Contents/MacOS/Chromium" ]; then
            chrome_path="/Applications/Chromium.app/Contents/MacOS/Chromium"
        elif command -v google-chrome &>/dev/null; then
            chrome_path="google-chrome"
        elif command -v chromium &>/dev/null; then
            chrome_path="chromium"
        fi

        if [ -n "$chrome_path" ]; then
            # Enhanced Chrome flags for better PDF output with preserved links
            "$chrome_path" --headless --disable-gpu --print-to-pdf="$pdf_out" \
                --print-to-pdf-no-header \
                --virtual-time-budget=5000 \
                --run-all-compositor-stages-before-draw \
                "$html_out"

            if [ -f "$pdf_out" ] && [ -s "$pdf_out" ]; then
                echo "✓ Created PDF: $pdf_out"
                rm "$html_out"
                open "$pdf_out" 2>/dev/null || xdg-open "$pdf_out" 2>/dev/null
                return 0
            fi
        fi

        echo "✗ PDF creation failed. Keeping HTML version."
        open "$html_out" 2>/dev/null || xdg-open "$html_out" 2>/dev/null
    else
        # BasicTeX-based conversion
        pdf_out="$OUTPUT_DIR/${name}.pdf"
        echo "Creating PDF using BasicTeX..."

        # Build pandoc command with enhanced options
        pandoc_cmd=(pandoc "$file" -o "$pdf_out" --pdf-engine=xelatex)

        # Add geometry and spacing
        pandoc_cmd+=(--variable=geometry:margin=1in)
        pandoc_cmd+=(--variable=fontsize:11pt)
        pandoc_cmd+=(--variable=linestretch:1.2)

        # Add hyperlink support if enabled
        if [ "$ENABLE_LINKS" = true ]; then
            pandoc_cmd+=(--variable=colorlinks:true)
            pandoc_cmd+=(--variable=linkcolor:blue)
            pandoc_cmd+=(--variable=urlcolor:blue)
            pandoc_cmd+=(--variable=filecolor:magenta)
            pandoc_cmd+=(--variable=citecolor:red)
        else
            pandoc_cmd+=(--variable=hidelinks:true)
        fi

        # Add table of contents if requested
        if [ "$INCLUDE_TOC" = true ]; then
            pandoc_cmd+=(--toc --toc-depth=6)
        fi

        # Better heading formatting
        pandoc_cmd+=(--variable=secnumdepth:0)  # No section numbering unless you want it
        pandoc_cmd+=(--variable=subparagraph:yes)  # Support for all 6 heading levels

        # Execute the pandoc command
        "${pandoc_cmd[@]}"

        if [ -f "$pdf_out" ] && [ -s "$pdf_out" ]; then
            echo "✓ Created PDF: $pdf_out"
            if [ "$ENABLE_LINKS" = true ]; then
                echo "  ✓ Hyperlinks preserved"
            fi
            if [ "$INCLUDE_TOC" = true ]; then
                echo "  ✓ Table of contents included"
            fi
            open "$pdf_out" 2>/dev/null || xdg-open "$pdf_out" 2>/dev/null
            return 0
        else
            echo "✗ PDF creation failed using BasicTeX. Falling back to CSS-based conversion..."
            USE_CSS_MODE=true
            md2pdf "$file"  # Recursive call with CSS mode
        fi
    fi
}

# Main script execution
selected_files=$(find_markdown)

if [ -z "$selected_files" ]; then
    echo "No files selected. Exiting."
    exit 0
fi

# Show configuration
echo "Configuration:"
echo "  BasicTeX mode: $([ "$USE_CSS_MODE" = true ] && echo "Disabled" || echo "Enabled")"
echo "  Hyperlinks: $([ "$ENABLE_LINKS" = true ] && echo "Enabled" || echo "Disabled")"
echo "  Table of Contents: $([ "$INCLUDE_TOC" = true ] && echo "Enabled" || echo "Disabled")"
echo "-----------------------------------"

# Process each selected file
echo "$selected_files" | while IFS= read -r file; do
    if [ -f "$file" ]; then
        md2pdf "$file"
        echo "-----------------------------------"
    else
        echo "✗ File not found: $file"
    fi
done

echo "All conversions completed!"
