

# Use Fuzzy to find the target XML file
file=$(find ../../Dropbox/Active_Directories/Notes/Primary_Sources -type f | fzf --preview 'cat {}' --delimiter / --with-nth -1)

echo $file

# Extract just the name of the file for output reading file file purposes
name="${file%.xml}"
name="${name##*/}"
echo $name

# Output file name
output_name="${name}.xhtml"
output_path="../xml_development_eurasia/reading_views/${output_name}"
echo $output_path

# XSLT Style Sheet source directory
xsl_dir="../xml_development_eurasia/xslt/persian_document_reading_view_basic.xsl"

# Saxon jar file Directory
sax_dir="../sync/SaxonHE10-5Jsaxon-he-10.5.jar"
echo $sax_dir

# run XSL transformation
java -cp ../sync/SaxonHE10-5J/saxon-he-10.5.jar net.sf.saxon.Transform -s:$file -xsl:$xsl_dir -o:$output_path
