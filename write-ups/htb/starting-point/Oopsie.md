# Oopsie

**Platform:** Hack The Box · **Type:** Starting Point · **OS:** Linux · **Difficulty:** Tier 2

> **Status:** in progress. This write-up stops before the end of the box.

**Summary:** Apache site with a hidden admin panel. Passive crawling through Burp Suite is the way to find the login page. Exposed services: SSH and HTTP.

## 1. Reconnaissance

### 1.1 Port scan

```
┌──(julicc㉿diavlo)-[~]
└─$ nmap -sV -sC 10.129.90.91
Starting Nmap 7.98 ( https://nmap.org ) at 2026-04-21 12:06 +0200
Nmap scan report for megacorp.com (10.129.90.91)
Host is up (0.22s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   2048 61:e4:3f:d4:1e:e2:b2:f1:0d:3c:ed:36:28:36:67:c7 (RSA)
|   256 24:1d:a4:17:d4:e3:2a:9c:90:5c:30:58:8f:60:77:8d (ECDSA)
|_  256 78:03:0e:b4:a1:af:e5:c2:f9:8d:29:05:3e:29:c9:f2 (ED25519)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-title: Welcome
|_http-server-header: Apache/2.4.29 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 13.43 seconds
```

| **Port** | **Service** | **Version** | **State** |
|---|---|---|---|
| 22 | SSH | OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 | Open |
| 80 | HTTP | Apache httpd 2.4.29 (Ubuntu) | Open |

### 1.2 Web service
The links on the home page don't go anywhere, but scrolling down there's a hint that services are available after logging in. So there should be a login page somewhere.

Before brute-forcing directories, I mapped the site by proxying it through **Burp Suite** for passive crawling.

> **Web crawler:** a program that walks a website methodically. If you proxy your browsing through Burp Suite (without intercepting), it passively spiders the site: every requested resource lands in the site map, which builds a tree of files and directories without sending any extra requests.

## 2. Foothold, 3. Privilege Escalation: still to write up

Remaining steps:
- [ ] Find the login path through Burp's passive crawl
- [ ] Use the IDOR to escalate privileges inside the web app
- [ ] Upload a PHP web shell and get a shell as `www-data`
- [ ] Local privilege escalation to root

## 4. Conclusion

**Severity:** High

**Remediation:**
1. **Server-side access control:** check authorization on every endpoint, so that the logged-in user must actually have rights to the requested resource. Don't rely on client-side parameters.
2. **Don't expose admin panels:** protect admin login paths with MFA or restrict them by IP.
3. **Least privilege:** file upload shouldn't be available to every user role.
4. **Validate uploads:** allowlist extensions, check the real MIME type, and store uploads outside the webroot.
