#!/bin/bash
# Description: Analyze auth logs for failed SSH attempts and brute force

LOG_FILE="/var/log/auth.log"
OUTPUT_DIR="$HOME/linux-server-toolkit/logs"
OUTPUT_FILE="$OUTPUT_DIR/security_report_$(date +%Y-%m-%d).txt"
mkdir -p $OUTPUT_DIR

echo "Security Log Analysis - $(date)" | tee $OUTPUT_FILE
echo "==========================================" | tee -a $OUTPUT_FILE

# Check if auth.log exists, else use journalctl
if [ -f "$LOG_FILE" ]; then
    SOURCE="$LOG_FILE"
    echo "Source: $SOURCE" | tee -a $OUTPUT_FILE
    
    echo -e "\n--- TOP 10 IPs with FAILED SSH login ---" | tee -a $OUTPUT_FILE
    grep "Failed password" "$SOURCE" | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -10 | tee -a $OUTPUT_FILE
    
    echo -e "\n--- Total Failed Attempts Today ---" | tee -a $OUTPUT_FILE
    grep "Failed password" "$SOURCE" | wc -l | tee -a $OUTPUT_FILE
    
    echo -e "\n--- Usernames Targeted ---" | tee -a $OUTPUT_FILE
    grep "Failed password" "$SOURCE" | awk '{for(i=1;i<=NF;i++) if($i=="for") print $(i+1)}' | sort | uniq -c | sort -nr | head -10 | tee -a $OUTPUT_FILE
else
    echo "Using journalctl" | tee -a $OUTPUT_FILE
    echo -e "\n--- TOP 10 IPs with FAILED SSH login ---" | tee -a $OUTPUT_FILE
    journalctl _SYSTEMD_UNIT=ssh.service --since "24 hours ago" | grep "Failed password" | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -10 | tee -a $OUTPUT_FILE
    
    echo -e "\n--- Total Failed Attempts Today ---" | tee -a $OUTPUT_FILE
    journalctl _SYSTEMD_UNIT=ssh.service --since "today" | grep "Failed password" | wc -l | tee -a $OUTPUT_FILE
fi

echo -e "\n--- SUCCESSFUL Logins Today ---" | tee -a $OUTPUT_FILE
if [ -f "$LOG_FILE" ]; then
    grep "Accepted password" "$LOG_FILE" 2>/dev/null | tail -10 | tee -a $OUTPUT_FILE
else
    journalctl _SYSTEMD_UNIT=ssh.service --since "today" | grep "Accepted" | tail -10 | tee -a $OUTPUT_FILE
fi

# Simple alert logic
if [ -f "$LOG_FILE" ]; then
    FAILED_COUNT=$(grep "Failed password" "$LOG_FILE" 2>/dev/null | wc -l)
else
    FAILED_COUNT=$(journalctl _SYSTEMD_UNIT=ssh.service --since "today" | grep "Failed password" | wc -l)
fi

if [ "$FAILED_COUNT" -gt 50 ]; then
    echo -e "\n[ALERT] Possible Brute Force Attack Detected! Failed count: $FAILED_COUNT" | tee -a $OUTPUT_FILE
fi

echo -e "\nFull report: $OUTPUT_FILE"
