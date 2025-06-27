#!/bin/bash
# setup_scripts.sh - Make all scripts in dot_files executable

cd "$(dirname "$0")"  # Navigate to script directory
chmod +x *.sh         # Make all shell scripts executable
echo "All scripts are now executable."


# setting up path to jupyter notebook configurations
ln -sf $PROJ/dot_files/jupyter_notebook_config.py ~/.jupyter/jupyter_notebook_config.py
