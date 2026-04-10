# Week 2: Intermediate - Practical System Administration

**Duration:** 7 Days  
**Level:** Intermediate  
**Focus:** Real-world system administration scenarios, automation, and production-ready scripts

---

## 📋 Week Overview

Building on Week 1 foundations, this week introduces modular scripting with functions, advanced data structures, and practical automation for real system administration tasks. You will learn to create reusable, maintainable, and production-ready scripts.

### Learning Objectives

By the end of Week 2, you will be able to:
- Write modular scripts using functions
- Work with arrays and associative arrays for data manipulation
- Perform advanced string operations
- Automate file system monitoring and maintenance
- Manage processes and background jobs efficiently
- Analyze and aggregate log files
- Schedule automated tasks with cron
- Create backup and restore scripts
- Handle errors gracefully with proper error handling

---

## Day 1: Functions and Modular Scripting

### 🎯 Learning Goals
- Understand the purpose and benefits of functions
- Learn to create and call functions
- Master function parameters and return values
- Apply modular scripting principles

### 📚 Topics Covered

#### 1.1 Introduction to Functions

**Problem Statement:** You need to write scripts that perform similar tasks multiple times. Instead of duplicating code, you want to create reusable blocks that can be called with different parameters.

**Solution:**
```bash
#!/bin/bash

# Basic function definition
greet() {
    echo "Hello, World!"
}

# Call the function
greet

# Function with parameters
greet_user() {
    local name="$1"
    echo "Hello, $name!"
}

greet_user "Alice"
greet_user "Bob"

# Function with return value
add_numbers() {
    local a="$1"
    local b="$2"
    local result=$((a + b))
    echo "$result"
}

sum=$(add_numbers 5 3)
echo "Sum: $sum"
```

**Key Concepts:**
- Functions are reusable blocks of code
- Parameters are accessed via `$1`, `$2`, etc.
- Use `local` to restrict variable scope
- Return values via `echo` and command substitution

#### 1.2 Function Parameters and Arguments

**Problem Statement:** You need to pass multiple parameters to functions and handle them properly, including default values and validation.

**Solution:**
```bash
#!/bin/bash

# Function with multiple parameters
create_user() {
    local username="$1"
    local home_dir="$2"
    local shell="${3:-/bin/bash}"
    
    # Validate parameters
    if [ -z "$username" ]; then
        echo "Error: Username is required"
        return 1
    fi
    
    if [ -z "$home_dir" ]; then
        home_dir="/home/$username"
    fi
    
    echo "Creating user: $username"
    echo "Home directory: $home_dir"
    echo "Shell: $shell"
    
    # Actual user creation would go here
    # useradd -m -d "$home_dir" -s "$shell" "$username"
}

# Call with different parameter combinations
create_user "john" "/home/john" "/bin/zsh"
echo "---"
create_user "jane"  # Uses default shell
echo "---"
create_user "" "/home/test"  # Error case

# Function with named parameters using associative array
process_config() {
    local -A params=(
        [host]="localhost"
        [port]="8080"
        [timeout]="30"
    )
    
    # Override with passed parameters
    while [ $# -gt 0 ]; do
        case "$1" in
            --host)
                params[host]="$2"
                shift 2
                ;;
            --port)
                params[port]="$2"
                shift 2
                ;;
            --timeout)
                params[timeout]="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    echo "Host: ${params[host]}"
    echo "Port: ${params[port]}"
    echo "Timeout: ${params[timeout]}"
}

process_config --host "db.example.com" --port "5432"
```

#### 1.3 Return Values and Exit Status

**Problem Statement:** You need functions to indicate success or failure, similar to how system commands work, and return meaningful data.

**Solution:**
```bash
#!/bin/bash

# Function returning exit status
file_exists() {
    local file="$1"
    if [ -f "$file" ]; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

if file_exists "/etc/passwd"; then
    echo "File exists!"
else
    echo "File not found!"
fi

# Function returning multiple values
get_system_info() {
    local hostname=$(hostname)
    local kernel=$(uname -r)
    local uptime=$(uptime -p)
    
    # Return as newline-separated output
    cat <<EOF
hostname:$hostname
kernel:$kernel
uptime:$uptime
EOF
}

# Parse returned values
while IFS=: read -r key value; do
    case "$key" in
        hostname) sys_hostname="$value" ;;
        kernel) sys_kernel="$value" ;;
        uptime) sys_uptime="$value" ;;
    esac
done < <(get_system_info)

echo "System: $sys_hostname"
echo "Kernel: $sys_kernel"
echo "Uptime: $sys_uptime"

# Function using global variables
calculate_stats() {
    local numbers=("$@")
    local sum=0
    local count=${#numbers[@]}
    
    for num in "${numbers[@]}"; do
        sum=$((sum + num))
    done
    
    avg=$((sum / count))
    max=${numbers[0]}
    min=${numbers[0]}
    
    for num in "${numbers[@]}"; do
        [ "$num" -gt "$max" ] && max="$num"
        [ "$num" -lt "$min" ] && min="$num"
    done
}

calculate_stats 10 20 30 40 50
echo "Average: $avg, Max: $max, Min: $min"
```

#### 1.4 Modular Script Structure

**Problem Statement:** You want to organize large scripts into logical sections with reusable library functions that can be sourced from multiple scripts.

**Solution:**
```bash
#!/bin/bash

# library.sh - Common utility functions

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message"
}

log_info() { log "INFO" "$@"; }
log_error() { log "ERROR" "$@"; }
log_warn() { log "WARN" "$@"; }

# Check if running as root
require_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure directory exists
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_info "Created directory: $dir"
    fi
}

# Backup file
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup="${file}.$(date +%Y%m%d_%H%M%S).bak"
        cp -a "$file" "$backup"
        log_info "Backed up $file to $backup"
        echo "$backup"
    fi
}

# main_script.sh - Using the library

#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/library.sh"

log_info "Starting main script"

require_root

ensure_dir "/tmp/myapp"
backup_file "/etc/myapp/config.conf"

log_info "Script completed"
```

### 💡 Practice Exercise 1.1

**Task:** Create a function library for system monitoring with the following functions:
1. `check_disk_space` - Checks disk usage and returns status
2. `check_memory` - Checks memory usage and returns status
3. `check_cpu` - Checks CPU usage and returns status
4. `check_service` - Checks if a service is running
5. `send_alert` - Sends alert message with timestamp

Create a test script that uses this library to perform a complete system health check.

**Solution:** See `exercises/exercise_1_1_solution.sh`

---

## Day 2: Arrays and Data Structures

### 🎯 Learning Goals
- Master indexed arrays in bash
- Learn associative arrays for key-value data
- Perform array operations and manipulations
- Process data files using arrays

### 📚 Topics Covered

#### 2.1 Indexed Arrays

**Problem Statement:** You need to store and process multiple values efficiently, such as a list of server names, file paths, or configuration values.

**Solution:**
```bash
#!/bin/bash

# Basic array operations
servers=("server1" "server2" "server3" "server4")

# Access elements
echo "First server: ${servers[0]}"
echo "Last server: ${servers[-1]}"

# Array length
echo "Number of servers: ${#servers[@]}"

# Iterate over array
echo "All servers:"
for server in "${servers[@]}"; do
    echo "  - $server"
done

# Array slicing
echo "First two servers: ${servers[@]:0:2}"
echo "Last two servers: ${servers[@]: -2}"

# Adding elements
servers+=("server5" "server6")
echo "After adding: ${servers[@]}"

# Remove element by index
unset servers[1]  # Removes server2
echo "After removing index 1: ${servers[@]}"

# Array with different types
mixed=(1 "hello" 3.14 true)
for item in "${mixed[@]}"; do
    echo "Item: $item (type: ${item//[^0-9]/})"
done

# Reading file into array
mapfile -t lines < /etc/hostname
echo "Hostname lines: ${lines[@]}"

# Alternative: readarray
readarray -t log_files < <(find /var/log -name "*.log" 2>/dev/null | head -5)
echo "Log files found: ${#log_files[@]}"
```

