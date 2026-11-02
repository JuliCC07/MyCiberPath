---
title: "Security Tooling Arsenal & Lab Automation"
type: "tooling-index"
updated: "2026-11-02"
---

# Security Tooling Arsenal & ASIR Automation

> A curated collection of Python tools, network sockets, penetration testing automation, and system administration scripts built for ASIR labs and Hack The Box challenges.

---

## Python Arsenal (`learning/python/`)

| Script / Module | Purpose | Key Techniques |
| :--- | :--- | :--- |
| `bindshell.py` | Standalone TCP Bind Shell | Python `socket`, `subprocess`, interactive shell binding |
| `C2TcpConnection.py` | Command & Control Client/Server | Context-managed bidirectional TCP socket connection |
| `html-parser-and-word-sorter.py` | Target Content Scraper | Wordlist generation, HTML entity parsing, regex filtering |
| `request_flood.py` | HTTP Stress Testing & Fuzzing | Multithreaded requests, rate-limit analysis, response inspection |
| `lab_network_topology.py` | Virtual Lab Topology Tester | OOP inheritance model, attribute encapsulation, MRO resolution |
| `Python - Sec - PyJail and Sandbox Escape.md` | PyJail Escapes | Introspection, `__subclasses__()`, `__builtins__` restoration |
| `Python - OOP - Object Introspection and Escalation.md` | Object Escalation | Vertical and horizontal class traversal via MRO |
| `Python - OOP - Dunder Methods.md` | Magic Methods | Special method overloading and security implications |

---

## Bash Automation & System Scripting (`learning/bash/`)

| Script | Purpose | Key Commands |
| :--- | :--- | :--- |
| `user_provisioning.sh` | Automated User & Group Provisioning | `useradd`, `groupadd`, bulk parsing and verification |
| `iso_copy.sh` | Live USB & ISO Flashing Utility | Remote `scp` transfer, CLI argument parsing with `getopts` |
| `legion-battery-script/` | Power Management Profiles | ACPI event handling, TuneD profile overrides, systemd unit |
| `nmap/` | Rapid Recon Wrappers | Automated mass scanning, greppable output parsing |

---

## Core Pentesting Notes (`notes/pentesting/`)

- [[Web - LFI - PHP Wrappers and Log Poisoning (RCE)|PHP Filters & Log Poisoning (RCE)]]
- [[Web - LFI - Fuzzing Parameters|LFI Parameter Fuzzing Methodology]]
- [[Web - LFI - Server Files Chain|Server Files Traversal Chain]]
- [[Web - SSTI - Mako Template Injection|Server-Side Template Injection (Mako)]]
- [[Pentesting - Tools - cURL Cheatsheet|cURL Mastery Cheatsheet]]
- [[Linux - PrivEsc - SUID|SUID Privilege Escalation Methodology]]
- [[Getting Started Notes|Offensive Security Fundamentals]]
