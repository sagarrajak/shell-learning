#!/bin/bash

# Week 1 Project Solution: System Maintenance Automation Script
# A comprehensive daily maintenance script that performs health checks,
# log management, backup verification, and report generation

set -euo pipefail

# =================================================================
# System Maintenance Automation Script
# =================================================================
# Author: System Administrator
# Date: $(date +%Y-%m-%d)
# Description: Automated daily system maintenance tasks
# =================================================================

# Configuration
# ------------
DISK_THRESHOLD=80
MEMORY_THRESHOLD=80
CPU_THRESHOLD=80
LOG_RETENTION_DAYS=7
REPORT_DIR="/var/log/maintenance"
BACKUP_CHECK_ENABLED=true
ALERT_EMAIL="admin@localhost"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Timestamp for reports
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="${REPORT_DIR}/maintenance_report_${TIMESTAMP}.log"

# Initialize counters
ISSUES_FOUND=0
ERRORS_FOUND=0
WARNINGS_FOUND=0

# =================================================================
# Helper Functions
# =================================================================

log_message() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[${timestamp}] [${level}] ${message}"
    
    # Also write to report file
    if [ -d "$REPORT_DIR" ]; then
        echo "[${timestamp}] [${level}] ${message}" >> "$REPORT_FILE"
    fi
}

log_info() { log_message "INFO" "$@"; }
log_warn() { log_message "WARN" "$@"; }
log_error() { log_message "ERROR" "$@"; }

increment_warnings() {
    ((WARNINGS_FOUND++))
}

increment_errors() {
    ((ERRORS_FOUND++))
    ((ISSUES_FOUND++))
}

# =================================================================
# System Health Checks
# =================================================================

check_disk_space() {
    echo ""
    echo "================================================"
    echo -e "${BLUE}Checking Disk Space...${NC}"
    echo "================================================"
    
    local disk_issues=0
    
    df -h | grep -E '^/dev/' | while read -r filesystem size used avail percent mountpoint; do
        percent_value=${percent%\%}
        
        if [ "$percent_value" -ge "$DISK_THRESHOLD" ]; then
            log_error "Disk space CRITICAL: ${mountpoint} is ${percent} full"
            echo -e "${RED}CRITICAL: ${mountpoint} is ${percent} full${NC}"
            ((disk_issues++))
            increment_errors
        elif [ "$percent_value" -ge 70 ]; then
            log_warn "Disk space WARNING: ${mountpoint} is ${percent} full"
            echo -e "${YELLOW}WARNING: ${mountpoint} is ${percent} full${NC}"
            ((disk_issues++))
            increment_warnings
        else
            log_info "Disk space OK: ${mountpoint} is ${percent} full"
            echo -e "${GREEN}OK: ${mountpoint} is ${percent} full${NC}"
        fi
    done
    
    if [ "$disk_issues" -eq 0 ]; then
        log_info "All disk partitions within acceptable limits"
    fi
}

check_memory_usage() {
    echo ""
    echo "================================================"
    echo -e "${BLUE}Checking Memory Usage...${NC}"
    echo "================================================"
    
    if [ -f /proc/meminfo ]; then
        local total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        local available=$(grep MemAvailable /proc/meminfo 2>/dev/null | awk '{print $2}')
        
        # Fallback if MemAvailable not available
        if [ -z "$available" ]; then
            local free=$(grep MemFree /proc/meminfo | awk '{print $2}')
            local buffers=$(grep Buffers /proc/meminfo | awk '{print $2}')
            local cached=$(grep Cached /proc/meminfo | awk '{print $2}')
            available=$((free + buffers + cached))
        fi
        
        local used=$((total - available))
        local percent=$((used * 100 / total))
        
        log_info "Memory usage: ${percent}% (Total: $((total/1024))MB, Used: $((used/1024))MB)"
        echo "Memory Usage: ${percent}%"
        
        if [ "$percent" -ge "$MEMORY_THRESHOLD" ]; then
            log_error "Memory usage CRITICAL: ${percent}% (threshold: ${MEMORY_THRESHOLD}%)"
            echo -e "${RED}CRITICAL: Memory usage is ${percent}%${NC}"
            increment_errors
        elif [ "$percent" -ge 70 ]; then
            log_warn "Memory usage WARNING: ${percent}%"
            echo -e "${YELLOW}WARNING: Memory usage is high (${percent}%)${NC}"
            increment_warnings
        else
            echo -e "${GREEN}OK: Memory usage is normal (${percent}%)${NC}"
        fi
    else
        log_error "Could not check memory usage"
        echo -e "${RED}ERROR: Cannot read memory information${NC}"
        increment_errors
    fi
}

