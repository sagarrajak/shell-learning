# Week 1: Foundation - Linux Shell Scripting for Beginners

**Duration:** 7 Days  
**Level:** Beginner  
**Focus:** Building strong fundamentals in shell scripting and basic system administration

---

## 📋 Week Overview

This week establishes your foundation in Linux shell scripting. You'll learn the essential building blocks that every system administrator needs to know, from basic commands to writing your first automation scripts.

### Learning Objectives

By the end of Week 1, you will be able to:
- Navigate and operate in the Linux command line efficiently
- Write and execute basic shell scripts
- Use variables, operators, and control flow structures
- Perform file and directory operations
- Monitor system resources using essential commands
- Automate simple daily tasks

---

## Day 1: Shell Environment & Basic Commands

### 🎯 Learning Goals
- Understand the Linux shell environment
- Master essential navigation and file operation commands
- Learn command-line basics and shortcuts

### 📚 Topics Covered

#### 1.1 Understanding the Shell

**Problem Statement:** You're a new system administrator who needs to understand how to interact with Linux servers efficiently. You need to know what the shell is and how to use it effectively.

**Solution:**
```bash
# Check your current shell
echo $SHELL

# List available shells
cat /etc/shells

# Switch to bash if not already
bash

# Check bash version
bash --version
```

**Key Concepts:**
- **Shell**: Command-line interface that interprets your commands
- **Bash**: Bourne Again Shell - most common and powerful
- **Terminal**: The program that runs the shell
- **Prompt**: Shows current user, hostname, and directory

#### 1.2 Essential Navigation Commands

**Problem Statement:** You need to navigate through the Linux file system to locate configuration files, logs, and application directories.

**Solution:**
```bash
# Print working directory
pwd

# List files (detailed view)
ls -la

# List with human-readable sizes
ls -lh

# Change directory
cd /var/log
cd ~          # Go to home directory
cd ..         # Go up one level
cd -          # Go to previous directory

# Tree view (install if needed: sudo apt install tree)
tree -L 2     # Show 2 levels deep
```

#### 1.3 File Operations

**Problem Statement:** You need to create, copy, move, and delete files as part of your daily administration tasks.

**Solution:**
```bash
# Create files
touch testfile.txt
echo "Hello World" > newfile.txt

# Copy files
cp source.txt destination.txt
cp -r directory/ new_directory/

# Move/rename files
mv oldname.txt newname.txt
mv file.txt /path/to/destination/

# Remove files
rm file.txt
rm -r directory/          # Recursive delete
rm -rf directory/         # Force recursive (use carefully!)

# View file contents
cat file.txt
less file.txt             # Scrollable view
head -n 10 file.txt       # First 10 lines
tail -n 10 file.txt       # Last 10 lines
tail -f logfile.txt       # Follow file in real-time
```

#### 1.4 Command Line Shortcuts

**Problem Statement:** You want to work faster in the terminal by using keyboard shortcuts.

**Solution:**
```bash
# History navigation
!!              # Execute last command
!100            # Execute command number 100 from history
history         # Show command history
Ctrl+r          # Search command history

# Cursor movement
Ctrl+a          # Go to start of line
Ctrl+e          # Go to end of line
Alt+b           # Move back one word
Alt+f           # Move forward one word

# Editing
Ctrl+u          # Cut from cursor to start
Ctrl+k          # Cut from cursor to end
Ctrl+w          # Cut last word
Ctrl+y          # Paste last cut

# Process control
Ctrl+c          # Interrupt current command
Ctrl+z          # Suspend current command
Ctrl+d          # Exit shell
```

### 💡 Practice Exercise 1.1

**Task:** Create a directory structure for a web application and populate it with sample files.

```bash
# Create the following structure:
# /home/user/webapp/
# ├── config/
# ├── logs/
# ├── scripts/
# └── public/
#     ├── css/
#     ├── js/
#     └── images/

# Create sample configuration file in config/
# Create empty log files in logs/
# Create a sample script in scripts/
```

**Solution:** See `exercises/exercise_1_1_solution.sh`

---

## Day 2: Your First Shell Script