#### 2.2 Associative Arrays

**Problem Statement:** You need to store key-value pairs for configuration data, server metrics, or lookup tables.

**Solution:**
```bash
#!/bin/bash

# Declare associative array
declare -A server_config

# Add key-value pairs
server_config=(
    [hostname]="web-server-01"
    [ip]="192.168.1.100"
    [port]="8080"
    [status]="active"
    [disk_threshold]="80"
)

# Access elements
echo "Hostname: ${server_config[hostname]}"
echo "IP: ${server_config[ip]}"

# List all keys
echo "All keys: ${!server_config[@]}"

# List all values
echo "All values: ${server_config[@]}"

# Check if key exists
if [ -v server_config[status] ]; then
    echo "Status: ${server_config[status]}"
fi

# Iterate over associative array
echo "Server configuration:"
for key in "${!server_config[@]}"; do
    echo "  $key = ${server_config[$key]}"
done

# Sorted iteration
echo "Sorted configuration:"
for key in $(echo "${!server_config[@]}" | tr ' ' '\n' | sort); do
    echo "  $key = ${server_config[$key]}"
done

# Multiple server configurations
declare -A servers

add_server() {
    local name="$1"
    local ip="$2"
    local port="$3"
    
    servers["${name}_ip"]="$ip"
    servers["${name}_port"]="$port"
    servers["${name}_status"]="unknown"
}

add_server "web1" "192.168.1.101" "8080"
add_server "web2" "192.168.1.102" "8080"
add_server "db1" "192.168.1.201" "5432"

# Get all web servers
echo "Web servers:"
for key in "${!servers[@]}"; do
    if [[ "$key" == web*_ip ]]; then
        server_name="${key%_ip}"
        echo "  ${servers[$key]}:${servers[${server_name}_port]}"
    fi
done

# Count servers by type
echo "Server counts:"
for key in "${!servers[@]}"; do
    if [[ "$key" == *"_ip" ]]; then
        count=$((count + 1))
    fi
done
echo "Total servers: $count"
```

#### 2.3 Array Operations and Manipulations

**Problem Statement:** You need to perform complex array operations like searching, sorting, filtering, and transforming data.

**Solution:**
```bash
#!/bin/bash

# Array filtering
numbers=(1 2 3 4 5 6 7 8 9 10)

# Filter even numbers
even_numbers=()
for num in "${numbers[@]}"; do
    if [ $((num % 2)) -eq 0 ]; then
        even_numbers+=("$num")
    fi
done
echo "Even numbers: ${even_numbers[@]}"

# Array sorting
fruits=("banana" "apple" "cherry" "date")
IFS=$'\n' sorted_fruits=($(sort <<<"${fruits[*]}"))
unset IFS
echo "Sorted fruits: ${sorted_fruits[@]}"

# Reverse array
reverse_fruits=($(printf '%s\n' "${fruits[@]}" | tac))
echo "Reversed fruits: ${reverse_fruits[@]}"

# Unique elements
mixed=(1 2 2 3 3 3 4 4 4 4)
unique=($(echo "${mixed[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
echo "Unique: ${unique[@]}"

# Array intersection
arr1=(1 2 3 4 5)
arr2=(4 5 6 7 8)

intersection=()
for val in "${arr1[@]}"; do
    for val2 in "${arr2[@]}"; do
        if [ "$val" = "$val2" ]; then
            intersection+=("$val")
        fi
    fi
done
echo "Intersection: ${intersection[@]}"

# Find index of element
array=("one" "two" "three" "four")
find_index() {
    local element="$1"
    local index=-1
    for i in "${!array[@]}"; do
        if [ "${array[$i]}" = "$element" ]; then
            index=$i
            break
        fi
    done
    echo "$index"
}

idx=$(find_index "three")
echo "Index of 'three': $idx"

# Two-dimensional array simulation
declare -A matrix
rows=3
cols=3

for i in $(seq 0 $((rows - 1))); do
    for j in $(seq 0 $((cols - 1))); do
        value=$((i * cols + j))
        matrix[$i,$j]=$value
    done
done

# Print matrix
echo "Matrix:"
for i in $(seq 0 $((rows - 1))); do
    row=""
    for j in $(seq 0 $((cols - 1))); do
        row+=" ${matrix[$i,$j]}"
    done
    echo "$row"
done
```

#### 2.4 Processing Data Files with Arrays

**Problem Statement:** You need to read CSV files, configuration files, and structured data into arrays for processing and analysis.

**Solution:**
```bash
#!/bin/bash

# Read CSV file into array
read_csv() {
    local file="$1"
    local -n arr="$2"
    local line_num=0
    
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip header
        if [ $line_num -gt 0 ]; then
            arr+=("$line")
        fi
        ((line_num++))
    done < "$file"
}

# Parse CSV line
parse_csv() {
    local line="$1"
    IFS=',' read -ra fields <<< "$line"
    echo "${fields[@]}"
}

# Example: Process user data
# Format: username,uid,gid,home,shell
user_data=()
while IFS=: read -r user uid gid home shell; do
    if [ "$uid" -ge 1000 ] 2>/dev/null; then
        user_data+=("$user:$uid:$gid:$home:$shell")
    fi
done < /etc/passwd

echo "System users (UID >= 1000):"
for entry in "${user_data[@]}"; do
    IFS=':' read -r user uid gid home shell <<< "$entry"
    echo "  $user (UID: $uid, Home: $home)"
done

# Build lookup table from data
declare -A uid_lookup
for entry in "${user_data[@]}"; do
    IFS=':' read -r user uid gid home shell <<< "$entry"
    uid_lookup[$uid]="$user"
done

# Query by UID
echo "User with UID 1000: ${uid_lookup[1000]:-Not found}"

# Process space-separated values
process_values() {
    local input="$1"
    local -a values=()
    
    for val in $input; do
        values+=("$val")
    done
    
    echo "Count: ${#values[@]}"
    echo "Sum: $(echo "${values[@]}" | tr ' ' '+' | bc)"
    echo "Average: $(echo "scale=2; ($(echo "${values[@]}" | tr ' ' '+'))/${#values[@]}" | bc)"
}

process_values "10 20 30 40 50"

# JSON-like data parsing
parse_json_config() {
    local config="$1"
    declare -A config_map
    
    while IFS=':' read -r key value; do
        key=$(echo "$key" | tr -d ' "')
        value=$(echo "$value" | tr -d '," ')
        config_map[$key]="$value"
    done <<< "$config"
    
    echo "Parsed config:"
    for key in "${!config_map[@]}"; do
        echo "  $key = ${config_map[$key]}"
    done
}

config_data="name:server1 port:8080 host:localhost"
parse_json_config "$config_data"
```

### 💡 Practice Exercise 2.1

**Task:** Create a script that:
1. Reads a list of server hostnames from a file
2. For each server, stores IP address, status, and response time
3. Provides functions to query servers by status or IP range
4. Displays a formatted table of server information
5. Exports the data in different formats (CSV, JSON-like)

**Solution:** See `exercises/exercise_2_1_solution.sh`

---

## Day 3: String Manipulation

### 🎯 Learning Goals
- Master string operations and transformations
- Learn pattern matching and regular expressions
- Process text data efficiently
- Handle file paths and extensions

