# Week 4: Professional System Administration

**Duration:** 7 Days  
**Level:** Professional  
**Focus:** Advanced text processing, time synchronization, user/group management, and service management

---

## 📋 Week Overview

Building on Weeks 1-3 foundations, this week focuses on professional-level system administration skills including advanced text processing with sed and awk, time synchronization services, user/group management, and systemd service management.

### Learning Objectives

By the end of Week 4, you will be able to:
- Master sed and awk for complex text processing and log analysis
- Manage Linux services and understand service lifecycle
- Handle file and folder permissions professionally
- Integrate grep, sed, awk together for powerful data processing
- Configure and manage NTP services (ntpd, chrony, timesyncd)
- Manage users and groups effectively
- Work with systemd for service management

---

## Day 1: Advanced Text Processing - sed Mastery

### 🎯 Learning Goals
- Master sed for text transformations
- Understand sed addressing and pattern matching
- Perform in-place editing and backups
- Create complex sed scripts

### 📚 Topics Covered

#### 1.1 sed Fundamentals Review

**Problem Statement:** You need to perform text transformations on configuration files and logs efficiently.

**Solution:**
```bash
#!/bin/bash

# Basic sed substitution
echo "Hello World" | sed 's/World/Universe/'

# Case-insensitive replacement
echo "ERROR: test error" | sed 's/error/WARNING/gi'

# Regex with capture groups
echo "2024-01-15" | sed -E 's/([0-9]+)-([0-9]+)-([0-9]+)/\3-\2-\1/'

# Multiple replacements
sed -e 's/foo/bar/g' -e 's/baz/qux/g' file.txt
```

#### 1.2 sed Addressing

**Problem Statement:** You need to apply transformations only to specific lines.

**Solution:**
```bash
#!/bin/bash

# Line addressing
sed '5s/old/new/' file.txt           # Only line 5
sed '1,10s/old/new/' file.txt        # Lines 1-10
sed '10,$s/old/new/' file.txt        # Line 10 to end

# Pattern addressing
sed '/^#/d' file.txt                 # Delete comment lines
sed '/^$/d' file.txt                 # Delete empty lines
sed '/ERROR/,/WARNING/d' file.txt     # Delete range

# Context addressing
sed -n '/PATTERN/p' file.txt         # Print only matches
sed '/PATTERN/!s/old/new/' file.txt # Replace except match
```

#### 1.3 Advanced sed Operations

**Problem Statement:** You need multi-line operations and complex transformations.

**Solution:**
```bash
#!/bin/bash

# Multi-line substitution
sed ':a;N;$!ba;s/\n/ /g' file.txt    # Join lines

# In-place with backup
sed -i.bak 's/old/new/g' file.txt

# Hold space operations
sed -n '1h;G;p' file.txt             # Duplicate first line

# Character translation
sed 'y/abc/xyz/' file.txt             # a->x, b->y, c->z

# Conditional replacement
sed '/ERROR/ s/WARNING/CRITICAL/g' logfile.log
```

#### 1.4 sed Scripts

**Problem Statement:** You need reusable sed scripts for complex operations.

**Solution:**
```bash
#!/bin/bash

# Create sed script file
cat > clean.sed << 'EOF'
# Remove comments
/^#/d
# Remove empty lines
/^$/d
# Remove trailing whitespace
s/[[:space:]]*$//
// Convert tabs to spaces
s/\t/    /g
EOF

# Run sed script
sed -f clean.sed input.txt > output.txt
```

---

## Day 2: Advanced Text Processing - awk Mastery

### 🎯 Learning Goals
- Master awk for data extraction and reporting
- Understand awk variables and arrays
- Create awk-based reporting tools

### 📚 Topics Covered

#### 2.1 awk Fundamentals

**Problem Statement:** You need to extract and process structured data.

**Solution:**
```bash
#!/bin/bash

# Basic field extraction
awk '{print $1, $3}' data.txt

# Field separator
awk -F: '{print $1, $NF}' /etc/passwd
awk -F',' '{print $2}' data.csv

# Print specific lines
awk 'NR==1 || NR==5' file.txt
awk 'NR>5 && NR<=10' file.txt

# Pattern matching
awk '/ERROR/ {print}' logfile.log
awk '$3 > 100 {print}' data.txt
```