### 🎯 Learning Goals
- Create and execute shell scripts
- Understand script structure and shebang
- Learn about script permissions

### 📚 Topics Covered

#### 2.1 Creating Your First Script

**Problem Statement:** You need to automate the repetitive task of checking system information every morning.

**Solution:**
```bash
#!/bin/bash

# System Information Checker
# Author: Your Name
# Date: $(date +%Y-%m-%d)

echo "=========================================="
echo "       System Information Report"
echo "=========================================="
echo "Hostname: $(hostname)"
echo "Current User: $(whoami)"
echo "Current Date: $(date)"
echo "Uptime: $(uptime -p)"
echo "Kernel Version: $(uname -r)"
echo "=========================================="
```

**Key Components:**
- `#!/bin/bash` - Shebang line, tells system which interpreter to use
- `#` - Comments for documentation
- `echo` - Print to stdout
- `$(command)` - Command substitution

#### 2.2 Making Scripts Executable

**Problem Statement:** You've created a script but can't run it directly.

**Solution:**
```bash
# Create the script
nano system_info.sh

# Make it executable
chmod +x system_info.sh

# Run it
./system_info.sh

# Or run with bash
bash system_info.sh
```

**Permission Modes:**
```bash
# Read, write, execute permissions
chmod 755 script.sh    # rwxr-xr-x (owner: all, group/others: read+execute)
chmod 700 script.sh    # rwx------ (owner only)
chmod +x script.sh     # Add execute permission
chmod -x script.sh     # Remove execute permission
```

#### 2.3 Script Best Practices

**Problem Statement:** You want to write clean, maintainable scripts.

**Solution:**
```bash
#!/bin/bash

# =============================================================================
# Script Name: backup_checker.sh
# Description: Checks if backup files exist and are recent
# Author: System Administrator
# Created: 2024-01-15
# Last Modified: 2024-01-15
# Usage: ./backup_checker.sh [directory]
# =============================================================================

# Set strict mode for better error handling
set -euo pipefail

# Configuration
BACKUP_DIR="${1:-/var/backups}"
MAX_AGE_DAYS=7

# Function to check backup
check_backup() {
    local dir="$1"
    echo "Checking backups in: $dir"
    
    if [ ! -d "$dir" ]; then
        echo "Error: Directory $dir does not exist"
        return 1
    fi
    
    # Find files modified within MAX_AGE_DAYS
    find "$dir" -type f -mtime -"$MAX_AGE_DAYS" | while read -r file; do
        echo "Recent backup found: $file"
    done
}

# Main execution
check_backup "$BACKUP_DIR"
```

### 💡 Practice Exercise 2.1

**Task:** Create a script that:
1. Prints a welcome message with your name
2. Shows the current date and time
3. Lists files in the current directory
4. Counts the number of files
5. Prints a goodbye message

**Solution:** See `exercises/exercise_2_1_solution.sh`

---

## Day 3: Variables and Data Types

### 🎯 Learning Goals
- Understand variable declaration and usage
- Learn about different data types
- Master variable scope and environment variables

### 📚 Topics Covered

#### 3.1 Variable Basics

**Problem Statement:** You need to store and manipulate data in your scripts for configuration and processing.

**Solution:**
```bash
#!/bin/bash

# Variable assignment (no spaces around =)
name="John Doe"
age=30
is_admin=true
salary=50000.50

# Using variables
echo "Name: $name"
echo "Age: $age"
echo "Is Admin: $is_admin"
echo "Salary: $salary"

# Variable with command substitution
current_date=$(date +%Y-%m-%d)
echo "Today is: $current_date"

# Variable with arithmetic
count=10
count=$((count + 5))
echo "Count is now: $count"
```

#### 3.2 Environment Variables

**Problem Statement:** You need to access system environment variables and set your own for script configuration.

