Got it! Here’s the simplified version with just the essential commands:  

---

### **1️⃣ System Resource Usage**  
#### **CPU Usage**  
```bash
top -bn1 | grep "Cpu(s)"
```

#### **Memory Usage**  
```bash
free -h
```

#### **Disk Usage**  
```bash
df -h
```

---

### **2️⃣ System Logs**  
#### **Failed SSH Logins**  
```bash
grep "Failed password" /var/log/auth.log
```

#### **System Errors**  
```bash
grep -i "error" /var/log/syslog
```

---

### **3️⃣ Clean Temporary Files**  
```bash
find /tmp -type f -atime +7
```

---

### **4️⃣ Check & Restart Services**  
#### **Check Nginx Status**  
```bash
systemctl status nginx
```

#### **Check MySQL Status**  
```bash
systemctl status mysql
```

---

### **5️⃣ Apply System Updates**  
```bash
sudo apt update && sudo apt upgrade -y
```

---

That’s all—just the raw commands for quick checks! 🚀
