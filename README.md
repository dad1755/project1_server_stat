Let's break down the `server-stats.sh`  script line by line, explaining each part in detail:



### Shebang

#!/bin/

- Explanation: This is the shebang line, which tells the system to use the  shell (`/bin/`) to interpret and execute the script. It ensures the script runs in a  environment.



### Script Description

#server-stats.sh - Basic Linux Server Performance Report

- Explanation: This is a comment describing the purpose of the script. It doesn't affect execution but provides context for anyone reading the code.



### Color Variables

#Colors for headings
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

- Explanation: These lines define ANSI escape codes for text colors to make the output visually appealing:
  - `RED`: Sets text to red (not used in the script but defined).
  - `GREEN`: Sets text to green, used for headings.
  - `NC`: Resets text to the default color (no color).
- These are used with `echo -e` to format output.



### `print_heading` Function

print_heading() {
    echo -e "\n${GREEN}=== $1 ===${NC}"
}

- Explanation:
  - Defines a function called `print_heading` that takes one argument (`$1`).
  - `echo -e`: Enables interpretation of escape sequences (like `\n` for a newline and color codes).
  - Outputs a green-colored heading with the argument (`$1`) surrounded by `===`, preceded by a blank line, and resets the color with `${NC}`.
  - Example output: `=== CPU Usage ===` in green.



### `cpu_usage` Function

cpu_usage() {
    print_heading "Total CPU Usage"
    top -bn1 | grep "Cpu(s)" | awk '{printf "CPU Usage: %.2f%%\n", 100 - $8}'
}

- Explanation:
  - Defines a function to display CPU usage.
  - `print_heading "Total CPU Usage"`: Calls the `print_heading` function to print a heading.
  - `top -bn1`: Runs the `top` command in batch mode (`-b`) for one iteration (`-n1`) to capture system stats.
  - `| grep "Cpu(s)"`: Filters the output to find the line containing CPU stats (e.g., `%Cpu(s): ...`).
  - `| awk '{printf "CPU Usage: %.2f%%\n", 100 - $8}'`:
    - `awk` processes the filtered line.
    - `$8` refers to the idle CPU percentage (from the `top` output).
    - `100 - $8` calculates the used CPU percentage.
    - `printf "CPU Usage: %.2f%%\n"` formats the output to two decimal places with a percentage sign.
  - Example output: `CPU Usage: 12.34%`.



### `memory_usage` Function

memory_usage() {
    print_heading "Memory Usage"
    free -h
    echo ""
    free | awk '/Mem:/ {
        used=$3; total=$2; printf "Used: %d MB | Total: %d MB | Usage: %.2f%%\n", used/1024, total/1024, used/total*100
    }'
}

- Explanation:
  - Defines a function to display memory usage.
  - `print_heading "Memory Usage"`: Prints the heading.
  - `free -h`: Runs the `free` command with human-readable output (`-h`), showing memory stats in a table (e.g., total, used, free in GB/MB).
  - `echo ""`: Adds a blank line for readability.
  - `free | awk '/Mem:/ { ... }'`:
    - `free`: Runs `free` again (without `-h`) to get raw numbers (in KB).
    - `| awk '/Mem:/`: Filters for the line starting with `Mem:` (the main memory stats).
    - `used=$3; total=$2;`: Assigns the used memory (`$3`) and total memory (`$2`) fields to variables.
    - `printf "Used: %d MB | Total: %d MB | Usage: %.2f%%\n", used/1024, total/1024, used/total*100`:
      - Converts used and total memory from KB to MB by dividing by 1024.
      - Calculates the percentage of memory used (`used/total*100`).
      - Formats output with integers for MB and two decimal places for the percentage.
  - Example output:
    
    === Memory Usage ===
    <free -h table output>
    
    Used: 2048 MB | Total: 8192 MB | Usage: 25.00%
    



### `disk_usage` Function

disk_usage() {
    print_heading "Disk Usage"
    df -h --total | awk 'END {print "Total Disk Usage:"; print "Used:", $3, "| Available:", $4, "| Usage:", $5}'
}

- Explanation:
  - Defines a function to display disk usage.
  - `print_heading "Disk Usage"`: Prints the heading.
  - `df -h --total`:
    - `df -h`: Displays disk usage in human-readable format (e.g., GB, MB).
    - `--total`: Adds a total line summarizing all filesystems.
  - `| awk 'END { ... }'`:
    - `END`: Processes only the last line (the total line from `df`).
    - `print "Total Disk Usage:"`: Prints a label.
    - `print "Used:", $3, "| Available:", $4, "| Usage:", $5`:
      - `$3`: Used space (e.g., `100G`).
      - `$4`: Available space (e.g., `400G`).
      - `$5`: Usage percentage (e.g., `20%`).
  - Example output:
    
    === Disk Usage ===
    Total Disk Usage:
    Used: 100G | Available: 400G | Usage: 20%
    



### `top_cpu_processes` Function

top_cpu_processes() {
    print_heading "Top 5 Processes by CPU Usage"
    ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 6
}

