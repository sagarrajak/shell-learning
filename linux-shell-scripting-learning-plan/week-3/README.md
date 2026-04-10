# Week 3: Advanced - Professional System Administration

**Duration:** 7 Days  
**Level:** Advanced  
**Focus:** Complex automation, debugging, and production-ready scripts

---

## 📋 Week Overview

Building on Week 1 and Week 2 foundations, this week focuses on advanced techniques that transform you into a professional shell scripting expert. You will master production-ready scripting with proper error handling, parallel processing, network operations, and database interactions.

### Learning Objectives

By the end of Week 3, you will be able to:
- Master advanced text processing with awk, sed, and grep
- Implement robust error handling and debugging
- Create parallel processing solutions
- Perform network operations from shell scripts
- Interact with databases programmatically
- Build production-ready monitoring and alerting systems
- Apply security best practices
- Optimize script performance
- Design and implement complex automation frameworks

---

## Day 1: Advanced Text Processing

### 🎯 Learning Goals
- Master awk for complex data processing
- Master sed for advanced text transformations
- Combine multiple text processing tools effectively
- Process structured data formats

### 📚 Topics Covered

#### 1.1 Advanced awk Techniques

**Problem Statement:** You need to process complex structured data files, generate reports, and perform calculations that require sophisticated text parsing capabilities.

**Solution:**
```awk
#!/bin/awk -f

# Advanced awk script for data processing
# Usage: awk -f processor.awk data.csv

BEGIN {
    FS=","
    OFS="\t"
    print "=== Data Processing Report ==="
    print "Generated:", strftime("%Y-%m-%d %H:%M:%S")
    print ""
}

# Process header
NR == 1 {
    print "Headers:", $0
    print ""
    headers = 1
    next
}

# Skip empty lines
/^$/ { next }

# Process data records
{
    total++
    
    # Calculate sum
    for (i = 1; i <= NF; i++) {
        if ($i ~ /^[0-9]+(\.[0-9]+)?$/) {
            sum += $i
        }
    }
    
    # Conditional processing
    if ($3 ~ /error/i) {
        errors++
        error_records[errors] = $0
    }
    
    # Store for later analysis
    data[NR] = $0
    
    # Group by category
    category = $2
    count[category]++
}

END {
    print "=== Summary Statistics ==="
    print "Total records:", total
    print "Error count:", errors
    print "Average value:", sum / total
    print ""
    
    print "=== Category Breakdown ==="
    for (cat in count) {
        printf "%-20s %5d\n", cat, count[cat]
    }
}
```

**Multidimensional Arrays in awk:**
```awk
#!/bin/awk -f

# Two-dimensional array example
# Process server metrics

BEGIN {
    FS=","
}

{
    server = $1
    metric = $2
    value = $3
    
    # Store in 2D array
    data[server][metric] = value
    total[metric] += value
    count[metric]++
}

END {
    print "=== Server Metrics Summary ==="
    
    # Get all servers
    for (srv in data) {
        print "\nServer:", srv
        for (met in data[srv]) {
            printf "  %-15s: %s\n", met, data[srv][met]
        }
    }
    
    print "\n=== Aggregate Statistics ==="
    for (met in total) {
        avg = total[met] / count[met]
        printf "%-15s: Total=%s, Avg=%.2f\n", met, total[met], avg
    }
}
```

**Associative Arrays and Sorting:**
```awk
#!/bin/awk -f

# Sort associative array by value

BEGIN {
    FS="\t"
}

{
    name = $1
    score = $2
    
    scores[name] = score
    names[name] = 1
}

END {
    print "=== Scores (sorted by score) ==="
    
    # Sort by score descending
    n = 0
    for (name in scores) {
        arr[n++] = name
    }
    
    # Bubble sort
    for (i = 0; i < n; i++) {
        for (j = i + 1; j < n; j++) {
            if (scores[arr[i]] < scores[arr[j]]) {
                tmp = arr[i]
                arr[i] = arr[j]
                arr[j] = tmp
            }
        }
    }
    
    # Print sorted
    for (i = 0; i < n; i++) {
        printf "%-20s %5d\n", arr[i], scores[arr[i]]
    }
}
```

#### 1.2 Advanced sed Techniques

**Problem Statement:** You need to perform complex text transformations including multi-line operations, conditional replacements, and complex pattern matching.

**Solution:**
```bash
#!/bin/bash

# Advanced sed operations

# Multi-line substitution
# Replace text spanning multiple lines
sed ':a;N;$!ba;s/pattern1\npattern2/replacement/g' file.txt

# Conditional replacement
# Replace only if line contains another pattern
sed '/ERROR/ s/WARNING/CRITICAL/g' logfile.log

# Use hold space for multi-line operations
sed -n '1h;G;p' file.txt  # Append first line to end of each line

# Insert and append
sed -i '/PATTERN/i\Inserted line' file.txt    # Insert before
sed -i '/PATTERN/a\Appended line' file.txt    # Append after

# Pattern groups and backreferences
# Swap first two fields
sed -E 's/^([^,]+),([^,]+)/\2,\1/' data.csv

# Transform characters
sed 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/' file.txt

# Delete lines based on pattern
sed '/^$/d' file.txt              # Delete empty lines
sed '/^\s*#/d' file.txt          # Delete comments
sed '1d;$d' file.txt             # Delete first and last line

# In-place with backup
sed -i.bak 's/old/new/g' file.txt

# Read and write to files
sed -n '/PATTERN/w /tmp/matches.txt' file.txt  # Write matches
sed '/PATTERN/r /tmp/insert.txt' file.txt      # Insert file

# Complex transformations
# Convert CSV to pipe-delimited
sed -E 's/,/|/g' file.csv

# Remove ANSI color codes
sed -r 's/\x1B\[[0-9;]*[mK]//g' colored.txt

# Replace only Nth occurrence
sed -i 's/old/new/3' file.txt  # Replace only 3rd occurrence

# Print specific lines
sed -n '10,20p' file.txt       # Print lines 10-20
sed -n '5p;10p;15p' file.txt   # Print specific lines
sed -n '/PATTERN/,/PATTERN2/p' file.txt  # Print range
```

**sed Functions and Scripts:**
```bash
#!/bin/bash

# sed script file for complex operations
# Create file: complex.sed

# Add line numbers
1s/^/0 /
2,$s/^/[=]/g

# Replace between patterns
/PATTERN1/,/PATTERN2/s/old/new/g

# Delete blank lines at end
:loop
/^$/d
N
b loop

# Reverse file
# 1!G;h;$!d

# Run sed script
sed -f complex.sed input.txt > output.txt
```

#### 1.3 Combining Text Processing Tools

**Problem Statement:** You need to combine multiple text processing tools to solve complex data transformation tasks that require the strengths of each tool.

**Solution:**
```bash
#!/bin/bash

# Pipeline examples combining multiple tools

# Extract and analyze log data
cat /var/log/syslog | \
    grep -E '(ERROR|WARN)' | \
    sed -E 's/.*\[([0-9]+)\].*/\1/' | \
    sort | \
    uniq -c | \
    sort -rn | \
    head -20

# Process CSV with multiple tools
cat data.csv | \
    grep -v '^#' | \                   # Remove comments
    awk -F',' '$3 > 100 {print}' | \   # Filter
    sort -t',' -k4 -rn | \              # Sort
    head -100 | \                      # Limit
    awk -F',' '{print $1, $4}' | \     # Select columns
    column -t                           # Format output

# Generate statistics report
echo "=== System Report ===" > report.txt
echo "Generated: $(date)" >> report.txt

# CPU stats
top -bn1 | head -20 >> report.txt

# Memory stats
free -h >> report.txt

# Disk usage
df -h | grep -E '^/dev/' >> report.txt

# Network connections
netstat -tuln | grep LISTEN >> report.txt

# Process list
ps aux --sort=-%cpu | head -20 >> report.txt

# Complex data transformation pipeline
process_logs() {
    local logdir="$1"
    local output="$2"
    
    {
        echo "Log Analysis Report"
        echo "==================="
        echo ""
        
        # Error summary
        echo "Error Summary:"
        find "$logdir" -name "*.log" -exec cat {} \; | \
            grep -iE 'error|fatal|exception' | \
            sed 's/.*\berror\b.*/ERROR/gi' | \
            sort | \
            uniq -c | \
            sort -rn | \
            awk '{printf "  %-20s %5d\n", $2, $1}'
        
        echo ""
        
        # Top users by request count
        echo "Top Users:"
        find "$logdir" -name "*.log" -exec cat {} \; | \
            awk '{print $1}' | \
            sort | \
            uniq -c | \
            sort -rn | \
            head -10 | \
            awk '{printf "  %-15s %5d\n", $2, $1}'
        
    } > "$output"
}
```

#### 1.4 Processing Structured Data

**Problem Statement:** You need to parse and process structured data formats like JSON, XML, and CSV from shell scripts.