### 📚 Topics Covered

#### 3.1 Basic String Operations

**Problem Statement:** You need to manipulate strings for text processing, file naming, and data formatting in your scripts.

**Solution:**
```bash
#!/bin/bash

# String length
str="Hello, World!"
echo "Length: ${#str}"

# String concatenation
first="Hello"
second="World"
greeting="$first, $second!"
echo "$greeting"

# String repetition
bar=$(printf '%*s' 20 | tr ' ' '-')
echo "$bar"

# Substring extraction
str="Hello, World!"
echo "Substring [0,5]: ${str:0:5}"     # Hello
echo "Substring [7,5]: ${str:7:5}"     # World
echo "Last 6 chars: ${str: -6}"       # World!

# Substring replacement
echo "${str/World/Universe}"          # First occurrence
echo "${str//o/O}"                    # All occurrences

# Prefix/suffix removal
path="/var/log/nginx/access.log"
echo "Basename: ${path##*/}"          # access.log
echo "Dirname: ${path%/*}"            # /var/log/nginx
echo "Extension: ${path##*.}"         # log

filename="report-2024-01-15.csv"
echo "Name: ${filename%.*}"           # report-2024-01-15
echo "Ext: ${filename##*.}"          # csv

# Case conversion
lowercase="Hello World"
echo "Upper: ${lowercase^^}"          # HELLO WORLD
echo "Lower: ${lowercase,,}"          # hello world

# Partial case conversion
echo "First upper: ${lowercase^}"     # Hello world
```

#### 3.2 Pattern Matching and Globbing

**Problem Statement:** You need to match strings against patterns for validation, filtering, or conditional logic.

**Solution:**
```bash
#!/bin/bash

# Wildcard matching
filename="report-2024-01-15.csv"

if [[ "$filename" == *.csv ]]; then
    echo "CSV file detected"
fi

if [[ "$filename" == report-*.csv ]]; then
    echo "Report file detected"
fi

# Extended pattern matching
shopt -s extglob

# Match one or more
text="abc123def456"
if [[ "$text" == *([a-z])+([0-9])* ]]; then
    echo "Contains letters followed by numbers"
fi

# Match zero or more
if [[ "$text" == *([a-z])*([0-9]) ]]; then
    echo "Pattern matched"
fi

# Multiple alternatives
color="red"
case "$color" in
    red|green|blue) echo "Primary color" ;;
    yellow|purple|orange) echo "Secondary color" ;;
    *) echo "Other color" ;;
esac

# Regex matching
email="user@example.com"
if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Valid email format"
fi

ip="192.168.1.100"
if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "IP address format detected"
fi

# Capture groups
timestamp="2024-01-15 14:30:45"
if [[ "$timestamp" =~ ([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
    echo "Year: ${BASH_REMATCH[1]}"
    echo "Month: ${BASH_REMATCH[2]}"
    echo "Day: ${BASH_REMATCH[3]}"
fi

# Extract numbers from string
text="Order 12345 shipped on 2024-01-15"
numbers=$(echo "$text" | grep -oE '[0-9]+' | tr '\n' ' ')
echo "Numbers found: $numbers"
```

#### 3.3 Text Processing with sed and awk

**Problem Statement:** You need to process text files for transformations, extractions, and reporting.

**Solution:**
```bash
#!/bin/bash

# sed basics
echo "Hello World" | sed 's/World/Universe/'

# sed with regex
echo "IP: 192.168.1.100" | sed -E 's/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/REDACTED/'

# sed in-place editing
# sed -i 's/old/new/g' file.txt

# awk basics
echo -e "Alice 25\nBob 30\nCharlie 35" | awk '{print $1, "is", $2, "years old"}'

# awk with field separator
echo "user:pass:uid" | awk -F: '{print $1}'

# awk with conditions
ps aux | awk '$3 > 50 {print $11, $3}'

# awk with calculations
echo -e "Item1 10\nItem2 20\nItem3 30" | awk '{sum+=$2} END {print "Total:", sum}'

# Complex awk processing
cat <<'EOF' | awk -F, '
NR==1 {next}  # Skip header
{ 
    name=$1
    score=$2
    grade=$3
    
    if (grade >= 90) rating="A"
    else if (grade >= 80) rating="B"
    else if (grade >= 70) rating="C"
    else rating="D"
    
    total_score += score
    count++
    print name ": Score=" score ", Grade=" grade ", Rating=" rating
}
END {
    print "---"
    print "Average Score:", total_score/count
}
' 
Alice,95,92
Bob,85,88
Charlie,78,75
David,92,90
EOF

# Combining sed and awk
# Extract and transform log entries
# cat /var/log/syslog | sed 's/\[[0-9]*\]:/:/' | awk -F: '{print $3}'

# Multi-line processing
echo -e "Line1\nLine2\nLine3" | awk 'BEGIN{RS=""}{gsub(/\n/," ");print}'
```

#### 3.4 Path and Filename Manipulation

**Problem Statement:** You need to safely handle file paths, extract components, and validate filenames in your scripts.

**Solution:**
```bash
#!/bin/bash

# Extract path components
filepath="/var/log/nginx/access.log"

# Get individual components
dirname "$filepath"      # /var/log/nginx
basename "$filepath"    # access.log
basename "$filepath" .log  # access

# Real path resolution
realpath "/etc/../etc/passwd"  # /etc/passwd

# Path normalization
path="/var//log//nginx/./access.log"
echo "${path//\/\//\/}"  # Simple normalization

# File extension handling
filename="document.tar.gz"

# Get extension
ext="${filename##*.}"
echo "Extension: $ext"  # gz

# Get filename without extension
name="${filename%.*}"
echo "Name: $name"  # document.tar

# Multiple extensions
base="${filename%.*}"
first_ext="${base##*.}"
echo "Base: $base, First extension: $first_ext"

# Validate path
is_valid_path() {
    local path="$1"
    [[ "$path" =~ ^/[^/]+ ]]  # Must start with /
}

# Check safe path (no .. traversal)
is_safe_path() {
    local path="$1"
    [[ "$path" != *"\.\."* ]]
}

# Build path safely
join_path() {
    local base="${1%/}"
    local component="$2"
    echo "$base/$component"
}

full_path=$(join_path "/var/log" "app.log")
echo "Full path: $full_path"

# Generate unique filename
generate_unique_name() {
    local prefix="$1"
    local suffix="${2:-}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local random=$(head -c 4 /dev/urandom | xxd -p)
    echo "${prefix}_${timestamp}_${random}${suffix}"
}

unique_name=$(generate_unique_name "backup" ".tar.gz")
echo "Unique name: $unique_name"
```

### 💡 Practice Exercise 3.1

**Task:** Create a log file analyzer that:
1. Parses Apache/Nginx access log format
2. Extracts IP addresses, timestamps, requests, and status codes
3. Generates statistics (top IPs, most requested URLs, error codes)
4. Creates a summary report with formatted output
5. Supports filtering by date range or status code

**Solution:** See `exercises/exercise_3_1_solution.sh`

---

## Day 4: File System Operations and Monitoring

### 🎯 Learning Goals
- Perform advanced file operations
- Monitor file system changes
- Implement file backup and rotation
- Handle file permissions securely

### 📚 Topics Covered

#### 4.1 Advanced File Operations

**Problem Statement:** You need to perform complex file operations including finding files by various criteria, comparing files, and safely manipulating file content.

