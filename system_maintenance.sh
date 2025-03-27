#!/bin/bash

# Define the directory and log file where all actions and outputs will be recorded
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/system_maintenance.log"

# Ensure the log directory exists; create it if it doesn't
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
fi
# Define placeholders for system log files
AUTH_LOG="./auth.log"
SYS_LOG="./syslog"

# Ensure the log files exist; create them if they don't
if [ ! -f "$AUTH_LOG" ]; then
    touch "$AUTH_LOG"
    log "ℹ️ Created placeholder for auth.log."
fi

if [ ! -f "$SYS_LOG" ]; then
    touch "$SYS_LOG"
    log "ℹ️ Created placeholder for syslog."
fi



# Directory containing temporary files to clean up
TEMP_DIR="/tmp"

# Array of critical services to monitor and restart if necessary
CRITICAL_SERVICES=("nginx" "mysql")  # Add more services here if required

# Resource usage thresholds for alerts (percentage)
DISK_THRESHOLD=80  # Disk usage threshold
CPU_THRESHOLD=75   # CPU usage threshold
MEM_THRESHOLD=75   # Memory usage threshold

# Function to log messages with a timestamp
log() {
    # Echoes a message to both the terminal and the log file
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to monitor system resources (CPU, memory, and disk usage)
monitor_system() {
    log "Starting system monitoring..."
    
    # Gather CPU usage percentage using `top` command
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    
    # Gather memory usage percentage using `free` command
    MEM_USAGE=$(free | awk '/Mem/{printf("%.2f"), $3/$2 * 100}')
    
    # Gather disk usage percentage for the root filesystem
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

    # Log current resource usage
    log "CPU Usage: ${CPU_USAGE}% | Memory Usage: ${MEM_USAGE}% | Disk Usage: ${DISK_USAGE}%"

    # Check if CPU usage exceeds the defined threshold
    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        log "⚠️ High CPU Usage detected: ${CPU_USAGE}%"
    fi

    # Check if memory usage exceeds the defined threshold
    if (( $(echo "$MEM_USAGE > $MEM_THRESHOLD" | bc -l) )); then
        log "⚠️ High Memory Usage detected: ${MEM_USAGE}%"
    fi

    # Check if disk usage exceeds the defined threshold
    if (( DISK_USAGE > DISK_THRESHOLD )); then
        log "⚠️ Disk Usage exceeded threshold: ${DISK_USAGE}%"
    fi
}

# Function to analyze system logs for potential security and error issues
analyze_logs() {
    log "Analyzing system logs for security issues..."

    # Count the number of failed SSH login attempts
    FAILED_LOGINS=$(grep "Failed password" ./auth.log | wc -l)
    
    # Count the number of general system errors from the syslog
    SYSTEM_ERRORS=$(grep -i "error" ./syslog | wc -l)

    # Log findings
    log "Failed SSH logins: $FAILED_LOGINS | System Errors: $SYSTEM_ERRORS"

    # Alert if there are multiple failed SSH login attempts
    if [ "$FAILED_LOGINS" -gt 5 ]; then
        log "🚨 Multiple failed SSH login attempts detected!"
    fi

    # Alert if the number of system errors is unusually high
    if [ "$SYSTEM_ERRORS" -gt 10 ]; then
        log "⚠️ High number of system errors detected!"
    fi
}

# Function to optimize system performance
optimize_performance() {
    log "Cleaning up temporary files..."
    
    # Find and delete temporary files that haven't been accessed in the last 7 days
    find "$TEMP_DIR" -type f -atime +7 -delete
    log "Temporary files older than 7 days have been deleted."

    # Check the status of critical services and restart them if they are not running
    for service in "${CRITICAL_SERVICES[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log "✅ $service is running."
        else
            log "⚠️ $service is not running. Restarting..."
            systemctl restart "$service"
            if systemctl is-active --quiet "$service"; then
                log "🔄 Successfully restarted $service."
            else
                log "❌ Failed to restart $service!"
            fi
        fi
    done
}

# Function to apply system updates
apply_updates() {
    if [ "$EUID" -ne 0 ]; then
        log "⚠️ System updates require elevated permissions. Please run the script with sudo."
        return
    fi
    
    log "Applying system updates..."
    apt update && apt upgrade -y
    
    if [ $? -eq 0 ]; then
        log "✅ System updates completed successfully."
    else
        log "❌ System updates failed! Check the logs for details."
    fi
}


# Main function to execute all maintenance tasks in sequence
main() {
    log "===== System Maintenance Script Started ====="
    
    # Step 1: Monitor system resources
    monitor_system
    
    # Step 2: Analyze logs for potential issues
    analyze_logs
    
    # Step 3: Optimize system performance
    optimize_performance
    
    # Step 4: Apply system updates
    apply_updates
    
    log "===== System Maintenance Script Completed ====="
}

# Execute the main function
main