**Solution:**
```bash
#!/bin/bash

# JSON processing with jq-like functionality using pure bash

# Parse JSON and extract values
parse_json() {
    local json="$1"
    local key="$2"
    
    echo "$json" | grep -oP "\"$key\"\s*:\s*\"[^\"]*\"" | \
        sed 's/.*:\s*"\([^"]*\)"/\1/'
}

# Process JSON array
process_json_array() {
    local json="$1"
    
    echo "$json" | grep -oP '\[[^\]]+\]' | \
        tr ',' '\n' | \
        sed 's/^\s*"\(.*\)"\s*/\1/'
}

# Example: Parse config file
parse_config() {
    local config_file="$1"
    
    declare -A config
    
    while IFS='=' read -r key value; do
        # Remove comments and trim
        key=$(echo "$key" | sed 's/#.*//' | xargs)
        value=$(echo "$value" | sed 's/#.*//' | xargs)
        
        if [ -n "$key" ]; then
            config["$key"]="$value"
        fi
    done < "$config_file"
    
    # Return values
    for key in "${!config[@]}"; do
        echo "$key=${config[$key]}"
    done
}

# XML parsing with grep/sed
parse_xml() {
    local xml="$1"
    local tag="$2"
    
    echo "$xml" | grep -oP "<$tag[^>]*>.*?</$tag>" | \
        sed -E "s/<$tag[^>]*>|<\/$tag>//g"
}

# CSV processing functions
csv_to_json() {
    local csv_file="$1"
    local json_file="${2:-output.json}"
    
    local headers=$(head -1 "$csv_file" | tr ',' '\n')
    local header_array=()
    
    while IFS= read -r line; do
        header_array+=("$line")
    done <<< "$headers"
    
    echo "[" > "$json_file"
    
    tail -n +2 "$csv_file" | while IFS=',' read -ra fields; do
        echo "  {" >> "$json_file"
        for i in "${!fields[@]}"; do
            echo "    \"${header_array[$i]}\": \"${fields[$i]}\"" >> "$json_file"
            if [ $i -lt $((${#fields[@]} - 1)) ]; then
                echo "," >> "$json_file"
            fi
        done
        echo "  }" >> "$json_file"
    done >> "$json_file"
    
    echo "]" >> "$json_file"
}

# Parse YAML-like configuration
parse_yaml() {
    local yaml_file="$1"
    local prefix="${2:-}"
    
    awk -F':' -v prefix="$prefix" '
    /^[[:space:]]*[a-zA-Z_]+:/ {
        key = $1
        gsub(/^[ \t]+/, "", key)
        
        if ($2 !~ /^[[:space:]]*$/) {
            value = substr($0, index($0, $2))
            gsub(/^[ \t]+/, "", value)
            gsub(/[ \t]+$/, "", value)
            
            if (prefix != "") {
                print prefix "." key "=" value
            } else {
                print key "=" value
            }
        }
    }
    ' "$yaml_file"
}
```

### 💡 Practice Exercise 1.1

**Task:** Create a log analysis script that:
1. Processes multiple log files in different formats (syslog, Apache, application logs)
2. Extracts and normalizes data from each format
3. Generates a comprehensive statistics report
4. Identifies top errors, warnings, and their frequencies
5. Creates trend analysis over multiple log files
6. Outputs results in multiple formats (text, CSV, HTML)

**Solution:** See `exercises/exercise_1_1_solution.sh`

---

## Day 2: Error Handling and Debugging

### 🎯 Learning Goals
- Implement comprehensive error handling
- Master debugging techniques and tools
- Use logging effectively
- Handle edge cases and validation

### 📚 Topics Covered

#### 2.1 Error Handling Fundamentals

**Problem Statement:** You need to write scripts that handle errors gracefully, provide meaningful error messages, and can recover from failures without crashing.

**Solution:**
```bash
#!/bin/bash

# Comprehensive error handling framework

# Enable strict error mode
set -euo pipefail
IFS=$'\n\t'

# Error handling function
error_handler() {
    local line_no=$1
    local error_code=$2
    local command="$3"
    
    echo "========================================="
    echo "ERROR DETECTED"
    echo "========================================="
    echo "Line number: $line_no"
    echo "Error code: $error_code"
    echo "Command: $command"
    echo "Date: $(date)"
    echo "========================================="
    
    # Call cleanup function
    cleanup
    
    exit "$error_code"
}

# Set error handler
trap 'error_handler ${LINENO} $? "$BASH_COMMAND"' ERR

# Cleanup function
cleanup() {
    echo "Performing cleanup..."
    # Remove temporary files
    rm -f /tmp/myapp.*
    # Close file descriptors
    exec 3>&-
    # Kill child processes
    pkill -P $$ 2>/dev/null || true
}

# Validation functions
validate_file() {
    local file="$1"
    local description="${2:-File}"
    
    if [ -z "$file" ]; then
        echo "Error: $description is empty"
        return 1
    fi
    
    if [ ! -e "$file" ]; then
        echo "Error: $description does not exist: $file"
        return 1
    fi
    
    if [ ! -f "$file" ]; then
        echo "Error: $description is not a regular file: $file"
        return 1
    fi
    
    if [ ! -r "$file" ]; then
        echo "Error: $description is not readable: $file"
        return 1
    fi
    
    return 0
}

validate_directory() {
    local dir="$1"
    local description="${2:-Directory}"
    
    if [ -z "$dir" ]; then
        echo "Error: $description is empty"
        return 1
    fi
    
    if [ ! -d "$dir" ]; then
        echo "Error: $description is not a directory: $dir"
        return 1
    fi
    
    return 0
}

validate_number() {
    local num="$1"
    local description="${2:-Number}"
    
    if ! [[ "$num" =~ ^-?[0-9]+$ ]]; then
        echo "Error: $description is not a valid integer: $num"
        return 1
    fi
    
    return 0
}

validate_ip() {
    local ip="$1"
    
    if ! [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "Error: Invalid IP address format: $ip"
        return 1
    fi
    
    return 0
}

# Safe command execution with error handling
run_command() {
    local description="$1"
    shift
    local cmd="$@"
    
    echo "Running: $description"
    echo "Command: $cmd"
    
    if eval "$cmd"; then
        echo "Success: $description"
        return 0
    else
        echo "Failed: $description (exit code: $?)"
        return 1
    fi
}

# Try-catch like pattern
try_catch() {
    local try_block="$1"
    local catch_block="${2:-}"
    
    if eval "$try_block"; then
        return 0
    else
        local error_code=$?
        if [ -n "$catch_block" ]; then
            eval "$catch_block"
        fi
        return "$error_code"
    fi
}
```

#### 2.2 Debugging Techniques

**Problem Statement:** You need to debug complex scripts, identify issues quickly, and use proper debugging tools and techniques.

**Solution:**
```bash
#!/bin/bash

# Debug mode control
DEBUG="${DEBUG:-false}"

debug() {
    if [ "$DEBUG" = "true" ]; then
        echo "[DEBUG] $(date '+%H:%M:%S') $*"
    fi
}

# Verbose tracing
trace() {
    if [ "${TRACE:-false}" = "true" ]; then
        echo "[TRACE] Line $LINENO: $*"
    fi
}

# Use set -x for line-by-line tracing
# set -x  # Uncomment to enable

# Dry run mode
DRY_RUN="${DRY_RUN:-false}"

dry_run() {
    if [ "$DRY_RUN" = "true" ]; then
        echo "[DRY RUN] $*"
        return 0
    else
        eval "$@"
        return $?
    fi
}

# Debug specific sections
debug_section() {
    local section_name="$1"
    shift
    
    if [ "$DEBUG" = "true" ]; then
        echo "=========================================="
        echo "DEBUG: Starting section: $section_name"
        echo "=========================================="
        
        (
            set -x
            "$@"
        )
        
        echo "=========================================="
        echo "DEBUG: Finished section: $section_name"
        echo "=========================================="
    else
        "$@"
    fi
}

# Variable inspection
inspect_var() {
    local var_name="$1"
    local var_value="${!var_name}"
    
    echo "[INSPECT] $var_name='$var_value' (length: ${#var_value})"
}

# Dump all variables matching pattern
dump_vars() {
    local pattern="${1:-.*}"
    
    compgen -A variable | while read -r var; do
        if [[ "$var" =~ $pattern ]]; then
            echo "$var=${!var}"
        fi
    done
}

# Stack trace
show_stack() {
    local i=0
    local frame=0
    
    echo "Stack trace:"
    while caller $frame >/dev/null 2>&1; do
        caller $frame
        ((frame++))
    done
}

# Performance timing
time_it() {
    local description="$1"
    shift
    
    local start=$(date +%s.%N)
    "$@"
    local status=$?
    local end=$(date +%s.%N)
    local duration=$(echo "$end - $start" | bc)
    
    echo "[TIMING] $description: ${duration}s (exit: $status)"
    return $status
}

# Memory usage check
check_memory() {
    echo "Memory usage:"
    ps -o pid,vsz,rss,pmem,comm -p $$ | tail -1
}
```

**ShellCheck Integration:**
```bash
#!/bin/bash

# Integrate ShellCheck for static analysis

run_shellcheck() {
    local script="$1"
    
    if command -v shellcheck >/dev/null 2>&1; then
        echo "Running ShellCheck..."
        shellcheck -x "$script" || {
            echo "ShellCheck found issues"
            return 1
        }
    else
        echo "ShellCheck not installed, skipping..."
    fi
}

# Common shellcheck exclusions for portability
# shellcheck disable=SC1090,SC1091

# Common checks to disable when needed
# SC2086: Double quote to prevent globbing
# SC2166: Prefer [ p ] || [ q ] as [ p -o q ] is deprecated
```

#### 2.3 Logging Framework

**Problem Statement:** You need to implement a comprehensive logging system for scripts that supports different log levels, multiple outputs, and rotation.

**Solution:**
```bash
#!/bin/bash

# Advanced logging framework

# Log levels
declare -r LOG_LEVEL_DEBUG=0
declare -r LOG_LEVEL_INFO=1
declare -r LOG_LEVEL_WARN=2
declare -r LOG_LEVEL_ERROR=3
declare -r LOG_LEVEL_FATAL=4

# Current log level (default: INFO)
: "${LOG_LEVEL:=$LOG_LEVEL_INFO}"

# Log file
: "${LOG_FILE:-/var/log/${0##*/}.log}"
: "${LOG_MAX_SIZE:=10485760}"  # 10MB
: "${LOG_MAX_FILES:=5}"

# Color codes
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_debug() {
    [ "$LOG_LEVEL" -le "$LOG_LEVEL_DEBUG" ] && \
        log_message "DEBUG" "$RED" "$*"
}

log_info() {
    [ "$LOG_LEVEL" -le "$LOG_LEVEL_INFO" ] && \
        log_message "INFO" "$GREEN" "$*"
}

log_warn() {
    [ "$LOG_LEVEL" -le "$LOG_LEVEL_WARN" ] && \
        log_message "WARN" "$YELLOW" "$*"
}

log_error() {
    [ "$LOG_LEVEL" -le "$LOG_LEVEL_ERROR" ] && \
        log_message "ERROR" "$RED" "$*"
}

log_fatal() {
    [ "$LOG_LEVEL" -le "$LOG_LEVEL_FATAL" ] && \
        log_message "FATAL" "$RED" "$*" >&2
}

log_message() {
    local level="$1"
    local color="$2"
    shift 2
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Console output with color
    if [ -t 1 ]; then
        echo -e "${color}[${timestamp}] [${level}] ${message}${NC}"
    else
        echo "[${timestamp}] [${level}] ${message}"
    fi
    
    # File output
    if [ -n "$LOG_FILE" ]; then
        rotate_log_if_needed
        echo "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE"
    fi
}

# Log rotation
rotate_log_if_needed() {
    if [ -f "$LOG_FILE" ]; then
        local size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
        
        if [ "$size" -gt "$LOG_MAX_SIZE" ]; then
            rotate_log
        fi
    fi
}

rotate_log() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local archive="${LOG_FILE}.${timestamp}"
    
    mv "$LOG_FILE" "$archive"
    gzip "$archive"
    
    # Clean old logs
    if [ -d "$(dirname "$LOG_FILE")" ]; then
        find "$(dirname "$LOG_FILE")" -name "$(basename "$LOG_FILE").*.gz" \
            -mtime +7 -delete 2>/dev/null || true
    fi
    
    touch "$LOG_FILE"
    chmod 644 "$LOG_FILE"
    
    log_info "Log rotated: $archive"
}

# Function logging wrapper
log_function() {
    local func_name="$1"
    shift
    
    log_debug "Calling function: $func_name"
    log_debug "Arguments: $*"
    
    local start=$(date +%s.%N)
    "$func_name" "$@"
    local status=$?
    local end=$(date +%s.%N)
    local duration=$(echo "$end - $start" | bc)
    
    if [ $status -eq 0 ]; then
        log_debug "Function $func_name completed in ${duration}s"
    else
        log_error "Function $func_name failed (exit: $status) in ${duration}s"
    fi
    
    return $status
}
```