**Solution:**
```bash
#!/bin/bash

# Access environment variables
echo "Home Directory: $HOME"
echo "Current User: $USER"
echo "Shell: $SHELL"
echo "Path: $PATH"
echo "Hostname: $HOSTNAME"

# Set local environment variable
export MY_APP_ENV="production"
export DB_HOST="localhost"
export DB_PORT="5432"

# Use in script
echo "Application Environment: $MY_APP_ENV"
echo "Database: $DB_HOST:$DB_PORT"

# Check if variable is set
if [ -z "${UNSET_VAR:-}" ]; then
    echo "Variable is not set or empty"
fi

# Set default value if not set
TIMEOUT="${REQUEST_TIMEOUT:-30}"
echo "Timeout: $TIMEOUT seconds"
```

#### 3.3 Special Variables

**Problem Statement:** You need to handle script arguments and special shell variables.

**Solution:**
```bash
#!/bin/bash

# Script arguments
echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "Number of arguments: $#"
echo "Process ID: $$"
echo "Exit status of last command: $?"

# Example with arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <arg1> <arg2>"
    exit 1
fi

echo "Processing $# arguments..."
for arg in "$@"; do
    echo "  - $arg"
done
```

#### 3.4 Read User Input

**Problem Statement:** You need to interact with users and get input during script execution.

**Solution:**
```bash
#!/bin/bash

# Simple input
echo "Enter your name:"
read name
echo "Hello, $name!"

# Prompt with -p flag
read -p "Enter your age: " age
echo "You are $age years old"

# Silent input (for passwords)
read -s -p "Enter password: " password
echo
echo "Password received (length: ${#password})"

# Timeout input
read -t 5 -p "Quick response (5 seconds): " response
echo "You said: $response"

# Read into array
read -p "Enter multiple values (space separated): " -a values
echo "Array elements: ${values[@]}"
echo "First element: ${values[0]}"
echo "Number of elements: ${#values[@]}"
```

### 💡 Practice Exercise 3.1

**Task:** Create a script that:
1. Asks user for their name, age, and favorite color
2. Stores these in variables
3. Calculates the year they were born
4. Prints a personalized message with all information
5. Uses environment variables to get the current year

**Solution:** See `exercises/exercise_3_1_solution.sh`

---

## Day 4: Operators and Arithmetic

### 🎯 Learning Goals
- Master arithmetic operators
- Learn comparison operators
- Understand string operations
- Use logical operators

### 📚 Topics Covered

#### 4.1 Arithmetic Operators

**Problem Statement:** You need to perform calculations in your scripts for resource monitoring and statistics.

**Solution:**
```bash
#!/bin/bash

# Basic arithmetic
a=10
b=5

echo "Addition: $((a + b))"        # 15
echo "Subtraction: $((a - b))"     # 5
echo "Multiplication: $((a * b))"  # 50
echo "Division: $((a / b))"        # 2
echo "Modulus: $((a % b))"         # 0

# Increment/decrement
count=0
((count++))
echo "Count after increment: $count"  # 1

((count--))
echo "Count after decrement: $count"  # 0

# Power
echo "2^10: $((2 ** 10))"  # 1024

# Using expr (older method)
result=$(expr 5 + 3)
echo "Result using expr: $result"

# Using bc for floating point
pi=$(echo "scale=10; 22/7" | bc)
echo "Pi approximation: $pi"
```

#### 4.2 Comparison Operators

**Problem Statement:** You need to compare values for conditional logic in your scripts.

**Solution:**
```bash
#!/bin/bash

# Integer comparisons
num1=10
num2=20

if [ $num1 -eq $num2 ]; then
    echo "$num1 equals $num2"
elif [ $num1 -lt $num2 ]; then
    echo "$num1 is less than $num2"
elif [ $num1 -gt $num2 ]; then
    echo "$num1 is greater than $num2"
fi

# Comparison operators:
# -eq  : Equal
# -ne  : Not equal
# -lt  : Less than
# -le  : Less than or equal
# -gt  : Greater than
# -ge  : Greater than or equal

# String comparisons
str1="hello"
str2="world"

if [ "$str1" = "$str2" ]; then
    echo "Strings are equal"
elif [ "$str1" != "$str2" ]; then
    echo "Strings are not equal"
fi

# Check if string is empty
if [ -z "$str1" ]; then
    echo "String is empty"
fi

if [ -n "$str1" ]; then
    echo "String is not empty"
fi
```

