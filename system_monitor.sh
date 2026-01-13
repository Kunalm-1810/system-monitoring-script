#!/bin/bash
# Date: 2026-01-13
# Maintainer: kunal mane <kode.techm@gmail.com>
# Description: Monitor system resources and emit alerts via Email and Logs.
#version: 1.0
set -euo pipefail

# Thresholds
CPU_THRESHOLD=${CPU_THRESHOLD:-8}
MEMORY_THRESHOLD=${MEMORY_THRESHOLD:-8}
DISK_THRESHOLD=${DISK_THRESHOLD:-8}
EMAIL_ID="kode.techm@gmail.com"
APP_PASSWORD="ptof pvph pmcm ekqq"

SLEEP_INTERVAL=${SLEEP_INTERVAL:-60}
LOG_FILE=${LOG_FILE:-system_usage.log}
LOG_ENABLED=${LOG_ENABLED:-1}

send_email() {
    local SUBJECT="$1"
    local BODY="$2"
    # Using curl to send via Gmail SMTP
    curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd \
      --mail-from "$EMAIL_ID" \
      --mail-rcpt "$EMAIL_ID" \
      --user "$EMAIL_ID:$APP_PASSWORD" \
      -T <(echo -e "From: $EMAIL_ID\nTo: $EMAIL_ID\nSubject: $SUBJECT\n\n$BODY")
}

log() {
    if [ "${LOG_ENABLED:-0}" -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$LOG_FILE"
    fi
}

alert() {
    local type="$1"; local value="$2"; local threshold="$3"; local details="$4"
    local MSG="ALERT: $type usage is at ${value}% (threshold ${threshold}%)"
    
    echo -e "$MSG" >&2
    log "$MSG"
    
    # Trigger the email alert
    send_email "System Monitor Alert: $type" "$MSG\n\n$details"
}

top_processes_cpu() {
    echo -e "\n--- Top CPU-consuming processes ---\n$(ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6)"
}

top_processes_mem() {
    echo -e "\n--- Top Memory-consuming processes ---\n$(ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 6)"
}

check_usage() {
    # Stats Gathering
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "%d", 100 - $1}')
    MEMORY_USAGE=$(free | awk '/Mem/ {printf "%d", $3/$2 * 100}')
    DISK_USAGE=$(df / --output=pcent | tail -1 | tr -dc '0-9')

    log "Snapshot - CPU: ${CPU_USAGE}%, Memory: ${MEMORY_USAGE}%, Disk: ${DISK_USAGE}%"

    if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
        local DETAILS=$(top_processes_cpu)
        alert "CPU" "$CPU_USAGE" "$CPU_THRESHOLD" "$DETAILS"
        echo -e "$DETAILS"
    fi

    if [ "$MEMORY_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
        local DETAILS=$(top_processes_mem)
        alert "Memory" "$MEMORY_USAGE" "$MEMORY_THRESHOLD" "$DETAILS"
        echo -e "$DETAILS"
    fi

    if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
        local DETAILS="--- df -h for / ---\n$(df -h /)"
        alert "Disk (/)" "$DISK_USAGE" "$DISK_THRESHOLD" "$DETAILS"
        echo -e "$DETAILS"
    fi
}

trap 'echo "Exiting..."; exit 0' INT TERM

echo "Monitoring started for $EMAIL_ID..."
while true; do
    check_usage
    sleep "$SLEEP_INTERVAL"
done
# End of script

