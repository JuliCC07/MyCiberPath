---
title: "Offensive Security Arsenal & Automation"
type: "tooling-index"
updated: "2026-10-16"
---

# ⚔️ Offensive Security Arsenal & ASIR Automation

> A curated collection of custom Python offensive tooling, network socket implementations, penetration testing automation, and Linux system administration scripts developed for practical cybersecurity labs and Hack The Box challenges.

---

## 🐍 Python Security Arsenal & OOP (`learning/python/`)

| Script / Module | Purpose | Key Techniques |
| :--- | :--- | :--- |
| `bindshell.py` | Standalone Multithreaded TCP Bind Shell | Python `socket`, `subprocess`, interactive shell binding, thread pooling |
| `C2TcpConnection.py` | Command & Control Client/Server Protocol | Bidirectional TCP communications, persistent context manager (`__enter__`/`__exit__`) |
| `html-parser-and-word-sorter.py` | Targeted Web Scraper & Wordlist Generator | Regex word extraction, frequency analysis, rule-based mutation engine, Click CLI |
| `request_flood.py` | Concurrent HTTP Fuzzing & Race Condition Exploit | `ThreadPoolExecutor` (100 workers), high-throughput request blasting, automated flag regex extraction |
| `red_laboratorio.py` | Network Device Modeling & Attribute Interception | OOP inheritance, dynamic routing tables, MRO resolution, `__getattribute__` security controls |
| `Python - Sec - PyJail y Sandbox Escape.md` | PyJail Escapes & Sandbox Evasion | Introspection, MRO vertical traversal, `__subclasses__()`, `__builtins__` restoration |
| `Python - OOP - Introspección y escalada de objetos.md` | Object Introspection & Class Climbing | Runtime memory analysis, `__class__`, `__mro__`, root `object` discovery |
| `Python - OOP - Métodos Mágicos (Dunder Methods).md` | Special Dunder Methods in Security | Low-level magic method overloading (`__str__`, `__dict__`, `__getitem__`) |
| `Python - OOP - Sandbox.md` | Sandbox Architecture & Isolation Concepts | Module loading constraints, namespace restriction, defense-in-depth |

---

## 🐚 Bash Automation & System Scripting (`learning/bash/`)

| Script / Module | Purpose | Key Commands |
| :--- | :--- | :--- |
| `nmap/recon.sh` | Modular Reconnaissance & Fuzzing Pipeline | Automated SYN port scanning, targeted directory/vhost fuzzing with `ffuf`, service banner grabbing |
| `script_usuarios.sh` | Enterprise User & Group Provisioning | Bulk system user creation, departmental grouping, root privilege verification |
| `iso_copy.sh` | Remote ISO Deployment Utility | Automated SCP deployment to virtual lab servers with CLI parameter parsing |
| `legion-battery-script/` | Dynamic Power Management Daemon | Custom Tuned profiles, ACPI event switching, systemd power-monitoring daemon |

---

## 📚 Core Technical Reference Notes

- [[File Inclusions|In-Depth File Inclusion (LFI / RFI) Guide]] — Vulnerability patterns, PHP wrappers, log poisoning to RCE.
- [[LFI - PHP Wrappers y Log Poisoning (RCE)|PHP Filters & Log Poisoning Methodology]] — Exploit chains for Apache/Nginx web servers.
- [[ReactOOPS|Next.js & React Server Components RCE (CVE-2025-55182)]] — Deep dive into the Flight protocol deserialization flaw.
- [[SSTI - Mako Template Injection|Server-Side Template Injection (Mako)]] — Template introspection to system command execution.
- [[Getting Started Notes|Offensive Security Fundamentals & Tooling]] — Full penetration testing lifecycle notes from HTB Academy.