#### 4.3 Logical Operators

**Problem Statement:** You need to combine multiple conditions in your logic.

**Solution:**
```bash
#!/bin/bash

# AND operator
age=25
has_license=true

if [ $age -ge 18 ] && [ "$has_license" = true ]; then
    echo "You can drive"
fi

# OR operator
day="Saturday"
if [ "$day" = "Saturday" ] || [ "$day" = "Sunday" ]; then
    echo "It's weekend!"
fi

# NOT operator
is_raining=false
if [ ! "$is_raining" = true ]; then
    echo "It's not raining"
fi

# Complex conditions
score=85
attendance=90

if [ $score -ge 70 ] && [ $attendance -ge 80 ]; then
    echo "Passed with good attendance"
elif [ $score -ge 70 ]; then
    echo "Passed but attendance needs improvement"
else
    echo "Needs improvement"
fi
```

#### 4.4 File Test Operators

**Problem Statement:** You need to check file properties before performing operations.

**Solution:**
```bash
#!/bin/bash

file="/etc/passwd"
dir="/var/log"

# File existence and type
if [ -e "$file" ]; then
    echo "File exists"
fi

if [ -f "$file" ]; then
    echo "It's a regular file"
fi

if [ -d "$dir" ]; then
    echo "It's a directory"
fi

# File permissions
if [ -r "$file" ]; then
    echo "File is readable"
fi

if [ -w "$file" ]; then
    echo "File is writable"
fi

if [ -x "$file" ]; then
    echo "File is executable"
fi

# File properties
if [ -s "$file" ]; then
    echo "File is not empty"
fi

# More file tests:
# -e : Exists
# -f : Regular file
# -d : Directory
# -r : Readable
# -w : Writable
# -x : Executable
# -s : Not empty (size > 0)
# -L : Symbolic link
# -b : Block device
# -c : Character device
```

### 💡 Practice Exercise 4.1

**Task:** Create a calculator script that:
1. Accepts two numbers and an operator (+, -, *, /) as arguments
2. Performs the calculation
3. Handles division by zero
4. Displays the result in a formatted way

**Solution:** See `exercises/exercise_4_1_solution.sh`

---

## Day 5: Control Flow - If/Else and Case

### 🎯 Learning Goals
- Master conditional statements
- Learn case statement for multiple conditions
- Understand nested conditions
- Practice real-world decision-making scenarios

### 📚 Topics Covered

#### 5.1 If/Else Statements

**Problem Statement:** You need to make decisions based on system conditions, user input, or file states.

**Solution:**
```bash
#!/bin/bash

# Simple if statement
count=5
if [ $count -gt 0 ]; then
    echo "Count is positive"
fi

# If-else statement
age=18
if [ $age -ge 18 ]; then
    echo "You are an adult"
else
    echo "You are a minor"
fi

# If-elif-else
score=85
if [ $score -ge 90 ]; then
    echo "Grade: A"
elif [ $score -ge 80 ]; then
    echo "Grade: B"
elif [ $score -ge 70 ]; then
    echo "Grade: C"
elif [ $score -ge 60 ]; then
    echo "Grade: D"
else
    echo "Grade: F"
fi

# Nested if
temperature=25
weather="sunny"

if [ "$weather" = "sunny" ]; then
    if [ $temperature -gt 30 ]; then
        echo "It's hot and sunny"
    else
        echo "It's pleasant and sunny"
    fi
else
    echo "It's not sunny"
fi
```

#### 5.2 Case Statement

**Problem Statement:** You need to handle multiple possible values efficiently without many if-elif statements.

**Solution:**
```bash
#!/bin/bash

# Simple case
day="Monday"

case $day in
    "Monday"|"Tuesday"|"Wednesday"|"Thursday"|"Friday")
        echo "It's a weekday"
        ;;
    "Saturday"|"Sunday")
        echo "It's weekend!"
        ;;
    *)
        echo "Invalid day"
        ;;
esac

# Case with patterns
file="document.pdf"

case $file in
    *.txt)
        echo "Text file"
        ;;
    *.pdf)
        echo "PDF document"
        ;;
    *.jpg|*.png|*.gif)
        echo "Image file"
        ;;
    *)
        echo "Unknown file type"
        ;;
esac

# Case for menu selection
echo "Select an option:"
echo "1. Check disk space"
echo "2. Check memory"
echo "3. Check CPU"
echo "4. Exit"

read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        df -h
        ;;
    2)
        free -h
        ;;
    3)
        top -bn1 | head -20
        ;;
    4)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
```