#### 2.2 awk Variables and Arrays

**Problem Statement:** You need to perform calculations and store data.

**Solution:**
```bash
#!/bin/bash

# Variables and calculations
awk '{sum+=$2; count++} END {print "Average:", sum/count}' data.txt

# Associative arrays
awk '{counts[$1]++} END {for (k in counts) print k, counts[k]}' data.txt

# Multidimensional simulation
awk '{
    data[$1][$2]=$3
    total[$2]+=$3
}
END {
    for (srv in data) {
        print srv
        for (met in data[srv]) {
            print "  " met ": " data[srv][met]
        }
    }
}' metrics.txt
```

#### 2.3 awk Functions

**Problem Statement:** You need reusable awk functions for data processing.

**Solution:**
```bash
#!/bin/bash

# awk with functions
awk '
function round(x) {
    return int(x + 0.5)
}
{
    printf "%s: %.2f\n", $1, round($2)
}
' data.txt

# Custom formatting
awk '
BEGIN { printf "%-20s %10s\n", "Name", "Score" }
{ printf "%-20s %10d\n", $1, $2 }
' data.txt
```

---

## Day 3: Using sed, awk, grep Together

### 🎯 Learning Goals
- Integrate multiple text processing tools
- Create powerful data pipelines
- Build log analysis scripts

### 📚 Topics Covered

#### 3.1 Pipeline Integration

**Problem Statement:** You need to process data through multiple transformation stages.

**Solution:**
```bash
#!/bin/bash

# Extract and analyze log data
cat /var/log/syslog | \
    grep -E '(ERROR|WARN)' | \
    sed -E 's/.*\[([0-9]+)\].*/\1/' | \
    sort | \
    uniq -c | \
    sort -rn | \
    head -20

# Process Apache logs
cat access.log | \
    grep -v '127.0.0.1' | \
    awk '{print $1}' | \
    sort | \
    uniq -c | \
    sort -rn | \
    head -10 | \
    awk '{printf "%-15s %5d\n", $2, $1}'

# Complex data extraction
cat data.csv | \
    grep -v '^#' | \
    awk -F',' '$3 > 50 {print}' | \
    sort -t',' -k4 -rn | \
    awk -F',' '{print $1, $4}'
```

#### 3.2 Real-World Log Analysis

**Problem Statement:** You need to analyze complex log files using multiple tools.

**Solution:**
```bash
#!/bin/bash

# Complete log analysis script
analyze_logs() {
    local logfile="$1"
    
    echo "=== Log Analysis Report ==="
    echo "Generated: $(date)"
    echo
    
    # Error summary with sed, awk, grep
    echo "Error Summary:"
    grep -iE 'error|fatal|exception' "$logfile" | \
        sed 's/.*\berror\b.*/ERROR/gi' | \
        sort | \
        uniq -c | \
        sort -rn | \
        head -10 | \
        awk '{printf "  %-30s %5d\n", $2, $1}'
    
    echo
    
    # IP statistics
    echo "Top IP Addresses:"
    awk '{print $1}' "$logfile" | \
        sort | \
        uniq -c | \
        sort -rn | \
        head -10 | \
        awk '{printf "  %-20s %5d\n", $2, $1}'
    
    echo
    
    # Status code distribution
    echo "HTTP Status Codes:"
    grep -oE 'HTTP/[12]\.[01] [0-9]+' "$logfile" | \
        awk '{print $2}' | \
        sort | \
        uniq -c | \
        sort -rn | \
        awk '{printf "  %-10s %5d\n", $2, $1}'
}

analyze_logs /var/log/nginx/access.log
```

---

## Day 4: Linux Services and Permissions

### 🎯 Learning Goals
- Understand Linux service architecture
- Manage file and folder permissions
- Secure configurations

### 📚 Topics Covered

#### 4.1 Linux Service Basics

**Problem Statement:** You need to understand how Linux services work and their lifecycle.

