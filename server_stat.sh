#!/bin/bash

# server-stats.sh - Basic Linux Server Performance Report

# Colors for headings
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

print_heading() {
    echo -e "\n${GREEN}=== $1 ===${NC}"
}

cpu_usage() {
    print_heading "Total CPU Usage"
    top -bn1 | grep "Cpu(s)" | awk '{printf "CPU Usage: %.2f%%\n", 100 - $8}'
}

memory_usage() {
    print_heading "Memory Usage"
    free -h
    echo ""
    free | awk '/Mem:/ {
        used=$3; total=$2; printf "Used: %d MB | Total: %d MB | Usage: %.2f%%\n", used/1024, total/1024, used/total*100
    }'
}

disk_usage() {
    print_heading "Disk Usage"
    df -h --total | awk 'END {print "Total Disk Usage:"; print "Used:", $3, "| Available:", $4, "| Usage:", $5}'
}

top_cpu_processes() {
    print_heading "Top 5 Processes by CPU Usage"
    ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 6
}

top_mem_processes() {
    print_heading "Top 5 Processes by Memory Usage"
    ps -eo pid,ppid,cmd,%mem --sort=-%mem | head -n 6
}

additional_info() {
    print_heading "Additional System Info"
    echo "OS Version: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
    echo "Uptime: $(uptime -p)"
    echo "Load Average: $(uptime | awk -F'load average:' '{ print $2 }')"
    echo "Logged in users: $(who | wc -l)"
    echo -n "Failed login attempts (last 24h): "
    journalctl _COMM=sshd --since "1 day ago" | grep "Failed password" | wc -l
}

# Main
cpu_usage
memory_usage
disk_usage
top_cpu_processes
top_mem_processes
additional_info