#### 2.4 Edge Case Handling

**Problem Statement:** You need to handle edge cases, unusual inputs, and unexpected scenarios that could cause scripts to fail.

**Solution:**
```bash
#!/bin/bash

# Edge case handling patterns

# Handle empty input
handle_empty_input() {
    local input="${1:-}"
    local default="${2:-default_value}"
    
    if [ -z "$input" ]; then
        echo "$default"
        return 1
    fi
    
    echo "$input"
}

# Handle special characters
sanitize_input() {
    local input="$1"
    
    # Remove null bytes
    input="${input//$'\0'/}"
    
    # Escape special shell characters
    input="${input//\\/\\\\}"
    input="${input//\"/\\\"}"
    input="${input//\$/\\\$}"
    input="${input//\`/\\\`}"
    
    echo "$input"
}

# Handle very long lines
process_long_lines() {
    local file="$1"
    local max_len="${2:-1000}"
    
    awk -v max="$max_len" '
    {
        if (length($0) > max) {
            print "Line", NR, "exceeds max length:", length($0)
            # Truncate or skip
            # print substr($0, 1, max)
        } else {
            print
        }
    }
    ' "$file"
}

# Handle binary data
skip_binary_data() {
    local file="$1"
    
    strings "$file" | \
        grep -v '^$' | \
        head -100
}

# Handle files with unusual line endings
normalize_line_endings() {
    local file="$1"
    
    # Convert CRLF to LF
    sed -i 's/\r$//' "$file"
}

# Handle concurrent access
acquire_lock() {
    local lockfile="${1:-/tmp/script.lock}"
    local timeout="${2:-60}"
    local elapsed=0
    
    while [ -f "$lockfile" ]; do
        if [ $elapsed -ge $timeout ]; then
            echo "Timeout waiting for lock: $lockfile"
            return 1
        fi
        
        # Check if lock holder is still alive
        local pid=$(cat "$lockfile" 2>/dev/null)
        if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then
            rm -f "$lockfile"
        fi
        
        sleep 1
        ((elapsed++))
    done
    
    echo $$ > "$lockfile"
    return 0
}

release_lock() {
    local lockfile="${1:-/tmp/script.lock}"
    
    if [ -f "$lockfile" ]; then
        rm -f "$lockfile"
    fi
}

# Handle timeout
with_timeout() {
    local timeout="$1"
    shift
    local cmd="$@"
    
    (
        eval "$cmd" &
        pid=$!
        
        (
            sleep "$timeout"
            kill -0 $pid 2>/dev/null && kill $pid 2>/dev/null
        ) &
        watcher=$!
        
        wait $pid
        status=$?
        kill $watcher 2>/dev/null
        
        return $status
    )
}

# Handle signals gracefully
setup_signal_handlers() {
    local cleanup_func="${1:-cleanup}"
    
    trap '' SIGINT   # Ignore Ctrl+C
    trap '' SIGTSTP  # Ignore Ctrl+Z
    trap "$cleanup_func" EXIT
    trap 'echo "Received SIGTERM"; exit 143' SIGTERM
}
```

### 💡 Practice Exercise 2.1

**Task:** Create a production-ready script framework that:
1. Implements comprehensive error handling with custom error codes
2. Supports multiple log levels and log rotation
3. Includes debugging modes (verbose, dry-run, trace)
4. Validates all inputs and configurations
5. Handles signals and cleanup properly
6. Provides detailed documentation and usage help

**Solution:** See `exercises/exercise_2_1_solution.sh`

---

## Day 3: Parallel Processing and Performance

### 🎯 Learning Goals
- Implement parallel processing in shell scripts
- Manage multiple background jobs efficiently
- Optimize script performance
- Handle resource constraints

### 📚 Topics Covered

#### 3.1 Parallel Execution Patterns

**Problem Statement:** You need to execute multiple tasks concurrently to improve performance, particularly for I/O-bound operations or when processing multiple independent items.

**Solution:**
```bash
#!/bin/bash

# Parallel processing framework

# Job queue implementation
declare -a JOB_QUEUE=()
declare -a RUNNING_JOBS=()
MAX_JOBS=4

enqueue_job() {
    JOB_QUEUE+=("$1")
}

process_queue() {
    while [ ${#JOB_QUEUE[@]} -gt 0 ] || [ ${#RUNNING_JOBS[@]} -gt 0 ]; do
        # Start new jobs if queue has items and we're under limit
        while [ ${#JOB_QUEUE[@]} -gt 0 ] && [ ${#RUNNING_JOBS[@]} -lt $MAX_JOBS ]; do
            job="${JOB_QUEUE[0]}"
            JOB_QUEUE=("${JOB_QUEUE[@]:1}")
            
            (
                eval "$job"
            ) &
            
            RUNNING_JOBS+=($!)
            echo "Started job: $job (PID: $!)"
        done
        
        # Check for completed jobs
        for i in "${!RUNNING_JOBS[@]}"; do
            if ! kill -0 "${RUNNING_JOBS[$i]}" 2>/dev/null; then
                echo "Job completed: PID ${RUNNING_JOBS[$i]}"
                unset 'RUNNING_JOBS[$i]'
            fi
        done
        
        # Re-index array
        RUNNING_JOBS=("${RUNNING_JOBS[@]}")
        
        sleep 0.1
    done
}

# GNU Parallel integration
parallel_process() {
    local cmd="$1"
    local input_file="$2"
    local num_cores="${3:-$(nproc)}"
    
    if command -v parallel >/dev/null 2>&1; then
        parallel -j "$num_cores" "$cmd" :::: "$input_file"
    else
        # Fallback to xargs
        cat "$input_file" | xargs -P "$num_cores" -I {} $cmd {}
    fi
}

# Process files in parallel
parallel_file_processor() {
    local input_dir="$1"
    local output_dir="$2"
    local processor="$3"
    local max_parallel="${4:-4}"
    
    mkdir -p "$output_dir"
    
    find "$input_dir" -type f -name "*.txt" | \
    xargs -P "$max_parallel" -I {} \
        bash -c '
            input="{}"
            output="$3/${input##*/}"
            eval "$2" "$input" "$output"
        ' _ {} "$processor" "$output_dir"
}

# Parallel log processing
process_logs_parallel() {
    local log_dir="$1"
    local pattern="$2"
    local output_file="$3"
    
    local temp_dir=$(mktemp -d)
    
    # Split log file
    split -l 10000 "$log_dir" "${temp_dir}/chunk_"
    
    # Process chunks in parallel
    for chunk in "${temp_dir}/chunk_"*; do
        grep "$pattern" "$chunk" >> "${temp_dir}/results.txt" &
    done
    
    wait
    
    # Combine results
    sort "${temp_dir}/results.txt" > "$output_file"
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Throttled execution
throttled_execution() {
    local rate="$1"
    shift
    local cmd="$@"
    
    (
        while true; do
            eval "$cmd"
            sleep "$rate"
        done
    ) &
    
    echo $!
}
```

#### 3.2 Performance Optimization

**Problem Statement:** You need to optimize slow shell scripts, identify bottlenecks, and improve execution time.

**Solution:**
```bash
#!/bin/bash

# Performance optimization techniques

# Use built-ins instead of external commands where possible
optimize_string_operations() {
    # Slow: Use external command
    # count=$(echo "$string" | wc -c)
    
    # Fast: Use built-in
    count=${#string}
    
    # Slow: Use external command
    # upper=$(echo "$str" | tr '[:lower:]' '[:upper:]')
    
    # Fast: Use parameter expansion
    upper="${str^^}"
}

# Optimize loops
optimize_loop() {
    # Slow: Multiple subshells in loop
    # for item in "${array[@]}"; do
    #     result=$(process "$item")
    # done
    
    # Fast: Batch processing
    # Use process substitution or pipe
    printf '%s\n' "${array[@]}" | \
        while IFS= read -r item; do
            process "$item"
        done
    
    # Fastest: Direct array manipulation
    for item in "${array[@]}"; do
        # Inline processing
        :
    done
}

# Reduce subshell usage
reduce_subshells() {
    # Slow: Multiple subshells
    # dir=$(dirname "$path")
    # base=$(basename "$path")
    # ext="${base##*.}"
    
    # Fast: Single parameter expansion
    dir="${path%/*}"
    base="${path##*/}"
    ext="${base##*.}"
}

# Use awk instead of multiple pipes
optimize_text_processing() {
    # Slow: Multiple pipes
    # cat file | grep pattern | cut -d: -f2 | sort | uniq
    
    # Fast: Single awk
    # awk '/pattern/ {print $2}' file | sort | uniq
    
    # Faster: Pure awk with associative array
    awk '/pattern/ {count[$2]++} END {for (k in count) print k, count[k]}' file
}

# Batch file operations
batch_file_operations() {
    # Slow: Individual file operations
    # for file in *.txt; do
    #     gzip "$file"
    # done
    
    # Fast: Parallel gzip
    # find . -name "*.txt" -exec gzip {} +
    
    # Or use pigz for multi-threaded compression
    # find . -name "*.txt" -print0 | xargs -0 -P 4 pigz
}

# Optimize awk scripts
optimize_awk() {
    # Put BEGIN block first
    # Use FS and OFS
    # Minimize field splitting if not needed
    # Use NR and FNR correctly
    
    awk 'BEGIN {
        FS=","
        OFS="\t"
    }
    NR > 1 {
        # Only process if needed
        if ($3 > 100) {
            print $1, $2, $3
        }
    }' "$file"
}

# Profile script execution
profile_script() {
    local start_time=$(date +%s.%N)
    
    # Your script code here
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    echo "Execution time: ${duration}s"
}

# Cache expensive operations
declare -A CACHE=()
cache_result() {
    local key="$1"
    shift
    local cmd="$@"
    
    if [ -v CACHE[$key] ]; then
        echo "${CACHE[$key]}"
    else
        local result=$(eval "$cmd")
        CACHE[$key]="$result"
        echo "$result"
    fi
}
```