**Solution:**
```bash
#!/bin/bash

# Find files by multiple criteria
find /var/log -type f -name "*.log" -mtime -7 -size +1M

# Find with OR/AND conditions
find /home -type f \( -name "*.txt" -o -name "*.md" \)
find /var -type f -user www-data -perm -004

# Process found files
find /var/log -name "*.log" -mtime +30 -exec gzip {} \;

# Compare files
diff file1.txt file2.txt
diff -r dir1 dir2

# Three-way comparison
diff3 -m file1.txt file2.txt file3.txt

# Compare binary files
cmp file1.bin file2.bin

# Create checksum for verification
md5sum file.txt
sha256sum file.txt

# Verify checksums
sha256sum -c checksums.txt

# Secure file deletion
secure_delete() {
    local file="$1"
    local passes="${2:-3}"
    
    if [ ! -f "$file" ]; then
        echo "File not found: $file"
        return 1
    fi
    
    local size=$(stat -c%s "$file")
    
    # Overwrite with random data
    for i in $(seq 1 "$passes"); do
        dd if=/dev/urandom of="$file" bs=1M count="$size" 2>/dev/null
    done
    
    # Overwrite with zeros
    dd if=/dev/zero of="$file" bs=1M count="$size" 2>/dev/null
    
    # Remove
    rm -f "$file"
    echo "File securely deleted: $file"
}

# Atomic file updates
atomic_write() {
    local target="$1"
    local content="$2"
    local temp="${target}.tmp.${$}"
    
    echo "$content" > "$temp"
    mv "$temp" "$target"
}

# Lock file for concurrent access
create_lock() {
    local lockfile="$1"
    local timeout="${2:-30}"
    local elapsed=0
    
    while [ -f "$lockfile" ]; do
        if [ $elapsed -ge $timeout ]; then
            echo "Lock timeout"
            return 1
        fi
        sleep 1
        ((elapsed++))
    done
    
    echo $$ > "$lockfile"
    return 0
}

release_lock() {
    local lockfile="$1"
    rm -f "$lockfile"
}
```

#### 4.2 File System Monitoring

**Problem Statement:** You need to monitor file system changes, detect modifications, and track file system usage over time.

**Solution:**
```bash
#!/bin/bash

# Monitor directory for changes
watch_directory() {
    local dir="$1"
    local previous=""
    
    while true; do
        current=$(find "$dir" -type f -printf "%T@ %p\n" 2>/dev/null | sort)
        
        if [ "$current" != "$previous" ] && [ -n "$previous" ]; then
            echo "Changes detected at $(date)"
            diff <(echo "$previous") <(echo "$current") | head -20
        fi
        
        previous="$current"
        sleep 10
    done
}

# Track file modifications
track_changes() {
    local file="$1"
    local checksum_file="${file}.md5"
    
    # Calculate initial checksum
    md5sum "$file" > "$checksum_file"
    
    while true; do
        if ! md5sum -c --status "$checksum_file" 2>/dev/null; then
            echo "File modified: $file at $(date)"
            md5sum "$file" > "$checksum_file"
        fi
        sleep 60
    done
}

# Monitor disk usage trends
monitor_disk_usage() {
    local dir="$1"
    local threshold=80
    local output_file="/tmp/disk_usage_$(date +%Y%m%d).csv"
    
    echo "Directory,Size,Files,Directories,Modified" > "$output_file"
    
    for path in "$dir"/*; do
        if [ -d "$path" ]; then
            size=$(du -sb "$path" 2>/dev/null | cut -f1)
            files=$(find "$path" -type f 2>/dev/null | wc -l)
            dirs=$(find "$path" -type d 2>/dev/null | wc -l)
            modified=$(stat -c %y "$path" 2>/dev/null | cut -d' ' -f1)
            
            echo "\"$path\",$size,$files,$dirs,$modified" >> "$output_file"
        fi
    done
    
    echo "Disk usage report: $output_file"
}

# Detect large files
find_large_files() {
    local threshold="${1:-100M}"
    local search_path="${2:-/}"
    
    echo "Large files (>$threshold) in $search_path:"
    find "$search_path" -type f -size +"$threshold" -exec ls -lh {} \; 2>/dev/null
}

# Detect files with many hard links
find_hardlinks() {
    local dir="${1:-.}"
    
    echo "Files with multiple hard links:"
    find "$dir" -type f -links +1 -exec ls -li {} \; 2>/dev/null | \
        awk '{print $1, $NF}' | \
        sort -n | \
        uniq -D -w10
}

# Monitor inode usage
check_inode_usage() {
    echo "Inode usage by filesystem:"
    df -i | grep -E '^/dev/'
}
```

#### 4.3 Log Rotation and Management

**Problem Statement:** You need to implement log rotation policies to manage disk space and maintain historical log data.

**Solution:**
```bash
#!/bin/bash

# Log rotation script
rotate_logs() {
    local log_file="$1"
    local max_backups="${2:-7}"
    local compress="${3:-true}"
    
    # Check if log file exists
    if [ ! -f "$log_file" ]; then
        echo "Log file not found: $log_file"
        return 1
    fi
    
    local basename="${log_file##*/}"
    local dirname="${log_file%/*}"
    
    # Rotate existing backups
    for i in $(seq $((max_backups - 1)) -1 0); do
        if [ -f "${dirname}/${basename}.${i}" ]; then
            if [ "$compress" = true ] && [[ ! "${dirname}/${basename}.${i}" =~ \.gz$ ]]; then
                gzip "${dirname}/${basename}.${i}"
            fi
            mv "${dirname}/${basename}.${i}.gz" "${dirname}/${basename}.$((i + 1)).gz" 2>/dev/null || \
            mv "${dirname}/${basename}.${i}" "${dirname}/${basename}.$((i + 1))" 2>/dev/null
        fi
    done
    
    # Rotate current log
    if [ "$compress" = true ]; then
        mv "$log_file" "${log_file}.0"
        gzip "${log_file}.0"
    else
        mv "$log_file" "${log_file}.0"
    fi
    
    # Create new empty log
    touch "$log_file"
    chmod 644 "$log_file"
    
    # Clean up old backups
    if [ "$compress" = true ]; then
        find "${dirname}" -name "${basename}.*.gz" -mtime +"$max_backups" -delete
    else
        find "${dirname}" -name "${basename}.*" -type f -mtime +"$max_backups" -delete
    fi
    
    echo "Log rotated: $log_file"
}

# Compress old logs
compress_old_logs() {
    local log_dir="${1:-/var/log}"
    local age_days="${2:-7}"
    
    find "$log_dir" -name "*.log" -type f -mtime +"$age_days" ! -name "*.gz" -exec gzip {} \;
}

# Truncate log file safely
truncate_log() {
    local log_file="$1"
    local max_lines="${2:-10000}"
    
    if [ -f "$log_file" ]; then
        local current_lines=$(wc -l < "$log_file")
        
        if [ "$current_lines" -gt "$max_lines" ]; then
            tail -n "$max_lines" "$log_file" > "${log_file}.tmp"
            mv "${log_file}.tmp" "$log_file"
            echo "Truncated $log_file from $current_lines to $max_lines lines"
        fi
    fi
}

# Cleanup old log files
cleanup_old_logs() {
    local log_dir="${1:-/var/log}"
    local days="${2:-30}"
    local patterns=("*.log" "*.gz" "*.old")
    
    for pattern in "${patterns[@]}"; do
        deleted=$(find "$log_dir" -name "$pattern" -type f -mtime +"$days" -delete 2>/dev/null | wc -l)
        echo "Deleted $deleted files matching $pattern"
    done
}
```

#### 4.4 File Permissions and Security

**Problem Statement:** You need to manage file permissions securely, audit permission issues, and fix common security problems.

