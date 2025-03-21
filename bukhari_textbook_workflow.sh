# access global variables
source .aliases

# Use Fuzzy to find the target XML file
file=$(find $DROP/Active_Directories/Publications -type f | fzf --preview 'cat {}' --delimiter / --with-nth -1)

echo $file

# Extract just the name of the file for output reading file file purposes
name="${file%.xml}"
name="${name##*/}"
echo $name

# Output file name
output_name="${name}.xhtml"
output_path="$PROJ/bactriana/docs/sandbox/${output_name}"
echo $output_path

# XSLT Style Sheet source directory
xsl_dir="$PROJ/bactriana/docs/sandbox/transform_bukhari_textbook.xsl"

# Saxon jar file Directory
sax_dir="../sync/SaxonHE10-5Jsaxon-he-10.5.jar"
echo $sax_dir

# run XSL transformation
java -cp ../sync/SaxonHE10-5J/saxon-he-10.5.jar net.sf.saxon.Transform -s:$file -xsl:$xsl_dir -o:$output_path

# produce pdf version from the HTML

# Create PDF output path by changing extension
pdf_output="${output_path%.xhtml}.pdf"

# Convert XHTML to PDF using WeasyPrint
weasyprint "$output_path" "$pdf_output"

# Confirm PDF creation
echo "Created PDF: $pdf_output"




