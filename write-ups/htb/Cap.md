---
title: "Cap - Hack The Box"
target: "Cap"
os: "Linux"
difficulty: "Easy"
status: "Pwned"
vectors: "IDOR Network Capture Download, Cleartext Credentials in PCAP, Linux Capabilities (cap_setuid)"
tags:
  - ciber
  - htb
  - idor
  - pcap
  - capabilities
  - cap_setuid
synced: "2026-11-02 12:08"
---

<p align="center">
  <img src="https://cdn.services-k8s.prod.aws.htb.systems/content/machines/avatar/9e4d90d2-73c7-4da0-a15f-662bbc048868.png" alt="Cap Avatar" width="220">
</p>

## Operating System: Linux
![[Linux.png|70]]

## Machine Metadata

| Property | Value |
| :--- | :--- |
| **Machine ID** | 351 |
| **Machine Name** | Cap |
| **IP Address** | 10.129.131.96 |
| **Status** | Pwned |
| **Active on HTB** | ❌ |
| **User Flag** | ✅ |
| **Root Flag** | ✅ |
| **Difficulty** | Easy |
| **Stars** | ⭐️ 4.6 |
| **Created Note** | 2026-10-16 |
| **Release Date** | 2021-06-05 |
| **Tags** | #Vulnerability_Assessment #Security_Operations #Clear_Text_Credentials #File_System_Configuration #Insecure_Direct_Object_Reference_(IDOR) #Python #Packet_Capture_Analysis #Password_Reuse #SUID_Exploitation #Common_Security_Controls #Log_Analysis |

<p style="display:none">
id:: 351
active:: False
name:: Cap
os:: Linux
user_flag:: True
root_flag:: True
difficulty_text:: Easy
stars:: 4.6
created:: 2026-10-16
published:: 2021-06-05
avatar:: https://cdn.services-k8s.prod.aws.htb.systems/content/machines/avatar/9e4d90d2-73c7-4da0-a15f-662bbc048868.png
tags:: #Vulnerability_Assessment #Security_Operations #Clear_Text_Credentials #File_System_Configuration #Insecure_Direct_Object_Reference_(IDOR) #Python #Packet_Capture_Analysis #Password_Reuse #SUID_Exploitation #Common_Security_Controls #Log_Analysis
</p>

## Statistics

### Radar Matrix
```chartsview
#-----------------#
#- chart type    -#
#-----------------#
type: Radar

#-----------------#
#- chart data    -#
#-----------------#
data:
  - item: "ENUM"
    user: "user"
    score: 4.8
  - item: "REAL"
    user: "user"
    score: 4.2
  - item: "CVE"
    user: "user"
    score: 4.6
  - item: "CUSTOM"
    user: "user"
    score: 5.4
  - item: "CTF"
    user: "user"
    score: 5.8
  - item: "ENUM"
    user: "author"
    score: 2
  - item: "REAL"
    user: "author"
    score: 2
  - item: "CVE"
    user: "author"
    score: 7
  - item: "CUSTOM"
    user: "author"
    score: 3
  - item: "CTF"
    user: "author"
    score: 8

#-----------------#
#- chart options -#
#-----------------#
options:
  xField: "item"
  yField: "score"
  seriesField: "user"
  meta:
    score:
      alias: "Score"
      min: 0
      nice: true
  xAxis:
    line: null
    tickLine: null
  yAxis:
    label: false
    grid:
      alternateColor: "rgba(0, 0, 0, 0.04)"
  point: []
  area: []
```

### Community Difficulty Rating
```chartsview
#-----------------#
#- chart type    -#
#-----------------#
type: Column

#-----------------#
#- chart data    -#
#-----------------#
data:
  - folder: "PIECE OF CAKE"
    count: 21973
  - folder: "VERY EASY"
    count: 25061
  - folder: "EASY"
    count: 42397
  - folder: "NOT TOO EASY"
    count: 15456
  - folder: "MEDIUM"
    count: 7828
  - folder: "A BIT HARD"
    count: 1978
  - folder: "HARD"
    count: 1225
  - folder: "EXTREMELY HARD"
    count: 307
  - folder: "INSANE"
    count: 126
  - folder: "BRAINFUCK"
    count: 440

#-----------------#
#- chart options -#
#-----------------#
options:
  xField: "folder"
  yField: "count"
  padding: auto
  label:
    position: "middle"
    style:
      opacity: 0.6
      fontSize: 12
  columnStyle:
    fillOpacity: 0.5
    lineWidth: 1
    strokeOpacity: 0.7
    shadowColor: "grey"
    shadowBlur: 10
    shadowOffsetX: 5
    shadowOffsetY: 5
  xAxis:
    label:
      autoHide: false
      autoRotate: true
  meta:
    count:
      alias: "Votes"
```

---

## Information Gathering

### Port & Service Scanning
```bash
# Fast TCP port discovery
nmap -p- --open -sS --min-rate 5000 -n -Pn 10.129.131.96 -oN recon_ports.nmap

# Service & script enumeration
nmap -sCV -p<PORTS> 10.129.131.96 -oN recon_services.nmap
```

### Web & Service Enumeration
```bash
# Directory & file fuzzing
ffuf -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-directories.txt -u http://10.129.131.96/FUZZ -fc 404
```

---

## Vulnerability Assessment
<!-- Analysis of attack surface, identified technologies, CVEs, misconfigurations, or logic flaws -->
- **Identified Vector**: 
- **Target Zettelkasten Concept**: Cybersecurity Hub
- **Attack Hypothesis**: 

---

## Exploitation (Foothold)

### Weaponization & Payload Execution
<!-- Exploit details, PoC, parameters, or reverse shell payload -->
```bash

```

### User Shell & Flag
- **Initial Access User**: 
- **User Flag (`user.txt`)**:
```text

```

---

## Post-Exploitation & Lateral Movement

### Internal Enumeration & Pivoting
```bash
# Local reconnaissance (sudo privileges, SUIDs, listening services, cron)
sudo -l
find / -perm -4000 -type f 2>/dev/null
ss -tulpn
```

### Privilege Escalation Vector
<!-- Exploit technique used to escalate to root / NT AUTHORITY\SYSTEM -->
- **Technique**: 
- **Escalation Steps**:
```bash

```

### Root Shell & Flag
- **Final User**: root / SYSTEM
- **Root Flag (`root.txt` / `proof.txt`)**:
```text

```

---

## Proof of Concept & Attack Summary
<!-- High-level summary of the end-to-end exploit chain -->
- **Recon**: 
- **Foothold**: 
- **PrivEsc**: 

---

## Post-Engagement & Zettelkasten Notes

### Key Takeaways & Defense
- **Root Cause**: 
- **Remediation / Mitigation**: 

### Atomic Notes to Extract
<!-- Concepts and techniques to document in 20_Zettelkasten/ -->