**Solution:**
```bash
#!/bin/bash

# Audit world-writable files
audit_world_writable() {
    local path="${1:-.}"
    echo "World-writable files in $path:"
    find "$path" -type f -perm -0002 2>/dev/null
}

# Audit SUID files
audit_suid_files() {
    local path="${1:-/}"
    echo "SUID files:"
    find "$path" -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null
}

# Audit files with no owner
audit_unowned_files() {
    local path="${1:-.}"
    echo "Unowned files:"
    find "$path" -nouser -o -nogroup 2>/dev/null
}

# Set permissions according to policy
set_secure_permissions() {
    local file="$1"
    
    # Remove world permissions
    chmod o-rwx "$file"
    
    # Owner read/write only for sensitive files
    chmod 600 "$file"
}

# Verify permissions match expected
verify_permissions() {
    local file="$1"
    local expected="$2"
    
    actual=$(stat -c %a "$file")
    
    if [ "$actual" != "$expected" ]; then
        echo "Permission mismatch: $file (expected: $expected, actual: $actual)"
        return 1
    fi
    
    echo "OK: $file has correct permissions ($expected)"
    return 0
}

# Recursively set directory permissions
set_directory_permissions() {
    local dir="$1"
    local dir_perm="${2:-755}"
    local file_perm="${3:-644}"
    
    # Directories
    find "$dir" -type d -exec chmod "$dir_perm" {} \;
    
    # Files
    find "$dir" -type f -exec chmod "$file_perm" {} \;
    
    # Executable scripts
    find "$dir" -type f -name "*.sh" -exec chmod +x {} \;
}

# Check for dangerous file permissions
check_dangerous_permissions() {
    echo "Files with dangerous permissions:"
    
    # World-writable files
    echo -e "\n--- World-writable files ---"
    find / -type f -perm -0002 -uid +500 2>/dev/null | head -20
    
    # SUID root files
    echo -e "\n--- SUID root files ---"
    find / -type f -perm -4000 -uid 0 2>/dev/null | head -20
    
    # Unprotected sensitive files
    echo -e "\n--- Sensitive files with group/other access ---"
    for file in /etc/passwd /etc/shadow /etc/group; do
        perms=$(stat -c %a "$file" 2>/dev/null)
        if [[ "$perms" =~ [67] ]] || [[ "$perms" =~ [67].$ ]]; then
            echo "$file has permission $perms"
        fi
    done
}
```

### 💡 Practice Exercise 4.1

**Task:** Create a comprehensive log management script that:
1. Implements configurable log rotation with compression
2. Monitors log directory size and alerts when threshold exceeded
3. Archives old logs to a separate location
4. Cleans up logs based on retention policy
5. Generates daily/weekly/monthly reports on log statistics

**Solution:** See `exercises/exercise_4_1_solution.sh`

---

## Day 5: Process Management and Job Control

### 🎯 Learning Goals
- Manage background and foreground processes
- Implement process supervision
- Handle signals and traps
- Create daemon-like scripts

### 📚 Topics Covered

#### 5.1 Background Process Management

**Problem Statement:** You need to manage long-running processes, run multiple tasks in parallel, and control job execution.

**Solution:**
```bash
#!/bin/bash

# Start process in background
long_running_task() {
    while true; do
        echo "Task running at $(date)"
        sleep 10
    done
}

long_running_task &
TASK_PID=$!

# Store PID for later
echo "$TASK_PID" > /tmp/task.pid

# Check if process is running
if kill -0 "$TASK_PID" 2>/dev/null; then
    echo "Process $TASK_PID is running"
fi

# Run multiple processes in parallel
run_parallel() {
    local -a commands=("$@")
    local -a pids=()
    
    for cmd in "${commands[@]}"; do
        eval "$cmd" &
        pids+=($!)
    done
    
    # Wait for all to complete
    for pid in "${pids[@]}"; do
        wait "$pid"
        echo "Process $pid completed"
    done
}

# Limit concurrent processes
limited_parallel() {
    local max_jobs=5
    local -a commands=("$@")
    local running=0
    local -a pids=()
    
    for cmd in "${commands[@]}"; do
        # Wait if max jobs reached
        while [ $running -ge $max_jobs ]; do
            for i in "${!pids[@]}"; do
                if ! kill -0 "${pids[$i]}" 2>/dev/null; then
                    unset 'pids[$i]'
                    ((running--))
                fi
            done
            pids=("${pids[@]}")
            sleep 0.5
        done
        
        # Start new job
        eval "$cmd" &
        pids+=($!)
        ((running++))
    done
    
    # Wait for remaining jobs
    for pid in "${pids[@]}"; do
        wait "$pid" 2>/dev/null
    done
}

# Process timeout
run_with_timeout() {
    local timeout="$1"
    shift
    local cmd="$@"
    
    (
        eval "$cmd" &
        PID=$!
        
        (
            sleep "$timeout"
            kill -0 $PID 2>/dev/null && kill $PID 2>/dev/null
        ) &
        WATCHDOG=$!
        
        wait $PID
        STATUS=$?
        kill $WATCHDOG 2>/dev/null
        exit $STATUS
    )
}

# Example usage
run_with_timeout 5 sleep 10
echo "Timed out (or completed)"
```

#### 5.2 Process Supervision

**Problem Statement:** You need to ensure processes stay running, automatically restart failed services, and monitor process health.

**Solution:**
```bash
#!/bin/bash

# Simple process supervisor
supervisor_script() {
    local service_name="$1"
    local service_cmd="$2"
    local restart_delay="${3:-5}"
    
    echo "Starting supervisor for: $service_name"
    
    while true; do
        echo "[$(date)] Starting service..."
        $service_cmd &
        SERVICE_PID=$!
        
        # Monitor process
        while kill -0 $SERVICE_PID 2>/dev/null; do
            sleep 5
            
            # Health check (customize as needed)
            if ! check_health; then
                echo "Health check failed, restarting..."
                kill $SERVICE_PID 2>/dev/null
                break
            fi
        done
        
        # Process exited
        echo "[$(date)] Process exited with code $?"
        echo "Restarting in $restart_delay seconds..."
        sleep $restart_delay
    done
}

# Health check function (customize)
check_health() {
    # Return 0 if healthy, 1 if unhealthy
    return 0
}

# Monitor multiple services
monitor_services() {
    declare -A services=(
        [nginx]="nginx"
        [mysql]="mysqld"
        [redis]="redis-server"
    )
    
    while true; do
        for name in "${!services[@]}"; do
            proc="${services[$name]}"
            
            if ! pgrep -x "$proc" >/dev/null; then
                echo "[$(date)] $name is down, restarting..."
                systemctl start "$name" 2>/dev/null || service "$name" start
            else
                echo "[$(date)] $name is running"
            fi
        done
        
        sleep 30
    done
}

# Resource-limited process execution
run_with_limits() {
    local max_cpu=50  # percentage
    local max_mem=100M
    
    local cmd="$@"
    
    # Using ulimit (Bash built-in)
    ulimit -t 300  # 5 minute time limit
    ulimit -v 204800  # 200MB virtual memory
    
    eval "$cmd"
}

# Priority management
run_with_priority() {
    local nice_level="$1"
    shift
    local cmd="$@"
    
    nice -n "$nice_level" $cmd
}

# Run with low priority (for background tasks)
nice -n 19 tar -czf backup.tar.gz /data &
```

#### 5.3 Signal Handling and Traps

**Problem Statement:** You need to handle signals gracefully, cleanup on script exit, and implement proper interrupt handling.

