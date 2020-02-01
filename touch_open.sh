# Trying to make a simple script that creates and opens a file
#!/usr/bin/env bash
path=$1
touch $path".txt"
open $path".txt"
exit 0
