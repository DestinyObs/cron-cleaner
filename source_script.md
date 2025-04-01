### **1️⃣ Set Up Logging**  
First, define the logging mechanism:  

```bash
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/maintenance.log"
mkdir -p "$LOG_DIR"
echo "===== Starting Maintenance Tasks =====" | tee -a "$LOG_FILE"
```

---

### **2️⃣ Monitor System Resources (CPU, Memory, Disk Usage)**  

#### **Check CPU Usage**  
```bash
top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}'
```
If you want to store and log the CPU usage:  
```bash
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
echo "$(date '+%Y-%m-%d %H:%M:%S') - CPU: ${CPU_USAGE}%" | tee -a "$LOG_FILE"
```

#### **Check Memory Usage**  
```bash
free | awk '/Mem/{printf "%.2f", $3/$2 * 100}'
```
To log it:  
```bash
MEM_USAGE=$(free | awk '/Mem/{printf "%.2f", $3/$2 * 100}')
echo "$(date '+%Y-%m-%d %H:%M:%S') - Memory: ${MEM_USAGE}%" | tee -a "$LOG_FILE"
```

#### **Check Disk Usage**  
```bash
df / | awk 'NR==2 {print $5}' | sed 's/%//'
```
Log it:  
```bash
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
echo "$(date '+%Y-%m-%d %H:%M:%S') - Disk: ${DISK_USAGE}%" | tee -a "$LOG_FILE"
```

#### **Alerts for High Resource Usage**  
```bash
[[ $(echo "$CPU_USAGE > 75" | bc -l) -eq 1 ]] && echo "ALERT: High CPU usage (${CPU_USAGE}%)"
[[ $(echo "$MEM_USAGE > 75" | bc -l) -eq 1 ]] && echo "ALERT: High Memory usage (${MEM_USAGE}%)"
[[ $DISK_USAGE -gt 80 ]] && echo "ALERT: Disk usage high (${DISK_USAGE}%)"
```

---

### **3️⃣ Analyze System Logs**  

#### **Check Failed SSH Logins**  
```bash
grep -c "Failed password" ./auth.log
```
Log it:  
```bash
FAILED_LOGINS=$(grep -c "Failed password" ./auth.log)
echo "Failed SSH attempts: $FAILED_LOGINS" | tee -a "$LOG_FILE"
[[ $FAILED_LOGINS -gt 5 ]] && echo "SECURITY WARNING: Multiple failed SSH login attempts detected!"
```

#### **Check System Errors in Syslog**  
```bash
grep -i "error" ./syslog | wc -l
```
Log it:  
```bash
SYSTEM_ERRORS=$(grep -i "error" ./syslog | wc -l)
echo "System Errors: $SYSTEM_ERRORS" | tee -a "$LOG_FILE"
[[ $SYSTEM_ERRORS -gt 10 ]] && echo "WARNING: High number of system errors detected!"
```

---

### **4️⃣ Clean Up Temporary Files**  
```bash
find "/tmp" -type f -atime +7 -delete && echo "Cleared old files in /tmp."
```

---

### **5️⃣ Restart Critical Services (If Needed)**  
#### **Check If Service Is Running**  
```bash
systemctl is-active --quiet nginx && echo "Nginx is running." || echo "Nginx is not running."
```
#### **Restart Service If Down**  
```bash
systemctl restart nginx && echo "Nginx restarted successfully."
```
Do the same for MySQL:  
```bash
systemctl is-active --quiet mysql && echo "MySQL is running." || (systemctl restart mysql && echo "MySQL restarted.")
```

---

### **6️⃣ Apply System Updates**  
```bash
sudo apt update && sudo apt upgrade -y
```
If you want to log the update process:  
```bash
sudo apt update && sudo apt upgrade -y 2>&1 | tee -a "$LOG_FILE"
```

---

### **7️⃣ Finish Logging**  
```bash
echo "===== Maintenance Tasks Finished =====" | tee -a "$LOG_FILE"
```

---

Now, instead of running a script, you can execute each of these commands one by one directly in the terminal. 🚀