#### 5.3 Real-World Example: System Health Check

**Problem Statement:** You need to create a script that checks various system health indicators and reports issues.

**Solution:**
```bash
#!/bin/bash

# System Health Checker
# Checks disk space, memory, and CPU usage

# Configuration
DISK_THRESHOLD=80
MEM_THRESHOLD=80
CPU_THRESHOLD=80

# Check disk space
check_disk() {
    local usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ $usage -gt $DISK_THRESHOLD ]; then
        echo "WARNING: Disk usage is ${usage}% (threshold: ${DISK_THRESHOLD}%)"
        return 1
    else
        echo "OK: Disk usage is ${usage}%"
        return 0
    fi
}

# Check memory
check_memory() {
    local usage=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
    if [ $usage -gt $MEM_THRESHOLD ]; then
        echo "WARNING: Memory usage is ${usage}% (threshold: ${MEM_THRESHOLD}%)"
        return 1
    else
        echo "OK: Memory usage is ${usage}%"
        return 0
    fi
}

# Check CPU
check_cpu() {
    local usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    usage=${usage%.*}  # Remove decimal
    
    if [ $usage -gt $CPU_THRESHOLD ]; then
        echo "WARNING: CPU usage is ${usage}% (threshold: ${CPU_THRESHOLD}%)"
        return 1
    else
        echo "OK: CPU usage is ${usage}%"
        return 0
    fi
}

# Main
echo "=== System Health Check ==="
echo

check_disk
check_memory
check_cpu

echo
echo "Health check complete!"
```

### 💡 Practice Exercise 5.1

**Task:** Create a file manager script that:
1. Accepts a filename as argument
2. Checks if the file exists
3. Determines the file type (text, image, pdf, etc.)
4. Shows file size and permissions
5. Offers to open/view the file based on type

**Solution:** See `exercises/exercise_5_1_solution.sh`

---

## Day 6: Loops - For, While, and Until

### 🎯 Learning Goals
- Master all types of loops in bash
- Learn loop control (break, continue)
- Practice iteration over files and data
- Create practical automation scripts

### 📚 Topics Covered

#### 6.1 For Loops

**Problem Statement:** You need to process multiple items, files, or perform repetitive tasks.

**Solution:**
```bash
#!/bin/bash

# For loop with list
echo "Counting from 1 to 5:"
for i in 1 2 3 4 5; do
    echo "Number: $i"
done

# For loop with range
echo "Counting from 1 to 10:"
for i in {1..10}; do
    echo "Number: $i"
done

# For loop with step
echo "Even numbers from 2 to 10:"
for i in {2..10..2}; do
    echo "Number: $i"
done

# For loop over files
echo "Files in current directory:"
for file in *; do
    if [ -f "$file" ]; then
        echo "  - $file"
    fi
done

# For loop with command output
echo "Users on system:"
for user in $(cut -d: -f1 /etc/passwd | head -5); do
    echo "  - $user"
done

# C-style for loop
echo "Countdown:"
for ((i=10; i>=0; i--)); do
    echo "$i"
    sleep 1
done
echo "Liftoff!"
```

#### 6.2 While Loops

**Problem Statement:** You need to repeat actions until a condition is met or process data line by line.

**Solution:**
```bash
#!/bin/bash

# Simple while loop
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done

# While loop reading file line by line
echo "Reading /etc/hosts:"
while IFS= read -r line; do
    echo "  $line"
done < /etc/hosts | head -5

# While loop with user input
echo "Guess the number (1-10):"
secret_number=7

while true; do
    read -p "Enter your guess: " guess
    
    if [ $guess -eq $secret_number ]; then
        echo "Correct! You won!"
        break
    elif [ $guess -lt $secret_number ]; then
        echo "Too low! Try again."
    else
        echo "Too high! Try again."
    fi
done

# While loop monitoring file
echo "Monitoring file (press Ctrl+C to stop):"
while inotifywait -q -e modify /var/log/syslog > /dev/null 2>&1; do
    echo "File modified at $(date)"
done
```