**Solution:**
```bash
#!/bin/bash

# Signal handling basics
trap 'echo "Caught signal!"' INT TERM

# Cleanup on exit
cleanup() {
    echo "Cleaning up..."
    # Remove temporary files
    rm -f /tmp/myapp.*
    # Close file descriptors
    exec 3>&-
    # Kill child processes
    pkill -P $$ 2>/dev/null
    echo "Cleanup complete"
}

trap cleanup EXIT

# Multiple signals
trap 'handle_interrupt' INT
trap 'handle_terminate' TERM
trap 'handle_error' ERR

handle_interrupt() {
    echo "Interrupted!"
    exit 130
}

handle_terminate() {
    echo "Terminated!"
    exit 143
}

handle_error() {
    echo "Error on line $LINENO"
    exit 1
}

# Progressive cleanup
cleanup_on_exit() {
    local temp_files=()
    local lock_files=()
    
    # Register cleanup
    trap '
        echo "Cleaning up temporary files..."
        for f in "${temp_files[@]}"; do
            rm -f "$f"
        done
        for f in "${lock_files[@]}"; do
            rm -f "$f"
        done
    ' EXIT
    
    # Create temporary files
    temp_files+=("/tmp/myapp.cache.$$")
    temp_files+=("/tmp/myapp.data.$$")
    
    # Create lock files
    lock_files+=("/var/lock/myapp.lock")
}

# Ignore specific signals
trap '' SIGTSTP  # Ignore Ctrl+Z
trap '' SIGQUIT  # Ignore Ctrl+\

# Resume normal handling
trap '-' SIGTSTP SIGQUIT

# Wait with signal handling
wait_with_timeout() {
    local timeout="$1"
    shift
    local pid="$@"
    
    (
        sleep "$timeout"
        kill -ALRM "$pid" 2>/dev/null
    ) &
    WATCHDOG=$!
    
    wait "$pid" 2>/dev/null
    STATUS=$?
    kill "$WATCHDOG" 2>/dev/null
    
    return $STATUS
}
```

#### 5.4 Daemon-Style Scripts

**Problem Statement:** You need to create scripts that run as system services, with proper start/stop/restart functionality and PID file management.

**Solution:**
```bash
#!/bin/bash

### BEGIN INIT INFO
# Provides:          myapp
# Required-Start:    $local_fs $remote_fs $network
# Required-Stop:     $local_fs $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       My Application Service
### END INIT INFO

NAME="myapp"
DESC="My Application"
PIDFILE="/var/run/${NAME}.pid"
LOGFILE="/var/log/${NAME}.log"
DAEMON="/usr/local/bin/${NAME}.sh"

[ -x "$DAEMON" ] || exit 1

. /lib/lsb/init-functions

start_service() {
    if [ -f "$PIDFILE" ]; then
        if kill -0 $(cat "$PIDFILE") 2>/dev/null; then
            log_success_msg "$NAME is already running"
            return 1
        fi
    fi
    
    log_daemon_msg "Starting $DESC: $NAME"
    
    # Start daemon
    start-stop-daemon --start \
        --pidfile "$PIDFILE" \
        --make-pidfile \
        --background \
        --startas /bin/bash \
        -- -c "exec $DAEMON >> $LOGFILE 2>&1"
    
    log_end_msg $?
}

stop_service() {
    log_daemon_msg "Stopping $DESC: $NAME"
    
    start-stop-daemon --stop \
        --pidfile "$PIDFILE" \
        --remove-pidfile \
        --retry 10
    
    log_end_msg $?
}

status_service() {
    if [ -f "$PIDFILE" ]; then
        if kill -0 $(cat "$PIDFILE") 2>/dev/null; then
            log_success_msg "$NAME is running"
            return 0
        fi
    fi
    
    log_failure_msg "$NAME is not running"
    return 1
}

case "$1" in
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart)
        stop_service
        sleep 2
        start_service
        ;;
    status)
        status_service
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

exit 0
```

### 💡 Practice Exercise 5.1

**Task:** Create a service management script that:
1. Implements start, stop, restart, and status commands
2. Manages PID files properly
3. Logs service activity
4. Handles signals gracefully
5. Performs health checks before declaring service healthy
6. Supports configuration file for service parameters

**Solution:** See `exercises/exercise_5_1_solution.sh`

---

## Day 6: Job Scheduling with Cron

### 🎯 Learning Goals
- Understand cron syntax and scheduling
- Create and manage cron jobs
- Implement automated maintenance tasks
- Handle common scheduling challenges

### 📚 Topics Covered

#### 6.1 Cron Fundamentals

**Problem Statement:** You need to schedule recurring tasks for system maintenance, backups, and automated operations.

**Solution:**
```bash
#!/bin/bash

# Cron syntax: minute hour day month weekday command
# * = any value
# , = value list separator (1,2,3)
# - = range of values (1-5)
# / = step values (*/5 = every 5 units)

# Example cron entries:
# 0 * * * *           # Every hour
# 0 0 * * *           # Every day at midnight
# 0 0 * * 0           # Every Sunday at midnight
# 0 0 1 * *           # First day of every month
# */5 * * * *         # Every 5 minutes
# 0 */2 * * *         # Every 2 hours

# Add cron job programmatically
add_cron_job() {
    local schedule="$1"
    local command="$2"
    local user="${3:-root}"
    
    (crontab -l -u "$user" 2>/dev/null | grep -v "$command"; echo "$schedule $command") | crontab -u "$user" -
}

# Remove cron job
remove_cron_job() {
    local command="$1"
    local user="${2:-root}"
    
    crontab -l -u "$user" 2>/dev/null | grep -v "$command" | crontab -u "$user" -
}

# List cron jobs
list_cron_jobs() {
    local user="${1:-root}"
    crontab -l -u "$user" 2>/dev/null
}

# Common maintenance schedule expressions
EVERY_MINUTE="* * * * *"
EVERY_5_MINUTES="*/5 * * * *"
EVERY_15_MINUTES="*/15 * * * *"
EVERY_HOUR="0 * * * *"
EVERY_DAY_MIDNIGHT="0 0 * * *"
EVERY_WEEK_SUNDAY="0 0 * * 0"
EVERY_MONTH_FIRST="0 0 1 * *"
EVERY_DAY_2AM="0 2 * * *"
EVERY_WEEKDAY_9am="0 9 * * 1-5"
```

#### 6.2 Automated Maintenance Scripts

**Problem Statement:** You need to create scheduled maintenance scripts for common system administration tasks.

**Solution:**
```bash
#!/bin/bash

# daily-maintenance.sh - Run daily at 2 AM

set -euo pipefail

LOGFILE="/var/log/daily-maintenance.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOGFILE"
}

log "Starting daily maintenance"

# 1. Clean package cache
log "Cleaning package cache..."
apt-get clean 2>/dev/null || yum clean all 2>/dev/null

# 2. Rotate logs
log "Rotating logs..."
for logfile in /var/log/*.log; do
    if [ -f "$logfile" ] && [ -s "$logfile" ]; then
        find "$logfile"* -type f -mtime +7 -delete 2>/dev/null
    fi
done

# 3. Check disk space
log "Checking disk space..."
df -h | grep -E '^/dev/' >> "$LOGFILE"

# 4. Clean temporary files
log "Cleaning temporary files..."
find /tmp -type f -mtime +7 -delete 2>/dev/null
find /var/tmp -type f -mtime +30 -delete 2>/dev/null

# 5. Update locate database
log "Updating locate database..."
updatedb 2>/dev/null || true

# 6. Check for security updates
log "Checking for updates..."
apt-get -s upgrade 2>/dev/null | grep -E '^[0-9]+ upgraded' >> "$LOGFILE"

log "Daily maintenance completed"

# Crontab entry:
# 0 2 * * * /usr/local/bin/daily-maintenance.sh >> /var/log/daily-maintenance.log 2>&1
```