#### 3.3 Resource Management

**Problem Statement:** You need to manage system resources (CPU, memory, disk) within shell scripts to prevent resource exhaustion.

**Solution:**
```bash
#!/bin/bash

# Resource management utilities

# Limit memory usage
limit_memory() {
    local limit_mb="${1:-512}"
    local limit_kb=$((limit_mb * 1024))
    
    ulimit -v "$limit_kb"
    ulimit -m "$limit_kb"
}

# Limit CPU time
limit_cpu() {
    local limit_seconds="${1:-300}"
    
    ulimit -t "$limit_seconds"
}

# Monitor resource usage
monitor_resources() {
    local pid="$1"
    local interval="${2:-1}"
    
    while kill -0 "$pid" 2>/dev/null; do
        # CPU usage
        cpu=$(ps -p "$pid" -o %cpu= 2>/dev/null || echo 0)
        
        # Memory usage
        mem=$(ps -p "$pid" -o %mem= 2>/dev/null || echo 0)
        
        # RSS in KB
        rss=$(ps -p "$pid" -o rss= 2>/dev/null || echo 0)
        
        echo "[$(date '+%H:%M:%S')] CPU: ${cpu}% MEM: ${mem}% RSS: ${rss}KB"
        
        sleep "$interval"
    done
}

# Resource-limited execution
run_with_limits() {
    local max_cpu="$1"
    local max_mem="$2"
    shift 2
    local cmd="$@"
    
    (
        # Set resource limits
        [ -n "$max_cpu" ] && ulimit -t "$max_cpu"
        [ -n "$max_mem" ] && ulimit -v "$((max_mem * 1024))"
        
        eval "$cmd"
    )
}

# Check available resources
check_resources() {
    echo "=== Resource Check ==="
    
    # CPU load
    echo -n "CPU Load (1/5/15 min): "
    uptime | awk -F'load average:' '{print $2}'
    
    # Memory
    free -h | grep Mem
    
    # Disk
    df -h / | tail -1
    
    # Available processes
    echo "Available processes: $(ulimit -u)"
}

# Adaptive parallelism based on resources
adaptive_parallel() {
    local base_load=($(uptime | awk -F'load average:' '{print $2}' | tr ',' ' ' | xargs))
    local cores=$(nproc)
    local load_1min="${base_load[0]}"
    
    # Calculate safe parallelism
    # If load is 4 and we have 8 cores, we can run 4 more jobs
    local safe_jobs=$((cores - $(echo "$load_1min" | cut -d. -f1)))
    [ "$safe_jobs" -lt 1 ] && safe_jobs=1
    
    echo "Recommended parallelism: $safe_jobs"
    
    return "$safe_jobs"
}
```

### 💡 Practice Exercise 3.1

**Task:** Create a parallel file processing system that:
1. Processes multiple files concurrently using configurable parallelism
2. Implements a job queue with priority support
3. Monitors resource usage and adapts parallelism dynamically
4. Provides progress reporting and completion statistics
5. Handles failures gracefully and implements retry logic
6. Supports interruption and resumption

**Solution:** See `exercises/exercise_3_1_solution.sh`

---

## Day 4: Network Operations

### 🎯 Learning Goals
- Perform network operations from shell scripts
- Implement HTTP clients and servers
- Handle network errors and timeouts
- Create network monitoring tools

### 📚 Topics Covered

#### 4.1 HTTP Operations

**Problem Statement:** You need to make HTTP requests, download files, and interact with REST APIs from shell scripts.

**Solution:**
```bash
#!/bin/bash

# HTTP utilities

# Simple HTTP GET request
http_get() {
    local url="$1"
    local timeout="${2:-30}"
    
    if command -v curl >/dev/null 2>&1; then
        curl -s --max-time "$timeout" "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O - --timeout="$timeout" "$url"
    else
        echo "Error: No HTTP client available" >&2
        return 1
    fi
}

# HTTP POST request
http_post() {
    local url="$1"
    local data="$2"
    local content_type="${3:-application/json}"
    local timeout="${4:-30}"
    
    curl -s --max-time "$timeout" \
        -X POST \
        -H "Content-Type: $content_type" \
        -d "$data" \
        "$url"
}

# Download with retry
download_with_retry() {
    local url="$1"
    local output="$2"
    local max_retries="${3:-3}"
    local timeout="${4:-60}"
    
    local attempt=1
    
    while [ $attempt -le $max_retries ]; do
        echo "Download attempt $attempt/$max_retries..."
        
        if curl -s --max-time "$timeout" -o "$output" "$url"; then
            if [ -s "$output" ]; then
                echo "Download successful: $output"
                return 0
            fi
        fi
        
        echo "Attempt $attempt failed, retrying..."
        ((attempt++))
        sleep 2
    done
    
    echo "Download failed after $max_retries attempts"
    return 1
}

# API request with authentication
api_request() {
    local method="$1"
    local url="$2"
    local token="${3:-}"
    local data="${4:-}"
    
    local auth_header=""
    [ -n "$token" ] && auth_header="-H 'Authorization: Bearer $token'"
    
    local data_arg=""
    [ -n "$data" ] && data_arg="-d '$data'"
    
    eval curl -s -X "$method" \
        -H 'Content-Type: application/json' \
        $auth_header \
        $data_arg \
        "$url"
}

# Check HTTP status
http_status() {
    local url="$1"
    
    curl -s -o /dev/null -w "%{http_code}" "$url"
}

# Check if endpoint is healthy
health_check() {
    local url="$1"
    local expected_status="${2:-200}"
    local timeout="${3:-10}"
    
    local status=$(http_status "$url")
    
    if [ "$status" = "$expected_status" ]; then
        echo "Healthy: $url (status: $status)"
        return 0
    else
        echo "Unhealthy: $url (status: $status)"
        return 1
    fi
}

# REST API wrapper
api_wrapper() {
    local base_url="$1"
    local endpoint="$2"
    local method="${3:-GET}"
    local token="$4"
    local data="$5"
    
    local url="${base_url}${endpoint}"
    
    case "$method" in
        GET)
            http_get "$url" 30
            ;;
        POST)
            http_post "$url" "$data" "application/json"
            ;;
        PUT)
            curl -s -X PUT \
                -H "Authorization: Bearer $token" \
                -H "Content-Type: application/json" \
                -d "$data" \
                "$url"
            ;;
        DELETE)
            curl -s -X DELETE \
                -H "Authorization: Bearer $token" \
                "$url"
            ;;
        *)
            echo "Unsupported method: $method"
            return 1
            ;;
    esac
}
```

#### 4.2 Network Diagnostics

**Problem Statement:** You need to perform network diagnostics, check connectivity, and troubleshoot network issues from scripts.

**Solution:**
```bash
#!/bin/bash

# Network diagnostics

# Ping with timeout
ping_host() {
    local host="$1"
    local count="${2:-3}"
    local timeout="${3:-5}"
    
    if ping -c "$count" -W "$timeout" "$host" >/dev/null 2>&1; then
        echo "Host reachable: $host"
        return 0
    else
        echo "Host unreachable: $host"
        return 1
    fi
}

# Port check
check_port() {
    local host="$1"
    local port="$2"
    local timeout="${3:-5}"
    
    if command -v nc >/dev/null 2>&1; then
        if nc -zw "$timeout" "$host" "$port" 2>/dev/null; then
            echo "Port open: $host:$port"
            return 0
        else
            echo "Port closed: $host:$port"
            return 1
        fi
    elif command -v timeout >/dev/null 2>&1; then
        (echo >/dev/tcp/"$host"/"$port") 2>/dev/null && \
            echo "Port open: $host:$port" && return 0
        echo "Port closed: $host:$port"
        return 1
    else
        # Fallback using curl
        if timeout "$timeout" curl -s "http://$host:$port" >/dev/null 2>&1; then
            echo "Port open: $host:$port"
            return 0
        fi
        echo "Port closed or filtered: $host:$port"
        return 1
    fi
}

# DNS lookup
dns_lookup() {
    local domain="$1"
    
    if command -v dig >/dev/null 2>&1; then
        dig +short "$domain" | tail -1
    elif command -v nslookup >/dev/null 2>&1; then
        nslookup "$domain" | awk '/^Address: / {print $2; exit}'
    else
        getent hosts "$domain" | awk '{print $1; exit}'
    fi
}

# Trace route
trace_route() {
    local host="$1"
    local max_hops="${2:-30}"
    
    if command -v traceroute >/dev/null 2>&1; then
        traceroute -m "$max_hops" "$host"
    elif command -v tracepath >/dev/null 2>&1; then
        tracepath -m "$max_hops" "$host"
    else
        # Fallback using ping with TTL
        for ttl in $(seq 1 "$max_hops"); do
            result=$(ping -c 1 -t "$ttl" -W 2 "$host" 2>&1 | grep "from")
            echo "TTL $ttl: $result"
        done
    fi
}

# Bandwidth test
bandwidth_test() {
    local host="${1:-8.8.8.8}"
    
    # Simple RTT-based estimate
    local avg_rtt=$(ping -c 10 "$host" | awk -F'/' '/^rtt|^round-trip/ {print $5}')
    
    echo "Average RTT: ${avg_rtt}ms"
    
    # Rough bandwidth estimate (not accurate, just indicative)
    if command -v bc >/dev/null 2>&1; then
        local bw=$(echo "scale=2; 1500 * 8 / ($avg_rtt / 1000) / 1000000" | bc)
        echo "Estimated bandwidth: ${bw} Mbps"
    fi
}

# Network interface info
network_info() {
    echo "=== Network Interfaces ==="
    ip addr show
    
    echo ""
    echo "=== Routing Table ==="
    ip route show
    
    echo ""
    echo "=== Active Connections ==="
    ss -tuln | head -20
    
    echo ""
    echo "=== DNS Servers ==="
    cat /etc/resolv.conf
}

# Comprehensive connectivity test
test_connectivity() {
    local host="$1"
    local timeout="${2:-5}"
    
    echo "Testing connectivity to: $host"
    echo "================================"
    
    # DNS resolution
    echo -n "DNS Resolution: "
    if dns_lookup "$host" >/dev/null; then
        echo "OK"
    else
        echo "FAILED"
    fi
    
    # ICMP ping
    echo -n "ICMP Ping: "
    if ping -c 1 -W "$timeout" "$host" >/dev/null 2>&1; then
        echo "OK"
    else
        echo "FAILED"
    fi
    
    # Common ports
    for port in 22 80 443; do
        echo -n "Port $port: "
        check_port "$host" "$port" "$timeout"
    done
}
```

