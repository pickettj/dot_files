# Trying to make a simple script that creates and opens a file
#!/usr/bin/env bash
read -p "Serial no: " ser
touch ~/Dropbox/Active_Directories/Notes/Primary_Sources/transcription_markdown_drafting_stage1/"ser"$ser".md"
open ~/Dropbox/Active_Directories/Notes/Primary_Sources/transcription_markdown_drafting_stage1/"ser"$ser".md"
exit 0
