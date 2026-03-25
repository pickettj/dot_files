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
    echo "  -f, --fuzzy-dir            Use fuzzy search to select output directory"
    echo "  -c, --css FILE             Specify a CSS file for styling"
    echo "  --css-mode                 Force CSS-based conversion instead of LaTeX"
    echo "  -a, --all                  Search all of Dropbox (slower)"
    echo "  --toc                      Include table of contents"
    echo "  --no-links                 Disable hyperlinks in PDF"
    echo "  --endnotes                 Use endnotes instead of footnotes"
    echo "  --font FONTNAME            Override the main font (default: LaTeX Computer Modern)
  --unicode                  Use CMU Serif font for Cyrillic support (same look as LaTeX default)"
    exit 0
}

# -------------------------------------------------------
# Font detection: only used when --font flag is not set
# but Unicode coverage is needed (e.g. --unicode mode).
# Default is NO override, preserving classic LaTeX look.
# -------------------------------------------------------
detect_unicode_font() {
    # CMU Serif looks identical to Computer Modern but covers Cyrillic.
    # Install: sudo tlmgr install cm-unicode
    # Noto Serif covers everything including Arabic but looks different.
    # Install: brew install --cask font-noto-serif
    if command -v fc-list >/dev/null 2>&1; then
        for candidate in "CMU Serif" "Noto Serif" "FreeSerif" "Arial Unicode MS"; do
            if fc-list 2>/dev/null | grep -qi "$candidate"; then
                echo "$candidate"
                return
            fi
        done
    fi
    echo ""
}

# -------------------------------------------------------
# Parse command line options
# -------------------------------------------------------
INCLUDE_TOC=false
ENABLE_LINKS=true
ENDNOTES=false
FONT_OVERRIDE=""
UNICODE_MODE=false

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
        --endnotes)
            ENDNOTES=true
            shift
            ;;
        --font)
            FONT_OVERRIDE="$2"
            shift 2
            ;;
        --unicode)
            UNICODE_MODE=true
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

