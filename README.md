# System Maintenance Script

## Overview
This script automates essential system maintenance tasks, including:
- Monitoring system resource usage (CPU, memory, disk space)
- Analyzing authentication and system logs for security and errors
- Cleaning up temporary files and restarting critical services
- Applying system updates (requires sudo)

## How It Works
The script follows a structured process:
1. **Logging Setup** - Ensures logs are recorded for all actions.
2. **Resource Monitoring** - Checks system performance and alerts if thresholds are exceeded.
3. **Log Analysis** - Scans logs for security risks and system issues.
4. **System Optimization** - Cleans up temporary files and ensures services are running.
5. **System Updates** - Applies updates (if run with sudo).
6. **Execution Flow** - Runs all maintenance tasks sequentially.

## Script Breakdown

### 1. Logging Setup
```bash
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/maintenance.log"
mkdir -p "$LOG_DIR"
```
- **LOG_DIR**: Stores log files.
- **LOG_FILE**: Defines the log file path.
- **mkdir -p "$LOG_DIR"**: Ensures the log directory exists.

```bash
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}
```
- **log() Function**: Records messages with timestamps to both console and log file.

```bash
touch "./auth.log" "./syslog"
```
- Creates placeholder log files if they don't exist to avoid errors.

### 2. Resource Monitoring
```bash
DISK_THRESHOLD=80
CPU_THRESHOLD=75
MEM_THRESHOLD=75
```
- Defines the maximum acceptable CPU, memory, and disk usage percentages.

```bash
monitor_resources() {
    log "Checking system stats..."
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    MEM_USAGE=$(free | awk '/Mem/{printf "%.2f", $3/$2 * 100}')
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
```
- **CPU_USAGE**: Extracts CPU usage from the `top` command.
- **MEM_USAGE**: Calculates memory usage from `free`.
- **DISK_USAGE**: Retrieves disk usage from `df`.

```bash
    log "CPU: ${CPU_USAGE}% | Memory: ${MEM_USAGE}% | Disk: ${DISK_USAGE}%"
```
- Logs current system resource usage.

```bash
    [[ $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) -eq 1 ]] && log "Alert: CPU usage high (${CPU_USAGE}%)"
    [[ $(echo "$MEM_USAGE > $MEM_THRESHOLD" | bc -l) -eq 1 ]] && log "Alert: Memory usage high (${MEM_USAGE}%)"
    [[ $DISK_USAGE -gt $DISK_THRESHOLD ]] && log "Alert: Disk space almost full (${DISK_USAGE}%)"
}
```
- Checks if usage exceeds thresholds and logs warnings.

### 3. Log Analysis
```bash
review_logs() {
    log "Analyzing system logs..."
    FAILED_LOGINS=$(grep -c "Failed password" ./auth.log)
    SYSTEM_ERRORS=$(grep -i "error" ./syslog | wc -l)
```
- **FAILED_LOGINS**: Counts SSH failed login attempts from `auth.log`.
- **SYSTEM_ERRORS**: Counts system errors in `syslog`.

```bash
    log "Failed SSH attempts: $FAILED_LOGINS | System errors: $SYSTEM_ERRORS"
```
- Logs the number of security and error events.

```bash
    [[ $FAILED_LOGINS -gt 5 ]] && log "Security Notice: Multiple failed SSH logins detected."
    [[ $SYSTEM_ERRORS -gt 10 ]] && log "System Alert: Too many errors found in system logs."
}
```
- Logs warnings if SSH login failures or system errors exceed predefined limits.

### 4. System Optimization
```bash
cleanup_and_restart() {
    log "Running optimization tasks..."
    find "/tmp" -type f -atime +7 -delete && log "Cleared old files in /tmp."
```
- Deletes temporary files older than 7 days.

```bash
    for service in "${SERVICES[@]}"; do
        systemctl is-active --quiet "$service" || {
            log "Restarting $service..."
            systemctl restart "$service" && log "$service is now active." || log "Failed to restart $service!"
        }
    done
}
```
- **Checks and restarts critical services** (`nginx`, `mysql`) if they are inactive.

### 5. System Updates
```bash
update_system() {
    if [[ $EUID -ne 0 ]]; then
        log "Note: Use sudo to apply updates."
        return
    fi
    log "Updating system packages..."
    apt update && apt upgrade -y && log "System update completed successfully." || log "Update encountered errors."
}
```
- **update_system() Function**:
  - Ensures the script is run with sudo before proceeding.
  - Updates all installed packages.
  - Logs the success or failure of the update process.

### 6. Execution Flow
```bash
main() {
    log "===== Starting Maintenance Tasks ====="
    monitor_resources
    review_logs
    cleanup_and_restart
    update_system
    log "===== Maintenance Tasks Finished ====="
}
main
```
- Calls all functions sequentially.
- Logs the start and end of the maintenance process.

## Usage
### Running the Script
To execute the script:
```bash
bash maintenance.sh
```
If running system updates, use:
```bash
sudo bash maintenance.sh
```

### Logging
- Logs are saved in `logs/maintenance.log`.
- All actions are recorded for troubleshooting.

### Customization
- Modify `SERVICES` to monitor and restart additional services.
- Adjust thresholds (`DISK_THRESHOLD`, `CPU_THRESHOLD`, `MEM_THRESHOLD`) as needed.

## Conclusion
This script automates routine maintenance tasks, improving system stability and security. It is structured for efficiency, clear logging, and easy customization.


Happy automating! 🛠️🚀

*I’m DestinyObs | iBuild | iDeploy | iSecure | iSustain*

