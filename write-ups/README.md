---
title: "HTB & CTF Writeups Portfolio"
type: "portfolio-index"
updated: "2026-11-02"
---

<div align="center">

# 🛡️ Hack The Box — Write-ups & Assessment Portfolio

**Technical Audit Reports, Penetration Testing Labs & CTF Walkthroughs**  
*Aligned with the HTB Certified Penetration Testing Specialist (CPTS) Methodology*

[![Total Targets](https://img.shields.io/badge/Total%20Targets-26%20Documented-131316?style=for-the-badge&logo=hackthebox&logoColor=9FEF00)](https://profile.hackthebox.com/profile/019d3f0d-ff4b-731c-a6da-2395802a6ef5)
[![Seasoned Labs](https://img.shields.io/badge/Seasoned%20Labs-16%20Machines-ea7600?style=for-the-badge)](#-seasoned-lab-targets-medium--easy)
[![Starting Point](https://img.shields.io/badge/Starting%20Point-10%20Machines-57b846?style=for-the-badge)](#-starting-point-foundations)
[![Profile](https://img.shields.io/badge/HTB-CPTS%20Path-0A66C2?style=for-the-badge&logo=hackthebox&logoColor=white)](https://profile.hackthebox.com/profile/019d3f0d-ff4b-731c-a6da-2395802a6ef5)

---
</div>

## 🎯 Seasoned Lab Targets (Medium & Easy)

Stand-alone Linux and Windows targets covering web application exploitation, Active Directory domains, and local privilege escalation.

| Target Machine | Platform | Difficulty | Primary Attack Vector & Kill Chain |
| :--- | :--- | :--- | :--- |
| [**Cohort**](htb/Cohort.md) | `Linux` | `Medium` | MTU Fragmentation Handling, Grafana Enumeration, SQLite Database Extraction, SUID Exploit |
| [**DevHub**](htb/DevHub.md) | `Linux` | `Medium` | Exposed .git Repository Dumping, Gitea API Token Hijacking, CI/CD Runner Privilege Escalation |
| [**Facts**](htb/Facts.md) | `Linux` | `Medium` | CMS Made Simple Authenticated SQLi & RCE, SUID Misconfiguration, Sudo Environment Hijacking |
| [**Nexus**](htb/Nexus.md) | `Linux` | `Medium` | Sonatype Nexus Repository CVE-2020-10199 EL Injection RCE, Docker Escape / Sudo Abuse |
| [**Orion**](htb/Orion.md) | `Linux` | `Medium` | MikroTik RouterOS Enumeration, Custom WebApp Vulnerability, Hashcat NTLM Cracking, PrivEsc |
| [**Principal**](htb/Principal.md) | `Windows` | `Medium` | Active Directory Recon, Kerberoasting SPN Extraction, LDAP Enumeration, BloodHound Path Analysis |
| [**Reactor**](htb/Reactor.md) | `Linux` | `Medium` | Apache NiFi Processor Creation RCE, JVM Process Extraction, Custom Sudo Binary PrivEsc |
| [**Skill Assessment - File Inclusions**](htb/Skill%20Assessment%20-%20File%20Inclusions.md) | `Linux` | `Medium` | Local File Inclusion (LFI), PHP Filter Wrappers, Apache Log Poisoning to RCE |
| [**2million**](htb/2million.md) | `Linux` | `Easy` | REST API Reversing, ROT13 Invite, Command Injection (VPN .ovpn), Kernel Exploit (Dirty Cred) |
| [**Baggage**](htb/Baggage.md) | `Linux` | `Easy` | Werkzeug Console PIN Exploit, Flask Debugger, SUID Privilege Escalation |
| [**CCTV**](htb/CCTV.md) | `Linux` | `Easy` | Default Camera API Credentials, Authenticated RCE, Sudo Misconfiguration PrivEsc |
| [**Cacti**](htb/Cacti.md) | `Linux` | `Easy` | Cacti CVE-2022-46169 Unauthenticated Command Injection, Capsh PrivEsc |
| [**Cap**](htb/Cap.md) | `Linux` | `Easy` | IDOR Network Capture Download, Cleartext Credentials in PCAP, Linux Capabilities (cap_setuid) |
| [**Connected**](htb/Connected.md) | `Linux` | `Easy` | WPA2 Handshake Capture & Cracking, Network Pivoting, System Hardening Bypass |
| [**Get Simple**](htb/Get%20Simple.md) | `Linux` | `Easy` | GetSimple CMS 3.3.16 Theme Upload RCE, Sudo Binary Execution Abuse |
| [**Management**](htb/Management.md) | `Linux` | `Easy` | Apache Subversion (SVN) WebDAV Repository Leak, Hardcoded Admin Credentials, Crontab PrivEsc |

---

## 🔰 Starting Point Foundations

Fundamental Tier 0 to Tier 2 machines covering introductory attack surfaces, network services, and credential handling.

| Target Machine | Platform | Difficulty | Primary Attack Vector & Core Focus |
| :--- | :--- | :--- | :--- |
| [**Archetype**](htb/starting-point/Archetype.md) | `Windows` | `Tier 2` | SMB enumeration, MSSQL xp_cmdshell execution, PowerShell reverse shell, winPEAS |
| [**Oopsie**](htb/starting-point/Oopsie.md) | `Linux` | `Tier 1` | Web admin IDOR, cookie manipulation, arbitrary file upload, SUID privilege escalation |
| [**Responder**](htb/starting-point/Responder.md) | `Windows` | `Tier 1` | LLMNR/NBT-NS poisoning with Responder, NTLMv2 hash cracking, evil-winrm shell |
| [**Appointment**](htb/starting-point/Appointment.md) | `Linux` | `Tier 0` | SQL injection authentication bypass on administrative web login |
| [**Crocodile**](htb/starting-point/Crocodile.md) | `Linux` | `Tier 0` | Anonymous FTP login, credentials retrieval, PHP administrative portal access |
| [**Dancing**](htb/starting-point/Dancing.md) | `Windows` | `Tier 0` | Unauthenticated SMB share listing and file retrieval with smbclient |
| [**Fawn**](htb/starting-point/Fawn.md) | `Linux` | `Tier 0` | FTP protocol exploration, service banner grabbing, anonymous download |
| [**Meow**](htb/starting-point/Meow.md) | `Linux` | `Tier 0` | Telnet service discovery, blank root password exploitation |
| [**Reedemer**](htb/starting-point/Reedemer.md) | `Linux` | `Tier 0` | Redis in-memory cache interaction, database inspection and key dumping |
| [**Sequel**](htb/starting-point/Sequel.md) | `Linux` | `Tier 0` | MySQL remote connection, empty root password, database exfiltration |

---

## 🔍 Assessment Methodology

Every engagement follows a structured 4-phase audit lifecycle:

1. **Reconnaissance & Enumeration**: Deep service discovery with `nmap`, web directory and parameter fuzzing (`ffuf`), virtual host mapping, and Active Directory LDAP exploration.
2. **Initial Foothold (Access)**: Vulnerability research, customizing public Proof of Concepts (PoCs) or crafting custom Python exploits to obtain an interactive reverse shell.
3. **Privilege Escalation & Lateral Movement**: Internal environment auditing (`linpeas`, `winpeas`), abusing SUID binaries, misconfigured Linux capabilities (`cap_setuid`), vulnerable scheduled jobs, or Kerberos ticket extraction (Kerberoasting / AS-REP roasting).
4. **Defensive Hardening & Remediation**: Technical root-cause recommendations to patch vulnerabilities, enforce least-privilege principles, and prevent persistent compromise.