#### 4.3 Socket Operations

**Problem Statement:** You need to create network services or communicate via sockets for IPC (Inter-Process Communication).

**Solution:**
```bash
#!/bin/bash

# Socket operations

# Create a simple TCP server
tcp_server() {
    local port="$1"
    local handler="$2"
    
    # Using netcat
    while true; do
        echo "Listening on port $port..."
        cat /tmp/server.sock &
        nc -l -p "$port" > /tmp/client.sock
        
        # Handle client in background
        (
            cat /tmp/client.sock | while IFS= read -r line; do
                eval "$handler" "$line"
            done > /tmp/server.sock
        ) &
    done
}

# Simple TCP client
tcp_client() {
    local host="$1"
    local port="$2"
    
    nc "$host" "$port"
}

# UDP server
udp_server() {
    local port="$1"
    
    nc -ul -p "$port"
}

# Unix socket communication
unix_socket_server() {
    local socket="/tmp/myapp.sock"
    
    # Clean up old socket
    rm -f "$socket"
    
    # Create socket server
    while true; do
        nc -l -U "$socket" | \
        while IFS= read -r line; do
            echo "Received: $line"
            echo "Response: OK"
        done
    done
}

# Test port availability
is_port_available() {
    local port="$1"
    
    if command -v ss >/dev/null 2>&1; then
        ! ss -tuln | grep -q ":$port "
    elif command -v netstat >/dev/null 2>&1; then
        ! netstat -tuln | grep -q ":$port "
    else
        ! nc -z localhost "$port" 2>/dev/null
    fi
}

# Find available port
find_available_port() {
    local start="${1:-8000}"
    local end="${2:-9000}"
    
    for port in $(seq "$start" "$end"); do
        if is_port_available "$port"; then
            echo "$port"
            return 0
        fi
    done
    
    echo "No available port found" >&2
    return 1
}
```

### 💡 Practice Exercise 4.1

**Task:** Create a network monitoring script that:
1. Monitors multiple hosts and ports for availability
2. Checks HTTP endpoints and validates responses
3. Measures response times and latency
4. Sends alerts when services become unavailable
5. Generates availability reports
6. Supports configuration file for monitored endpoints

**Solution:** See `exercises/exercise_4_1_solution.sh`

---

## Day 5: Database Operations

### 🎯 Learning Goals
- Connect to databases from shell scripts
- Execute queries and process results
- Perform backup and restore operations
- Handle database errors

### 📚 Topics Covered

#### 5.1 MySQL/MariaDB Operations

**Problem Statement:** You need to interact with MySQL databases from shell scripts for backup, restore, monitoring, and administrative tasks.

**Solution:**
```bash
#!/bin/bash

# MySQL/MariaDB utilities

# MySQL connection parameters
MYSQL_HOST="${MYSQL_HOST:-localhost}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASS="${MYSQL_PASS:-}"
MYSQL_DATABASE="${MYSQL_DATABASE:-}"

# Execute query
mysql_query() {
    local query="$1"
    local database="${2:-$MYSQL_DATABASE}"
    
    local args=(-h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER")
    [ -n "$MYSQL_PASS" ] && args+=(-p"$MYSQL_PASS")
    [ -n "$database" ] && args+=("$database")
    
    mysql -N "${args[@]}" -e "$query" 2>/dev/null
}

# Execute query with output
mysql_query_output() {
    local query="$1"
    local database="${2:-$MYSQL_DATABASE}"
    
    mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" \
        ${MYSQL_PASS:+-p"$MYSQL_PASS"} \
        ${database:+-D "$database"} \
        -e "$query"
}

# Check if database exists
mysql_database_exists() {
    local db="$1"
    
    mysql_query "SHOW DATABASES LIKE '$db'" | grep -q "$db"
}

# Get table list
mysql_list_tables() {
    local database="$1"
    
    mysql_query "SHOW TABLES" "$database"
}

# Get table row count
mysql_table_count() {
    local database="$1"
    local table="$2"
    
    mysql_query "SELECT COUNT(*) FROM \`$table\`" "$database"
}

# Backup database
mysql_backup() {
    local database="$1"
    local output_file="$2"
    
    local args=(-h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER")
    [ -n "$MYSQL_PASS" ] && args+=(-p"$MYSQL_PASS")
    
    mysqldump "${args[@]}" \
        --single-transaction \
        --quick \
        --lock-tables=false \
        "$database" | \
        gzip > "$output_file"
    
    echo "Backup created: $output_file"
}

# Backup all databases
mysql_backup_all() {
    local output_dir="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    mkdir -p "$output_dir"
    
    local args=(-h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER")
    [ -n "$MYSQL_PASS" ] && args+=(-p"$MYSQL_PASS")
    
    # Backup all databases
    mysqldump "${args[@]}" --all-databases | \
        gzip > "$output_dir/all_databases_${timestamp}.sql.gz"
    
    # Individual database backups
    for db in $(mysql_query "SHOW DATABASES"); do
        [ "$db" = "information_schema" ] && continue
        [ "$db" = "performance_schema" ] && continue
        [ "$db" = "mysql" ] && continue
        
        mysqldump "${args[@]}" --single-transaction "$db" | \
            gzip > "$output_dir/${db}_${timestamp}.sql.gz"
    done
    
    echo "All backups created in: $output_dir"
}

# Restore database
mysql_restore() {
    local database="$1"
    local backup_file="$2"
    
    gunzip < "$backup_file" | \
        mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" \
            ${MYSQL_PASS:+-p"$MYSQL_PASS"} \
            ${database:+-D "$database"}
    
    echo "Database restored from: $backup_file"
}

# Monitor database health
mysql_health_check() {
    echo "=== MySQL Health Check ==="
    
    # Connection test
    echo -n "Connection: "
    if mysql_query "SELECT 1" >/dev/null 2>&1; then
        echo "OK"
    else
        echo "FAILED"
    fi
    
    # Slave replication status
    echo -n "Replication: "
    local slave_status=$(mysql_query "SHOW SLAVE STATUS\G" 2>/dev/null)
    if [ -n "$slave_status" ]; then
        echo "Configured"
    else
        echo "N/A (standalone)"
    fi
    
    # InnoDB status
    echo "InnoDB Buffer Pool:"
    mysql_query "SHOW ENGINE INNODB STATUS\G" | head -30
    
    # Table status
    echo ""
    echo "Database Sizes:"
    mysql_query "SELECT TABLE_SCHEMA, ROUND(SUM(DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS 'Size (MB)' FROM information_schema.TABLES GROUP BY TABLE_SCHEMA"
}
```

#### 5.2 PostgreSQL Operations

**Problem Statement:** You need to interact with PostgreSQL databases from shell scripts for similar database operations.

**Solution:**
```bash
#!/bin/bash

# PostgreSQL utilities

# PostgreSQL connection parameters
PG_HOST="${PG_HOST:-localhost}"
PG_PORT="${PG_PORT:-5432}"
PG_USER="${PG_USER:-postgres}"
PG_DATABASE="${PG_DATABASE:-}"

# Execute query
pg_query() {
    local query="$1"
    local database="${2:-$PG_DATABASE}"
    
    PGPASSWORD="${PGPASSWORD:-}" psql \
        -h "$PG_HOST" \
        -p "$PG_PORT" \
        -U "$PG_USER" \
        ${database:+-d "$database"} \
        -t -A -c "$query" 2>/dev/null
}

# Execute query with output
pg_query_output() {
    local query="$1"
    local database="${2:-$PG_DATABASE}"
    
    PGPASSWORD="${PGPASSWORD:-}" psql \
        -h "$PG_HOST" \
        -p "$PG_PORT" \
        -U "$PG_USER" \
        ${database:+-d "$database"} \
        -c "$query"
}

# Check if database exists
pg_database_exists() {
    local db="$1"
    
    pg_query "SELECT 1 FROM pg_database WHERE datname='$db'" postgres | grep -q 1
}

# List tables
pg_list_tables() {
    local database="$1"
    
    pg_query "SELECT tablename FROM pg_tables WHERE schemaname='public'" "$database"
}

# Backup database
pg_backup() {
    local database="$1"
    local output_file="$2"
    
    PGPASSWORD="${PGPASSWORD:-}" pg_dump \
        -h "$PG_HOST" \
        -p "$PG_PORT" \
        -U "$PG_USER" \
        -Fc \
        -f "$output_file" \
        "$database"
    
    echo "Backup created: $output_file"
}

# Backup all databases
pg_backup_all() {
    local output_dir="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    mkdir -p "$output_dir"
    
    for db in $(pg_query "SELECT datname FROM pg_database WHERE datistemplate=false" postgres); do
        PGPASSWORD="${PGPASSWORD:-}" pg_dump \
            -h "$PG_HOST" \
            -p "$PG_PORT" \
            -U "$PG_USER" \
            -Fc \
            -f "$output_dir/${db}_${timestamp}.dump" \
            "$db"
    done
    
    echo "All backups created in: $output_dir"
}

# Restore database
pg_restore() {
    local database="$1"
    local backup_file="$2"
    
    PGPASSWORD="${PGPASSWORD:-}" pg_restore \
        -h "$PG_HOST" \
        -p "$PG_PORT" \
        -U "$PG_USER" \
        -d "$database" \
        --clean \
        --if-exists \
        "$backup_file"
    
    echo "Database restored from: $backup_file"
}

# Check replication status
pg_replication_status() {
    echo "=== PostgreSQL Replication Status ==="
    
    pg_query "SELECT client_addr, state, sent_lsn, write_lsn, flush_lsn, replay_lsn FROM pg_stat_replication" postgres
}

# Vacuum database
pg_vacuum() {
    local database="$1"
    local vacuum_type="${2:-ANALYZE}"
    
    PGPASSWORD="${PGPASSWORD:-}" vacuumdb \
        -h "$PG_HOST" \
        -p "$PG_PORT" \
        -U "$PG_USER" \
        --$vacuum_type \
        --analyze \
        -d "$database"
    
    echo "Vacuum completed: $database"
}
```

