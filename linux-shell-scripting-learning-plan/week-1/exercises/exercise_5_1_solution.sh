#!/bin/bash

# Exercise 5.1 Solution: File Manager Script
# Task: Create a file manager that checks file existence, type, size, permissions, and offers to view

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to get file type
get_file_type() {
    local file="$1"
    
    if [ -L "$file" ]; then
        echo "Symbolic Link"
    elif [ -d "$file" ]; then
        echo "Directory"
    elif [ -f "$file" ]; then
        case "$file" in
            *.txt) echo "Text File" ;;
            *.pdf) echo "PDF Document" ;;
            *.jpg|*.jpeg|*.png|*.gif) echo "Image File" ;;
            *.mp3|*.wav|*.flac) echo "Audio File" ;;
            *.mp4|*.avi|*.mkv) echo "Video File" ;;
            *.zip|*.tar|*.gz|*.bz2) echo "Archive File" ;;
            *.sh) echo "Shell Script" ;;
            *.py) echo "Python Script" ;;
            *.html|*.htm) echo "HTML File" ;;
            *.css) echo "CSS File" ;;
            *.js) echo "JavaScript File" ;;
            *.log) echo "Log File" ;;
            *.conf|*.cfg|*.ini) echo "Configuration File" ;;
            *) echo "Regular File" ;;
        esac
    else
        echo "Unknown"
    fi
}

# Function to display file permissions
display_permissions() {
    local file="$1"
    
    if [ ! -e "$file" ]; then
        echo "N/A"
        return
    fi
    
    local perms=$(stat -c "%a" "$file" 2>/dev/null || echo "N/A")
    local owner=$(stat -c "%U" "$file" 2>/dev/null || echo "N/A")
    local group=$(stat -c "%G" "$file" 2>/dev/null || echo "N/A")
    
    echo "Permissions: $perms (Owner: $owner, Group: $group)"
}

# Function to display file info
display_file_info() {
    local file="$1"
    
    echo ""
    echo "================================================"
    echo -e "${BLUE}File Information${NC}"
    echo "================================================"
    echo ""
    
    if [ ! -e "$file" ]; then
        echo -e "${RED}Error: File does not exist${NC}"
        return 1
    fi
    
    # File name
    echo "File Name: $file"
    echo "Full Path: $(readlink -f "$file")"
    
    # File type
    echo "File Type: $(get_file_type "$file")"
    
    # File size
    local size=$(stat -c "%s" "$file" 2>/dev/null || echo 0)
    local size_human=$(stat -c "%s" "$file" 2>/dev/null | numfmt --to=iec-i 2>/dev/null || echo "$size bytes")
    echo "File Size: $size_human ($size bytes)"
    
    # Permissions
    display_permissions "$file"
    
    # Modification time
    local mtime=$(stat -c "%y" "$file" 2>/dev/null || echo "N/A")
    echo "Modified: $mtime"
    
    # Access time
    local atime=$(stat -c "%x" "$file" 2>/dev/null || echo "N/A")
    echo "Accessed: $atime"
    
    echo ""
}

# Function to view file content
view_file() {
    local file="$1"
    
    echo ""
    echo "================================================"
    echo -e "${BLUE}File Content${NC}"
    echo "================================================"
    echo ""
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}Error: Cannot view - not a regular file${NC}"
        return 1
    fi
    
    local size=$(stat -c "%s" "$file" 2>/dev/null || echo 0)
    
    if [ "$size" -gt 1048576 ]; then
        echo -e "${YELLOW}Warning: File is large ($size bytes). Showing first 100 lines.${NC}"
        head -n 100 "$file"
    else
        cat "$file"
    fi
    
    echo ""
}

# Main script logic
echo "================================================"
echo -e "${GREEN}       Simple File Manager${NC}"
echo "================================================"
echo ""

# Check if filename provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Please provide a filename${NC}"
    echo ""
    echo "Usage: $0 <filename>"
    exit 1
fi

filename="$1"

# Display file information
display_file_info "$filename"

# Offer to view file
if [ -f "$filename" ]; then
    echo ""
    echo -n "Would you like to view the file content? (y/n): "
    read answer
    
    case "$answer" in
        y|Y|yes|Yes|YES)
            view_file "$filename"
            ;;
        *)
            echo "Skipped viewing file."
            ;;
    esac
fi

echo ""
echo "================================================"
echo "File manager completed."
echo "================================================"
