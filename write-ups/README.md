---
title: "HTB & CTF Writeups Portfolio"
type: "portfolio-index"
updated: "2026-11-02"
---

# Hack The Box Write-ups & Lab Portfolio

> Central index of resolved Hack The Box machines, CTF challenges, and offensive security labs.
> Every machine documents the full engagement lifecycle: **Reconnaissance**, **Initial Foothold**, and **Privilege Escalation**.

---

### Portfolio Summary
- **Total Pwned Targets:** 16 Machines
- **Breakdown:** 6 Medium | 10 Easy
- **Operating Systems:** Linux (Debian/Ubuntu/Alpine) & Windows Active Directory
- **Key Methodologies:** OWASP Top 10, Port Scanning & Service Fingerprinting, LFI/RFI PHP Filters, Command Injection, Linux Capabilities, Active Directory Kerberoasting.

---

## Target Matrix & Writeup Index

| Target | OS | Difficulty | Primary Attack Vector & Kill Chain | Writeup Link |
| :--- | :--- | :--- | :--- | :--- |
| **Cohort** | `Linux` | `Medium` | MTU Fragmentation Handling, Grafana Enumeration, SQLite Database Extraction, SUID Exploit | [[Cohort]] |
| **DevHub** | `Linux` | `Medium` | Exposed .git Repository Dumping, Gitea API Token Hijacking, CI/CD Runner Privilege Escalation | [[DevHub]] |
| **Facts** | `Linux` | `Medium` | CMS Made Simple Authenticated SQLi & RCE, SUID Misconfiguration, Sudo Environment Hijacking | [[Facts]] |
| **Nexus** | `Linux` | `Medium` | Sonatype Nexus Repository CVE-2020-10199 EL Injection RCE, Docker Escape / Sudo Abuse | [[Nexus]] |
| **Orion** | `Linux` | `Medium` | MikroTik RouterOS Enumeration, Custom WebApp Vulnerability, Hashcat NTLM Cracking, PrivEsc | [[Orion]] |
| **Principal** | `Windows` | `Medium` | Active Directory Recon, Kerberoasting SPN Extraction, LDAP Enumeration, BloodHound Path Analysis | [[Principal]] |
| **Reactor** | `Linux` | `Medium` | Apache NiFi Processor Creation RCE, JVM Process Extraction, Custom Sudo Binary PrivEsc | [[Reactor]] |
| **Skill Assessment - File Inclusions** | `Linux` | `Medium` | Local File Inclusion (LFI), PHP Filter Wrappers, Apache Log Poisoning to RCE | [[Skill Assessment - File Inclusions]] |
| **2million** | `Linux` | `Easy` | REST API Reversing, ROT13 Invite, Command Injection (VPN .ovpn), Kernel Exploit (Dirty Cred) | [[2million]] |
| **Baggage** | `Linux` | `Easy` | Werkzeug Console PIN Exploit, Flask Debugger, SUID Privilege Escalation | [[Baggage]] |
| **CCTV** | `Linux` | `Easy` | Default Camera API Credentials, Authenticated RCE, Sudo Misconfiguration PrivEsc | [[CCTV]] |
| **Cacti** | `Linux` | `Easy` | Cacti CVE-2022-46169 Unauthenticated Command Injection, Capsh PrivEsc | [[Cacti]] |
| **Cap** | `Linux` | `Easy` | IDOR Network Capture Download, Cleartext Credentials in PCAP, Linux Capabilities (cap_setuid) | [[Cap]] |
| **Connected** | `Linux` | `Easy` | WPA2 Handshake Capture & Cracking, Network Pivoting, System Hardening Bypass | [[Connected]] |
| **Get Simple** | `Linux` | `Easy` | GetSimple CMS 3.3.16 Theme Upload RCE, Sudo Binary Execution Abuse | [[Get Simple]] |
| **Management** | `Linux` | `Easy` | Apache Subversion (SVN) WebDAV Repository Leak, Hardcoded Admin Credentials, Crontab PrivEsc | [[Management]] |

---

## Methodology: Modular Kill Chain

```mermaid
flowchart LR
    A["Recon & Port Scan<br/>(Nmap, Feroxbuster)"] --> B["Initial Foothold<br/>(LFI, RCE, IDOR, SQLi)"]
    B --> C["Internal Enumeration<br/>(LinPEAS, Capabilities, SUID)"]
    C --> D["Privilege Escalation<br/>(Root / SYSTEM Shell)"]
```

1. **Reconnaissance & Fingerprinting:** Deep port scanning, service version detection, and virtual host / directory fuzzing.
2. **Initial Foothold (Access):** Proof-of-concept exploitation targeting unauthenticated or authenticated web application flaws.
3. **Internal Recon & Escalation:** Local privilege escalation leveraging cron jobs, SUID binaries, misconfigured capabilities, or Active Directory delegations.
