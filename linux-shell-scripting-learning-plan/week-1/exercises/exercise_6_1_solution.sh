#!/bin/bash

# Exercise 6.1 Solution: Batch File Processor
# Task: Process all .txt files in a directory, count lines, words, chars, and show size

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Function to process a single file
process_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    # Count lines, words, characters
    local lines=$(wc -l < "$file")
    local words=$(wc -w < "$file")
    local chars=$(wc -c < "$file")
    local size=$(stat -c "%s" "$file" 2>/dev/null || echo 0)
    local size_human=$(numfmt --to=iec-i --format="%.0f" "$size" 2>/dev/null || echo "$size bytes")
    
    printf "%-30s %10s %10s %10s %10s\n" "$file" "$lines" "$words" "$chars" "$size_human"
}

# Main script
echo ""
echo "================================================"
echo -e "${GREEN}       Batch File Processor${NC}"
echo "================================================"
echo ""

# Get directory from argument or use current directory
if [ $# -gt 0 ]; then
    dir="$1"
else
    dir="."
fi

# Validate directory
if [ ! -d "$dir" ]; then
    echo -e "${RED}Error: Directory does not exist: $dir${NC}"
    exit 1
fi

# Find all .txt files
echo "Searching for .txt files in: $dir"
echo ""

# Count files first
txt_files=("$dir"/*.txt 2>/dev/null)
file_count=0

for file in "${txt_files[@]}"; do
    if [ -f "$file" ]; then
        ((file_count++))
    fi
done

if [ "$file_count" -eq 0 ]; then
    echo -e "${YELLOW}No .txt files found in $dir${NC}"
    exit 0
fi

echo "Found $file_count text file(s)"
echo ""
echo "================================================"
echo ""

# Display header
printf "%-30s %10s %10s %10s %10s\n" "FILE" "LINES" "WORDS" "CHARS" "SIZE"
echo "----------------------------------------------------------"

# Initialize counters
total_lines=0
total_words=0
total_chars=0
total_size=0

# Process each file
for file in "${txt_files[@]}"; do
    if [ -f "$file" ]; then
        process_file "$file"
        
        # Accumulate totals
        ((total_lines += $(wc -l < "$file")))
        ((total_words += $(wc -w < "$file")))
        ((total_chars += $(wc -c < "$file")))
        ((total_size += $(stat -c "%s" "$file" 2>/dev/null || echo 0)))
    fi
done

echo "----------------------------------------------------------"

# Display totals
printf "%-30s %10s %10s %10s %10s\n" "TOTAL" "$total_lines" "$total_words" "$total_chars" "$(numfmt --to=iec-i --format="%.0f" "$total_size" 2>/dev/null || echo "$total_size bytes")"

echo ""
echo "================================================"

# Summary statistics
echo ""
echo -e "${BLUE}Summary Statistics:${NC}"
echo "  Average lines per file: $((total_lines / file_count))"
echo "  Average words per file: $((total_words / file_count))"
echo "  Average chars per file: $((total_chars / file_count))"

# Find largest and smallest files
largest=""
smallest=""
largest_size=0
smallest_size=999999999

for file in "${txt_files[@]}"; do
    if [ -f "$file" ]; then
        size=$(stat -c "%s" "$file" 2>/dev/null || echo 0)
        if [ "$size" -gt "$largest_size" ]; then
            largest_size=$size
            largest="$file"
        fi
        if [ "$size" -lt "$smallest_size" ]; then
            smallest_size=$size
            smallest="$file"
        fi
    fi
done

if [ -n "$largest" ]; then
    echo ""
    echo "  Largest file: $largest ($(numfmt --to=iec-i --format="%.0f" "$largest_size" 2>/dev/null || echo "$largest_size bytes"))"
    echo "  Smallest file: $smallest ($(numfmt --to=iec-i --format="%.0f" "$smallest_size" 2>/dev/null || echo "$smallest_size bytes"))"
fi

echo ""
echo "================================================"
echo -e "${GREEN}Batch processing completed!${NC}"
echo "================================================"
