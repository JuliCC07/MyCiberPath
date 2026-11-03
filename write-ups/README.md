# Write-ups

My Hack The Box write-ups. Each one goes through reconnaissance, initial access, privilege escalation and a short conclusion with remediation advice. Machines are only published once they've retired.

## Machines (12)

| Name | OS | Difficulty | What it covers |
| :--- | :--- | :--- | :--- |
| [DevHub](htb/machines/DevHub.md) | Linux | Medium | Outdated MCPJam Inspector 1.4.2 for a foothold, hardcoded API key in a world-readable script, hidden debug endpoint on an internal API to root |
| [Principal](htb/machines/Principal.md) | Linux | Medium | pac4j JWT 'none' algorithm forgery (CVE-2026-29000), SSH certificate authority trusted without AuthorizedPrincipalsFile to root |
| [CCTV](htb/machines/CCTV.md) | Linux | Easy | ZoneMinder SQL injection (CVE-2024-51482), cracked hash for SSH, local MotionEye RCE as root through a port forward |
| [Cohort](htb/machines/Cohort.md) | Linux | Easy | SSRF to internal endpoints, pre-auth marimo WebSocket RCE (CVE-2026-39987), PackageKit TOCTOU race to root (CVE-2026-41651) |
| [Connected](htb/machines/Connected.md) | Linux | Easy | FreePBX RCE (CVE-2025-57819), writable script run by incron to root |
| [Facts](htb/machines/Facts.md) *(in progress)* | Linux | Easy | Recon so far: Camaleon CMS (Ruby on Rails) and a MinIO console on 54321/9001 |
| [Management](htb/machines/Management.md) | Linux | Easy | Credentials from config files and MariaDB, decrypted LDAP password for lateral movement, sudo rdiff-backup restricted-mode bypass to read /root |
| [MonitorsFour](htb/machines/MonitorsFour.md) | Windows | Easy | IDOR leaks credentials, Cacti RCE (CVE-2025-24367) inside a container, Docker Desktop engine API escape (CVE-2025-9074) |
| [Nexus](htb/machines/Nexus.md) | Linux | Easy | Exposed .env and open directories, Krayin CRM RCE (CVE-2026-38526), password reuse, path traversal in a root cron job's Git template sync |
| [Orion](htb/machines/Orion.md) | Linux | Easy | Craft CMS pre-auth RCE (CVE-2025-32432), DB credentials in .env and a weak password, vulnerable GNU inetutils telnetd 2.7 to root |
| [Reactor](htb/machines/Reactor.md) | Linux | Easy | Next.js React Server Components RCE, Node.js V8 inspector exposed on a root process |
| [TwoMillion](htb/machines/TwoMillion.md) | Linux | Easy | Invite API abuse, admin via insecure API endpoint, command injection in the VPN generator, reused DB credentials, OverlayFS kernel exploit (CVE-2023-0386) |

## Challenges (1)

| Name | OS | What it covers |
| :--- | :--- | :--- |
| [Baggage](htb/challenges/Baggage.md) | Windows | Registry forensics: UserAssist and Shellbags from NTUSER.DAT and UsrClass.dat with regipy |

## HTB Academy skills assessments (2)

| Name | OS | What it covers |
| :--- | :--- | :--- |
| [Getting Started - Skills Assessment](htb-academy/Getting%20Started%20-%20Skills%20Assessment.md) | Linux | GetSimple CMS 3.3.15: weak admin credentials, authenticated RCE, sudo php to root |
| [File Inclusions - Skills Assessment](htb-academy/File%20Inclusions%20-%20Skills%20Assessment.md) | Linux | LFI found by fuzzing an image endpoint, source disclosure, URL-encoded include filter bypass to run an uploaded shell |

## Starting Point (10)

| Name | OS | Difficulty | What it covers |
| :--- | :--- | :--- | :--- |
| [Meow](htb/starting-point/Meow.md) | Linux | Tier 0 | Telnet with a passwordless root account |
| [Fawn](htb/starting-point/Fawn.md) | Linux | Tier 0 | Anonymous FTP exposing the flag |
| [Dancing](htb/starting-point/Dancing.md) | Windows | Tier 0 | SMB null session on a readable share |
| [Redeemer](htb/starting-point/Redeemer.md) | Linux | Tier 0 | Unauthenticated Redis, key dump |
| [Appointment](htb/starting-point/Appointment.md) | Linux | Tier 0 | SQL injection login bypass |
| [Sequel](htb/starting-point/Sequel.md) | Linux | Tier 1 | MariaDB root login with no password |
| [Crocodile](htb/starting-point/Crocodile.md) | Linux | Tier 1 | Anonymous FTP leaks credentials for a hidden admin panel |
| [Responder](htb/starting-point/Responder.md) | Windows | Tier 1 | LFI to forced SMB auth, NetNTLMv2 capture and crack, WinRM as Administrator |
| [Archetype](htb/starting-point/Archetype.md) | Windows | Tier 2 | SMB config leak, MSSQL xp_cmdshell, admin password in PowerShell history, psexec as SYSTEM |
| [Oopsie](htb/starting-point/Oopsie.md) *(in progress)* | Linux | Tier 2 | Recon and passive crawling with Burp Suite |