**Solution:**
```bash
#!/bin/bash

# Service management basics
systemctl start nginx
systemctl stop nginx
systemctl restart nginx
systemctl status nginx
systemctl enable nginx
systemctl disable nginx

# Check service status
systemctl is-active nginx
systemctl is-enabled nginx

# View service logs
journalctl -u nginx
journalctl -u nginx -n 50
journalctl -u nginx --since "1 hour ago"
```

#### 4.2 File and Folder Permissions

**Problem Statement:** You need to manage permissions for security and proper access.

**Solution:**
```bash
#!/bin/bash

# Permission basics (rwx)
# Owner | Group | Others
# rwx   | rwx   | rwx
# 421   | 421   | 421

# Set permissions
chmod 755 script.sh          # rwxr-xr-x
chmod 644 config.txt         # rw-r--r--
chmod +x script.sh           # Add execute
chmod -R 755 directory/      # Recursive

# Owner and group
chown user:group file.txt
chown -R user:group directory/

# Special permissions
chmod u+s file               # SUID
chmod g+s directory          # SGID
chmod +t directory           # Sticky bit

# Octal breakdown
# 4 - read (r)
# 2 - write (w)
# 1 - execute (x)
```

#### 4.3 Permission Scripts

**Problem Statement:** You need to audit and fix permissions at scale.

**Solution:**
```bash
#!/bin/bash

# Audit world-writable files
audit_world_writable() {
    find / -type f -perm -0002 2>/dev/null | \
        grep -v '/proc' | \
        head -20
}

# Audit SUID files
audit_suid() {
    find / -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | \
        head -20
}

# Set standard permissions
set_standard_perms() {
    local dir="$1"
    find "$dir" -type d -exec chmod 755 {} \;
    find "$dir" -type f -exec chmod 644 {} \;
    find "$dir" -type f -name "*.sh" -exec chmod 755 {} \;
}

# Secure a web directory
secure_web_dir() {
    local dir="$1"
    chmod -R 755 "$dir"
    chmod 644 "$dir"/*
    find "$dir" -type d -exec chmod 755 {} \;
}
```

---

## Day 5: Time Synchronization Services

### 🎯 Learning Goals
- Configure and manage NTP services
- Compare ntpd, chrony, and timesyncd
- Ensure accurate time across systems

### 📚 Topics Covered

#### 5.1 NTP Fundamentals

**Problem Statement:** You need accurate system time for logging, certificates, and coordination.

**Solution:**
```bash
#!/bin/bash

# Check current time
timedatectl
date
hwclock

# View time sources
chronyc sources
ntpq -p
```

#### 5.2 chrony Configuration

**Problem Statement:** You need to configure chrony as the primary time sync solution.

**Solution:**
```bash
#!/bin/bash

# Install chrony
apt-get install -y chrony
# or
yum install -y chrony

# Configure chrony (/etc/chrony/chrony.conf)
cat > /etc/chrony/chrony.conf << 'EOF'
# Serve time even if not synced
makestep 1 -1

# NTP servers
server 0.pool.ntp.org iburst
server 1.pool.ntp.org iburst
server 2.pool.ntp.org iburst
server 3.pool.ntp.org iburst

# Allow local network
allow 192.168.0.0/24
EOF

# Manage chrony service
systemctl enable chrony
systemctl start chrony
systemctl status chrony

# Manual sync
chronyc makestep

# Check sync status
chronyc tracking
```

#### 5.3 ntpd Configuration

**Problem Statement:** You need to configure ntpd for traditional NTP service.

**Solution:**
```bash
#!/bin/bash

# Install ntpd
apt-get install -y ntp
# or
yum install -y ntp

# Configure ntpd (/etc/ntp.conf)
cat > /etc/ntp.conf << 'EOF'
driftfile /var/lib/ntp/ntp.drift
restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery
restrict 127.0.0.1
restrict ::1

server 0.pool.ntp.org iburst
server 1.pool.ntp.org iburst
server 2.pool.ntp.org iburst
server 3.pool.ntp.org iburst
EOF

# Manage ntpd
systemctl enable ntpd
systemctl start ntpd

# Check status
ntpq -p
ntpstat
```

