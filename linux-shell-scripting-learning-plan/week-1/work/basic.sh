#!/bin/bash

echo "==============================="
echo "======= System information ====="
echo "================================"
echo "Hostname $(hostname)"
echo "Current User: $(whoami)"
echo "Current Date: $(date)"
echo "Uptime $(uptime -p)"
echo "Kernal version $(uname -r)"


print_hello() {
    echo "Hello current logged in user is $(whoami)"
}

print_hello


print_date_time() {
    echo "Current Date and time is $(date +%Y-%m-%d)"
}

print_date_time