check_cpu_usage() {
    echo ""
    echo "================================================"
    echo -e "${BLUE}Checking CPU Usage...${NC}"
    echo "================================================"
    
    # Get CPU usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    local cpu_int=${cpu_usage%.*}
    
    log_info "Current CPU usage: ${cpu_int}%"
    echo "CPU Usage: ${cpu_int}%"
    
    if [ "$cpu_int" -ge "$CPU_THRESHOLD" ]; then
        log_error "CPU usage CRITICAL: ${cpu_int}% (threshold: ${CPU_THRESHOLD}%)"
        echo -e "${RED}CRITICAL: CPU usage is ${cpu_int}%${NC}"
        increment_errors
    elif [ "$cpu_int" -ge 70 ]; then
        log_warn "CPU usage WARNING: ${cpu_int}%"
        echo -e "${YELLOW}WARNING: CPU usage is high (${cpu_int}%)${NC}"
        increment_warnings
    else
        echo -e "${GREEN}OK: CPU usage is normal (${cpu_int}%)${NC}"
    fi
    
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
}

check_critical_services() {
    echo ""
    echo "================================================"
    echo -e "${BLUE}Checking Critical Services...${NC}"
    echo "================================================"
    
    local services=("sshd" "cron" "rsyslog")
    local failed_services=0
    
    for service in "${services[@]}"; do
        if pgrep -x "$service" >/dev/null 2>&1; then
            log_info "Service ${service} is running"
            echo -e "${GREEN}OK: ${service} is running${NC}"
        else
            log_error "Service ${service} is NOT running"
            echo -e "${RED}ERROR: ${service} is NOT running${NC}"
            ((failed_services++))
            increment_errors
        fi
    done
    
    if [ "$failed_services" -eq 0 ]; then
        log_info "All critical services are running"
    fi
}

# =================================================================
# Log Management
# =================================================================

rotate_old_logs() {
    echo ""
    echo "================================================"
    echo -e "${BLUE}Rotating Old Log Files...${NC}"
    echo "================================================"
    
    local log_dirs=("/var/log" "/home")
    local rotated_count=0
    
    for log_dir in "${log_dirs[@]}"; do
        if [ -d "$log_dir" ]; then
            find "$log_dir" -name "*.log" -type f -mtime +"$LOG_RETENTION_DAYS" 2>/dev/null | while read -r logfile; do
                if [ -f "$logfile" ] && [ -s "$logfile" ]; then
                    log_info "Rotating: $logfile"
                    gzip -9 "$logfile" 2>/dev/null || true
                    ((rotated_count++))
                fi
            done
        fi
    done
    
    echo "Rotated $rotated_count log file(s)"
    log_info "Log rotation complete: $rotated_count files rotated"
}

cleanup_temporary_files() {
    echo ""
    echo "================================================"
    echo -e "${BLUE}Cleaning Temporary Files...${NC}"
    echo "================================================"
    
    local temp_dirs=("/tmp" "/var/tmp")
    local deleted_count=0
    
    for temp_dir in "${temp_dirs[@]}"; do
        if [ -d "$temp_dir" ]; then
            # Find and remove old temporary files (excluding recent ones)
            while IFS= read -r -d '' file; do
                rm -f "$file" 2>/dev/null || true
                ((deleted_count++))
            done < <(find "$temp_dir" -type f -name "tmp.*" -mtime +1 -print0 2>/dev/null)
        fi
    done
    
    echo "Deleted $deleted_count temporary file(s)"
    log_info "Cleanup complete: $deleted_count temp files removed"
}

# =================================================================
# Backup Verification
# =================================================================

verify_backups() {
    echo ""
    echo "================================================"
    echo -e "${BLUE}Verifying Backups...${NC}"
    echo "================================================"
    
    local backup_dirs=("/var/backups" "/backup" "/home/*/backups")
    local backup_found=0
    local backup_issues=0
    
    for backup_pattern in "${backup_dirs[@]}"; do
        for backup_dir in $backup_pattern; do
            if [ -d "$backup_dir" ]; then
                ((backup_found++))
                
                # Check for recent backup (within last 24 hours)
                local recent_backup=$(find "$backup_dir" -type f -mtime -1 2>/dev/null | head -1)
                
                if [ -n "$recent_backup" ]; then
                    local backup_size=$(du -h "$recent_backup" | cut -f1)
                    log_info "Recent backup found: $recent_backup (Size: $backup_size)"
                    echo -e "${GREEN}OK: Recent backup found: $(basename "$recent_backup") (Size: $backup_size)${NC}"
                else
                    log_warn "No recent backup in: $backup_dir"
                    echo -e "${YELLOW}WARNING: No recent backup in $backup_dir${NC}"
                    ((backup_issues++))
                    increment_warnings
                fi
            fi
        done
    done
    
    if [ "$backup_found" -eq 0 ]; then
        log_warn "No backup directories found"
        echo -e "${YELLOW}WARNING: No backup directories found${NC}"
        increment_warnings
    elif [ "$backup_issues" -gt 0 ]; then
        echo -e "${YELLOW}WARNING: $backup_issues backup issue(s) found${NC}"
    fi
}

