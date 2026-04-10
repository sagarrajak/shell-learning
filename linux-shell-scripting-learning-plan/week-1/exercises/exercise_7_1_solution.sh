#!/bin/bash

# Exercise 7.1 Solution: System Monitoring Script
# Task: Create comprehensive system monitoring with thresholds and alerts

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration thresholds
DISK_THRESHOLD=80
MEMORY_THRESHOLD=80
CPU_THRESHOLD=80

# Function to check disk space
check_disk() {
    echo ""
    echo -e "${BLUE}=== Disk Space Check ===${NC}"
    echo ""
    
    local issues_found=0
    
    df -h | grep -E '^/dev/' | while read -r filesystem size used avail percent mountpoint; do
        percent_value=${percent%\%}
        
        if [ "$percent_value" -ge "$DISK_THRESHOLD" ]; then
            echo -e "${RED}WARNING: $mountpoint is ${percent} full (Threshold: ${DISK_THRESHOLD}%)${NC}"
            ((issues_found++))
        elif [ "$percent_value" -ge 70 ]; then
            echo -e "${YELLOW}CAUTION: $mountpoint is ${percent} full${NC}"
        else
            echo -e "${GREEN}OK: $mountpoint is ${percent} full${NC}"
        fi
    done
    
    echo ""
    if [ "$issues_found" -gt 0 ]; then
        echo -e "${RED}ALERT: $issues_found disk partition(s) exceed threshold${NC}"
    fi
}

# Function to check memory usage
check_memory() {
    echo ""
    echo -e "${BLUE}=== Memory Usage Check ===${NC}"
    echo ""
    
    if [ -f /proc/meminfo ]; then
        local total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        local available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        local used=$((total - available))
        local percent=$((used * 100 / total))
        
        echo "Total Memory: $((total / 1024)) MB"
        echo "Used Memory: $((used / 1024)) MB"
        echo "Available Memory: $((available / 1024)) MB"
        echo "Memory Usage: ${percent}%"
        echo ""
        
        if [ "$percent" -ge "$MEMORY_THRESHOLD" ]; then
            echo -e "${RED}ALERT: Memory usage (${percent}%) exceeds threshold (${MEMORY_THRESHOLD}%)${NC}"
        elif [ "$percent" -ge 70 ]; then
            echo -e "${YELLOW}WARNING: Memory usage is high (${percent}%)${NC}"
        else
            echo -e "${GREEN}OK: Memory usage is normal${NC}"
        fi
    else
        echo "Memory information not available"
    fi
}

# Function to check CPU usage
check_cpu() {
    echo ""
    echo -e "${BLUE}=== CPU Usage Check ===${NC}"
    echo ""
    
    # Get CPU usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    
    if [ -n "$cpu_usage" ]; then
        echo "Current CPU Usage: ${cpu_usage}%"
        
        # Check load average
        echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
        
        local cpu_int=${cpu_usage%.*}
        
        if [ "$cpu_int" -ge "$CPU_THRESHOLD" ]; then
            echo -e "${RED}ALERT: CPU usage (${cpu_int}%) exceeds threshold (${CPU_THRESHOLD}%)${NC}"
        elif [ "$cpu_int" -ge 70 ]; then
            echo -e "${YELLOW}WARNING: CPU usage is high (${cpu_int}%)${NC}"
        else
            echo -e "${GREEN}OK: CPU usage is normal${NC}"
        fi
    else
        echo "CPU information not available"
    fi
}

# Function to list top processes
list_top_processes() {
    echo ""
    echo -e "${BLUE}=== Top 5 Processes by CPU ===${NC}"
    echo ""
    
    ps aux --sort=-%cpu | head -6 | awk 'NR==1 {printf "%-10s %-10s %-10s %s\n", "USER", "PID", "CPU%", "COMMAND"} {printf "%-10s %-10s %-10s %s\n", $1, $2, $3, $11}'
    
    echo ""
    echo -e "${BLUE}=== Top 5 Processes by Memory ===${NC}"
    echo ""
    
    ps aux --sort=-%mem | head -6 | awk 'NR==1 {printf "%-10s %-10s %-10s %s\n", "USER", "PID", "MEM%", "COMMAND"} {printf "%-10s %-10s %-10s %s\n", $1, $2, $4, $11}'
}

# Function to check recent errors
check_errors() {
    echo ""
    echo -e "${BLUE}=== Recent System Errors ===${NC}"
    echo ""
    
    if [ -f /var/log/syslog ]; then
        echo "Recent errors from /var/log/syslog:"
        grep -i error /var/log/syslog 2>/dev/null | tail -5 || echo "No recent errors found"
    elif [ -f /var/log/messages ]; then
        echo "Recent errors from /var/log/messages:"
        grep -i error /var/log/messages 2>/dev/null | tail -5 || echo "No recent errors found"
    else
        echo "System log not found"
    fi
}

# Function to check critical services
check_services() {
    echo ""
    echo -e "${BLUE}=== Critical Services Status ===${NC}"
    echo ""
    
    local services=("sshd" "cron" "rsyslog")
    
    for service in "${services[@]}"; do
        if pgrep -x "$service" >/dev/null; then
            echo -e "${GREEN}OK: $service is running${NC}"
        else
            echo -e "${RED}WARNING: $service is NOT running${NC}"
        fi
    done
}

# Function to generate report
generate_report() {
    local report_file="/tmp/system_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "================================================"
        echo "       System Health Report"
        echo "================================================"
        echo ""
        echo "Generated: $(date)"
        echo "Hostname: $(hostname)"
        echo "Uptime: $(uptime -p)"
        echo ""
        
        check_disk
        check_memory
        check_cpu
        list_top_processes
        check_errors
        check_services
        
        echo ""
        echo "================================================"
        echo "Report generated: $report_file"
        echo "================================================"
        
    } > "$report_file"
    
    echo ""
    echo -e "${GREEN}Report saved to: $report_file${NC}"
}

# Main script
echo ""
echo "================================================"
echo -e "${GREEN}       System Monitoring Script${NC}"
echo "================================================"
echo ""
echo "Monitoring Time: $(date)"
echo "Hostname: $(hostname)"
echo ""

# Run all checks
check_disk
check_memory
check_cpu
check_services
list_top_processes
check_errors

echo ""
echo "================================================"
echo "Would you like to generate a report file?"
echo -n "Enter 'yes' to save report: "
read answer

if [ "$answer" = "yes" ] || [ "$answer" = "y" ]; then
    generate_report
fi

echo ""
echo "================================================"
echo -e "${GREEN}Monitoring completed!${NC}"
echo "================================================"