#### 5.4 timesyncd Configuration

**Problem Statement:** You need to use systemd-timesyncd for simple time sync.

**Solution:**
```bash
#!/bin/bash

# Check timesyncd status
timedatectl status

# Enable timesyncd
timedatectl set-ntp true

# Configure timesyncd (/etc/systemd/timesyncd.conf)
cat > /etc/systemd/timesyncd.conf << 'EOF'
[Time]
NTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org
FallbackNTP=0.debian.pool.ntp.org 1.debian.pool.ntp.org
RootDistanceMaxSec=5
PollIntervalMinSec=32
PollIntervalMaxSec=2048
EOF

# Restart service
systemctl restart systemd-timesyncd

# View logs
journalctl -u systemd-timesyncd
```

#### 5.5 Time Service Comparison

**Problem Statement:** You need to choose the right time sync solution.

**Solution:**
```bash
#!/bin/bash

# Comparison script
echo "=== Time Synchronization Service Comparison ==="
echo

echo "chrony:"
echo "  - Recommended for most systems"
echo "  - Handles intermittent connections"
echo "  - Faster initial sync"
echo "  - Lower memory usage"
echo

echo "ntpd:"
echo "  - Traditional NTP daemon"
echo "  - Full NTP protocol implementation"
echo "  - Better for stable servers"
echo "  - More comprehensive"
echo

echo "systemd-timesyncd:"
echo "  - Simple, lightweight"
echo "  - Built into systemd"
echo "  - Limited features"
echo "  - Good for desktops"
echo

# Recommend based on use case
recommend_time_service() {
    echo "Recommendation:"
    if [ -f /etc/chrony/chrony.conf ]; then
        echo "  chrony is already installed"
    elif [ -f /etc/ntp.conf ]; then
        echo "  ntpd is already installed"
    else
        echo "  chrony is recommended for servers"
    fi
}

recommend_time_service
```

---

## Day 6: Managing Users and Groups

### 🎯 Learning Goals
- Create, modify, and delete users
- Manage groups and memberships
- Automate user management tasks

### 📚 Topics Covered

#### 6.1 User Management

**Problem Statement:** You need to manage system users for various services and administrators.

**Solution:**
```bash
#!/bin/bash

# Create user
useradd -m -s /bin/bash username
useradd -m -d /home/username -s /bin/bash -G sudo username

# Set password
passwd username

# Modify user
usermod -aG groupname username      # Add to group
usermod -s /bin/zsh username        # Change shell
usermod -d /new/home username      # Change home

# Delete user
userdel username
userdel -r username                 # Remove home directory

# Check user info
id username
finger username
```

#### 6.2 Group Management

**Problem Statement:** You need to manage groups for access control.

**Solution:**
```bash
#!/bin/bash

# Create group
groupadd groupname

# Add user to group
usermod -aG groupname username
gpasswd -a username groupname

# Remove user from group
gpasswd -d username groupname

# List group members
getent group groupname

# Delete group
groupdel groupname

# Set group administrators
gpasswd -A username groupname
```

#### 6.3 User Management Scripts

**Problem Statement:** You need to automate user creation and management.

**Solution:**
```bash
#!/bin/bash

# Create user with defaults
create_user() {
    local username="$1"
    local shell="${2:-/bin/bash}"
    local groups="${3:-}"
    
    if id "$username" &>/dev/null; then
        echo "User $username already exists"
        return 1
    fi
    
    useradd -m -s "$shell" "$username"
    
    if [ -n "$groups" ]; then
        usermod -aG "$groups" "$username"
    fi
    
    echo "User $username created with shell $shell"
}

# Bulk user creation from CSV
bulk_create_users() {
    local csv_file="$1"
    
    while IFS=',' read -r username shell groups; do
        [ "$username" = "username" ] && continue  # Skip header
        create_user "$username" "$shell" "$groups"
    done < "$csv_file"
}

# Disable user account
disable_user() {
    local username="$1"
    
    usermod -L -s /sbin/nologin "$username"
    echo "User $username disabled"
}

# Set password with expiry
set_expiring_password() {
    local username="$1"
    local days="${2:-90}"
    
    chage -M "$days" "$username"
    passwd -n "$days" "$username"
    echo "Password for $username expires in $days days"
}
```