#### 6.3 Until Loops

**Problem Statement:** You need to repeat actions until a condition becomes true.

**Solution:**
```bash
#!/bin/bash

# Until loop
count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    ((count++))
done

# Until loop waiting for service
echo "Waiting for service to start..."
until curl -s http://localhost:8080/health > /dev/null; do
    echo "Service not ready yet..."
    sleep 2
done
echo "Service is ready!"

# Until loop with timeout
timeout=30
elapsed=0

until [ $elapsed -ge $timeout ]; do
    if [ -f "/tmp/signal.txt" ]; then
        echo "Signal file found!"
        break
    fi
    echo "Waiting... ($elapsed/$timeout)"
    sleep 1
    ((elapsed++))
done

if [ $elapsed -ge $timeout ]; then
    echo "Timeout reached!"
fi
```

#### 6.4 Loop Control

**Problem Statement:** You need to control loop execution with break and continue.

**Solution:**
```bash
#!/bin/bash

# Break example
echo "Finding first even number:"
for i in {1..10}; do
    if [ $((i % 2)) -eq 0 ]; then
        echo "Found: $i"
        break
    fi
done

# Continue example
echo "Printing odd numbers:"
for i in {1..10}; do
    if [ $((i % 2)) -eq 0 ]; then
        continue
    fi
    echo "  $i"
done

# Nested loops with break
echo "Searching in 2D array:"
found=false
for i in {1..3}; do
    for j in {1..3}; do
        echo "Checking [$i,$j]"
        if [ $i -eq 2 ] && [ $j -eq 2 ]; then
            echo "Found at [$i,$j]!"
            found=true
            break 2  # Break out of both loops
        fi
    done
done
```

#### 6.5 Real-World Example: Log Analyzer

**Problem Statement:** You need to analyze log files and count different types of errors.

**Solution:**
```bash
#!/bin/bash

# Log Analyzer
# Counts different types of log entries

LOG_FILE="/var/log/syslog"

if [ ! -f "$LOG_FILE" ]; then
    echo "Log file not found: $LOG_FILE"
    exit 1
fi

# Initialize counters
error_count=0
warning_count=0
info_count=0
other_count=0

# Process log file
while IFS= read -r line; do
    case "$line" in
        *ERROR*|*error*)
            ((error_count++))
            ;;
        *WARNING*|*warning*)
            ((warning_count++))
            ;;
        *INFO*|*info*)
            ((info_count++))
            ;;
        *)
            ((other_count++))
            ;;
    esac
done < "$LOG_FILE"

# Display results
echo "=== Log Analysis Results ==="
echo "Errors:   $error_count"
echo "Warnings: $warning_count"
echo "Info:     $info_count"
echo "Other:    $other_count"
echo "Total:    $((error_count + warning_count + info_count + other_count))"
```

### 💡 Practice Exercise 6.1

**Task:** Create a batch file processor script that:
1. Accepts a directory path as argument
2. Finds all .txt files in that directory
3. For each file:
   - Count lines
   - Count words
   - Count characters
   - Display file size
4. Show summary statistics at the end

**Solution:** See `exercises/exercise_6_1_solution.sh`

---

## Day 7: Essential System Administration Commands

### 🎯 Learning Goals
- Master daily system administration commands
- Learn system monitoring tools
- Understand process management
- Practice log analysis techniques

### 📚 Topics Covered

#### 7.1 System Information Commands

**Problem Statement:** As a system administrator, you need to quickly gather system information for troubleshooting and reporting.