#### 5.3 Generic Database Scripts

**Problem Statement:** You need to create database-agnostic scripts that can work with multiple database types.

**Solution:**
```bash
#!/bin/bash

# Generic database utilities

# Database type detection
detect_db_type() {
    if command -v mysql >/dev/null 2>&1; then
        echo "mysql"
    elif command -v psql >/dev/null 2>&1; then
        echo "postgresql"
    elif command -v sqlite3 >/dev/null 2>&1; then
        echo "sqlite"
    else
        echo "unknown"
    fi
}

# Generic backup function
database_backup() {
    local db_type="$1"
    local database="$2"
    local output_file="$3"
    
    case "$db_type" in
        mysql)
            mysql_backup "$database" "$output_file"
            ;;
        postgresql)
            pg_backup "$database" "$output_file"
            ;;
        sqlite)
            sqlite_backup "$database" "$output_file"
            ;;
        *)
            echo "Unsupported database type: $db_type"
            return 1
            ;;
    esac
}

# SQLite backup
sqlite_backup() {
    local database="$1"
    local output_file="$2"
    
    sqlite3 "$database" ".backup '$output_file'"
}

# Table row counts for any database
table_counts() {
    local db_type="$1"
    local database="$2"
    
    case "$db_type" in
        mysql)
            mysql_query "SHOW TABLES" "$database" | while read -r table; do
                local count=$(mysql_table_count "$database" "$table")
                printf "%-30s %10s\n" "$table" "$count"
            done
            ;;
        postgresql)
            pg_query "SELECT tablename FROM pg_tables WHERE schemaname='public'" "$database" | \
            while read -r table; do
                local count=$(pg_query "SELECT COUNT(*) FROM \"$table\"" "$database")
                printf "%-30s %10s\n" "$table" "$count"
            done
            ;;
    esac
}

# Execute SQL from file
execute_sql_file() {
    local db_type="$1"
    local database="$2"
    local sql_file="$3"
    
    case "$db_type" in
        mysql)
            mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" \
                ${MYSQL_PASS:+-p"$MYSQL_PASS"} \
                ${database:+-D "$database"} \
                < "$sql_file"
            ;;
        postgresql)
            PGPASSWORD="${PGPASSWORD:-}" psql \
                -h "$PG_HOST" \
                -p "$PG_PORT" \
                -U "$PG_USER" \
                ${database:+-d "$database"} \
                -f "$sql_file"
            ;;
    esac
}
```

### 💡 Practice Exercise 5.1

**Task:** Create a database administration script that:
1. Performs automated backups with configurable retention
2. Monitors database health and size
3. Checks for slow queries
4. Generates database statistics reports
5. Supports both MySQL and PostgreSQL
6. Includes alerting for critical conditions

**Solution:** See `exercises/exercise_5_1_solution.sh`

---

## Day 6: Production-Ready Scripting

### 🎯 Learning Goals
- Create production-ready scripts with all best practices
- Implement comprehensive configuration management
- Build monitoring and alerting systems
- Document scripts professionally

### 📚 Topics Covered

#### 6.1 Configuration Management

**Problem Statement:** You need to create scripts that are configurable, support multiple environments, and can be deployed consistently across systems.

**Solution:**
```bash
#!/bin/bash

# Configuration management framework

# Configuration file locations (in order of precedence)
# 1. /etc/<app>/config.conf
# 2. ~/.config/<app>/config.conf
# 3. ./config.conf
# 4. Environment variables

# Default configuration
DEFAULT_CONFIG='
# Application Settings
APP_NAME="myapp"
APP_VERSION="1.0.0"
LOG_LEVEL="INFO"
LOG_FILE="/var/log/myapp.log"

# Network Settings
NETWORK_TIMEOUT=30
MAX_RETRIES=3

# Database Settings
DB_HOST="localhost"
DB_PORT=3306
DB_NAME="myapp_db"
DB_USER="myapp"
DB_PASS=""

# Monitoring
ENABLE_MONITORING=true
METRICS_PORT=9090

# Features
ENABLE_CACHE=true
CACHE_TTL=3600
'

# Load configuration
load_config() {
    local config_file="${1:-}"
    
    # Create default config if it doesn't exist
    if [ -z "$config_file" ]; then
        # Try standard locations
        for loc in "/etc/${APP_NAME:-myapp}/config.conf" \
                   "~/.config/${APP_NAME:-myapp}/config.conf" \
                   "./config.conf"; do
            if [ -f "$loc" ]; then
                config_file="$loc"
                break
            fi
        done
    fi
    
    # Load from file if exists
    if [ -f "$config_file" ]; then
        source "$config_file"
    fi
    
    # Override with environment variables
    # These take highest precedence
    APP_NAME="${APP_NAME:-${APP_NAME}}"
    LOG_LEVEL="${LOG_LEVEL:-INFO}"
    LOG_FILE="${LOG_FILE:-/var/log/${APP_NAME:-myapp}.log}"
    
    # Export all config variables
    export APP_NAME APP_VERSION LOG_LEVEL LOG_FILE
    export NETWORK_TIMEOUT MAX_RETRIES
    export DB_HOST DB_PORT DB_NAME DB_USER DB_PASS
    export ENABLE_MONITORING METRICS_PORT
    export ENABLE_CACHE CACHE_TTL
}

# Validate configuration
validate_config() {
    local errors=0
    
    # Check required variables
    [ -z "$APP_NAME" ] && { echo "Error: APP_NAME is required"; ((errors++)); }
    [ -z "$LOG_FILE" ] && { echo "Error: LOG_FILE is required"; ((errors++)); }
    
    # Validate numeric ranges
    if [ -n "$NETWORK_TIMEOUT" ] && [ "$NETWORK_TIMEOUT" -lt 1 ]; then
        echo "Error: NETWORK_TIMEOUT must be positive"
        ((errors++))
    fi
    
    if [ -n "$DB_PORT" ] && [ "$DB_PORT" -lt 1 ] || [ "$DB_PORT" -gt 65535 ]; then
        echo "Error: DB_PORT must be between 1 and 65535"
        ((errors++))
    fi
    
    # Validate log level
    case "$LOG_LEVEL" in
        DEBUG|INFO|WARN|ERROR|FATAL) ;;
        *)
            echo "Error: Invalid LOG_LEVEL: $LOG_LEVEL"
            ((errors++))
            ;;
    esac
    
    return $errors
}

# Generate sample configuration
generate_sample_config() {
    cat <<'EOF'
# Sample Configuration File
# Copy to appropriate location and modify

# Application Settings
APP_NAME="myapp"
APP_VERSION="1.0.0"
LOG_LEVEL="INFO"
LOG_FILE="/var/log/myapp.log"

# Network Settings
NETWORK_TIMEOUT=30
MAX_RETRIES=3

# Database Settings
DB_HOST="localhost"
DB_PORT=3306
DB_NAME="myapp_db"
DB_USER="myapp"
DB_PASS="secretpassword"

# Monitoring
ENABLE_MONITORING=true
METRICS_PORT=9090

# Features
ENABLE_CACHE=true
CACHE_TTL=3600
EOF
}
```

#### 6.2 Monitoring and Metrics

**Problem Statement:** You need to create scripts that expose metrics and integrate with monitoring systems.

**Solution:**
```bash
#!/bin/bash

# Monitoring and metrics framework

# Metrics storage
declare -A METRICS_COUNTERS=()
declare -A METRICS_GAUGES=()
declare -A METRICS_HISTOGRAMS=()

# Counter metric
counter_inc() {
    local name="$1"
    local value="${2:-1}"
    
    METRICS_COUNTERS[$name]=$((METRICS_COUNTERS[$name] + value))
}

# Gauge metric
gauge_set() {
    local name="$1"
    local value="$2"
    
    METRICS_GAUGES[$name]="$value"
}

# Histogram metric (simplified)
histogram_observe() {
    local name="$1"
    local value="$2"
    
    if [ -z "${METRICS_HISTOGRAMS[$name]}" ]; then
        METRICS_HISTOGRAMS[$name]="$value"
    else
        METRICS_HISTOGRAMS[$name]="${METRICS_HISTOGRAMS[$name]},$value"
    fi
}

# Prometheus format output
metrics_prometheus() {
    local metric_type="$1"
    local metric_name="$2"
    local value="$3"
    local labels="${4:-}"
    
    local label_str=""
    if [ -n "$labels" ]; then
        label_str="{${labels}}"
    fi
    
    echo "${metric_name}${label_str} ${value}"
}

# Export all metrics in Prometheus format
export_metrics() {
    echo "# HELP application_info Application information"
    echo "# TYPE application_info gauge"
    echo "application_info{version=\"${APP_VERSION:-unknown}\"} 1"
    echo ""
    
    echo "# Counters"
    for name in "${!METRICS_COUNTERS[@]}"; do
        echo "# TYPE $name counter"
        metrics_prometheus "counter" "$name" "${METRICS_COUNTERS[$name]}"
    done
    echo ""
    
    echo "# Gauges"
    for name in "${!METRICS_GAUGES[@]}"; do
        echo "# TYPE $name gauge"
        metrics_prometheus "gauge" "$name" "${METRICS_GAUGES[$name]}"
    done
    echo ""
    
    echo "# Histograms"
    for name in "${!METRICS_HISTOGRAMS[@]}"; do
        echo "# TYPE $name histogram"
        local values="${METRICS_HISTOGRAMS[$name]}"
        local sum=0
        local count=0
        for v in $(echo "$values" | tr ',' ' '); do
            sum=$(echo "$sum + $v" | bc)
            ((count++))
        done
        metrics_prometheus "histogram" "${name}_sum" "$sum"
        metrics_prometheus "histogram" "${name}_count" "$count"
    done
}

# Start metrics server (simple HTTP server)
start_metrics_server() {
    local port="${1:-9090}"
    local metrics_file="/tmp/metrics_output"
    
    # Create metrics output function
    export_metrics > "$metrics_file"
    
    # Simple HTTP server using netcat
    while true; do
        cat "$metrics_file" | nc -l -p "$port" -q 1
    done &
    
    echo "Metrics server started on port $port"
}

# Health check endpoint
health_check() {
    echo "{
  \"status\": \"healthy\",
  \"timestamp\": \"$(date -Iseconds)\",
  \"uptime\": $(cut -d. -f1 /proc/uptime),
  \"version\": \"${APP_VERSION:-unknown}\"
}"
}
```