---

## Day 7: Managing Services with systemd

### 🎯 Learning Goals
- Master systemd service management
- Create custom service units
- Manage service dependencies and ordering

### 📚 Topics Covered

#### 7.1 systemd Fundamentals

**Problem Statement:** You need to understand systemd and manage services properly.

**Solution:**
```bash
#!/bin/bash

# Service control
systemctl start serviceName
systemctl stop serviceName
systemctl restart serviceName
systemctl reload serviceName

# Service status
systemctl status serviceName
systemctl is-active serviceName
systemctl is-enabled serviceName

# Enable/disable services
systemctl enable serviceName
systemctl disable serviceName

# View service logs
journalctl -u serviceName
journalctl -u serviceName -f
journalctl -u serviceName --since "1 hour ago"
```

#### 7.2 Creating Service Units

**Problem Statement:** You need to create custom service units for your applications.

**Solution:**
```bash
#!/bin/bash

# Create service unit file
cat > /etc/systemd/system/myapp.service << 'EOF'
[Unit]
Description=My Application Service
After=network.target

[Service]
Type=simple
User=myapp
Group=myapp
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/bin/myapp
ExecStop=/bin/kill -TERM $MAINPID
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

# Environment
Environment="NODE_ENV=production"
EnvironmentFile=/etc/myapp/env

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
systemctl daemon-reload

# Enable and start
systemctl enable myapp
systemctl start myapp
```

#### 7.3 Timer Units

**Problem Statement:** You need to schedule periodic tasks with systemd.

**Solution:**
```bash
#!/bin/bash

# Create timer unit
cat > /etc/systemd/system/daily-backup.timer << 'EOF'
[Unit]
Description=Daily Backup Timer

[Timer]
OnCalendar=daily
AccuracySec=1h
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Create corresponding service
cat > /etc/systemd/system/daily-backup.service << 'EOF'
[Unit]
Description=Daily Backup Service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/daily-backup.sh
EOF

# Enable timer
systemctl enable daily-backup.timer
systemctl start daily-backup.timer
```

#### 7.4 Service Management Scripts

**Problem Statement:** You need to manage multiple services programmatically.

**Solution:**
```bash
#!/bin/bash

# Check all services status
check_services() {
    local services=("nginx" "mysql" "redis")
    
    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc"; then
            echo "$svc: RUNNING"
        else
            echo "$svc: STOPPED"
        fi
    done
}

# Restart failed services
restart_failed() {
    systemctl list-units --state=failed | \
        grep '\.service$' | \
        awk '{print $1}' | \
        while read -r svc; do
            echo "Restarting $svc..."
            systemctl restart "$svc"
        done
}

# Service dependency check
check_dependencies() {
    local service="$1"
    systemctl list-dependencies "$service"
}
```

---

## Practice Exercises

### Exercise 1: Log Analysis Pipeline
Create a script that combines sed, awk, and grep to:
1. Parse Apache/Nginx access logs
2. Extract IPs, status codes, and request paths
3. Generate a summary report
4. Identify top errors and their frequencies

### Exercise 2: User Management System
Create a script that:
1. Creates users from a CSV file
2. Assigns them to appropriate groups
3. Sets up home directories and shells
4. Generates initial passwords

### Exercise 3: Service Health Monitor
Create a script that:
1. Monitors multiple systemd services
2. Checks service status and dependencies
3. Logs service failures
4. Attempts automatic restart on failure

### Exercise 4: Time Sync Configuration
Create a script that:
1. Detects current time sync method
2. Configures appropriate NTP service
3. Verifies synchronization status
4. Reports time accuracy

---

## Summary

This week covers essential professional-level system administration skills:

- **Day 1-2:** Advanced text processing with sed and awk
- **Day 3:** Integrated text processing pipelines
- **Day 4:** Linux services and file permissions
- **Day 5:** Time synchronization (ntpd, chrony, timesyncd)
- **Day 6:** User and group management
- **Day 7:** systemd service management

These skills form the foundation for professional Linux system administration.
