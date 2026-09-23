#!/bin/bash
# Project: Linux Server Toolkit - Day 1
# Author: [Your Name]
# Description: Full system health report

LOG_DIR="$HOME/linux-server-toolkit/logs"
LOG_FILE="$LOG_DIR/health_$(date +%Y-%m-%d).log"
mkdir -p $LOG_DIR

echo "==========================================" | tee -a $LOG_FILE
echo " System Health Report - $(date)" | tee -a $LOG_FILE
echo "==========================================" | tee -a $LOG_FILE

# 1. Uptime
echo -e "\n--- UPTIME ---" | tee -a $LOG_FILE
uptime | tee -a $LOG_FILE

# 2. CPU Load
echo -e "\n--- CPU INFO ---" | tee -a $LOG_FILE
lscpu | grep "Model name" | tee -a $LOG_FILE
echo "Load Average:" | tee -a $LOG_FILE
cat /proc/loadavg | tee -a $LOG_FILE

# 3. Memory
echo -e "\n--- MEMORY USAGE ---" | tee -a $LOG_FILE
free -h | tee -a $LOG_FILE

# 4. Disk
echo -e "\n--- DISK USAGE ---" | tee -a $LOG_FILE
df -h | grep -E '^/dev/' | tee -a $LOG_FILE

# 5. Top 5 CPU processes
echo -e "\n--- TOP 5 CPU CONSUMING PROCESSES ---" | tee -a $LOG_FILE
ps aux --sort=-%cpu | head -n 6 | tee -a $LOG_FILE

# 6. Top 5 Memory processes
echo -e "\n--- TOP 5 MEMORY CONSUMING PROCESSES ---" | tee -a $LOG_FILE
ps aux --sort=-%mem | head -n 6 | tee -a $LOG_FILE

# 7. Failed services
echo -e "\n--- FAILED SYSTEMD SERVICES ---" | tee -a $LOG_FILE
systemctl --failed | tee -a $LOG_FILE

echo -e "\nReport saved to: $LOG_FILE"