# =================================================================
# Report Generation
# =================================================================

generate_report() {
    echo ""
    echo "================================================"
    echo -e "${BLUE}Generating Report...${NC}"
    echo "================================================"
    
    # Ensure report directory exists
    mkdir -p "$REPORT_DIR"
    
    # Generate summary report
    {
        echo "================================================"
        echo "   Daily Maintenance Report"
        echo "================================================"
        echo ""
        echo "Report Generated: $(date)"
        echo "Hostname: $(hostname)"
        echo "Uptime: $(uptime -p)"
        echo ""
        echo "================================================"
        echo "   Summary Statistics"
        echo "================================================"
        echo ""
        echo "Total Issues Found: $ISSUES_FOUND"
        echo "  - Errors: $ERRORS_FOUND"
        echo "  - Warnings: $WARNINGS_FOUND"
        echo ""
        
        if [ "$ISSUES_FOUND" -eq 0 ]; then
            echo "STATUS: ALL CHECKS PASSED"
        elif [ "$ERRORS_FOUND" -gt 0 ]; then
            echo "STATUS: ATTENTION REQUIRED (ERRORS FOUND)"
        else
            echo "STATUS: MONITORING RECOMMENDED (WARNINGS ONLY)"
        fi
        
        echo ""
        echo "================================================"
        
    } >> "$REPORT_FILE"
    
    echo "Report saved to: $REPORT_FILE"
    log_info "Report generated: $REPORT_FILE"
}

# =================================================================
# Email Alert
# =================================================================

send_alert() {
    if [ "$ISSUES_FOUND" -gt 0 ]; then
        log_warn "Sending alert email..."
        
        if command -v mail >/dev/null 2>&1; then
            mail -s "[ALERT] System Maintenance Issues on $(hostname)" "$ALERT_EMAIL" <<EOF
System maintenance issues detected on $(hostname).

Summary:
- Total Issues: $ISSUES_FOUND
- Errors: $ERRORS_FOUND
- Warnings: $WARNINGS_FOUND

Please review the maintenance report at: $REPORT_FILE

This is an automated message from the System Maintenance Script.
EOF
            echo "Alert email sent to: $ALERT_EMAIL"
        else
            echo "Email utility not available. Alert not sent."
        fi
    fi
}

# =================================================================
# Main Execution
# =================================================================

main() {
    echo ""
    echo "================================================"
    echo -e "${GREEN}   System Maintenance Automation${NC}"
    echo "================================================"
    echo ""
    echo "Started: $(date)"
    echo "Hostname: $(hostname)"
    echo ""
    
    # Create report directory
    mkdir -p "$REPORT_DIR"
    
    # Run maintenance tasks
    check_disk_space
    check_memory_usage
    check_cpu_usage
    check_critical_services
    
    if [ "$BACKUP_CHECK_ENABLED" = true ]; then
        verify_backups
    fi
    
    rotate_old_logs
    cleanup_temporary_files
    
    # Generate report
    generate_report
    
    # Send alert if needed
    if [ "$ISSUES_FOUND" -gt 0 ]; then
        send_alert
    fi
    
    # Final summary
    echo ""
    echo "================================================"
    echo "   Maintenance Complete"
    echo "================================================"
    echo ""
    echo "Finished: $(date)"
    echo "Issues Found: $ISSUES_FOUND (Errors: $ERRORS_FOUND, Warnings: $WARNINGS_FOUND)"
    echo "Report Location: $REPORT_FILE"
    echo ""
    
    if [ "$ISSUES_FOUND" -eq 0 ]; then
        echo -e "${GREEN}All maintenance tasks completed successfully!${NC}"
    elif [ "$ERRORS_FOUND" -gt 0 ]; then
        echo -e "${RED}Maintenance completed with errors. Review required.${NC}"
    else
        echo -e "${YELLOW}Maintenance completed with warnings.${NC}"
    fi
    
    echo "================================================"
}

# Run main function
main

exit 0