```bash
#!/bin/bash

# weekly-maintenance.sh - Run weekly on Sunday at 3 AM

set -euo pipefail

LOGFILE="/var/log/weekly-maintenance.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOGFILE"
}

log "Starting weekly maintenance"

# 1. Full system backup
log "Starting full backup..."
tar -czf "/backup/system-$(date +%Y%m%d).tar.gz" /etc /var/www /home 2>/dev/null || true

# 2. Database backups (example for PostgreSQL)
log "Backing up databases..."
# pg_dumpall -U postgres | gzip > "/backup/db-$(date +%Y%m%d).sql.gz"

# 3. Check for failed services
log "Checking failed services..."
systemctl list-units --state=failed 2>/dev/null >> "$LOGFILE" || true

# 4. Review log sizes
log "Log file sizes:"
du -sh /var/log/* >> "$LOGFILE"

# 5. Check user accounts
log "Checking for inactive accounts..."
for user in $(cut -d: -f1 /etc/passwd); do
    lastlog -t 30 "$user" 2>/dev/null | grep "Never" && echo "Inactive: $user"
done >> "$LOGFILE"

# 6. Clean old backups (keep 4 weeks)
find /backup -name "*.tar.gz" -mtime +28 -delete 2>/dev/null
find /backup -name "*.sql.gz" -mtime +28 -delete 2>/dev/null

log "Weekly maintenance completed"

# Crontab entry:
# 0 3 * * 0 /usr/local/bin/weekly-maintenance.sh >> /var/log/weekly-maintenance.log 2>&1
```

#### 6.3 Monitoring and Alerting Jobs

**Problem Statement:** You need to create scheduled monitoring jobs that check system health and send alerts when issues are detected.

**Solution:**
```bash
#!/bin/bash

# system-monitor.sh - Run every 5 minutes via cron

set -euo pipefail

ALERT_EMAIL="admin@example.com"
ALERT_THRESHOLD=85

log_alert() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ALERT: $message" | tee -a /var/log/monitoring.log
    # Send email alert
    echo "$message" | mail -s "System Alert: $(hostname)" "$ALERT_EMAIL" 2>/dev/null || true
}

# Check disk usage
check_disk() {
    local usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ "$usage" -gt "$ALERT_THRESHOLD" ]; then
        log_alert "Disk usage is ${usage}% (threshold: ${ALERT_THRESHOLD}%)"
        return 1
    fi
}

# Check memory usage
check_memory() {
    local usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    
    if [ "$usage" -gt "$ALERT_THRESHOLD" ]; then
        log_alert "Memory usage is ${usage}% (threshold: ${ALERT_THRESHOLD}%)"
        return 1
    fi
}

# Check load average
check_load() {
    local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    local cores=$(nproc)
    local threshold=$((cores * 2))
    
    # Compare load to threshold
    if (( $(echo "$load > $threshold" | bc -l 2>/dev/null || echo 0) )); then
        log_alert "Load average is $load (threshold: $threshold)"
        return 1
    fi
}

# Check if critical services are running
check_services() {
    local services=("nginx" "mysql" "redis-server")
    
    for service in "${services[@]}"; do
        if ! systemctl is-active --quiet "$service" 2>/dev/null; then
            log_alert "Service $service is not running"
            return 1
        fi
    done
}

# Check for zombie processes
check_zombies() {
    local zombies=$(ps aux | awk '$8 == "Z" {count++} END {print count+0}')
    
    if [ "$zombies" -gt 10 ]; then
        log_alert "High number of zombie processes: $zombies"
        return 1
    fi
}

# Run all checks
main() {
    check_disk
    check_memory
    check_load
    check_services
    check_zombies
}

main

# Crontab entry:
# */5 * * * * /usr/local/bin/system-monitor.sh >> /var/log/monitoring.log 2>&1
```

#### 6.4 Anacron for Non-Always-On Systems

**Problem Statement:** You need to schedule tasks on systems that may not be running continuously, like laptops or servers with irregular uptime.

**Solution:**
```bash
#!/bin/bash

# Anacron configuration
# Install: apt-get install anacron

# /etc/anacrontab format:
# period delay job-identifier command
# - period: how often (daily, weekly, monthly, or number of days)
# - delay: minutes to wait after system start
# - job-identifier: unique name for the job
# - command: what to run

# Example /etc/anacrontab entries:

# Run daily maintenance after 10 minutes from boot
# 1 10 daily.maintenance /usr/local/bin/daily-maintenance.sh

# Run weekly maintenance after 15 minutes from boot on Monday
# 7 15 weekly.maintenance /usr/local/bin/weekly-maintenance.sh

# Run monthly on the 1st after 30 minutes from boot
# 30 30 monthly.cleanup /usr/local/bin/monthly-cleanup.sh

# Create anacron job
add_anacron_job() {
    local period="$1"
    local delay="$2"
    local job_id="$3"
    local command="$4"
    
    echo "$period $delay $job_id $command" >> /etc/anacrontab
}

# Remove anacron job
remove_anacron_job() {
    local job_id="$1"
    
    grep -v "$job_id" /etc/anacrontab > /tmp/anacrontab.tmp
    mv /tmp/anacrontab.tmp /etc/anacrontab
}

# List anacron jobs
list_anacron_jobs() {
    grep -v '^#' /etc/anacrontab | grep -v '^$'
}
```

### 💡 Practice Exercise 6.1

**Task:** Create a comprehensive scheduled maintenance system that:
1. Has scripts for daily, weekly, and monthly maintenance
2. Implements proper logging for each job
3. Sends email notifications on failures
4. Creates a status report after each run
5. Includes a monitoring script to verify jobs are running
6. Documents all cron entries and schedules

**Solution:** See `exercises/exercise_6_1_solution.sh`

---

## Day 7: Log Aggregation and Analysis

### 🎯 Learning Goals
- Aggregate logs from multiple sources
- Analyze log patterns and trends
- Extract meaningful statistics
- Create automated alerting based on logs

### 📚 Topics Covered

#### 7.1 Log Aggregation Basics

**Problem Statement:** You need to collect and centralize logs from multiple servers or applications for unified analysis.

**Solution:**
```bash
#!/bin/bash

# Centralized log aggregator

LOG_SERVER="logs.example.com"
LOG_PORT=514
REMOTE_DIR="/var/log/remote"
LOCAL_DIR="/var/log/centralized"

# Collect local logs
collect_local_logs() {
    local log_sources=(
        "/var/log/syslog"
        "/var/log/auth.log"
        "/var/log/nginx/access.log"
        "/var/log/nginx/error.log"
        "/var/log/mysql/error.log"
    )
    
    for log in "${log_sources[@]}"; do
        if [ -f "$log" ]; then
            local basename="${log##*/}"
            local timestamp=$(date +%Y%m%d_%H%M%S)
            local dest="${LOCAL_DIR}/${hostname}/${timestamp}_${basename}"
            
            mkdir -p "$(dirname "$dest")"
            cp "$log" "$dest"
            echo "Collected: $log -> $dest"
        fi
    done
}

# Fetch remote logs via SSH
fetch_remote_logs() {
    local server="$1"
    local remote_path="$2"
    local local_dest="$3"
    
    mkdir -p "$local_dest"
    
    rsync -avz --remove-source-files \
        "${server}:${remote_path}" \
        "${local_dest}/" 2>/dev/null || \
    scp -r "${server}:${remote_path}"/* "${local_dest}/" 2>/dev/null || \
    ssh "${server}" "cat ${remote_path}" > "${local_dest}/$(basename ${remote_path})"
    
    echo "Fetched logs from ${server}"
}

# Real-time log tailing
tail_remote_logs() {
    local server="$1"
    local log_path="$2"
    
    ssh "$server" "tail -f $log_path" 2>/dev/null
}

# Compress and archive logs
archive_logs() {
    local source_dir="$1"
    local archive_dir="$2"
    local days="${3:-30}"
    
    mkdir -p "$archive_dir"
    
    find "$source_dir" -type f -mtime +"$days" | while read -r file; do
        gzip "$file"
        mv "${file}.gz" "$archive_dir/"
        echo "Archived: $file"
    done
}
```

