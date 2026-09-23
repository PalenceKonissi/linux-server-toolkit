# 🛠️ Linux Server Toolkit

A hands-on, production-ready automation and monitoring toolkit designed to implement security hardening, live performance metrics tracking, and automated log analysis on Linux systems using Bash and Ansible.

## 🚀 Project Overview

The **linux-server-toolkit** is built around the principle of **Least Privilege** and automated system maintenance. It transforms a standard Linux server into a secure, self-monitoring environment by deploying hardening scripts, system health checkers, log analyzers, and cron jobs entirely through an infrastructure-as-code approach.

### ⚙️ Core Architecture & Deliverables
* **Hardened Server Configuration:** Restricts server access by setting up dedicated operational groups and isolated users with passwordless, strictly limited `sudo` privileges.
* **`system_health.sh`:** A custom Bash script providing real-time infrastructure snapshots (CPU, RAM, Disk, and top resource-consuming processes).
* **`log_analyzer.sh`:** A automated monitoring script parsing system authentication records to instantly flag brute-force SSH attacks.
* **Automated Cron Scheduling:** A background engine configured to automatically trigger health metrics on an hourly cycle.
* **Ansible Master Playbook:** An end-to-end automation suite capable of deploying the entire environment to remote nodes without manual intervention.

---

## 📁 Repository Structure

```text
linux-server-toolkit/
├── ansible/
│   └── playbook.yml          # Master playbook for remote automation
├── logs/                     # Local directory for output logs (Git-ignored)
├── scripts/
│   ├── system_health.sh      # Core server metrics collection engine
│   └── log_analyzer.sh       # Security log parsing script
├── .gitignore                # Blocklist for sensitive data & logs
└── README.md                 # Project documentation
```

---

## 💻 Features & Terminal Executions

### 1. User Hardening & Security Permissions
The server isolates operational duties by provisioning a `devops` user explicitly confined to critical administrative paths (`apt`, `systemctl`, `docker`).

```bash
# Verify the user configuration and group delegation
id devops
# Expected output: uid=1001(devops) gid=1001(devops) groups=1001(devops),1002(deploy)

# Verify the passwordless rule syntax 
cat /etc/sudoers.d/devops
# Expected output: devops ALL=(ALL) NOPASSWD: /usr/bin/apt, /usr/bin/systemctl, /usr/bin/docker
```

#### The Production Security Test
```bash
su - devops

# This ALLOWED command runs flawlessly without prompting for a password:
sudo apt update

# This UNAUTHORIZED command fails instantly:
sudo ls /root
# Expected output: Sorry, user devops is not allowed to execute '/usr/bin/ls /root' as root on this host.
```

### 2. Live System Health Monitoring (`system_health.sh`)
The monitoring engine captures system performance and dumps data seamlessly while printing live terminal results. It maps:
* System Uptime & Load Averages
* Hardware Profiles & Available Memory
* Disk Array Capacities
* Top 5 CPU and Memory Consuming Threads

```bash
# Run the monitoring check manually
./scripts/system_health.sh
```
<img width="1577" height="960" alt="system_health" src="https://github.com/user-attachments/assets/b96ae178-d47d-4cda-a04f-10309b514af8" />

*Outputs are archived automatically inside the `/logs/` folder using timestamped formats: `health_YYYY-MM-DD.log`.*

---

### 3. Automated Security Log Analysis (`log_analyzer.sh`)
This component scans system authentication records (`/var/log/auth.log` or `/var/log/secure`) to detect brute-force SSH attacks, tracking malicious actors, targeted usernames, and successful entry points.

#### ⚔️ Attack Simulation (Testing the Script)
To test the script's defensive capabilities, a loop command was executed to simulate an automated brute-force password spraying attack from a local connection using mock usernames (`fakeuser1` through `fakeuser6`):

```bash
for i in {1..11}; do ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no fakeuser$i@127.0.0.1 "echo" 2>/dev/null; echo -n "."; done; echo -e "\n[DONE]"
```

#### 🔍 Expected Output (Log Analysis Report)
Running the log analyzer immediately flags the simulated attack patterns, correctly identifying the threat vector and summarizing the incident statistics:
<img width="1587" height="436" alt="log_analyzer" src="https://github.com/user-attachments/assets/1076e162-cccb-4456-ba9f-459e7f1963fc" />

```bash
sudo ~/linux-server-toolkit/scripts/log_analyzer.sh
```

**Terminal Output Snapshot:**

<img width="1270" height="416" alt="log_analyser_output" src="https://github.com/user-attachments/assets/4b03c4e7-ef72-448f-a25b-68e87ecec7e8" />


## 🔒 Security & Git Hygiene

To protect production telemetry, workspace environments are locked to the specific deploying owner, and analytical dump targets are hidden from public control.

* **Directory Restrictions:** Evaluated using `ls -ld ~/linux-server-toolkit`, confirming `drwx------` permission values.
* **Repository Safety:** The system explicitly filters files using a strict `.gitignore` footprint:
  ```text
  logs/
  *.log
  .terraform/
  ```

---

## 🛠️ Requirements & Setup

1. **Local Lab Target:** Linux OS (WSL2, Ubuntu Native, VirtualBox, or AWS EC2).
2. **Execution Permissions:** Ensure all components are given execution allowances before launching:
   ```bash
   chmod +x scripts/system_health.sh
   ```
