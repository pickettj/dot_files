  # Trying to make a simple script that creates and opens a file
#!/usr/bin/env bash
read -p "Note title: " note
touch ~/Dropbox/Active_Directories/Notes/Secondary_Works/$note".txt"
open ~/Dropbox/Active_Directories/Notes/Secondary_Works/$note".txt"
exit 0