**Solution:**
```bash
#!/bin/bash

# System Information Gathering Script

echo "=== System Information ==="
echo

# Basic system info
echo "--- Basic Info ---"
echo "Hostname: $(hostname)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Uptime: $(uptime -p)"
echo

# Hardware info
echo "--- Hardware Info ---"
echo "CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
echo "CPU Cores: $(nproc)"
echo "Total Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Disk Space: $(df -h / | tail -1 | awk '{print $2}')"
echo

# Network info
echo "--- Network Info ---"
ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print "IP: " $2}'
echo "Gateway: $(ip route | grep default | awk '{print $3}')"
echo

# User info
echo "--- User Info ---"
echo "Current User: $(whoami)"
echo "Logged in users: $(who | wc -l)"
echo
```

#### 7.2 Process Management

**Problem Statement:** You need to monitor and manage processes running on the system.

**Solution:**
```bash
#!/bin/bash

# Process Management Examples

# List all processes
echo "All processes:"
ps aux

# Find specific process
echo "Finding nginx process:"
ps aux | grep nginx

# Process with specific user
echo "Processes by user:"
ps -u username

# Kill process by name
pkill process_name

# Kill process by PID
kill 1234

# Force kill
kill -9 1234

# Background process
sleep 60 &

# Bring to foreground
fg

# List background jobs
jobs

# Monitor process in real-time
top

# Process tree
pstree

# Find process using port
lsof -i :8080
netstat -tulpn | grep :8080
```

#### 7.3 System Monitoring

**Problem Statement:** You need to monitor system resources in real-time and generate reports.

**Solution:**
```bash
#!/bin/bash

# System Monitoring Script

echo "=== System Resource Monitor ==="
echo

# CPU Usage
echo "--- CPU Usage ---"
top -bn1 | grep "Cpu(s)" | \
  sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
  awk '{print "CPU Usage: " 100 - $1 "%"}'
echo

# Memory Usage
echo "--- Memory Usage ---"
free -h | grep Mem | awk '{
  total=$2
  used=$3
  free=$4
  percent=$3/$2*100
  printf "Total: %s, Used: %s (%.1f%%), Free: %s\n", total, used, percent, free
}'
echo

# Disk Usage
echo "--- Disk Usage ---"
df -h | grep -E '^/dev/' | awk '{
  printf "%-20s %5s  %5s  %5s  %s\n", $1, $3, $4, $5, $6
}'
echo

# Network Statistics
echo "--- Network Statistics ---"
echo "Received packets: $(cat /proc/net/dev | grep eth0 | awk '{print $2}')"
echo "Transmitted packets: $(cat /proc/net/dev | grep eth0 | awk '{print $10}')"
echo

# Load Average
echo "--- Load Average ---"
uptime | awk -F'load average:' '{print "Load Average:" $2}'
echo

# Top 5 processes by CPU
echo "--- Top 5 Processes by CPU ---"
ps aux --sort=-%cpu | head -6 | awk 'NR>1 {printf "%-10s %5s %s\n", $1, $3, $11}'
echo
```

#### 7.4 Log File Analysis

**Problem Statement:** You need to analyze system logs to find errors, warnings, and important events.

**Solution:**
```bash
#!/bin/bash

# Log Analysis Script

LOG_FILE="/var/log/syslog"

if [ ! -f "$LOG_FILE" ]; then
    echo "Log file not found: $LOG_FILE"
    exit 1
fi

echo "=== Log Analysis: $LOG_FILE ==="
echo

# Total lines
total_lines=$(wc -l < "$LOG_FILE")
echo "Total lines: $total_lines"
echo

# Recent errors (last 100 lines)
echo "--- Recent Errors (last 100 lines) ---"
tail -n 100 "$LOG_FILE" | grep -i error | head -10
echo

# Count by log level
echo "--- Log Level Counts ---"
echo "Errors: $(grep -ci error "$LOG_FILE")"
echo "Warnings: $(grep -ci warning "$LOG_FILE")"
echo "Info: $(grep -ci info "$LOG_FILE")"
echo

# Top 5 services by log entries
echo "--- Top 5 Services ---"
grep -oP '\[\K[^\]]+' "$LOG_FILE" | sort | uniq -c | sort -rn | head -5
echo

# Recent activity
echo "--- Recent Activity (last 10 lines) ---"
tail -n 10 "$LOG_FILE"
echo

# Find specific pattern
echo "--- SSH Login Attempts ---"
grep -i "sshd.*accepted" "$LOG_FILE" | tail -5
echo
```