- Explanation:
  - Defines a function to list the top 5 CPU-consuming processes.
  - `print_heading "Top 5 Processes by CPU Usage"`: Prints the heading.
  - `ps -eo pid,ppid,cmd,%cpu --sort=-%cpu`:
    - `ps -eo`: Lists processes with specific columns:
      - `pid`: Process ID.
      - `ppid`: Parent Process ID.
      - `cmd`: Command that started the process.
      - `%cpu`: CPU usage percentage.
    - `--sort=-%cpu`: Sorts in descending order by CPU usage (highest first).
  - `| head -n 6`: Takes the first 6 lines (header + top 5 processes).
  - Example output:
    
    === Top 5 Processes by CPU Usage ===
    PID  PPID CMD                         %CPU
    1234 5678 /usr/bin/python3 script.py  45.6
    ...
    



### `top_mem_processes` Function

top_mem_processes() {
    print_heading "Top 5 Processes by Memory Usage"
    ps -eo pid,ppid,cmd,%mem --sort=-%mem | head -n 6
}

- Explanation:
  - Defines a function to list the top 5 memory-consuming processes.
  - `print_heading "Top 5 Processes by Memory Usage"`: Prints the heading.
  - `ps -eo pid,ppid,cmd,%mem --sort=-%mem`:
    - Similar to `top_cpu_processes`, but:
      - `%mem`: Shows memory usage percentage.
      - `--sort=-%mem`: Sorts by memory usage in descending order.
  - `| head -n 6`: Takes the first 6 lines (header + top 5 processes).
  - Example output:
    
    === Top 5 Processes by Memory Usage ===
    PID  PPID CMD                         %MEM
    5678 1234 /usr/lib/firefox/firefox    12.3
    ...
    



### `additional_info` Function

additional_info() {
    print_heading "Additional System Info"
    echo "OS Version: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
    echo "Uptime: $(uptime -p)"
    echo "Load Average: $(uptime | awk -F'load average:' '{ print $2 }')"
    echo "Logged in users: $(who | wc -l)"
    echo -n "Failed login attempts (last 24h): "
    journalctl _COMM=sshd --since "1 day ago" | grep "Failed password" | wc -l
}

- Explanation:
  - Defines a function to display miscellaneous system information.
  - `print_heading "Additional System Info"`: Prints the heading.
  - OS Version:
    - `cat /etc/os-release | grep PRETTY_NAME`: Reads the OS details and filters for the `PRETTY_NAME` line (e.g., `PRETTY_NAME="Ubuntu 22.04 LTS"`).
    - `cut -d= -f2`: Extracts the value after the `=` (e.g., `"Ubuntu 22.04 LTS"`).
    - `tr -d '\"'`: Removes quotation marks.
    - Example: `OS Version: Ubuntu 22.04 LTS`.
  - Uptime:
    - `uptime -p`: Shows system uptime in a human-readable format (e.g., `up 2 days, 3 hours, 45 minutes`).
  - Load Average:
    - `uptime | awk -F'load average:' '{ print $2 }'`:
      - `uptime`: Outputs system uptime and load averages (e.g., `load average: 0.50, 0.60, 0.70`).
      - `awk -F'load average:'`: Splits the output at `load average:`.
      - `{ print $2 }`: Prints the part after the delimiter (the load averages).
  - Logged in users:
    - `who | wc -l`:
      - `who`: Lists currently logged-in users.
      - `wc -l`: Counts the number of lines (i.e., users).
  - Failed login attempts:
    - `echo -n "Failed login attempts (last 24h): "`: Prints the label without a newline (`-n`).
    - `journalctl _COMM=sshd --since "1 day ago" | grep "Failed password" | wc -l`:
      - `journalctl _COMM=sshd --since "1 day ago"`: Queries system logs for SSH daemon (`sshd`) entries from the last 24 hours.
      - `grep "Failed password"`: Filters for lines indicating failed password attempts.
      - `wc -l`: Counts the number of such lines.
  - Example output:
    
    === Additional System Info ===
    OS Version: Ubuntu 22.04 LTS
    Uptime: up 2 days, 3 hours, 45 minutes
    Load Average: 0.50, 0.60, 0.70
    Logged in users: 2
    Failed login attempts (last 24h): 5
    



### Main Execution

# Main
cpu_usage
memory_usage
disk_usage
top_cpu_processes
top_mem_processes
additional_info

- Explanation:
  - This is the main part of the script that calls each function in sequence.
  - Each function generates its respective section of the report.
  - The functions are executed in the order listed, producing a comprehensive server performance report.



### Summary
The script is a  utility that generates a formatted report on a Linux server's performance, including:
- CPU usage
- Memory usage
- Disk usage
- Top 5 processes by CPU and memory
- Additional system info (OS, uptime, load, users, failed logins)

It uses commands like `top`, `free`, `df`, `ps`, `uptime`, `who`, and `journalctl`, with `awk`, `grep`, and other tools to process and format the output. The use of colors and headings makes the report easy to read.