#### 6.3 Service Integration

**Problem Statement:** You need to integrate scripts with system services, systemd, and container environments.

**Solution:**
```bash
#!/bin/bash

# Service integration framework

# Systemd integration
systemd_service() {
    cat <<'EOF'
[Unit]
Description=My Application
After=network.target mysql.service
Wants=network-online.target

[Service]
Type=simple
User=myapp
Group=myapp
WorkingDirectory=/opt/myapp
ExecStartPre=/usr/local/bin/myapp-check.sh
ExecStart=/usr/local/bin/myapp.sh
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=/bin/kill -TERM $MAINPID
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp

# Security hardening
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/log/myapp /var/run
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
}

# Docker integration
docker_wrapper() {
    local container_name="$1"
    shift
    local cmd="$@"
    
    # Check if container exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        docker exec "$container_name" $cmd
    else
        echo "Container not found: $container_name"
        return 1
    fi
}

# Container health monitoring
docker_health_monitor() {
    local container="$1"
    local interval="${2:-30}"
    
    while true; do
        local status=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null)
        
        if [ "$status" = "healthy" ]; then
            log_info "Container $container is healthy"
        else
            log_error "Container $container is $status"
            # Restart container
            docker restart "$container"
        fi
        
        sleep "$interval"
    done
}

# Kubernetes integration
kubectl_wrapper() {
    local namespace="${KUBERNETES_NAMESPACE:-default}"
    local resource="$1"
    local name="$2"
    shift 3
    
    kubectl -n "$namespace" "$resource" "$name" "$@"
}

# Get pod logs
kubectl_logs() {
    local pod="$1"
    local namespace="${2:-default}"
    local tail="${3:-100}"
    
    kubectl -n "$namespace" logs "$pod" --tail="$tail"
}

# Scale deployment
kubectl_scale() {
    local deployment="$1"
    local replicas="$2"
    local namespace="${3:-default}"
    
    kubectl -n "$namespace" scale deployment "$deployment" --replicas="$replicas"
}

# Check deployment status
kubectl_deployment_status() {
    local deployment="$1"
    local namespace="${2:-default}"
    
    kubectl -n "$namespace" rollout status deployment "$deployment"
}

# Professional documentation template
generate_docs() {
    cat <<'EOF'
# My Application

## Overview
Brief description of the application and its purpose.

## Requirements
- Software requirements
- Hardware requirements
- Network requirements

## Installation
Step-by-step installation instructions.

## Configuration
Configuration options and examples.

## Usage
Usage examples and command reference.

## Troubleshooting
Common issues and solutions.

## Security
Security considerations and best practices.

## License
License information.
EOF
}

# Usage documentation
show_help() {
    cat <<EOF
${APP_NAME:-myapp} - Application description

USAGE:
    ${0##*/} [OPTIONS] COMMAND

COMMANDS:
    start       Start the application
    stop        Stop the application
    restart     Restart the application
    status      Show application status
    config      Show current configuration
    logs        Show application logs
    help        Show this help message

OPTIONS:
    -c, --config FILE    Use configuration file
    -d, --debug          Enable debug mode
    -v, --verbose        Verbose output
    -h, --help           Show this help message
    -V, --version        Show version

EXAMPLES:
    ${0##*/} start
    ${0##*/} -d restart
    ${0##*/} --config /etc/myapp.conf status

For more information, see documentation.
EOF
}

### 💡 Practice Exercise 6.1

**Task:** Create a complete production-ready application script that:
1. Uses comprehensive configuration management
2. Implements all error handling and logging best practices
3. Provides systemd service integration
4. Exposes metrics in Prometheus format
5. Includes health check endpoints
6. Has professional documentation and help system

**Solution:** See `exercises/exercise_6_1_solution.sh`

---

## Day 7: Security Best Practices

### 🎯 Learning Goals
- Apply security best practices in shell scripts
- Handle sensitive data securely
- Implement proper input validation
- Use secure coding patterns

### 📚 Topics Covered

#### 7.1 Secure Scripting Patterns

**Problem Statement:** You need to write scripts that handle sensitive data securely, prevent common vulnerabilities, and follow security best practices.

**Solution:**
```bash
#!/bin/bash

# Security best practices framework

# Disable insecure features
set -euo pipefail
IFS=$'\n\t'

# Never trust environment
PATH="/usr/local/bin:/usr/bin:/bin"
export PATH

# Secure temp file creation
create_secure_temp() {
    local temp_file
    temp_file=$(mktemp) || return 1
    chmod 600 "$temp_file"
    echo "$temp_file"
}

# Secure temp directory
create_secure_tempdir() {
    local temp_dir
    temp_dir=$(mktemp -d) || return 1
    chmod 700 "$temp_dir"
    echo "$temp_dir"
}

# Secure password handling
read_password() {
    local prompt="${1:-Enter password: }"
    local password
    
    read -s -p "$prompt" password
    echo
    
    # Don't store in history
    history -d $((HISTCMD - 1)) 2>/dev/null || true
    
    echo "$password"
}

# Validate input thoroughly
validate_input() {
    local input="$1"
    local type="$2"
    local max_length="${3:-1000}"
    
    # Length check
    if [ ${#input} -gt "$max_length" ]; then
        return 1
    fi
    
    # Type-specific validation
    case "$type" in
        alphanumeric)
            [[ "$input" =~ ^[a-zA-Z0-9]+$ ]]
            ;;
        email)
            [[ "$input" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
            ;;
        filename)
            # No path separators, no special chars
            [[ "$input" =~ ^[a-zA-Z0-9._-]+$ ]]
            ;;
        integer)
            [[ "$input" =~ ^-?[0-9]+$ ]]
            ;;
        path)
            # Sanitize path
            [[ "$input" =~ ^[/a-zA-Z0-9._-]+$ ]]
            ;;
        *)
            return 0
            ;;
    esac
}

# Sanitize environment
sanitize_environment() {
    # Clear potentially dangerous variables
    unset BASH_ENV ENV
    
    # Disable filename generation
    set -f
    
    # Export restricted PATH
    export PATH="/usr/local/bin:/usr/bin:/bin"
}

# Secure command execution
secure_execute() {
    local cmd="$1"
    shift
    local args=("$@")
    
    # Whitelist approach
    local allowed_commands=("ls" "cat" "grep" "awk" "sed")
    
    # Validate command is in whitelist
    local found=0
    for allowed in "${allowed_commands[@]}"; do
        if [ "$cmd" = "$allowed" ]; then
            found=1
            break
        fi
    done
    
    if [ $found -eq 0 ]; then
        echo "Command not allowed: $cmd" >&2
        return 1
    fi
    
    # Execute with quoted arguments
    "$cmd" "${args[@]}"
}

# Input sanitization for shell commands
sanitize_for_shell() {
    local input="$1"
    
    # Remove dangerous characters
    input="${input//;/}"
    input="${input//|/}"
    input="${input//`/}"
    input="${input//$/}"
    input="${input//>/}"
    input="${input//</}"
    input="${input//|/}"
    input="${input//\\//}"
    
    echo "$input"
}

# Secure file permissions
secure_file_permissions() {
    local file="$1"
    local expected_perms="${2:-600}"
    
    # Set correct owner
    chown "$USER:$USER" "$file" 2>/dev/null || true
    
    # Set correct permissions
    chmod "$expected_perms" "$file"
}

# Audit trail
audit_log() {
    local action="$1"
    local user="$USER"
    local timestamp=$(date -Iseconds)
    local pid=$$
    
    echo "[$timestamp] AUDIT: user=$user pid=$pid action=$action" >> /var/log/audit.log
}
```

#### 7.2 Secrets Management

**Problem Statement:** You need to handle passwords, API keys, and other sensitive data securely in scripts.

**Solution:**
```bash
#!/bin/bash

# Secrets management utilities

# Hash passwords
hash_password() {
    local password="$1"
    local salt=$(head -c 16 /dev/urandom | base64)
    
    echo "$password" | openssl passwd -6 -salt "$salt" -
}

# Verify password against hash
verify_password() {
    local password="$1"
    local hash="$2"
    
    echo "$password" | openssl passwd -6 -r 6 -stdin <<< "$password" | \
        grep -q "$hash"
}

# Use environment variables for secrets (12-factor app style)
load_secrets_from_env() {
    # Check required secrets
    local required_secrets=(
        "DATABASE_PASSWORD"
        "API_KEY"
        "SECRET_KEY"
    )
    
    for secret in "${required_secrets[@]}"; do
        if [ -z "${!secret}" ]; then
            echo "Error: Required secret $secret not found" >&2
            return 1
        fi
    done
}

# Encrypt sensitive files
encrypt_file() {
    local input="$1"
    local output="$2"
    local password="$3"
    
    openssl enc -aes-256-cbc -salt -pbkdf2 -in "$input" -out "$output" -k "$password"
}

# Decrypt sensitive files
decrypt_file() {
    local input="$1"
    local output="$2"
    local password="$3"
    
    openssl enc -aes-256-cbc -d -pbkdf2 -in "$input" -out "$output" -k "$password"
}

