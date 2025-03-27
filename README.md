# Maintenance Script: Keeping Your Linux Box in Check

## Introduction

Welcome, esteemed engineer, noble sysadmin, or brave soul who just realized their server is on fire. 🎩🔥

System maintenance is like brushing your teeth—you can skip it, but eventually, it’ll cost you. This script is your trusty sidekick, automating crucial tasks like monitoring CPU and disk usage, restarting critical services, and applying security updates. Think of it as a tiny, relentless janitor for your Linux system, sweeping up messes before they turn into disasters.

This guide will walk you through the script’s functions, ensuring that you understand what each piece does instead of just running it blindly and praying to the Bash gods.

And no, this knowledge is NOT a waste—whether you’re a rookie or a battle-hardened sysadmin, mastering these skills will make you the unsung hero of your team.

---

## Why Is This Important?

### 1. Monitoring Resource Usage

Ever had a server slow down so badly you suspected it had just given up on life? Monitoring CPU, RAM, and disk usage helps you spot trouble before your users start screaming on Twitter.

This script logs system metrics and warns you when things start going south.

### 2. Detecting Security Threats

Hackers never sleep, and your logs are proof. SSH brute-force attacks happen all the time, and failed logins pile up like rejection emails from that dream job you applied for.

This script helps you keep an eye on unauthorized access attempts and system errors.

### 3. Ensuring Critical Services Stay Running

Imagine waking up to find out your database crashed hours ago, and now your boss is calling. 😱

The script monitors essential services (e.g., Nginx, MySQL) and restarts them if they go down—because humans need sleep, but servers don’t.

### 4. Automating System Cleanup & Updates

Old temp files waste space. Security patches are life-saving. This script takes care of both, so you don’t have to do it manually like some medieval peasant.

---
## Deep Dive Into the Code

### 1. Setting Up Logging

```bash
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/system_maintenance.log"
```

All script actions are recorded in a custom logging directory to avoid system-level permission issues. This ensures the logs are accessible without requiring elevated privileges.

Additionally, the script ensures the log directory exists:

```bash
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
fi
```

### 2. Placeholder Log Files

The script creates placeholders for missing log files (`auth.log` and `syslog`):

```bash
AUTH_LOG="./auth.log"
SYS_LOG="./syslog"

if [ ! -f "$AUTH_LOG" ]; then
    touch "$AUTH_LOG"
    log "ℹ️ Created placeholder for auth.log."
fi

if [ ! -f "$SYS_LOG" ]; then
    touch "$SYS_LOG"
    log "ℹ️ Created placeholder for syslog."
fi
```

This step eliminates execution errors caused by non-existent files.

### 3. Defining Important Variables

```bash
TEMP_DIR="/tmp"
CRITICAL_SERVICES=("nginx" "mysql")
DISK_THRESHOLD=80
CPU_THRESHOLD=75
MEM_THRESHOLD=75
```

- **TEMP_DIR**: Temporary files older than 7 days are deleted.
- **CRITICAL_SERVICES**: Defines services critical to your environment.
- **Thresholds**: Sets alarm limits for resource usage.

### 4. Logging Function

```bash
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}
```

Messages are logged with timestamps for easy troubleshooting.

### 5. Monitoring System Resources

```bash
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEM_USAGE=$(free | awk '/Mem/{printf("%.2f"), $3/$2 * 100}')
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
```

- Extracts CPU, memory, and disk usage.
- Checks resource levels against thresholds:
  
  ```bash
  if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
      log "⚠️ High CPU Usage detected: ${CPU_USAGE}%"
  fi
  ```

Warnings are raised if limits are exceeded.

### 6. Analyzing Logs for Security & Errors

The script analyzes failed SSH login attempts and system errors:

```bash
FAILED_LOGINS=$(grep "Failed password" ./auth.log | wc -l)
SYSTEM_ERRORS=$(grep -i "error" ./syslog | wc -l)

if [ "$FAILED_LOGINS" -gt 5 ]; then
    log "🚨 Multiple failed SSH login attempts detected!"
fi

if [ "$SYSTEM_ERRORS" -gt 10 ]; then
    log "⚠️ High number of system errors detected!"
fi
```

This ensures you stay informed of potential security risks or system instability.

### 7. Cleaning Up Temporary Files

```bash
find "$TEMP_DIR" -type f -atime +7 -delete
```

Old temporary files are cleared to improve system performance.

### 8. Restarting Critical Services

The script checks critical services and restarts them if they are not running:

```bash
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
```

### 9. Applying System Updates

To avoid permission issues, the script checks for elevated privileges before attempting updates:

```bash
if [ "$EUID" -ne 0 ]; then
    log "⚠️ System updates require elevated permissions. Please run the script with sudo."
    return
fi

apt update && apt upgrade -y

if [ $? -eq 0 ]; then
    log "✅ System updates completed successfully."
else
    log "❌ System updates failed! Check the logs for details."
fi
```

This ensures you know when and how to address missing updates.

### 10. Running Everything in Sequence

```bash
main() {
    log "===== System Maintenance Script Started ====="
    monitor_system
    analyze_logs
    optimize_performance
    apply_updates
    log "===== System Maintenance Script Completed ====="
}
main
```

The script smoothly executes all steps, keeping your system maintained with minimal intervention.

---

## Automating with Cron

To schedule the script daily at midnight:

```bash
0 0 * * * /path/to/script.sh
```

Paste this into `crontab` via `crontab -e` for automatic maintenance tasks.

---

Ensure the script has execution permissions (`chmod +x script.sh`) and is run with `sudo` to function correctly.
---

## Final Thoughts

This script is just one of many ways to automate system maintenance. It’s a simple yet effective tool to help you monitor and manage your system natively. More advanced methods exist, but this provides a solid foundation for understanding how things work under the hood.

Happy automating! 🛠️🚀

*I’m DestinyObs | iBuild | iDeploy | iSecure | iSustain*