#### 7.2 Log Pattern Analysis

**Problem Statement:** You need to identify patterns, trends, and anomalies in log data for troubleshooting and capacity planning.

**Solution:**
```bash
#!/bin/bash

# Log pattern analyzer

analyze_log_patterns() {
    local logfile="$1"
    
    echo "=== Log Analysis: $logfile ==="
    echo
    
    # Total entries
    total=$(wc -l < "$logfile")
    echo "Total entries: $total"
    
    # Entries by hour
    echo -e "\n--- Entries by hour ---"
    if grep -q '^\w\+ \d\+ \d\+\:\d\+\:\d\+' "$logfile"; then
        # Syslog format
        awk '{print substr($3,1,2)}' "$logfile" | sort | uniq -c
    elif grep -q '^\[\d\d/\w\+\/\d\d\d\d\:\d\d\:\d\d\:\d\d' "$logfile"; then
        # Apache/Nginx format
        awk -F: '{print $2}' "$logfile" | sort | uniq -c
    fi
    
    # Top error types
    echo -e "\n--- Top error types ---"
    grep -iE 'error|fail|exception|critical' "$logfile" | \
        sed -E 's/.*\b(error|fail|exception|critical)\b.*/\1/gi' | \
        sort | uniq -c | sort -rn | head -10
    
    # Error frequency by minute
    echo -e "\n--- Error frequency (last 100 entries) ---"
    tail -n 100 "$logfile" | grep -c -iE 'error|fail'
}

# Trend analysis
analyze_trends() {
    local log_dir="$1"
    local pattern="$2"
    
    echo "Trend analysis for: $pattern"
    echo "Date               Count"
    echo "------------------------"
    
    for logfile in $(ls -t "$log_dir" | head -30); do
        date=$(echo "$logfile" | grep -oE '\d{4}-\d{2}-\d{2}' | head -1)
        count=$(grep -c "$pattern" "${log_dir}/${logfile}" 2>/dev/null || echo 0)
        printf "%s  %d\n" "$date" "$count"
    done
}

# Detect anomalies
detect_anomalies() {
    local logfile="$1"
    local threshold="${2:-100}"
    
    echo "=== Anomaly Detection ==="
    
    # Detect sudden spikes
    echo -e "\n--- Request spikes (per minute) ---"
    awk '{print substr($4,14,5)}' "$logfile" 2>/dev/null | \
        sort | uniq -c | sort -rn | head -10
    
    # Detect error bursts
    echo -e "\n--- Error bursts ---"
    awk '/ERROR/' "$logfile" | \
        awk '{print substr($2,1,5)}' | \
        sort | uniq -c | sort -rn | head -10
    
    # Detect unusual user agents
    echo -e "\n--- User agents ---"
    grep -oE '"[^"]*"$' "$logfile" | sort | uniq -c | sort -rn | head -10
    
    # Detect 404 patterns
    echo -e "\n--- 404 errors (missing resources) ---"
    grep ' 404 ' "$logfile" | awk '{print $7}' | sort | uniq -c | sort -rn | head -10
}

# Generate statistics report
generate_report() {
    local logfile="$1"
    local report_file="${2:-report.txt}"
    
    {
        echo "=== Log Statistics Report ==="
        echo "Generated: $(date)"
        echo "Log file: $logfile"
        echo
        
        echo "--- Overview ---"
        echo "Total lines: $(wc -l < "$logfile")"
        echo "File size: $(du -h "$logfile" | cut -f1)"
        
        echo -e "\n--- Time range ---"
        echo "First entry: $(head -1 "$logfile")"
        echo "Last entry: $(tail -1 "$logfile")"
        
        echo -e "\n--- HTTP Status Codes ---"
        if grep -qE 'HTTP/[12]\.[01] [0-9]+' "$logfile"; then
            grep -oE 'HTTP/[12]\.[01] [0-9]+' "$logfile" | \
                awk '{print $2}' | sort | uniq -c | sort -rn
        fi
        
        echo -e "\n--- Top 10 IP Addresses ---"
        awk '{print $1}' "$logfile" | sort | uniq -c | sort -rn | head -10
        
    } > "$report_file"
    
    echo "Report generated: $report_file"
}
```

#### 7.3 Real-Time Log Monitoring

**Problem Statement:** You need to monitor logs in real-time and trigger alerts when specific patterns occur.

**Solution:**
```bash
#!/bin/bash

# Real-time log monitor with alerting

watch_log() {
    local logfile="$1"
    local pattern="$2"
    local alert_cmd="$3"
    
    tail -n 0 -f "$logfile" 2>/dev/null | \
    while IFS= read -r line; do
        if echo "$line" | grep -q "$pattern"; then
            echo "Pattern matched: $line"
            eval "$alert_cmd" "$line"
        fi
    done
}

# Multiple pattern monitoring
multi_pattern_watch() {
    local logfile="$1"
    shift
    declare -A patterns=("$@")
    
    tail -n 0 -f "$logfile" 2>/dev/null | \
    while IFS= read -r line; do
        for pattern in "${!patterns[@]}"; do
            if echo "$line" | grep -q "$pattern"; then
                echo "[${patterns[$pattern]}] $line"
                # Trigger action based on pattern
                case "${patterns[$pattern]}" in
                    CRITICAL) send_critical_alert "$line" ;;
                    WARNING) log_warning "$line" ;;
                esac
            fi
        done
    done
}

# Example usage
send_alert() {
    local message="$1"
    local severity="$2"
    
    echo "[$severity] $(date): $message" | \
        tee -a /var/log/alerts.log | \
        mail -s "[$severity] Log Alert from $(hostname)" admin@example.com 2>/dev/null
}

# Rate-limited alerting
send_rate_limited_alert() {
    local key="$1"
    local message="$2"
    local window="${3:-300}"
    local rate_file="/tmp/alerts_${key}.rate"
    
    mkdir -p "$(dirname "$rate_file")"
    
    # Clean old entries
    find "$(dirname "$rate_file")" -name "${key}*.rate" -mmin +"$window" -delete
    
    # Check rate
    if [ -f "$rate_file" ]; then
        count=$(wc -l < "$rate_file")
        if [ "$count" -ge 10 ]; then
            echo "Rate limit reached for $key, skipping alert"
            return 0
        fi
    fi
    
    # Send alert and record
    echo "$(date)" >> "$rate_file"
    echo "ALERT: $message"
}

# Log aggregation with buffering
buffered_log_monitor() {
    local logfile="$1"
    local pattern="$2"
    local buffer_file="/tmp/log_monitor.buffer"
    local flush_interval=60
    local last_flush=$(date +%s)
    
    tail -n 0 -f "$logfile" 2>/dev/null | \
    while IFS= read -r line; do
        if echo "$line" | grep -q "$pattern"; then
            echo "$line" >> "$buffer_file"
            
            # Flush buffer periodically
            if [ $(($(date +%s) - last_flush)) -ge $flush_interval ]; then
                if [ -s "$buffer_file" ]; then
                    count=$(wc -l < "$buffer_file")
                    echo "Flushing $count alerts"
                    # Process buffer
                    cat