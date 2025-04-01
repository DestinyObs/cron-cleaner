#!/bin/bash

# Set up directories and logging
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/maintenance.log"
mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Create placeholder log files if missing
touch "./auth.log" "./syslog"

# Thresholds for resource usage
DISK_THRESHOLD=80
CPU_THRESHOLD=75
MEM_THRESHOLD=75

# Services to keep running
SERVICES=("nginx" "mysql")

# Monitor system usage
monitor_resources() {
    log "Checking system stats..."

    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    MEM_USAGE=$(free | awk '/Mem/{printf "%.2f", $3/$2 * 100}')
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

    log "CPU: ${CPU_USAGE}% | Memory: ${MEM_USAGE}% | Disk: ${DISK_USAGE}%"

    [[ $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) -eq 1 ]] && log "Alert: CPU usage high (${CPU_USAGE}%)"
    [[ $(echo "$MEM_USAGE > $MEM_THRESHOLD" | bc -l) -eq 1 ]] && log "Alert: Memory usage high (${MEM_USAGE}%)"
    [[ $DISK_USAGE -gt $DISK_THRESHOLD ]] && log "Alert: Disk space almost full (${DISK_USAGE}%)"
}

# Analyze log files
review_logs() {
    log "Analyzing system logs..."

    FAILED_LOGINS=$(grep -c "Failed password" ./auth.log)
    SYSTEM_ERRORS=$(grep -i "error" ./syslog | wc -l)

    log "Failed SSH attempts: $FAILED_LOGINS | System errors: $SYSTEM_ERRORS"

    [[ $FAILED_LOGINS -gt 5 ]] && log "Security Notice: Multiple failed SSH logins detected."
    [[ $SYSTEM_ERRORS -gt 10 ]] && log "System Alert: Too many errors found in system logs."
}

# Optimize system performance
cleanup_and_restart() {
    log "Running optimization tasks..."

    find "/tmp" -type f -atime +7 -delete && log "Cleared old files in /tmp."
    
    for service in "${SERVICES[@]}"; do
        systemctl is-active --quiet "$service" || {
            log "Restarting $service..."
            systemctl restart "$service" && log "$service is now active." || log "Failed to restart $service!"
        }
    done
}

# Apply system updates
update_system() {
    if [[ $EUID -ne 0 ]]; then
        log "Note: Use sudo to apply updates."
        return
    fi

    log "Updating system packages..."
    apt update && apt upgrade -y && log "System update completed successfully." || log "Update encountered errors."
}

# Main routine
main() {
    log "===== Starting Maintenance Tasks ====="
    monitor_resources
    review_logs
    cleanup_and_restart
    update_system
    log "===== Maintenance Tasks Finished ====="
}

main