# -------------------------------------------------------
# Create enhanced default CSS file if it doesn't exist
# -------------------------------------------------------
if [ ! -f "$CSS_FILE" ]; then
    mkdir -p "$(dirname "$CSS_FILE")"
    cat > "$CSS_FILE" << 'EOF'
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
h1 { font-size: 2.2em; border-bottom: 2px solid #333; padding-bottom: 0.3em; }
h2 { font-size: 1.8em; border-bottom: 1px solid #666; padding-bottom: 0.2em; }
h3 { font-size: 1.5em; color: #555; }
h4 { font-size: 1.3em; color: #666; }
h5 { font-size: 1.1em; color: #777; font-weight: 600; }
h6 { font-size: 1em; color: #888; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }
code, pre {
    font-family: SFMono-Regular, Menlo, Monaco, Consolas, monospace;
    background-color: #f5f5f5;
    border-radius: 3px;
}
code { padding: 0.2em 0.4em; }
pre { padding: 1em; overflow-x: auto; border-left: 3px solid #0366d6; }
a { color: #0366d6; text-decoration: none; }
a:hover { text-decoration: underline; }
table { border-collapse: collapse; width: 100%; margin: 1em 0; }
th, td { border: 1px solid #ddd; padding: 8px; }
th { background-color: #f5f5f5; text-align: left; }
blockquote { border-left: 4px solid #ddd; padding-left: 1em; color: #666; margin-left: 0; font-style: italic; }
img { max-width: 100%; }
.toc { background: #f9f9f9; border: 1px solid #ddd; padding: 1em; margin-bottom: 2em; border-radius: 5px; }
.toc ul { margin: 0; padding-left: 1.5em; }
.toc > ul { padding-left: 0; }
@media print {
    body { max-width: none; }
    a { color: #000; }
    @page { margin: 2.5cm; }
}
EOF
    echo "Created enhanced CSS at $CSS_FILE"
fi

# -------------------------------------------------------
# Function to select markdown file using fzf
# -------------------------------------------------------
find_markdown() {
    echo "Searching for Markdown files in common directories..." >&2
    find "${SEARCH_DIRS[@]}" -type f -name "*.md" | fzf -m --preview 'cat {}' --delimiter / --with-nth -1
}

# -------------------------------------------------------
# Main conversion function
# -------------------------------------------------------
md2pdf() {
    local file="$1"
    name="${file%.md}"
    name="${name##*/}"
    echo "Processing: $name"

    # Check if BasicTeX / XeLaTeX is installed
    if ! command -v pdflatex >/dev/null 2>&1 && ! command -v xelatex >/dev/null 2>&1; then
        echo "BasicTeX not found. Falling back to CSS-based conversion..."
        USE_CSS_MODE=true
    fi

    if [ "$USE_CSS_MODE" = true ]; then
        # ---------------------------------------------------
        # CSS / Chrome-based conversion
        # ---------------------------------------------------
        html_out="$OUTPUT_DIR/${name}.html"
        echo "Using CSS-based conversion..."

        html_cmd=(pandoc "$file" -o "$html_out" --standalone --embed-resources --css="$CSS_FILE" -t html5)
        html_cmd+=(--resource-path="$(dirname "$file")")

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
        # ---------------------------------------------------
        # XeLaTeX-based conversion
        # ---------------------------------------------------
        pdf_out="$OUTPUT_DIR/${name}.pdf"
        echo "Creating PDF using BasicTeX..."

        pandoc_cmd=(pandoc "$file" -o "$pdf_out" --pdf-engine=xelatex)

        # Resolve images relative to the source file's directory
        pandoc_cmd+=(--resource-path="$(dirname "$file")")

        # Geometry and spacing
        pandoc_cmd+=(--variable=geometry:margin=1in)
        pandoc_cmd+=(--variable=fontsize:11pt)
        pandoc_cmd+=(--variable=linestretch:1.2)

        # ---------------------------------------------------
        # Font: pick a Unicode-rich font that covers
        # Latin, Cyrillic, Arabic, Persian, Uyghur scripts.
        #
        # Noto Serif is the best option — install via:
        #   brew install --cask font-noto-serif
        # FreeSerif is a good fallback:
        #   brew install --cask font-freeserif   (or via TeX Live)
        # Arial Unicode MS ships with macOS/Office.
        # ---------------------------------------------------
        # Font selection:
        # Default is NO override — preserves classic Computer Modern LaTeX look.
        # --font FONTNAME: explicit override
        # --unicode: auto-selects CMU Serif (identical look, adds Cyrillic support)
        #            install: sudo tlmgr install cm-unicode
        if [ -n "$FONT_OVERRIDE" ]; then
            MAIN_FONT="$FONT_OVERRIDE"
            echo "  Font: $MAIN_FONT (explicit override)"
        elif [ "$UNICODE_MODE" = true ]; then
            MAIN_FONT=$(detect_unicode_font)
            if [ -n "$MAIN_FONT" ]; then
                echo "  Font: $MAIN_FONT (unicode mode)"
            else
                echo "  Font: LaTeX default — CMU Serif not found for unicode mode"
                echo "        Fix: sudo tlmgr install cm-unicode"
                MAIN_FONT=""
            fi
        else
            MAIN_FONT=""
            echo "  Font: LaTeX default (Computer Modern)"
        fi

        if [ -n "$MAIN_FONT" ]; then
            pandoc_cmd+=(--variable=mainfont:"$MAIN_FONT")
        fi

        # ---------------------------------------------------
        # Arabic / Persian / Urdu / Uyghur script support.
        #
        # XeLaTeX handles inline RTL (Arabic/Persian mixed
        # into LTR documents) natively via its Unicode bidi
        # algorithm — no extra package needed.
        #
        # We declare a \arabicfont family so you can wrap
        # Arabic-script passages: {\arabicfont نص عربي}
        #
        # Best Arabic fonts (install any one):
        #   Amiri             — classical, scholarly
        #   Scheherazade New  — broad Unicode coverage
        #   Noto Naskh Arabic — clean modern
        # Install: brew install --cask font-amiri
        # ---------------------------------------------------
        ARABIC_FONT=""
        if command -v fc-list >/dev/null 2>&1; then
            for af in "Amiri" "Scheherazade New" "Noto Naskh Arabic"; do
                if fc-list 2>/dev/null | grep -qi "$af"; then
                    ARABIC_FONT="$af"
                    break
                fi
            done
        fi

        # ---------------------------------------------------
        # Build a single header-includes string combining
        # all LaTeX preamble additions. Passing header-includes
        # multiple times via --variable can conflict, so we
        # accumulate everything here and pass it once.
        # fontspec is auto-loaded by XeLaTeX when mainfont is
        # set, so we only need to add what's extra.
        # ---------------------------------------------------
        HEADER_INCLUDES=""

        if [ -n "$ARABIC_FONT" ]; then
            HEADER_INCLUDES+='\newfontfamily\arabicfont[Script=Arabic,RightToLeft]{'"$ARABIC_FONT"'}'
            echo "  Arabic font: $ARABIC_FONT"
        else
            echo "  Arabic font: none detected (install Amiri: brew install --cask font-amiri)"
        fi

        # Force figures to appear inline (not floated to separate page)
        HEADER_INCLUDES+='\usepackage{float}\floatplacement{figure}{H}'

        if [ "$ENDNOTES" = true ]; then
            HEADER_INCLUDES+='\usepackage{endnotes}\let\footnote=\endnote'
        fi

        if [ -n "$HEADER_INCLUDES" ]; then
            pandoc_cmd+=(--variable=header-includes:"$HEADER_INCLUDES")
        fi

        # ---------------------------------------------------
        # Hyperlinks
        # ---------------------------------------------------
        if [ "$ENABLE_LINKS" = true ]; then
            pandoc_cmd+=(--variable=colorlinks:true)
            pandoc_cmd+=(--variable=linkcolor:blue)
            pandoc_cmd+=(--variable=urlcolor:blue)
            pandoc_cmd+=(--variable=filecolor:magenta)
            pandoc_cmd+=(--variable=citecolor:red)
        else
            pandoc_cmd+=(--variable=hidelinks:true)
        fi

        # Table of contents
        if [ "$INCLUDE_TOC" = true ]; then
            pandoc_cmd+=(--toc --toc-depth=6)
        fi

        # Heading formatting
        pandoc_cmd+=(--variable=secnumdepth:0)
        pandoc_cmd+=(--variable=subparagraph:yes)

        # ---------------------------------------------------
        # Endnotes: append \theendnotes after document body
        # so all notes collect at the end of the PDF.
        # ---------------------------------------------------
        local endnote_tmpfile=""
        if [ "$ENDNOTES" = true ]; then
            endnote_tmpfile=$(mktemp /tmp/endnotes_XXXXXX.tex)
            echo '\theendnotes' > "$endnote_tmpfile"
            pandoc_cmd+=(--include-after-body="$endnote_tmpfile")
            echo "  Notes mode: endnotes"
        else
            echo "  Notes mode: footnotes (default)"
        fi

        # Execute pandoc — capture stderr to detect missing LaTeX packages.
        # Check exit code directly; don't rely on file existence since a
        # stale PDF from a prior run would cause a false-positive.
        local pandoc_stderr
        pandoc_stderr=$( cd "$(dirname "$file")" && "${pandoc_cmd[@]}" 2>&1 )
        local pandoc_exit=$?

        # Clean up temp file
        [ -n "$endnote_tmpfile" ] && rm -f "$endnote_tmpfile"

        if [ $pandoc_exit -eq 0 ] && [ -f "$pdf_out" ] && [ -s "$pdf_out" ]; then
            echo "✓ Created PDF: $pdf_out"
            [ "$ENABLE_LINKS" = true ]  && echo "  ✓ Hyperlinks preserved"
            [ "$INCLUDE_TOC" = true ]   && echo "  ✓ Table of contents included"
            [ "$ENDNOTES" = true ]      && echo "  ✓ Endnotes collected at end of document"
            open "$pdf_out" 2>/dev/null || xdg-open "$pdf_out" 2>/dev/null
            return 0
        else
            echo "✗ LaTeX PDF creation failed."
            # Check for missing .sty packages and give an actionable fix
            local missing_pkg
            missing_pkg=$(echo "$pandoc_stderr" | grep -o "File \`[^']*\.sty' not found" | grep -o "\`[^']*'" | tr -d "\`'" | sed 's/\.sty//')
            if [ -n "$missing_pkg" ]; then
                echo ""
                echo "  Missing LaTeX package: $missing_pkg"
                echo "  Fix:  sudo tlmgr install $missing_pkg"
                echo ""
                echo "$pandoc_stderr" | grep "^!" | head -5
            else
                echo ""
                echo "  LaTeX error output:"
                echo "$pandoc_stderr" | grep -E "^(!|Error|l\.[0-9])" | head -15
                echo ""
                echo "  Full stderr (last 20 lines):"
                echo "$pandoc_stderr" | tail -20
            fi
            echo ""
            echo "  Not falling back to CSS — LaTeX formatting is preferred."
            echo "  Run with --css-mode to force Chrome/HTML conversion."
            return 1
        fi
    fi
}

# -------------------------------------------------------
# Main script execution
# -------------------------------------------------------
selected_files=$(find_markdown)

if [ -z "$selected_files" ]; then
    echo "No files selected. Exiting."
    exit 0
fi

echo "Configuration:"
echo "  BasicTeX mode:     $([ "$USE_CSS_MODE" = true ] && echo "Disabled" || echo "Enabled")"
echo "  Hyperlinks:        $([ "$ENABLE_LINKS" = true ] && echo "Enabled" || echo "Disabled")"
echo "  Table of Contents: $([ "$INCLUDE_TOC" = true ] && echo "Enabled" || echo "Disabled")"
echo "  Notes:             $([ "$ENDNOTES" = true ] && echo "Endnotes" || echo "Footnotes")"
echo "-----------------------------------"

echo "$selected_files" | while IFS= read -r file; do
    if [ -f "$file" ]; then
        md2pdf "$file"
        echo "-----------------------------------"
    else
        echo "✗ File not found: $file"
    fi
done

echo "All conversions completed!"