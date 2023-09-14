#!/bin/bash

# Prompt the user for the search term
read -p "grep search term: " search_term

# Perform the grep search and store the results in an array
search_results=$(grep -ril "$search_term" .)
IFS=$'\n' read -d '' -ra options <<< "$search_results"

# Prompt message
echo "Please choose an option:"

# Display the menu and wait for user input
select choice in "${options[@]}"; do
    case $choice in
        *)
            echo "opening: $choice"
            # Open the selected file
            xdg-open "$choice"  # For Linux
            # OR
            open "$choice"     # For macOS
            ;;
    esac
    break
done


# IFS (Internal Field Separator):
# In Bash, IFS is an environment variable that determines how Bash interprets word splitting and line splitting. It specifies a set of characters that are used to split strings into words when performing expansions. By default, IFS is set to whitespace characters (space, tab, and newline).

# In the provided script, IFS=$'\n' sets the IFS variable to the newline character (\n). This change in IFS allows us to read the output of grep (which is a multi-line string containing filenames) and split it into an array (options) based on newlines. The read command with the -d '' option reads until a null character, and the -ra option populates the options array with the split results.

# case statement:
# The case statement is a conditional construct in Bash that allows you to test a variable against multiple patterns. It provides an alternative to a series of if-elif-else statements when you need to check a variable against various values or patterns.

# In the provided script, the select command captures the user's choice in the choice variable. The case statement is then used to match the value of choice against different patterns specified within the case block.