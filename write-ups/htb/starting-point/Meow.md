# Meow

**Platform:** Hack The Box · **Type:** Starting Point · **OS:** Linux · **Difficulty:** Tier 0

**Summary:** Telnet was exposed on port 23 and let me log in as `root` with no password.

## 1. Reconnaissance

- **Command:** `nmap -sC -sV 10.129.3.234`
- **Open ports:**

| **Port** | **Service** | **Version**  | **State** |
| -------- | ----------- | ------------ | --------- |
| 23       | telnet      | Linuxtelnetd | Open      |

Only Telnet is listening. Trying common usernames, `root` has no password set.

## 2. Foothold

- **Vulnerability:** Telnet (cleartext protocol) with no authentication for the administrator account.
- Logging in over Telnet as `root` gives a shell straight away.

## 3. Privilege Escalation

Not needed: the session is already `root`.

- 🚩 **Root flag:** `b40abdfe23665f766f9c61ecba8a4c19`

## 4. Conclusion

**Chain:** exposed Telnet → passwordless `root` → full compromise.

**Remediation:**
1. Shut down Telnet entirely and use SSH instead.
2. Enforce strong password policies for every account.
3. Block direct root logins over SSH (`PermitRootLogin no`).