# HashiCorp Vault integration
vault_get_secret() {
    local secret_path="$1"
    local secret_key="${2:-value}"
    
    if ! command -v vault >/dev/null 2>&1; then
        echo "Vault CLI not found" >&2
        return 1
    fi
    
    vault kv get -field="$secret_key" "$secret_path"
}

# AWS Secrets Manager integration
aws_get_secret() {
    local secret_name="$1"
    
    if ! command -v aws >/dev/null 2>&1; then
        echo "AWS CLI not found" >&2
        return 1
    fi
    
    aws secretsmanager get-secret-value \
        --secret-id "$secret_name" \
        --query SecretString \
        --output text
}

# Generate secure random password
generate_password() {
    local length="${1:-32}"
    
    head -c 32 /dev/urandom | base64 | head -c "$length"
}

# Mask secrets in output
mask_secret() {
    local value="$1"
    local visible_chars="${2:-4}"
    
    if [ ${#value} -le $((visible_chars * 2)) ]; then
        echo "****"
        return
    fi
    
    local start="${value:0:$visible_chars}"
    local end="${value: -$visible_chars}"
    
    echo "${start}****${end}"
}
```

#### 7.3 Secure Network Operations

**Problem Statement:** You need to perform network operations securely, including TLS/SSL verification and secure data transfer.

**Solution:**
```bash
#!/bin/bash

# Secure network operations

# HTTPS request with certificate verification
https_request() {
    local url="$1"
    local method="${2:-GET}"
    local data="${3:-}"
    local ca_bundle="${4:-}"
    
    local curl_args=(
        -sS
        --tlsv1.2
        --tls-max 1.2
        -X "$method"
        -w "\n%{http_code}"
    )
    
    # Add CA bundle if provided
    [ -n "$ca_bundle" ] && curl_args+=(--cacert "$ca_bundle")
    
    # Add data if provided
    [ -n "$data" ] && curl_args+=(-d "$data")
    
    curl "${curl_args[@]}" "$url"
}

# Validate SSL certificate
validate_ssl_cert() {
    local host="$1"
    local port="${2:-443}"
    
    echo | openssl s_client -connect "$host:$port" -servername "$host" 2>/dev/null | \
        openssl x509 -noout -dates -subject
}

# Check certificate expiration
check_cert_expiration() {
    local host="$1"
    local port="${2:-443}"
    local warning_days="${3:-30}"
    
    local expiry_date=$(echo | openssl s_client -connect "$host:$port" 2>/dev/null | \
        openssl x509 -noout -enddate 2>/dev/null | \
        cut -d= -f2)
    
    if [ -z "$expiry_date" ]; then
        echo "Unable to get certificate"
        return 1
    fi
    
    local expiry_epoch=$(date -d "$expiry_date" +%s)
    local now_epoch=$(date +%s)
    local days_until_expiry=$(( (expiry_epoch - now_epoch) / 86400 ))
    
    if [ "$days_until_expiry" -lt "$warning_days" ]; then
        echo "WARNING: Certificate expires in $days_until_expiry days"
        return 1
    fi
    
    echo "Certificate expires in $days_until_expiry days"
}

# Secure file transfer
secure_transfer() {
    local source="$1"
    local destination="$2"
    local host="$3"
    local user="${4:-}"
    
    if [ -n "$user" ]; then
        scp -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o IdentitiesOnly=yes \
            "$source" "${user}@${host}:${destination}"
    else
        rsync -avz --checksum \
            -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
            "$source" "${host}:${destination}"
    fi
}

# Verify checksum
verify_checksum() {
    local file="$1"
    local expected_checksum="$2"
    local algorithm="${3:-sha256}"
    
    local actual_checksum=$(${algorithm}sum "$file" | awk '{print $1}')
    
    if [ "$actual_checksum" != "$expected_checksum" ]; then
        echo "Checksum mismatch!"
        echo "Expected: $expected_checksum"
        echo "Actual:   $actual_checksum"
        return 1
    fi
    
    echo "Checksum verified"
}
```

#### 7.4 Security Auditing

**Problem Statement:** You need to audit scripts for security issues and ensure they meet security standards.

**Solution:**
```bash
#!/bin/bash

# Security auditing utilities

# Run shellcheck with security profile
audit_script() {
    local script="$1"
    
    if ! command -v shellcheck >/dev/null 2>&1; then
        echo "ShellCheck not installed"
        return 1
    fi
    
    shellcheck -S error \
        -S warning \
        -x \
        -a \
        --exclude=SC1090,SC1091 \
        "$script"
}

# Check for common vulnerabilities
scan_for_vulnerabilities() {
    local script="$1"
    
    echo "Scanning: $script"
    echo "================================"
    
    # Check for hardcoded passwords
    if grep -qiE 'password|passwd|pwd.*=' "$script"; then
        echo "[!] Potential hardcoded password found"
    fi
    
    # Check for hardcoded IPs
    if grep -qiE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' "$script"; then
        echo "[!] Potential hardcoded IP address found"
    fi
    
    # Check for eval usage
    if grep -q 'eval\s' "$script"; then
        echo "[!] eval usage detected - review carefully"
    fi
    
    # Check for insecure options
    if grep -q 'set\s+[+-]e' "$script"; then
        echo "[+] Proper error handling detected"
    fi
    
    # Check for input validation
    if grep -q 'read.*p.*' "$script"; then
        echo "[+] User input handling detected"
    fi
    
    # Check for logging
    if grep -qi 'log' "$script"; then
        echo "[+] Logging detected"
    fi
}

# Check file permissions
audit_permissions() {
    local path="$1"
    
    echo "Permission audit for: $path"
    echo "================================"
    
    # World-readable sensitive files
    echo "World-readable files:"
    find "$path" -type f -perm -004 2>/dev/null | head -10
    
    # SUID files
    echo ""
    echo "SUID files:"
    find "$path" -type f -perm -4000 2>/dev/null | head -10
    
    # World-writable files
    echo ""
    echo "World-writable files:"
    find "$path" -type f -perm -002 2>/dev/null | head -10
}

# Generate security report
security_report() {
    local script="$1"
    local report_file="${2:-security_report.txt}"
    
    {
        echo "Security Audit Report"
        echo "====================="
        echo "Script: $script"
        echo "Date: $(date)"
        echo ""
        
        echo "ShellCheck Analysis:"
        audit_script "$script" || true
        echo ""
        
        echo "Vulnerability Scan:"
        scan_for_vulnerabilities "$script"
        echo ""
        
        echo "Permission Audit:"
        audit_permissions "$script"
        
    } > "$report_file"
    
    echo "Report generated: $report_file"
}
```

### 💡 Practice Exercise 7.1

**Task:** Create a secure script template that:
1. Implements all security best practices
2. Handles secrets securely (with encryption option)
3. Validates all inputs thoroughly
4. Logs all security-relevant events
5. Passes security audits
6. Includes security documentation

**Solution:** See `exercises/exercise_7_1_solution.sh`

---

## 🎯 Week 3 Summary

### What You Have Learned

**Day 1: Advanced Text Processing**
- Mastered awk for complex data processing
- Learned advanced sed operations
- Combined multiple text processing tools
- Processed structured data formats (JSON, XML, CSV)

**Day 2: Error Handling and Debugging**
- Implemented comprehensive error handling
- Mastered debugging techniques and tools
- Built logging frameworks
- Handled edge cases and validation

**Day 3: Parallel Processing and Performance**
- Executed tasks in parallel
- Optimized script performance
- Managed system resources
- Implemented caching strategies

**Day 4: Network Operations**
- Performed HTTP requests from shell
- Implemented network diagnostics
- Created socket operations
- Built network monitoring tools

**Day 5: Database Operations**
- Connected to MySQL/MariaDB
- Connected to PostgreSQL
- Performed backups and restores
- Monitored database health

**Day 6: Production-Ready Scripting**
- Implemented configuration management
- Built monitoring and metrics systems
- Integrated with systemd and containers
- Created professional documentation

**Day 7: Security Best Practices**
- Applied secure coding patterns
- Handled secrets securely
- Performed secure network operations
- Conducted security audits

### Key Takeaways

1. **Production scripts require comprehensive error handling** - Never assume operations will succeed
2. **Performance matters** - Use built-ins, batch operations, and parallelism where appropriate
3. **Security is paramount** - Validate all inputs, protect secrets, follow least privilege
4. **Modularity wins** - Break complex scripts into functions and libraries
5. **Testing and debugging are essential** - Use proper tools and techniques
6. **Documentation is part of quality** - Professional scripts need professional documentation

### Next Steps

Congratulations on completing the 3-week Linux Shell Scripting Learning Plan! You are now equipped with skills to:
- Write production-quality shell scripts
- Automate complex system administration tasks
- Monitor and maintain Linux systems
- Handle databases and network operations
- Apply security best practices

### Recommended Next Topics

- Advanced systems administration with Ansible
- Container orchestration with Docker and Kubernetes
- CI/CD pipeline development
- Cloud infrastructure automation
- Infrastructure as Code concepts

---

## 📝 Week 3 Project

**Project: Complete System Administration Toolkit**

Create a comprehensive system administration toolkit that integrates all concepts learned over 3 weeks.

### Requirements

1. **Core Components**
   - System monitoring script with metrics export
   - Log aggregation and analysis tool
   - Database backup and monitoring system
   - Network health checker
   - Automated alerting system

2. **Features**
   - Configuration file support
   - Multiple log levels
   - Error handling and recovery
   - Parallel processing where applicable
   - Security best practices
   - Comprehensive documentation

3. **Integration**
   - Unified command structure
   - Shared configuration
   - Cross-component logging
   - Status reporting dashboard

4. **Documentation**
   - Installation guide
   - Configuration reference
   - Usage examples
   - Troubleshooting guide

### Bonus Challenges

- Create systemd service files
- Add Docker support
- Implement API endpoints
- Add Prometheus metrics
- Create web dashboard

**Solution:** See `exercises/week3_project_solution.sh`

---

**Congratulations on completing Week 3!** 🎉

You have successfully completed the entire 3-week Linux Shell Scripting Learning Plan. You now have the skills to tackle complex automation challenges in production environments.

**Ready to level up further?** Explore topics like:
- Infrastructure as Code with Terraform
- Configuration management with Ansible
- Containerization with Docker
- Cloud automation with AWS CLI or Azure CLI

**Happy scripting!**