#### 7.5 File System Operations

**Problem Statement:** You need to perform common file system operations for maintenance.

**Solution:**
```bash
#!/bin/bash

# File System Operations

# Find large files
echo "Finding files larger than 100MB:"
find / -type f -size +100M 2>/dev/null | head -10
echo

# Find old files
echo "Finding files older than 30 days:"
find /var/log -type f -mtime +30 | head -10
echo

# Find empty files
echo "Finding empty files:"
find /tmp -type f -empty | head -10
echo

# Disk usage by directory
echo "Disk usage by directory:"
du -sh /var/* 2>/dev/null | sort -rh | head -10
echo

# Check file permissions
echo "Files with write permission for all:"
find /var/www -type f -perm -o+w | head -10
echo

# Find broken symlinks
echo "Finding broken symlinks:"
find / -type l ! -exec test -e {} \; 2>/dev/null | head -10
echo
```

#### 7.6 User Management

**Problem Statement:** You need to automate user and group management tasks.

**Solution:**
```bash
#!/bin/bash

# User Management Operations

# List all users
echo "All system users:"
cut -d: -f1 /etc/passwd
echo

# List logged in users
echo "Currently logged in users:"
who
echo

# Add user (requires root)
# sudo useradd -m -s /bin/bash username
# sudo passwd username

# Delete user
# sudo userdel -r username

# Add user to group
# sudo usermod -aG groupname username

# List user groups
echo "Groups for current user:"
groups
echo

# Check user details
echo "Current user details:"
id
echo

# List all groups
echo "All system groups:"
cut -d: -f1 /etc/group
echo
```

### 💡 Practice Exercise 7.1

**Task:** Create a comprehensive system monitoring script that:
1. Checks disk space on all mounted partitions
2. Monitors CPU and memory usage
3. Lists top 5 processes by CPU and memory
4. Checks for recent errors in system logs
5. Sends alerts if any threshold is exceeded
6. Generates a daily report file

**Solution:** See `exercises/exercise_7_1_solution.sh`

---

## 🎯 Week 1 Summary

### What You've Learned

1. **Shell Environment**: Understanding the Linux shell and command line
2. **Script Creation**: Writing and executing your first scripts
3. **Variables**: Storing and manipulating data
4. **Operators**: Performing calculations and comparisons
5. **Control Flow**: Making decisions with if/else and case
6. **Loops**: Automating repetitive tasks
7. **System Commands**: Essential administration tools

### Key Takeaways

- Always start scripts with `#!/bin/bash`
- Use `chmod +x` to make scripts executable
- Quote variables to handle spaces: `"$var"`
- Test your scripts thoroughly before production use
- Use comments to document your code
- Practice daily to build muscle memory

### Next Steps

You're now ready for **Week 2: Intermediate**, where you'll learn:
- Functions and modular scripting
- Arrays and advanced data structures
- String manipulation and text processing
- Real-world automation scenarios
- Log aggregation and analysis
- Job scheduling with cron

---

## 📝 Week 1 Project

**Project: System Maintenance Automation Script**

Create a comprehensive script that performs the following daily maintenance tasks:

1. **System Health Check**
   - Check disk space (alert if > 80%)
   - Check memory usage (alert if > 80%)
   - Check CPU usage (alert if > 80%)
   - Check if critical services are running

2. **Log Management**
   - Rotate old log files (older than 7 days)
   - Compress rotated logs
   - Clean up temporary files

3. **Backup Verification**
   - Check if daily backup exists
   - Verify backup file size
   - Report backup status

4. **Report Generation**
   - Create a daily report with all findings
   - Save report with timestamp
   - Send email notification if issues found

**Requirements:**
- Use all concepts learned this week
- Include proper error handling
- Add logging functionality
- Make it configurable with variables
- Test thoroughly before deployment

**Solution:** See `exercises/week1_project_solution.sh`

---

**Congratulations on completing Week 1!** 🎉

You've built a solid foundation in Linux shell scripting. Continue to Week 2 to take your skills to the next level!
