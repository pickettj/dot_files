#!/bin/bash
# setup_scripts.sh - Make all scripts in dot_files executable

cd "$(dirname "$0")"  # Navigate to script directory
chmod +x *.sh         # Make all shell scripts executable
echo "All scripts are now executable."
