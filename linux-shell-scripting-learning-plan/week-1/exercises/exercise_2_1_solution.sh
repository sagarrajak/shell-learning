#!/bin/bash

# Exercise 2.1 Solution: Welcome Script with User Input
# Task: Create a script that prints welcome, date/time, lists files, counts them, and says goodbye

set -euo pipefail

# Configuration
AUTHOR="System Administrator"
SCRIPT_NAME="Welcome Script"

# Get current date and time
CURRENT_DATE=$(date +"%A, %B %d, %Y")
CURRENT_TIME=$(date +"%H:%M:%S")

# Welcome message
echo "================================================"
echo "       Welcome to $SCRIPT_NAME"
echo "================================================"
echo ""
echo "Author: $AUTHOR"
echo "Date: $CURRENT_DATE"
echo "Time: $CURRENT_TIME"
echo ""

# Ask for user's name
echo -n "Enter your name: "
read user_name

# Personalized greeting
echo ""
echo "Hello, $user_name! Nice to meet you."
echo ""

# List files in current directory
echo "Files in current directory ($(pwd)):"
echo "-----------------------------------"

file_count=0
if [ -d "$(pwd)" ]; then
    for item in *; do
        if [ -e "$item" ]; then
            echo "  - $item"
            ((file_count++))
        fi
    done
fi

echo ""
echo "Total files: $file_count"
echo ""

# Directory statistics
dir_count=$(find . -maxdepth 1 -type d 2>/dev/null | wc -l)
file_only_count=$((file_count - dir_count + 1))

echo "Statistics:"
echo "  Directories: $((dir_count - 1))"
echo "  Files: $file_only_count"
echo "  Total items: $file_count"
echo ""

# System information
echo "System Information:"
echo "-------------------"
echo "  Hostname: $(hostname)"
echo "  User: $(whoami)"
echo "  Shell: $SHELL"
echo "  Kernel: $(uname -r)"
echo ""

# Goodbye message
echo "================================================"
echo "Goodbye, $user_name! Have a great day!"
echo "================================================"
