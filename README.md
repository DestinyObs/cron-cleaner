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
LOG_FILE="/var/log/system_maintenance.log"
```

Everything the script does gets logged here, so you can trace back when things went wrong (or prove to your boss that it wasn’t your fault).

### 2. Defining Important Variables

```bash
TEMP_DIR="/tmp"
CRITICAL_SERVICES=("nginx" "mysql")
DISK_THRESHOLD=80
CPU_THRESHOLD=75
MEM_THRESHOLD=75
```

- **TEMP\_DIR**: Where temp files go to die.
- **CRITICAL\_SERVICES**: Add more if you don’t like surprises.
- **Thresholds**: Numbers beyond which alarms should go off.

### 3. Logging Function

```bash
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}
```

Logs messages with timestamps—so you can pinpoint the exact moment your server started misbehaving.

### 4. Monitoring System Resources

```bash
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEM_USAGE=$(free | awk '/Mem/{printf("%.2f"), $3/$2 * 100}')
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
```

- **top**: Extracts CPU usage.
- **free**: Gets memory usage.
- **df**: Checks disk space.

If the numbers exceed thresholds, the script raises an alarm:

```bash
if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    log "⚠️ High CPU Usage detected: ${CPU_USAGE}%"
fi
```

Similar checks exist for memory and disk.

### 5. Analyzing Logs for Security & Errors

```bash
FAILED_LOGINS=$(grep "Failed password" /var/log/auth.log | wc -l)
SYSTEM_ERRORS=$(grep -i "error" /var/log/syslog | wc -l)
```

- Counts failed SSH login attempts.
- Scans system logs for errors.

If things look fishy, the script logs a warning:

```bash
if [ "$FAILED_LOGINS" -gt 5 ]; then
    log "🚨 Multiple failed SSH login attempts detected!"
fi
```

### 6. Cleaning Up Temporary Files

```bash
find "$TEMP_DIR" -type f -atime +7 -delete
```

Deletes temp files older than 7 days, because hoarding is bad.

### 7. Restarting Critical Services

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
```

The script checks each service and restarts it if it’s down—because downtime is expensive, and customers don’t care about your excuses.

### 8. Applying System Updates

```bash
apt update && apt upgrade -y
```

Keeps your system up to date without manual intervention.

```bash
if [ $? -eq 0 ]; then
    log "✅ System updates completed successfully."
else
    log "❌ System updates failed! Check logs."
fi
```

Because nobody likes outdated, vulnerable software.

### 9. Running Everything in Order

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

Each function runs in sequence, ensuring smooth operations while you sip coffee like a boss.

---

## Automating with Cron

To make this run every day at midnight, add this line to your crontab:

```bash
0 0 * * * /path/to/script.sh
```

Run `crontab -e` and paste the above line. Boom! Automated maintenance.

---

## Final Thoughts

This script does the dirty work while you enjoy a stress-free sysadmin life. Customize it to fit your needs, tweak the logs for extra flair, and bask in the glory of a well-maintained system.

Happy automating! 🛠️🚀

*I’m DestinyObs | iBuild | iDeploy | iSecure | iSustain*

